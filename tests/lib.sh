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
have_py=0
if [ "${FRAMEWORK_TEST_NO_PY:-0}" = "1" ]; then
  have_py=0
elif command -v python3 >/dev/null 2>&1; then
  have_py=1
fi

have_opencode=0
if [ "${FRAMEWORK_TEST_NO_OPENCODE:-0}" = "1" ]; then
  have_opencode=0
elif command -v opencode >/dev/null 2>&1; then
  have_opencode=1
fi

have_npm=0
if [ "${FRAMEWORK_TEST_NO_NPM:-0}" = "1" ]; then
  have_npm=0
elif command -v npm >/dev/null 2>&1; then
  have_npm=1
fi

# Registry reachability, probed only when npm is present and only best-effort:
# a failure to reach the registry means "skip", never "fail".
have_net=0
if [ "$have_npm" -eq 1 ]; then
  if command -v timeout >/dev/null 2>&1; then
    timeout 15 npm view @playwright/mcp version >/dev/null 2>&1 && have_net=1
  else
    npm view @playwright/mcp version >/dev/null 2>&1 && have_net=1
  fi
fi
