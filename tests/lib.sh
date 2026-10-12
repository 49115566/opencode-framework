#!/usr/bin/env bash
#
# Shared harness for the framework's committed test suite.
#
# Sourced by tests/run.sh, never executed directly. Defines the counters, the
# ok/FAIL/skip reporters, the path constants, the file/naming extractors, and
# the optional-tool probes that every tests/checks/*.sh file relies on.
#
# Conventions mirror the historical read-only suites (work/**/verify-tests.sh):
# `ok`/`FAIL` line output, an optional repo-root argument, and a non-zero exit on
# failure. Unlike those suites, the optional-tool probes are overridable so a
# skip is deterministic under test.
#
# Bash 3.2 compatible: no associative arrays, no mapfile, no ${arr[@]} on an
# empty array under `set -u`.

# --- counters ---------------------------------------------------------------
pass=0
fail=0
skip=0

ok()   { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
skip() { skip=$((skip+1)); printf 'skip  %s\n' "$1"; }

# --- assertions -------------------------------------------------------------
has()   { grep -qF -- "$2" "$1"; }               # literal presence
hasE()  { grep -qE -- "$2" "$1"; }               # regex presence
need()  { if grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3 (missing '$2' in $1)"; fi; }
needE() { if grep -qE -- "$2" "$1"; then ok "$3"; else bad "$3 (no /$2/ in $1)"; fi; }

# --- extractors -------------------------------------------------------------
fm()   { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; } # frontmatter
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
agent_names() { ls "$AGENT_DIR"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
cmd_names()   { ls "$CMD_DIR"/*.md   2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
skill_names() { ls -d "$SKILL_DIR"/*/ 2>/dev/null | xargs -n1 basename | sort; }

# --- agreement-area selection -----------------------------------------------
# An agreement area is one tests/checks/*.sh file; its selector is the file's
# basename without the .sh suffix (for example 10-readiness, 85-conflict-guards).
# A selector resolves by exact area name first, then by a unique name prefix; a
# prefix matching two or more areas is ambiguous and one matching none is
# unknown. The selected areas are the only ones a run sources.
area_name_of() {  # $1 check-file path -> area name on stdout
  local base
  base="$(basename "$1")"
  printf '%s\n' "${base%.sh}"
}

# resolve_area_selector <selector> <newline-separated area names>
#   prints the resolved area name and returns 0;
#   returns 3 when unknown, 4 when ambiguous (printing the candidate names).
resolve_area_selector() {
  local sel="${1:-}" names="${2:-}" name n
  local -a cands
  cands=()
  [ -n "$sel" ] || return 3
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if [ "$name" = "$sel" ]; then
      printf '%s\n' "$name"
      return 0
    fi
  done <<NAMES
$names
NAMES
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    case "$name" in
      "$sel"*) cands[${#cands[@]}]="$name" ;;
    esac
  done <<NAMES
$names
NAMES
  n=${#cands[@]}
  if [ "$n" -eq 1 ]; then
    printf '%s\n' "${cands[0]}"
    return 0
  elif [ "$n" -gt 1 ]; then
    printf '%s\n' "${cands[@]}"
    return 4
  fi
  return 3
}

# --- live-surface path constants (relative to the resolved repo root) -------
AGENT_DIR=".opencode/agent"
CMD_DIR=".opencode/command"
SKILL_DIR=".opencode/skill"
CONV="docs/artifact-conventions.md"
WF="docs/workflow.md"
README="README.md"
AGENTS="AGENTS.md"
CFG="opencode.json"
CUST="docs/customization.md"

# --- optional-tool probes ---------------------------------------------------
# FRAMEWORK_TEST_NO_PY / _OPENCODE / _NPM = 1 force the tool to "absent" so a
# skip can be exercised deterministically. Each check that needs a missing
# optional tool must call `skip`, never `bad`.
#
# Detection is lazy: run.sh calls `probe_needed_by` on the selected checks so a
# run only probes the tools an executed area actually references. Each probe is
# idempotent, honors the force-absent overrides, and caches into have_*.
have_py=0
have_opencode=0
have_npm=0
have_net=0

probe_py() {
  if [ "${_probed_py:-0}" = "1" ]; then return 0; fi
  _probed_py=1
  have_py=0
  if [ "${FRAMEWORK_TEST_NO_PY:-0}" = "1" ]; then
    have_py=0
  elif command -v python3 >/dev/null 2>&1; then
    have_py=1
  fi
}

probe_opencode() {
  if [ "${_probed_opencode:-0}" = "1" ]; then return 0; fi
  _probed_opencode=1
  have_opencode=0
  if [ "${FRAMEWORK_TEST_NO_OPENCODE:-0}" = "1" ]; then
    have_opencode=0
  elif command -v opencode >/dev/null 2>&1; then
    have_opencode=1
  fi
}

probe_npm() {
  if [ "${_probed_npm:-0}" = "1" ]; then return 0; fi
  _probed_npm=1
  have_npm=0
  if [ "${FRAMEWORK_TEST_NO_NPM:-0}" = "1" ]; then
    have_npm=0
  elif command -v npm >/dev/null 2>&1; then
    have_npm=1
  fi
}

# Registry reachability, probed only when npm is present and only best-effort:
# a failure to reach the registry means "skip", never "fail".
probe_net() {
  if [ "${_probed_net:-0}" = "1" ]; then return 0; fi
  _probed_net=1
  have_net=0
  probe_npm
  if [ "$have_npm" -eq 1 ]; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 15 npm view @playwright/mcp version >/dev/null 2>&1 && have_net=1
    else
      npm view @playwright/mcp version >/dev/null 2>&1 && have_net=1
    fi
  fi
}

# probe_needed_by <check-file>... — call only the probes referenced by the named
# check files. The check source is the declaration of need: a check that reads
# have_npm (etc.) gets that probe called; over-probing is harmless and a missed
# reference can only turn a would-be probe into a skip.
probe_needed_by() {
  if [ "$#" -eq 0 ]; then return 0; fi
  local f
  for f in "$@"; do
    [ -f "$f" ] || continue
    grep -q 'have_py'       "$f" && probe_py
    grep -q 'have_opencode' "$f" && probe_opencode
    grep -q 'have_npm'      "$f" && probe_npm
    grep -q 'have_net'      "$f" && probe_net
  done
  return 0
}
