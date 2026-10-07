#!/usr/bin/env bash
#
# Executable evidence for work/0005-merge-conflict-workflow/0002-conflict-detection
# (pre-flight conflict detection and classification).
#
# Read-only against the repository. The deliverable is prompt/config/document
# content only: there is no runtime harness. The automatable criteria (AC1-AC12)
# are encoded as content assertions over the delivered surfaces:
#
#   - .opencode/skill/merge-conflict/SKILL.md   (pre-flight + integrity checks)
#   - .opencode/agent/shipper.md                (allowlist, preconditions, rules, handoff)
#   - .opencode/command/ship.md                 (work-item pre-flight bullet)
#   - .opencode/agent/status.md                 (offline integrity findings)
#   - .opencode/command/status.md               (offline integrity findings)
#   - .opencode/skill/pr-workflow/SKILL.md      (PR Conflict detection section)
#
# AC13/AC14 are integration-verified by the canonical `bash tests/run.sh` plus
# the command/agent/skill inventory and unchanged-lifecycle invariants.
#
# This mirrors the historical read-only item suites (work/**/verify-tests.sh). It
# is deliberately NOT a committed tests/checks/ guard: the design defers
# committed merge-integrity guards to sibling 0005-merge-integrity-guards, and
# the spec's ACs require only that the committed suite stays green.
#
# Usage: bash work/0005-merge-conflict-workflow/0002-conflict-detection/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures, 2 = setup error.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

SKILL=".opencode/skill/merge-conflict/SKILL.md"
SHIPPER=".opencode/agent/shipper.md"
STATUS=".opencode/agent/status.md"
SHIPCMD=".opencode/command/ship.md"
STATUSCMD=".opencode/command/status.md"
PRSKILL=".opencode/skill/pr-workflow/SKILL.md"
WF="docs/workflow.md"
CONV="docs/artifact-conventions.md"

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }

# flat: collapse newlines/whitespace so a phrase survives line wrapping.
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
# need: exact literal (single-line).
need()      { if grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3 (missing '$2' in $1)"; fi; }
# needflat: exact literal after whitespace collapsing (cross-line phrases).
needflat()  { if flat "$1" | grep -qF -- "$2"; then ok "$3"; else bad "$3 (missing '$2' in $1)"; fi; }
# needE: regex.
needE()     { if grep -qE -- "$2" "$1"; then ok "$3"; else bad "$3 (no /$2/ in $1)"; fi; }
# absent: literal must NOT appear (negative control).
absent()    { if grep -qF -- "$2" "$1"; then bad "$3 (found forbidden '$2' in $1)"; else ok "$3"; fi; }

# ===========================================================================
echo "== AC1: read-only pre-flight determines base, reports changed paths, mutates nothing =="
# ===========================================================================
need   "$SKILL" '## Pre-flight (read-only detection)' "AC1 skill has a read-only pre-flight section"
needflat "$SKILL" '**read-only pre-flight**'           "AC1 pre-flight is explicitly read-only"
needflat "$SKILL" 'before any ship operation'          "AC1 pre-flight runs before any ship operation"
needflat "$SKILL" 'merge base'                         "AC1 determines the merge base"
needflat "$SKILL" 'git merge-base HEAD origin/<default>' "AC1 names the merge-base command"
needflat "$SKILL" 'git fetch <remote> <default-branch>' "AC1 fetches remote-tracking refs"
needflat "$SKILL" 'Report the paths each branch changed' "AC1 reports the paths each branch changed"
needflat "$SKILL" 'git diff --name-only <base>..HEAD'   "AC1 item-branch changed paths"
needflat "$SKILL" 'git diff --name-only <base>..origin/<default>' "AC1 default-branch changed paths"
needflat "$SKILL" 'mutates neither the branch nor the working tree' "AC1 no-mutation statement"
needflat "$SKILL" 'no merge applied'                    "AC1 states no merge applied"
needflat "$SKILL" 'no rebase'                           "AC1 states no rebase"
needflat "$SKILL" 'no force-push'                       "AC1 states no force-push"
needflat "$SKILL" 'no commit'                           "AC1 states no commit"
needflat "$SKILL" 'no branch change'                    "AC1 states no branch change"
# The pre-flight must be a distinct step *ahead of* the resolve procedure.
pf_line="$(grep -n '^## Pre-flight (read-only detection)' "$SKILL" | head -1 | cut -d: -f1)"
proc_line="$(grep -n '^## Procedure' "$SKILL" | head -1 | cut -d: -f1)"
if [ -n "$pf_line" ] && [ -n "$proc_line" ] && [ "$pf_line" -lt "$proc_line" ]; then
  ok "AC1 pre-flight section precedes the resolve procedure (line $pf_line < $proc_line)"
else
  bad "AC1 pre-flight section does not precede the resolve procedure (pf=$pf_line proc=$proc_line)"
fi

# ===========================================================================
echo "== AC2: dry-run textual probe classifies conflicting paths (a)/(b) without applying =="
# ===========================================================================
needflat "$SKILL" 'Dry-run textual probe'               "AC2 dry-run textual probe present"
needflat "$SKILL" 'git merge-tree --write-tree --name-only HEAD origin/<default>' "AC2 names the dry-run merge-tree form"
needflat "$SKILL" 'report the paths on which a merge would conflict' "AC2 reports conflicting paths"
needflat "$SKILL" 'exit status `1` means conflicts were found' "AC2 merge-tree exit 1 means conflicts, not failure"
needflat "$SKILL" 'skip that OID line when extracting the paths' "AC2 merge-tree output shape documented"
needflat "$SKILL" 'does not apply to the working tree'  "AC2 probe does not apply to the working tree"
needflat "$SKILL" 'git merge-tree <base> <branch1> <branch2>' "AC2 older-git three-argument fallback"
needflat "$SKILL" 'Classify each conflicting path as class' "AC2 classifies each conflicting path"
needflat "$SKILL" 'class `(a)`'                         "AC2 class (a) label"
needflat "$SKILL" 'class `(b)`'                         "AC2 class (b) label"
needflat "$SKILL" 'per the `0001` taxonomy in `docs/workflow.md`' "AC2 cites the 0001 taxonomy"
# Class (a) surfaces named.
for s in 'README.md' 'AGENTS.md' 'docs/*.md' '.opencode/{agent,command,skill}/**' 'template/**' 'tests/checks/**'; do
  needflat "$SKILL" "$s" "AC2 class (a) names surface $s"
done
needflat "$SKILL" 'class `(b)` — a `work/` path'        "AC2 class (b) is a work/ path"
# Behavioral check: the documented dry-run probe actually reports a conflict,
# prints the tree OID first, and leaves the working tree untouched. This closes
# the gap left by a pure literal assertion (AC2 requires the probe to work, not
# merely to be described).
probe_tmp="$(mktemp -d 2>/dev/null || true)"
if [ -n "$probe_tmp" ] && git -C "$probe_tmp" init -q -b main 2>/dev/null; then
  printf 'base\n' > "$probe_tmp/f.txt"
  git -C "$probe_tmp" -c user.email=t@t.t -c user.name=t add f.txt 2>/dev/null
  git -C "$probe_tmp" -c user.email=t@t.t -c user.name=t commit -qm base 2>/dev/null
  git -C "$probe_tmp" checkout -qb side 2>/dev/null
  printf 'side\n' > "$probe_tmp/f.txt"
  git -C "$probe_tmp" -c user.email=t@t.t -c user.name=t commit -qam side 2>/dev/null
  git -C "$probe_tmp" checkout -q main 2>/dev/null
  printf 'main\n' > "$probe_tmp/f.txt"
  git -C "$probe_tmp" -c user.email=t@t.t -c user.name=t commit -qam main 2>/dev/null
  probe_out="$(git -C "$probe_tmp" merge-tree --write-tree --name-only HEAD side 2>/dev/null)"; probe_rc=$?
  if [ "$probe_rc" -ne 0 ] && printf '%s\n' "$probe_out" | grep -qx 'f.txt'; then
    ok "AC2 dry-run probe reports the conflicted path with a non-zero exit"
  else
    bad "AC2 dry-run probe did not report the conflict (rc=$probe_rc)"
  fi
  first_line="$(printf '%s\n' "$probe_out" | head -1)"
  if printf '%s' "$first_line" | grep -qE '^[0-9a-f]{40}$'; then
    ok "AC2 dry-run probe output starts with the merged tree OID"
  else
    bad "AC2 dry-run probe output did not start with a tree OID ('$first_line')"
  fi
  if [ "$(cat "$probe_tmp/f.txt" 2>/dev/null)" = "main" ]; then
    ok "AC2 dry-run probe leaves the working tree unchanged"
  else
    bad "AC2 dry-run probe mutated the working tree"
  fi
  rm -rf "$probe_tmp"
else
  [ -n "$probe_tmp" ] && rm -rf "$probe_tmp"
  bad "AC2 could not create a scratch git repo for the behavioral probe"
fi

# ===========================================================================
echo "== AC3: framework-integrity checks (duplicates, graph faults, drift) =="
# ===========================================================================
needflat "$SKILL" 'Framework-integrity checks'          "AC3 integrity checks section present"
needflat "$SKILL" 'Duplicate top-level sequence prefixes' "AC3 duplicate top-level prefixes"
needflat "$SKILL" 'top-level `work/`'                    "AC3 scope is top-level work/"
needflat "$SKILL" '4-digit `NNNN` prefix is equal'       "AC3 names the NNNN prefix equality"
needflat "$SKILL" 'Duplicate per-parent roadmap child numbers' "AC3 duplicate per-parent child numbers"
needflat "$SKILL" '4-digit `MMMM` prefix is equal'       "AC3 names the MMMM prefix equality"
needflat "$SKILL" 'Roadmap graph faults'                 "AC3 roadmap graph faults present"
needflat "$SKILL" 'Depends on'                           "AC3 resolves Depends on"
for t in 'dangling' 'missing' 'unlisted' 'cyclic'; do
  needflat "$SKILL" "$t" "AC3 graph fault '$t' named"
done
needflat "$SKILL" 'Duplicated inventory/count facts'     "AC3 duplicated inventory/count facts"
needflat "$SKILL" "README.md's Layout counts"            "AC3 compares README Layout counts"
needflat "$SKILL" 'Skills table membership'              "AC3 compares README Skills table"
needflat "$SKILL" 'git ls-tree --name-only origin/<default>:work' "AC3 cross-branch prefix comparison"

# ===========================================================================
echo "== AC4: finding grammar carries class + offender, nothing silently dropped =="
# ===========================================================================
needflat "$SKILL" '- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>' "AC4 canonical finding grammar"
needflat "$SKILL" 'No finding is silently dropped'       "AC4 no finding silently dropped"
needflat "$SKILL" 'every conflicting path is reported'   "AC4 every conflicting path reported"
needflat "$SKILL" 'never truncated'                      "AC4 path list never truncated"
for c in 'TEXTUAL-CONFLICT' 'DANGLING-DEP' 'MISSING-CHILD' 'UNLISTED-CHILD' 'CYCLIC-DEP' 'DUPLICATE-PREFIX' 'DUPLICATE-CHILD' 'DRIFT-FACT'; do
  needflat "$SKILL" "$c" "AC4 vocabulary code '$c' present"
done
for cl in '`(a)`' '`(b)`' '`(c)`' '`(d)`'; do
  needflat "$SKILL" "$cl" "AC4 class label $cl present"
done

# ===========================================================================
echo "== AC5: shipper + /ship run the pre-flight before any ship operation =="
# ===========================================================================
needflat "$SHIPPER" 'read-only pre-flight (per the `merge-conflict` skill) runs before any ship operation' "AC5 shipper precondition wires pre-flight before ship"
needflat "$SHIPPER" 'its result is recorded'             "AC5 shipper requires the result recorded"
needflat "$SHIPPER" 'a semantic finding is handed to the `0001` reconcile step for escalation' "AC5 shipper hands semantic finding to 0001 reconcile"
needflat "$SHIPPER" 'never resolved by detection'        "AC5 shipper says detection never resolves"
needflat "$SHIPPER" '`conventional-commits`, `merge-conflict`, and `pr-workflow`' "AC5 shipper inputs list the merge-conflict skill"
needflat "$SHIPCMD" 'Run the read-only pre-flight per the `merge-conflict` skill before any ship operation' "AC5 /ship bullet runs pre-flight before ship"
needflat "$SHIPCMD" 'escalate a semantic conflict at the `0001` reconcile step' "AC5 /ship hands semantic conflict to 0001 reconcile"
needflat "$SHIPCMD" 'record the result'                  "AC5 /ship records the result"

# ===========================================================================
echo "== AC6: intent-judgment conflict stops and escalates; detection never resolves =="
# ===========================================================================
needflat "$SKILL" 'never resolves a semantic conflict'   "AC6 skill says detection never resolves a semantic conflict"
needflat "$SKILL" 'judgment about intent'                "AC6 names the intent-judgment trigger"
needflat "$SKILL" 'Stop and escalate'                    "AC6 skill has the stop-and-escalate step"
needflat "$SHIPPER" 'a finding that needs a judgment about intent is a semantic conflict handed to the `0001` reconcile step for escalation, not resolved here' "AC6 shipper escalates instead of resolving"
needflat "$SHIPCMD" 'rather than resolving it'           "AC6 /ship escalates rather than resolving"

# ===========================================================================
echo "== AC7: minimal read-only git permissions granted; rebase/force-push still forbidden =="
# ===========================================================================
need   "$SHIPPER" '"git fetch*": allow'        "AC7 git fetch allowed"
need   "$SHIPPER" '"git merge-tree*": allow'   "AC7 git merge-tree allowed"
need   "$SHIPPER" '"git ls-tree*": allow'      "AC7 git ls-tree allowed"
need   "$SHIPPER" '"git symbolic-ref*": allow' "AC7 git symbolic-ref allowed for default-branch resolution"
need   "$SHIPPER" '"git push*": ask'           "AC7 push remains ask"
absent "$SHIPPER" 'git rebase'                 "AC7 no rebase permission introduced"
# The read-only git additions sit in the existing git-gh bash class; the coarse
# class must not weaken (AC13 re-checks this via the committed suite).

# ===========================================================================
echo "== AC8: /status reports duplicate-sequence + drift findings alongside existing four =="
# ===========================================================================
for c in 'DUPLICATE-PREFIX' 'DUPLICATE-CHILD' 'DRIFT-FACT' 'DANGLING-DEP' 'MISSING-CHILD' 'UNLISTED-CHILD' 'CYCLIC-DEP'; do
  needflat "$STATUS" "$c" "AC8 status agent names '$c'"
done
needflat "$STATUS" 'Findings are informational and never fatal' "AC8 findings are non-fatal"
needflat "$STATUS" 'Every finding carries its class label'      "AC8 every finding carries a class"
needflat "$STATUS" 'No file was modified'                       "AC8 status modifies no file"
for c in 'DUPLICATE-PREFIX' 'DUPLICATE-CHILD' 'DRIFT-FACT'; do
  needflat "$STATUSCMD" "$c" "AC8 /status command names '$c'"
done
needflat "$STATUSCMD" 'without failing'                 "AC8 /status reports without failing"
needflat "$STATUSCMD" 'modifies no file'                "AC8 /status modifies no file"
absent "$STATUS" 'or the other branch'                  "AC8 status drift finding stays local-only (no other-branch clause)"

# ===========================================================================
echo "== AC9: /status detection is local-only (no fetch, no dry-run merge, no remote) =="
# ===========================================================================
needflat "$STATUS" 'Local-only detection'               "AC9 status declares local-only detection"
needflat "$STATUS" 'fetches nothing'                    "AC9 status fetches nothing"
needflat "$STATUS" 'hits no remote'                     "AC9 status hits no remote"
needflat "$STATUS" 'runs no dry-run merge'              "AC9 status runs no dry-run merge"
needflat "$STATUS" 'takes no lock'                      "AC9 status takes no lock"
needflat "$STATUS" 'writes nothing'                     "AC9 status writes nothing"
needflat "$STATUSCMD" 'local-only'                      "AC9 /status declares local-only"
needflat "$STATUSCMD" 'fetches nothing'                 "AC9 /status fetches nothing"
needflat "$STATUSCMD" 'hits no remote'                  "AC9 /status hits no remote"
needflat "$STATUSCMD" 'runs no dry-run merge'           "AC9 /status runs no dry-run merge"
needflat "$STATUSCMD" 'modifies no file'                "AC9 /status modifies no file"
absent "$STATUS" 'git fetch'                            "AC9 negative: no git fetch in status agent"
absent "$STATUS" 'git merge-tree'                       "AC9 negative: no git merge-tree in status agent"
absent "$STATUSCMD" 'git fetch'                          "AC9 negative: no git fetch in /status"
absent "$STATUSCMD" 'git merge-tree'                    "AC9 negative: no git merge-tree in /status"

# ===========================================================================
echo "== AC10: findings name the offending canonical reference and class =="
# ===========================================================================
needflat "$SKILL" 'the offender is the exact path or canonical reference so a reader can locate it' "AC10 grammar requires the offender"
needflat "$STATUS" 'names the offending canonical reference' "AC10 status names the offending reference"
needflat "$STATUS" '[DUPLICATE-PREFIX] (c) 0004-billing, 0004-billing-v2' "AC10 example names duplicate-prefix refs + class"
needflat "$STATUS" '[DUPLICATE-CHILD] (c) 0002-agentic-roadmaps/0003-spec, 0002-agentic-roadmaps/0003-plan' "AC10 example names duplicate-child refs + class"
needflat "$STATUS" '[DRIFT-FACT] (d) README.md' "AC10 example names drift offender + class"

# ===========================================================================
echo "== AC11: already-up-to-date branch reports no conflicts and does not error =="
# ===========================================================================
needflat "$SKILL" 'already up to date with the default branch reports `no conflicts`' "AC11 up-to-date reports no conflicts"
needflat "$SKILL" 'the pre-flight is a no-op and does not error' "AC11 up-to-date is a no-op, no error"
needflat "$SHIPPER" 'up-to-date branch reports `no conflicts` without error' "AC11 shipper states the no-op"

# ===========================================================================
echo "== AC12: detection result recorded in ship handoff and PR description =="
# ===========================================================================
need   "$SHIPPER" 'Detected: <conflict classes and paths found, or "no conflicts detected">' "AC12 shipper handoff has a Detected line"
needflat "$SHIPPER" 'The `Detected:` line is work-item mode only' "AC12 Detected line is scoped to work-item mode"
needflat "$PRSKILL" '## Conflict detection'             "AC12 pr-workflow gains a Conflict detection section"
needflat "$PRSKILL" 'No conflicts detected'             "AC12 PR section records the no-conflict case"
needflat "$SHIPCMD" 'in `ship.md` and the PR description' "AC12 /ship records the result in ship.md and PR"

# ===========================================================================
echo "== Edge cases =="
# ===========================================================================
# No remote or no default-branch reference.
needflat "$SKILL" 'report that the default branch cannot be determined' "EDGE default branch undeterminable is reported"
needflat "$SKILL" 'instead of guessing one'             "EDGE does not guess the default branch"
needflat "$SKILL" 'that alone does not fail the ship'   "EDGE undeterminable default does not fail the ship"
# git fetch unavailable/denied.
needflat "$SKILL" 'If `git fetch` is unavailable or denied' "EDGE fetch unavailable path"
needflat "$SKILL" 'report the comparison as `skipped`'  "EDGE fetch failure reported as skipped"
needflat "$SKILL" 'never run it on a stale base'        "EDGE never runs on a stale base"
# Empty state: /status handles an empty work/ tree without error.
needflat "$STATUS" 'If it is empty'                     "EDGE status handles empty work/"
needflat "$STATUS" 'report that no items exist'         "EDGE status reports no items, does not error"
needflat "$STATUSCMD" 'If `work/` is empty'             "EDGE /status handles empty work/"
# Duplicate sequence number, one shipped and one not: any two duplicates report.
needflat "$SKILL" 'Any two top-level `work/`'           "EDGE duplicate prefixes detected regardless of state"
needflat "$SKILL" 'are a duplicate top-level class `(c)` collision' "EDGE duplicate prefix classified (c)"
needflat "$SKILL" 'never defines a second rule'         "EDGE class (c) defers to the renumbering contract"
# Overlapping classes.
needflat "$SKILL" 'each applicable class'               "EDGE overlapping classes reported under each"
# Both sides changed the same duplicated fact to the same value.
needflat "$SKILL" 'Both sides changing the same duplicated fact to the same value is not drift' "EDGE equal changes are not drift"
needflat "$SKILL" 'report no class `(d)` finding'       "EDGE equal changes emit no drift finding"
# Clean dry-run merge is not proof of correctness.
needflat "$SKILL" 'A clean dry-run merge (no conflict markers) is not proof of correctness' "EDGE clean dry-run still needs re-verification"
# Concurrent detection runs.
needflat "$SKILL" 'take no lock and write nothing'      "EDGE concurrent runs take no lock, write nothing"
# Large changed set is not truncated (already asserted in AC4); restate here.
needflat "$SKILL" 'never truncated'                     "EDGE large changed set never truncated"

# ===========================================================================
echo "== AC13: committed suite passes, incl. permission + inventory agreement =="
# ===========================================================================
suite_out="$(bash tests/run.sh 2>&1)"; suite_rc=$?
if [ "$suite_rc" -eq 0 ] && ! printf '%s\n' "$suite_out" | grep -q '^FAIL'; then
  total_line="$(printf '%s\n' "$suite_out" | grep '^TOTAL:' | tail -1)"
  ok "AC13 bash tests/run.sh exits 0 with no FAIL ($total_line)"
else
  bad "AC13 bash tests/run.sh failed (rc=$suite_rc)"
  printf '%s\n' "$suite_out" | grep '^FAIL' | sed 's/^/      /'
fi
if printf '%s\n' "$suite_out" | grep -q 'AC8 shipper: mode=primary edit=work bash=git-gh'; then
  ok "AC13 shipper remains the git-gh bash class"
else
  bad "AC13 shipper bash class changed (permission-agreement risk)"
fi
if printf '%s\n' "$suite_out" | grep -q 'AC8 status: mode=primary edit=none bash=read-only'; then
  ok "AC13 status agent remains the read-only bash class"
else
  bad "AC13 status bash class changed"
fi
if printf '%s\n' "$suite_out" | grep -q 'AC9 README Layout count for .role prompts. equals disk'; then
  ok "AC13 inventory check ran (README layout vs disk)"
else
  bad "AC13 inventory check did not run"
fi

# ===========================================================================
echo "== AC14: no new command/agent/skill; lifecycle + artifact formats unchanged =="
# ===========================================================================
cmd_n="$(ls .opencode/command/*.md 2>/dev/null | wc -l | tr -d ' ')"
agent_n="$(ls .opencode/agent/*.md 2>/dev/null | wc -l | tr -d ' ')"
skill_n="$(ls -d .opencode/skill/*/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$cmd_n" = "12" ]   && ok "AC14 command count is 12"   || bad "AC14 command count is $cmd_n (expected 12)"
[ "$agent_n" = "14" ] && ok "AC14 agent count is 14"     || bad "AC14 agent count is $agent_n (expected 14)"
[ "$skill_n" = "11" ] && ok "AC14 skill count is 11"     || bad "AC14 skill count is $skill_n (expected 11)"
# No new (untracked) command/agent/skill file.
new_surface="$(git status --porcelain -- .opencode/command .opencode/agent .opencode/skill 2>/dev/null | grep '^??' || true)"
if [ -z "$new_surface" ]; then
  ok "AC14 no new command/agent/skill file added"
else
  bad "AC14 new command/agent/skill file added:"; printf '%s\n' "$new_surface" | sed 's/^/      /'
fi
# No new executable detection script anywhere outside work/.
new_scripts="$(git status --porcelain 2>/dev/null | grep '^??' | grep -v '^?? work/' || true)"
if [ -z "$new_scripts" ]; then
  ok "AC14 no executable detection script added outside work/"
else
  bad "AC14 unexpected untracked file added:"; printf '%s\n' "$new_scripts" | sed 's/^/      /'
fi
# Lifecycle/artifact/readiness surfaces unchanged.
if git diff --quiet -- "$WF" "$CONV" AGENTS.md README.md opencode.json template tests 2>/dev/null; then
  ok "AC14 lifecycle, artifact, readiness, inventory, and suite surfaces unchanged"
else
  bad "AC14 a lifecycle/artifact/inventory/suite surface changed:"
  git diff --name-only -- "$WF" "$CONV" AGENTS.md README.md opencode.json template tests | sed 's/^/      /'
fi
# The delivered change is confined to the six design-named surfaces.
changed="$(git status --porcelain -- .opencode 2>/dev/null | awk '{print $2}' | sort)"
expected="$(printf '%s\n' \
  ".opencode/agent/shipper.md" \
  ".opencode/agent/status.md" \
  ".opencode/command/ship.md" \
  ".opencode/command/status.md" \
  ".opencode/skill/merge-conflict/SKILL.md" \
  ".opencode/skill/pr-workflow/SKILL.md" | sort)"
if [ "$changed" = "$expected" ]; then
  ok "AC14 .opencode change is confined to the six design-named surfaces"
else
  bad "AC14 .opencode change set differs from the design:"
  printf '%s\n' "$changed" | sed 's/^/      /'
fi

# ===========================================================================
printf '\nTOTAL: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
