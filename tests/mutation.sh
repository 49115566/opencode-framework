#!/usr/bin/env bash
#
# tests/mutation.sh — opt-in mutation self-check for the committed suite.
#
# This is maintainer tooling: it is NOT sourced by tests/run.sh and NOT run by
# CI. It exists to prove the suite is mutation-sensitive (AC15) and that it runs
# against a fresh-clone tree with no work/ (AC2) and with every optional tool
# absent (AC14).
#
# It stages a copy of the live surfaces under the git-ignored scratch/ WITHOUT
# any work/ artifact, then:
#   1. runs `bash tests/run.sh <copy>` and asserts exit 0 (AC2);
#   2. runs it with FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM=1 and asserts exit 0 with
#      visible skips (AC14);
#   3. for each agreement area AC6-AC13 and AC18-AC21, applies exactly one
#      mutation, asserts the suite exits non-zero and names that area, restores
#      the file, and asserts the clean copy passes again (AC15);
#   4. exits non-zero if any mutation is not caught or any clean run fails, and
#      cleans up its scratch/ subtree on exit.
#
# Usage: bash tests/mutation.sh
# Exit:  0 = every clean run passed and every mutation was caught and named
#        1 = a mutation escaped, or a clean run failed
#        2 = setup error (not a git repo / cannot stage)
#
# The real repository is never mutated: only files inside the scratch copy are
# changed, and scratch/ is removed when the script exits. The historical
# work/** suites and artifacts are never read or touched.

set -u

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || {
  echo "setup error: cannot locate the tests directory" >&2
  exit 2
}
REPO_ROOT="$(git -C "$TESTS_DIR" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "setup error: not a git repository" >&2
  exit 2
}
cd "$REPO_ROOT" || { echo "setup error: cannot cd to $REPO_ROOT" >&2; exit 2; }
REPO_ROOT="$(pwd)"

SCRATCH="$REPO_ROOT/scratch/framework-mutation"
COPY="$SCRATCH/live"
LOG="$SCRATCH/last-run.log"

mpass=0
mfail=0
mok()  { mpass=$((mpass+1)); printf 'ok    %s\n' "$1"; }
mbad() { mfail=$((mfail+1)); printf 'FAIL  %s\n' "$1"; }

cleanup() { rm -rf "$SCRATCH"; }
on_exit() { rc=$?; cleanup; exit "$rc"; }
trap on_exit EXIT

# ---------------------------------------------------------------------------
# Stage a copy of the live surfaces, deliberately without work/.
# ---------------------------------------------------------------------------
stage() {
  rm -rf "$SCRATCH"
  mkdir -p "$COPY/docs" "$COPY/.opencode" "$COPY/tests/fixtures"
  cp "$REPO_ROOT/opencode.json" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/README.md" "$COPY/"
  cp "$REPO_ROOT/LICENSE" "$REPO_ROOT/CONTRIBUTING.md" "$REPO_ROOT/CHANGELOG.md" \
     "$REPO_ROOT/VERSION" "$COPY/"
  cp "$REPO_ROOT"/docs/*.md "$COPY/docs/"
  cp -R "$REPO_ROOT/template" "$COPY/template"
  cp "$REPO_ROOT/tests/README.md" "$COPY/tests/README.md"
  cp -R "$REPO_ROOT/.opencode/agent"   "$COPY/.opencode/agent"
  cp -R "$REPO_ROOT/.opencode/command" "$COPY/.opencode/command"
  cp -R "$REPO_ROOT/.opencode/skill"   "$COPY/.opencode/skill"
  cp -R "$REPO_ROOT/tests/fixtures/cyclic-roadmap" "$COPY/tests/fixtures/cyclic-roadmap"
}

# ---------------------------------------------------------------------------
# Runner helpers. run_absent forces every optional tool absent so the mutation
# checks are deterministic and do not depend on network or the opencode CLI.
# ---------------------------------------------------------------------------
run_plain()  { bash "$TESTS_DIR/run.sh" "$COPY" >"$LOG" 2>&1; }
run_absent() {
  FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 \
    bash "$TESTS_DIR/run.sh" "$COPY" >"$LOG" 2>&1
}

assert_clean_plain() {  # $1 label
  run_plain; rc=$?
  if [ "$rc" -eq 0 ]; then mok "clean copy (no work/) passes ($1)"; else
    mbad "clean copy (no work/) failed ($1, exit $rc)"; fi
}
assert_clean_absent() {  # $1 label
  run_absent; rc=$?
  if [ "$rc" -eq 0 ]; then mok "clean copy passes with optional tools absent ($1)"; else
    mbad "clean copy failed with optional tools absent ($1, exit $rc)"; fi
}

check_mutation() {  # $1 area, $2 expected output substring, $3 description
  run_absent; rc=$?
  if [ "$rc" -eq 0 ]; then
    mbad "mutation $1 not caught ($3): suite exited 0"
    return 0
  fi
  if grep -qF -- "$2" "$LOG"; then
    mok "mutation $1 caught and named ($3)"
  else
    mbad "mutation $1 surfaced but did not name '$2' ($3)"
  fi
}

# ---------------------------------------------------------------------------
# Copy mutators (operate only on the scratch copy).
# ---------------------------------------------------------------------------
restore_file() {  # $1 path relative to the repo root
  mkdir -p "$COPY/$(dirname "$1")"
  cp "$REPO_ROOT/$1" "$COPY/$1"
}

append_line() { printf '%s\n' "$2" >> "$1"; }

replace_first() {  # $1 file, $2 old literal, $3 new literal
  awk -v old="$2" -v new="$3" '
    !done {
      i = index($0, old)
      if (i > 0) { print substr($0, 1, i - 1) new substr($0, i + length(old)); done = 1; next }
    }
    { print }
  ' "$1" > "$1.mut" && mv "$1.mut" "$1"
}

delete_first_line() {  # $1 file, $2 literal
  awk -v pat="$2" '
    !done && index($0, pat) > 0 { done = 1; next }
    { print }
  ' "$1" > "$1.mut" && mv "$1.mut" "$1"
}

set_readme_agent_cell() {  # $1 file, $2 agent, $3 field (3=mode,5=bash), $4 value
  awk -v name="$2" -v col="$3" -v val="$4" '
    BEGIN { FS = "|"; OFS = "|" }
    /^\|/ {
      c2 = $2; gsub(/`/, "", c2); gsub(/^[ \t]+|[ \t]+$/, "", c2)
      if (c2 == name && !done) { $col = " " val " "; done = 1 }
    }
    { print }
  ' "$1" > "$1.mut" && mv "$1.mut" "$1"
}

cfg_default_agent() {  # $1 file
  awk '
    match($0, /"default_agent"[[:space:]]*:[[:space:]]*"[^"]*"/) {
      s = substr($0, RSTART, RLENGTH)
      sub(/.*"[[:space:]]*:[[:space:]]*"/, "", s)
      sub(/"$/, "", s)
      print s; exit
    }
  ' "$1"
}

# ---------------------------------------------------------------------------
stage

echo "== environment: fresh-clone independence and optional-tool skips =="
assert_clean_plain "AC2"
assert_clean_absent "AC14"
if grep -q '^skip  ' "$LOG"; then
  mok "forced-absent run reports visible skips (AC14)"
else
  mbad "forced-absent run printed no skip line (AC14)"
fi

# ---------------------------------------------------------------------------
echo "== mutation: AC6 readiness =="
append_line "$COPY/README.md" 'approved-but-unshipped is not satisfied'
check_mutation AC6 'AC6 README.md contradicts' "contradicting readiness sentence"
restore_file README.md
assert_clean_absent "after AC6 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC7 lifecycle routing =="
replace_first "$COPY/.opencode/skill/workflow-lifecycle/SKILL.md" 'No spec.md?' 'No spec?'
check_mutation AC7 'AC7 skill routes no spec' "deleted a routing condition from the skill"
restore_file .opencode/skill/workflow-lifecycle/SKILL.md
assert_clean_absent "after AC7 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC8 permission cell =="
set_readme_agent_cell "$COPY/README.md" "scribe" 5 "allow"
check_mutation AC8 'AC8 scribe disagrees' "flipped a README permission cell"
restore_file README.md
assert_clean_absent "after AC8 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC9 inventory count =="
orig_count="$(awk '
  $0 ~ "# [0-9]+ role prompts" {
    if (match($0, /# [0-9]+/)) { print substr($0, RSTART + 2, RLENGTH - 2); exit }
  }
' "$COPY/README.md")"
new_count=$((orig_count + 1))
replace_first "$COPY/README.md" "# $orig_count role prompts" "# $new_count role prompts"
check_mutation AC9 "AC9 README Layout count for 'role prompts'" "changed an inventory count"
restore_file README.md
assert_clean_absent "after AC9 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC10 instruction path =="
delete_first_line "$COPY/docs/customization.md" '`docs/artifact-conventions.md`'
check_mutation AC10 'AC10 docs/customization.md is missing' "dropped an always-loaded instruction path"
restore_file docs/customization.md
assert_clean_absent "after AC10 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC11 default agent =="
default_agent="$(cfg_default_agent "$COPY/opencode.json")"
other_agent=""
for a in $(ls "$COPY/.opencode/agent"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort); do
  [ "$a" = "$default_agent" ] && continue
  other_agent="$a"; break
done
other_mode="$(awk '
  NR == 1 && $0 == "---" { f = 1; next }
  f && $0 == "---" { exit }
  f && /^mode:/ { sub(/^mode:[ \t]*/, ""); print; exit }
' "$COPY/.opencode/agent/$other_agent.md")"
[ -n "$other_mode" ] || other_mode=primary
set_readme_agent_cell "$COPY/README.md" "$default_agent" 3 "primary"
set_readme_agent_cell "$COPY/README.md" "$other_agent" 3 "$other_mode (default)"
check_mutation AC11 'AC11 README.md marks' "moved the README default-agent marker"
restore_file README.md
assert_clean_absent "after AC11 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC12 external pin =="
pin="$(grep -oE '@playwright/mcp@[0-9]+\.[0-9]+\.[0-9]+' "$COPY/opencode.json" | head -n1 | sed 's|^@playwright/mcp@||')"
if [ -n "$pin" ]; then
  newpin="$(printf '%s' "$pin" | awk -F. '{ printf "%d.%s.%s\n", $1 + 1, $2, $3 }')"
  replace_first "$COPY/docs/customization.md" "@playwright/mcp@$pin" "@playwright/mcp@$newpin"
  check_mutation AC12 'AC12 surfaces disagree' "diverged the customization pin"
  restore_file docs/customization.md
  assert_clean_absent "after AC12 restore"
else
  mbad "mutation AC12 not applied: opencode.json names no exact pin"
fi

# ---------------------------------------------------------------------------
echo "== mutation: AC13 cycle fixture =="
rm -f "$COPY/tests/fixtures/cyclic-roadmap/roadmap.md"
check_mutation AC13 'AC13 committed cycle fixture missing' "removed the committed cycle fixture"
restore_file tests/fixtures/cyclic-roadmap/roadmap.md
assert_clean_absent "after AC13 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC18 manifest <-> changelog agreement =="
orig_ver="$(tr -d '\r\n' < "$COPY/VERSION")"
mut_ver="$(printf '%s' "$orig_ver" | awk -F. '{ printf "%d.%s.%s\n", $1 + 1, $2, $3 }')"
replace_first "$COPY/VERSION" "$orig_ver" "$mut_ver"
check_mutation AC18 \
  "AC18 VERSION ($mut_ver) and CHANGELOG.md newest released version ($orig_ver) disagree" \
  "diverged the version manifest from the changelog"
restore_file VERSION
assert_clean_absent "after AC18 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC19 copy-set surface agreement =="
replace_first "$COPY/tests/README.md" '`docs/*.md`)' '`docs/*.md`, `LICENSE`)'
check_mutation AC19 'AC19 tests/README.md copy-set sentence wrongly lists packaging file(s): LICENSE' \
  "added a packaging file to a copy-set enumeration"
restore_file tests/README.md
assert_clean_absent "after AC19 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC20 README Layout agreement =="
delete_first_line "$COPY/README.md" 'version source of truth'
check_mutation AC20 'AC20 README Layout does not document packaging file VERSION' \
  "dropped a packaging file from the README Layout block"
restore_file README.md
assert_clean_absent "after AC20 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC21 adoption split guard =="
replace_first "$COPY/README.md" 'template/AGENTS.md' 'AGENTS.md'
check_mutation AC21 \
  'AC21 README.md quickstart does not source AGENTS.md from template/AGENTS.md' \
  "repointed the quickstart at the root copy"
restore_file README.md
assert_clean_absent "after AC21 restore"

# ---------------------------------------------------------------------------
echo "== mutation: AC22 command signature agreement =="
replace_first "$COPY/README.md" '`/build [item-ref or task-id]`' '`/build [task]`'
check_mutation AC22 \
  'AC22 README.md states a divergent signature for /build' \
  "diverged the README Commands /build cell"
restore_file README.md
assert_clean_absent "after AC22 restore"

# ---------------------------------------------------------------------------
printf '\nMUTATION TOTAL: %s checked passed, %s failed\n' "$mpass" "$mfail"
[ "$mfail" -eq 0 ]
