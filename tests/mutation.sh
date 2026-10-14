#!/usr/bin/env bash
#
# tests/mutation.sh — opt-in, area-scoped mutation self-check for the suite.
#
# Maintainer tooling: NOT sourced by tests/run.sh and NOT run by CI. It proves
# the committed agreement suite is mutation-sensitive while running each mutation
# against only the single agreement area that must detect and name it.
#
# It stages a copy of the live surfaces under the git-ignored scratch/ WITHOUT
# any work/ artifact, then:
#   1. runs `bash tests/run.sh <copy>` and asserts exit 0;
#   2. runs it with FRAMEWORK_TEST_NO_PY/_OPENCODE/_NPM=1 and asserts exit 0 with
#      visible skips;
#   3. for each mutation job, applies exactly one mutation to the copy, runs ONLY
#      the one agreement area that must catch it (via FRAMEWORK_TEST_AREAS),
#      asserts the suite exits non-zero and names the expected token, then
#      restores the mutated surface from the repository and verifies the restore
#      byte-for-byte with `cmp -s` (falling back to `git diff --no-index`);
#   4. exits non-zero if any mutation is not caught, any restore fails, or any
#      clean whole-suite run fails, and cleans up its scratch/ subtree on exit.
#
# The two whole-suite runs in step 1-2 are the pass's only whole-suite
# executions: their number is a small constant independent of the mutation count.
#
# Jobs are dealt round-robin to FRAMEWORK_MUTATION_JOBS worker subshells (else a
# best-effort CPU count, else one). Each worker stages its own copy under
# scratch/.../w<N>/live, so concurrent jobs never observe one another's mutation;
# results are printed in job order and aggregate exactly as a serial run.
#
# The scratch root is unique per invocation (derived from the process id), so two
# concurrent passes never share a copy, log, result, or cleanup target and cannot
# interfere with one another.
#
# Usage: bash tests/mutation.sh [--selftest]
#   --selftest runs the runner's own self-test only (the corrupted-restore path
#   plus the run.sh selector error cases and one successful subset) and does not
#   run the mutation pass.
# Exit:  0 = every clean whole-suite run passed and every mutation was caught,
#            named, and restored (or every self-test assertion held)
#        1 = a mutation escaped, a restore was not byte-for-byte, a
#            whole-suite clean run failed, or a self-test assertion failed
#        2 = setup error (not a git repo / cannot stage / unknown argument)
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

# The scratch root is per-invocation (pid-suffixed) so concurrent passes are
# isolated: two runs never share COPY, RESULT_DIR, a log, or the exit-trap
# removal. The bare `scratch/framework-mutation` path is therefore never created
# or removed, so a concurrent pass is never disturbed by another's cleanup.
SCRATCH="$REPO_ROOT/scratch/framework-mutation.$$"
COPY="$SCRATCH/live"
SETUP_PLAIN_LOG="$SCRATCH/setup-plain.log"
SETUP_ABSENT_LOG="$SCRATCH/setup-absent.log"
WHOLE_LOG="$SCRATCH/whole-suite.log"
RESULT_DIR="$SCRATCH/results"

# The job inventory (job_1..job_<JOB_COUNT>). Kept as a count so worker
# assignment and result aggregation iterate the same range.
JOB_COUNT=30

# Mutation counters (the MUTATION TOTAL line) and a separate setup-failure tally:
# the two whole-suite setup runs are not mutations, so they do not inflate the
# mutation count, but a failed setup still fails the pass.
mpass=0
mfail=0
setup_fail=0

# A job's result goes to its own $J_RESULT file (one per job) so parallel worker
# subshells cannot race on shared counters; the main process prints those files
# in job order after `wait` and aggregates them there. Outside a job (the
# self-test and any direct call) J_RESULT is unset and the line is printed and
# counted in place.
mok()  {
  if [ -n "${J_RESULT:-}" ]; then printf 'ok    %s\n' "$1" >> "$J_RESULT"
  else mpass=$((mpass+1)); printf 'ok    %s\n' "$1"; fi
}
mbad() {
  if [ -n "${J_RESULT:-}" ]; then printf 'FAIL  %s\n' "$1" >> "$J_RESULT"
  else mfail=$((mfail+1)); printf 'FAIL  %s\n' "$1"; fi
}
sok()  { printf 'ok    %s\n' "$1"; }
sbad() { setup_fail=$((setup_fail+1)); printf 'FAIL  %s\n' "$1"; }

cleanup() { rm -rf "$SCRATCH"; }
on_exit() { rc=$?; cleanup; exit "$rc"; }
trap on_exit EXIT

# ---------------------------------------------------------------------------
# Stage a copy of the live surfaces, deliberately without work/.
# ---------------------------------------------------------------------------
stage_copy() {  # $1 = destination copy root
  local copy="$1"
  rm -rf "$copy"
  mkdir -p "$copy/docs" "$copy/.opencode" "$copy/tests/fixtures"
  cp "$REPO_ROOT/opencode.json" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/README.md" "$copy/"
  cp "$REPO_ROOT/LICENSE" "$REPO_ROOT/CONTRIBUTING.md" "$REPO_ROOT/CHANGELOG.md" \
     "$REPO_ROOT/VERSION" "$copy/"
  cp "$REPO_ROOT"/docs/*.md "$copy/docs/"
  cp -R "$REPO_ROOT/template" "$copy/template"
  cp "$REPO_ROOT/tests/README.md" "$copy/tests/README.md"
  cp -R "$REPO_ROOT/.opencode/agent"   "$copy/.opencode/agent"
  cp -R "$REPO_ROOT/.opencode/command" "$copy/.opencode/command"
  cp -R "$REPO_ROOT/.opencode/skill"   "$copy/.opencode/skill"
  cp -R "$REPO_ROOT/tests/fixtures/cyclic-roadmap" "$copy/tests/fixtures/cyclic-roadmap"
  cp -R "$REPO_ROOT/tests/fixtures/declared-conflicts" "$copy/tests/fixtures/declared-conflicts"
  cp -R "$REPO_ROOT/tests/fixtures/backtracking" "$copy/tests/fixtures/backtracking"
  cp -R "$REPO_ROOT/tests/fixtures/recursive-integrity" "$copy/tests/fixtures/recursive-integrity"
}

# ---------------------------------------------------------------------------
# Whole-suite setup runs. FRAMEWORK_TEST_AREAS is explicitly unset in a subshell
# so an ambient value cannot turn a setup run into a subset.
# ---------------------------------------------------------------------------
run_whole_plain() {
  ( unset FRAMEWORK_TEST_AREAS
    bash "$TESTS_DIR/run.sh" "$COPY" ) >"$SETUP_PLAIN_LOG" 2>&1
}

run_whole_absent() {
  ( unset FRAMEWORK_TEST_AREAS
    FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 \
      bash "$TESTS_DIR/run.sh" "$COPY" ) >"$SETUP_ABSENT_LOG" 2>&1
}

# ---------------------------------------------------------------------------
# Area-scoped job runner. A job runs only the single area that must catch it.
# ---------------------------------------------------------------------------
run_area() {  # $1 copy, $2 area, $3 log
  FRAMEWORK_TEST_AREAS="$2" \
    FRAMEWORK_TEST_NO_PY=1 FRAMEWORK_TEST_NO_OPENCODE=1 FRAMEWORK_TEST_NO_NPM=1 \
    bash "$TESTS_DIR/run.sh" "$1" >"$3" 2>&1
}

same_file() {  # $1 $2 -> 0 when byte-identical; cmp first, git fallback
  if command -v cmp >/dev/null 2>&1; then
    cmp -s "$1" "$2"
  else
    git diff --no-index --quiet -- "$1" "$2"
  fi
}

# restore_one <src> <dst> <label>: copy <src> over <dst>, then verify the result
# is byte-identical to <src>. A mismatch is a reported failure naming <label>
# (the surface). This is the single restore-verification path; --selftest
# exercises it directly without touching the repository.
restore_one() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst" 2>/dev/null
  if same_file "$src" "$dst"; then
    return 0
  fi
  mbad "restore failed: $label was not restored byte-for-byte"
  return 1
}

# Restore each named (repo-relative) file from the repository into the copy and
# verify it byte-for-byte. The first unrestored surface is reported.
restore_verify() {  # $1 copy, rest: repo-relative paths
  local copy="$1"; shift
  local f
  for f in "$@"; do
    restore_one "$REPO_ROOT/$f" "$copy/$f" "$f" || return 1
  done
  return 0
}

# Worker count: FRAMEWORK_MUTATION_JOBS when it is a positive integer, else a
# best-effort CPU count (getconf _NPROCESSORS_ONLN, then nproc), else 1. Capped
# at the job count so every worker gets at least one job and no round-robin
# assignment is empty.
resolve_workers() {
  local n=""
  if [ -n "${FRAMEWORK_MUTATION_JOBS:-}" ]; then
    case "$FRAMEWORK_MUTATION_JOBS" in
      *[!0-9]*) : ;;
      *) [ "$FRAMEWORK_MUTATION_JOBS" -gt 0 ] && n="$FRAMEWORK_MUTATION_JOBS" ;;
    esac
  fi
  if [ -z "$n" ]; then
    n="$(getconf _NPROCESSORS_ONLN 2>/dev/null)" || n=""
    case "$n" in *[!0-9]*|"") n="" ;; esac
  fi
  if [ -z "$n" ]; then
    n="$(nproc 2>/dev/null)" || n=""
    case "$n" in *[!0-9]*|"") n="" ;; esac
  fi
  if [ -z "$n" ] || [ "$n" -le 0 ] 2>/dev/null; then
    n=1
  fi
  if [ "$n" -gt "$JOB_COUNT" ]; then
    n="$JOB_COUNT"
  fi
  printf '%s\n' "$n"
}

# A job header sets J_AREA/J_EXPECTED/J_DESC, applies its mutation to the copy,
# then calls job_finish with the surfaces to restore.
J_AREA=""
J_EXPECTED=""
J_DESC=""
J_LOG=""
J_RESULT=""

job_finish() {  # $1 copy, rest: repo-relative paths to restore (may be empty)
  local copy="$1"; shift
  run_area "$copy" "$J_AREA" "$J_LOG"
  local rc=$?
  if [ "$rc" -eq 0 ]; then
    mbad "mutation $J_AREA not caught ($J_DESC): suite exited 0"
  elif grep -qF -- "$J_EXPECTED" "$J_LOG"; then
    mok "mutation $J_AREA caught and named ($J_DESC)"
  else
    mbad "mutation $J_AREA surfaced but did not name '$J_EXPECTED' ($J_DESC)"
  fi
  if [ "$#" -gt 0 ]; then
    restore_verify "$copy" "$@"
  fi
}

# ---------------------------------------------------------------------------
# Copy mutators (operate only on the scratch copy).
# ---------------------------------------------------------------------------
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
# Mutation jobs. Each targets exactly one agreement area (the one that prints the
# expected token) and restores exactly the surface it mutated.
# ---------------------------------------------------------------------------

# AC6 readiness sentence -> 10-readiness
job_1() {
  local copy="$1"
  J_AREA=10-readiness
  J_EXPECTED='AC6 README.md contradicts'
  J_DESC="contradicting readiness sentence"
  append_line "$copy/README.md" 'approved-but-unshipped is not satisfied'
  job_finish "$copy" README.md
}

# AC7 lifecycle route -> 20-lifecycle
job_2() {
  local copy="$1"
  J_AREA=20-lifecycle
  J_EXPECTED='AC7 skill routes no spec'
  J_DESC="deleted a routing condition from the skill"
  replace_first "$copy/.opencode/skill/workflow-lifecycle/SKILL.md" 'No spec.md?' 'No spec?'
  job_finish "$copy" .opencode/skill/workflow-lifecycle/SKILL.md
}

# AC8 permission cell -> 30-permissions
job_3() {
  local copy="$1"
  J_AREA=30-permissions
  J_EXPECTED='AC8 scribe disagrees'
  J_DESC="flipped a README permission cell"
  set_readme_agent_cell "$copy/README.md" "scribe" 5 "allow"
  job_finish "$copy" README.md
}

# AC9 inventory count -> 40-inventory
job_4() {
  local copy="$1"
  J_AREA=40-inventory
  J_EXPECTED="AC9 README Layout count for 'role prompts'"
  J_DESC="changed an inventory count"
  local orig_count new_count
  orig_count="$(awk '
    $0 ~ "# [0-9]+ role prompts" {
      if (match($0, /# [0-9]+/)) { print substr($0, RSTART + 2, RLENGTH - 2); exit }
    }
  ' "$copy/README.md")"
  new_count=$((orig_count + 1))
  replace_first "$copy/README.md" "# $orig_count role prompts" "# $new_count role prompts"
  job_finish "$copy" README.md
}

# AC10 instruction path -> 50-instructions
job_5() {
  local copy="$1"
  J_AREA=50-instructions
  J_EXPECTED='AC10 docs/customization.md is missing'
  J_DESC="dropped an always-loaded instruction path"
  delete_first_line "$copy/docs/customization.md" '`docs/artifact-conventions.md`'
  job_finish "$copy" docs/customization.md
}

# AC11 default agent -> 60-default-agent
job_6() {
  local copy="$1"
  J_AREA=60-default-agent
  J_EXPECTED='AC11 README.md marks'
  J_DESC="moved the README default-agent marker"
  local default_agent other_agent other_mode a
  default_agent="$(cfg_default_agent "$copy/opencode.json")"
  other_agent=""
  for a in $(ls "$copy/.opencode/agent"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort); do
    [ "$a" = "$default_agent" ] && continue
    other_agent="$a"; break
  done
  other_mode="$(awk '
    NR == 1 && $0 == "---" { f = 1; next }
    f && $0 == "---" { exit }
    f && /^mode:/ { sub(/^mode:[ \t]*/, ""); print; exit }
  ' "$copy/.opencode/agent/$other_agent.md")"
  [ -n "$other_mode" ] || other_mode=primary
  set_readme_agent_cell "$copy/README.md" "$default_agent" 3 "primary"
  set_readme_agent_cell "$copy/README.md" "$other_agent" 3 "$other_mode (default)"
  job_finish "$copy" README.md
}

# AC12 external pin -> 70-pin
job_7() {
  local copy="$1"
  J_AREA=70-pin
  J_EXPECTED='AC12 surfaces disagree'
  J_DESC="diverged the customization pin"
  local pin newpin
  pin="$(grep -oE '@playwright/mcp@[0-9]+\.[0-9]+\.[0-9]+' "$copy/opencode.json" | head -n1 | sed 's|^@playwright/mcp@||')"
  if [ -n "$pin" ]; then
    newpin="$(printf '%s' "$pin" | awk -F. '{ printf "%d.%s.%s\n", $1 + 1, $2, $3 }')"
    replace_first "$copy/docs/customization.md" "@playwright/mcp@$pin" "@playwright/mcp@$newpin"
    job_finish "$copy" docs/customization.md
  else
    mbad "mutation AC12 not applied: opencode.json names no exact pin"
  fi
}

# AC13 cycle fixture -> 80-cycle-fixture
job_8() {
  local copy="$1"
  J_AREA=80-cycle-fixture
  J_EXPECTED='AC13 committed cycle fixture missing'
  J_DESC="removed the committed cycle fixture"
  rm -f "$copy/tests/fixtures/cyclic-roadmap/roadmap.md"
  job_finish "$copy" tests/fixtures/cyclic-roadmap/roadmap.md
}

# AC18 manifest <-> changelog agreement -> 90-packaging
job_9() {
  local copy="$1"
  J_AREA=90-packaging
  J_DESC="diverged the version manifest from the changelog"
  local orig_ver mut_ver
  orig_ver="$(tr -d '\r\n' < "$copy/VERSION")"
  mut_ver="$(printf '%s' "$orig_ver" | awk -F. '{ printf "%d.%s.%s\n", $1 + 1, $2, $3 }')"
  replace_first "$copy/VERSION" "$orig_ver" "$mut_ver"
  J_EXPECTED="AC18 VERSION ($mut_ver) and CHANGELOG.md newest released version ($orig_ver) disagree"
  job_finish "$copy" VERSION
}

# AC19 copy-set surface agreement -> 90-packaging
job_10() {
  local copy="$1"
  J_AREA=90-packaging
  J_EXPECTED='AC19 tests/README.md copy-set sentence wrongly lists packaging file(s): LICENSE'
  J_DESC="added a packaging file to a copy-set enumeration"
  replace_first "$copy/tests/README.md" '`docs/*.md`)' '`docs/*.md`, `LICENSE`)'
  job_finish "$copy" tests/README.md
}

# AC20 README Layout agreement -> 90-packaging
job_11() {
  local copy="$1"
  J_AREA=90-packaging
  J_EXPECTED='AC20 README Layout does not document packaging file VERSION'
  J_DESC="dropped a packaging file from the README Layout block"
  delete_first_line "$copy/README.md" 'version source of truth'
  job_finish "$copy" README.md
}

# AC21 adoption split guard -> 95-split-guard
job_12() {
  local copy="$1"
  J_AREA=95-split-guard
  J_EXPECTED='AC21 README.md quickstart does not source AGENTS.md from template/AGENTS.md'
  J_DESC="repointed the quickstart at the root copy"
  replace_first "$copy/README.md" 'template/AGENTS.md' 'AGENTS.md'
  job_finish "$copy" README.md
}

# AC21 shared-body parity -> 95-split-guard
job_13() {
  local copy="$1"
  J_AREA=95-split-guard
  J_EXPECTED='AC21 AGENTS.md and template/AGENTS.md diverge outside the Project profile'
  J_DESC="dropped a shared Working-agreements bullet from the template copy"
  delete_first_line "$copy/template/AGENTS.md" '**Backtracking.**'
  job_finish "$copy" template/AGENTS.md
}

# AC22 command signature agreement -> 96-signature-sweep
job_14() {
  local copy="$1"
  J_AREA=96-signature-sweep
  J_EXPECTED='AC22 README.md states a divergent signature for /build'
  J_DESC="diverged the README Commands /build cell"
  replace_first "$copy/README.md" '`/build [item-ref or task-id]`' '`/build [task]`'
  job_finish "$copy" README.md
}

# AC23 conflict guards: column layout -> 85-conflict-guards
job_15() {
  local copy="$1"
  J_AREA=85-conflict-guards
  J_EXPECTED='FAIL  AC23 column-layout'
  J_DESC="renamed the conflicts-with fixture column"
  replace_first "$copy/tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md" \
    'conflicts-with' 'conflicts'
  job_finish "$copy" tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md
}

# AC23 conflict guards: positional parse -> 85-conflict-guards
job_16() {
  local copy="$1"
  J_AREA=85-conflict-guards
  J_EXPECTED='FAIL  AC23 positional-parse'
  J_DESC="reordered the fixture Children header"
  replace_first "$copy/tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md" \
    '| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |' \
    '| Local id | Title | Scope | conflicts-with | Depends on | Canonical reference |'
  job_finish "$copy" tests/fixtures/declared-conflicts/items/9001-roadmap-a/manifest.md
}

# AC23 conflict guards: cell resolution -> 85-conflict-guards
job_17() {
  local copy="$1"
  J_AREA=85-conflict-guards
  J_EXPECTED='FAIL  AC23 cell-resolution'
  J_DESC="broke a fixture target's resolution"
  replace_first "$copy/tests/fixtures/declared-conflicts/items/9010-surface-shared/design.md" \
    'docs/artifact-conventions.md' 'docs/does-not-exist.md'
  job_finish "$copy" tests/fixtures/declared-conflicts/items/9010-surface-shared/design.md
}

# AC23 conflict guards: pair predicate -> 85-conflict-guards
job_18() {
  local copy="$1"
  J_AREA=85-conflict-guards
  J_EXPECTED='FAIL  AC23 pair-predicate'
  J_DESC="broke the fixture's declared-conflict pair predicate"
  replace_first "$copy/tests/fixtures/declared-conflicts/items/9010-surface-shared/design.md" \
    'docs/artifact-conventions.md' 'README.md'
  job_finish "$copy" tests/fixtures/declared-conflicts/items/9010-surface-shared/design.md
}

# AC23 conflict guards: reporting vocabulary -> 85-conflict-guards
job_19() {
  local copy="$1"
  J_AREA=85-conflict-guards
  J_EXPECTED='FAIL  AC23 reporting-vocabulary'
  J_DESC="dropped the class from the finding grammar"
  replace_first "$copy/.opencode/skill/merge-conflict/SKILL.md" \
    '- [<CODE>] (<class>)' '- [<CODE>] <class>'
  job_finish "$copy" .opencode/skill/merge-conflict/SKILL.md
}

# AC24 backtrack guards: reverse-edge -> 87-backtrack-guards
job_20() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 reverse-edge'
  J_DESC="dropped a finding's target phase"
  delete_first_line "$copy/tests/fixtures/backtracking/items/9101-build-design/backtracks.md" \
    '- target phase:'
  job_finish "$copy" tests/fixtures/backtracking/items/9101-build-design/backtracks.md
}

# AC24 backtrack guards: record-status -> 87-backtrack-guards
job_21() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 record-status'
  J_DESC="unmatched a resolution header from its finding"
  replace_first "$copy/tests/fixtures/backtracking/items/9107-resolved/backtracks.md" \
    '## Resolution 1' '## Resolution 9'
  job_finish "$copy" tests/fixtures/backtracking/items/9107-resolved/backtracks.md
}

# AC24 backtrack guards: stale-downstream -> 87-backtrack-guards
job_22() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 stale-downstream'
  J_DESC="changed an edge's downstream stale token"
  replace_first "$copy/tests/fixtures/backtracking/items/9101-build-design/verify.md" \
    'stale: design' 'stale: spec'
  job_finish "$copy" tests/fixtures/backtracking/items/9101-build-design/verify.md
}

# AC24 backtrack guards: challenge-loop -> 87-backtrack-guards
job_23() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 challenge-loop'
  J_DESC="renamed the fixture's Reversal entry kind"
  replace_first "$copy/tests/fixtures/backtracking/items/9110-challenge-mixed/challenges.md" \
    '## Reversal 3' '## Ack 3'
  job_finish "$copy" tests/fixtures/backtracking/items/9110-challenge-mixed/challenges.md
}

# AC24 backtrack guards: roadmap-revision -> 87-backtrack-guards
job_24() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 roadmap-revision'
  J_DESC="reordered the fixture Children header"
  replace_first "$copy/tests/fixtures/backtracking/items/9120-revised-roadmap/manifest.md" \
    '| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |' \
    '| Local id | Title | Scope | conflicts-with | Depends on | Canonical reference |'
  job_finish "$copy" tests/fixtures/backtracking/items/9120-revised-roadmap/manifest.md
}

# AC24 backtrack guards: readiness-revocation -> 87-backtrack-guards
job_25() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 readiness-revocation'
  J_DESC="un-revoked a recalled ship record"
  delete_first_line "$copy/tests/fixtures/backtracking/items/9121-readiness/0001-recalled/ship.md" \
    'reopened: build'
  job_finish "$copy" tests/fixtures/backtracking/items/9121-readiness/0001-recalled/ship.md
}

# AC24 backtrack guards: derived-state -> 87-backtrack-guards
job_26() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 derived-state'
  J_DESC="changed a reopened marker's named phase"
  replace_first "$copy/tests/fixtures/backtracking/items/9113-reopened/ship.md" \
    'reopened: design' 'reopened: build'
  job_finish "$copy" tests/fixtures/backtracking/items/9113-reopened/ship.md
}

# AC24 backtrack guards: contract-pins -> 87-backtrack-guards
job_27() {
  local copy="$1"
  J_AREA=87-backtrack-guards
  J_EXPECTED='AC24 contract-pins'
  J_DESC="reworded a documented backlog record field"
  replace_first "$copy/docs/artifact-conventions.md" \
    '- resolves: Finding <n>' '- resolves: <n>'
  job_finish "$copy" docs/artifact-conventions.md
}

# AC25 review severity bar -> 25-review-severity-bar
job_28() {
  local copy="$1"
  J_AREA=25-review-severity-bar
  J_EXPECTED='AC25 all-severity-bar'
  J_DESC="weakened the reviewer verdict to a single severity"
  replace_first "$copy/.opencode/agent/reviewer.md" \
    'if any finding of any severity' 'if any finding of high severity'
  job_finish "$copy" .opencode/agent/reviewer.md
}

# AC25 severity definition preserved -> 25-review-severity-bar
job_29() {
  local copy="$1"
  J_AREA=25-review-severity-bar
  J_EXPECTED='AC25 contract-preserved'
  J_DESC="reintroduced the non-blocking Minor/Nit language"
  replace_first "$copy/.opencode/skill/code-review/SKILL.md" \
    'blocks the item' 'not merge-blocking'
  job_finish "$copy" .opencode/skill/code-review/SKILL.md
}

# AC26 renumber-sweep completeness -> 88-renumber-sweep
job_30() {
  local copy="$1"
  J_AREA=88-renumber-sweep
  J_EXPECTED='AC26 renumber-sweep'
  J_DESC="dropped the conflicts-with rewrite bullet from the renumber sweep"
  delete_first_line "$copy/.opencode/skill/merge-conflict/SKILL.md" \
    'every `conflicts-with` target that names the old local id'
  job_finish "$copy" .opencode/skill/merge-conflict/SKILL.md
}

# ---------------------------------------------------------------------------
# Self-test (`--selftest`): proves the runner's own assertions without running
# the mutation pass. It exercises the corrupted-restore path (restore_one) and
# the run.sh selector error cases (unknown, ambiguous, explicitly empty) plus
# one successful subset. Exit is 0 only when every self-test assertion holds.
# ---------------------------------------------------------------------------
self_pass=0
self_fail=0
stok()  { self_pass=$((self_pass+1)); printf 'ok    %s\n' "$1"; }
stbad() { self_fail=$((self_fail+1)); printf 'FAIL  %s\n' "$1"; }

selftest() {
  local d="$SCRATCH/selftest"
  local out rc

  # 1. A deliberately bad restore: the original is unavailable, so the mutated
  #    surface is left unrestored and restore_one must report it, naming it.
  rm -rf "$d"
  mkdir -p "$d"
  printf 'mutated\n' > "$d/example.txt"
  out="$(restore_one "$d/absent-original.txt" "$d/example.txt" "example.txt" 2>&1)"
  rc=$?
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -qF 'example.txt'; then
    stok "corrupted restore is reported as a failure naming the surface"
  else
    stbad "corrupted restore was not reported naming the surface (rc=$rc, out='$out')"
  fi

  # 2. Unknown selector against run.sh: exit 2, naming the offender.
  out="$(FRAMEWORK_TEST_AREAS=nope bash "$TESTS_DIR/run.sh" "$REPO_ROOT" 2>&1)"
  rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -qF 'nope'; then
    stok "unknown selector 'nope' exits 2 and names it"
  else
    stbad "unknown selector 'nope' did not exit 2 naming it (rc=$rc)"
  fi

  # 3. Ambiguous selector: exit 2, naming the offender and the candidates.
  out="$(FRAMEWORK_TEST_AREAS=8 bash "$TESTS_DIR/run.sh" "$REPO_ROOT" 2>&1)"
  rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -qF 'ambiguous' \
       && printf '%s' "$out" | grep -qF '8'; then
    stok "ambiguous selector '8' exits 2 and names it"
  else
    stbad "ambiguous selector '8' did not exit 2 naming it (rc=$rc)"
  fi

  # 4. Explicitly empty selection: exit 2, no silent full-run fallback.
  out="$(FRAMEWORK_TEST_AREAS= bash "$TESTS_DIR/run.sh" "$REPO_ROOT" 2>&1)"
  rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -qiF 'empty'; then
    stok "explicitly empty selection exits 2"
  else
    stbad "explicitly empty selection did not exit 2 (rc=$rc)"
  fi

  # 5. One successful subset: exit 0 and a TOTAL line.
  out="$(FRAMEWORK_TEST_AREAS=10-readiness bash "$TESTS_DIR/run.sh" "$REPO_ROOT" 2>&1)"
  rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -qF 'TOTAL:'; then
    stok "successful subset '10-readiness' exits 0"
  else
    stbad "successful subset '10-readiness' did not exit 0 (rc=$rc)"
  fi

  # 6. Concurrent-run isolation (D1 regression): the scratch root is unique per
  #    invocation, derived from this process's id, so two concurrent passes never
  #    share a copy/log/result/cleanup target. A fixed shared root (the pre-fix
  #    "$REPO_ROOT/scratch/framework-mutation") is the collision this pins out.
  if [ "$SCRATCH" = "$REPO_ROOT/scratch/framework-mutation.$$" ]; then
    stok "scratch root is unique per invocation (pid-suffixed)"
  elif [ "$SCRATCH" = "$REPO_ROOT/scratch/framework-mutation" ]; then
    stbad "scratch root is the fixed shared path (concurrent runs would collide)"
  else
    stbad "scratch root '$SCRATCH' is not the expected per-invocation root"
  fi

  [ "$self_fail" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Main: setup, then the job runner.
# ---------------------------------------------------------------------------
mode=run
case "${1:-}" in
  ""|--run)   mode=run ;;
  --selftest) mode=selftest ;;
  *) echo "setup error: unknown argument '$1'" >&2; exit 2 ;;
esac

if [ "$mode" = "selftest" ]; then
  echo "== mutation runner self-test =="
  mkdir -p "$SCRATCH"
  selftest
  rc=$?
  printf '\nSELFTEST: %s passed, %s failed\n' "$self_pass" "$self_fail"
  exit "$rc"
fi

mkdir -p "$SCRATCH"
: > "$WHOLE_LOG"
stage_copy "$COPY"

echo "== environment: fresh-clone independence and optional-tool skips =="
run_whole_plain
plain_rc=$?
grep '^TOTAL:' "$SETUP_PLAIN_LOG" | tee -a "$WHOLE_LOG"
if [ "$plain_rc" -eq 0 ]; then
  sok "clean copy (no work/) passes"
else
  sbad "clean copy (no work/) failed (exit $plain_rc)"
fi

run_whole_absent
absent_rc=$?
grep '^TOTAL:' "$SETUP_ABSENT_LOG" | tee -a "$WHOLE_LOG"
if [ "$absent_rc" -eq 0 ]; then
  sok "clean copy passes with optional tools absent"
else
  sbad "clean copy failed with optional tools absent (exit $absent_rc)"
fi
if grep -q '^skip  ' "$SETUP_ABSENT_LOG"; then
  sok "forced-absent run reports visible skips"
else
  sbad "forced-absent run printed no skip line"
fi

echo "== mutations (each run against only its catching area) =="
workers="$(resolve_workers)"
printf 'mutation workers: %s (jobs: %s)\n' "$workers" "$JOB_COUNT"

# One background worker subshell per resolved worker count. Each stages its own
# copy and runs every job dealt to it round-robin (worker w runs jobs w,
# w+workers, ...), so no worker can observe another's mutation and a failure in
# one never aborts another. Each job writes its own result file; the main
# process prints them in job order after `wait`.
worker_run() {
  local w="$1"
  local copy="$SCRATCH/w$w/live"
  stage_copy "$copy"
  local n
  for ((n = w; n <= JOB_COUNT; n += workers)); do
    J_RESULT="$RESULT_DIR/job-$n"
    : > "$J_RESULT"
    J_LOG="$SCRATCH/w$w/job-$n.log"
    "job_$n" "$copy"
  done
}

rm -rf "$RESULT_DIR"
mkdir -p "$RESULT_DIR"
wpids=()
for ((w = 1; w <= workers; w++)); do
  worker_run "$w" &
  wpids[${#wpids[@]}]="$!"
done
wait

# Print per-job results in job order, then aggregate: the set of named mutations
# and the aggregate exit equal a serial run regardless of completion order.
for ((n = 1; n <= JOB_COUNT; n++)); do
  if [ -s "$RESULT_DIR/job-$n" ]; then
    cat "$RESULT_DIR/job-$n"
  else
    mbad "job $n produced no result"
  fi
done
for ((n = 1; n <= JOB_COUNT; n++)); do
  [ -f "$RESULT_DIR/job-$n" ] || continue
  while IFS= read -r line; do
    case "$line" in
      ok*)   mpass=$((mpass+1)) ;;
      FAIL*) mfail=$((mfail+1)) ;;
    esac
  done < "$RESULT_DIR/job-$n"
done

whole_runs="$(grep -c '^TOTAL:' "$WHOLE_LOG" 2>/dev/null)"
[ -n "$whole_runs" ] || whole_runs=0

printf '\nwhole-suite runs: %s (AC10 bound)\n' "$whole_runs"
printf '\nMUTATION TOTAL: %s checked passed, %s failed\n' "$mpass" "$mfail"
[ "$mfail" -eq 0 ] && [ "$setup_fail" -eq 0 ]
