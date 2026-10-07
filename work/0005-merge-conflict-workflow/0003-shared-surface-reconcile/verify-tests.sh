#!/usr/bin/env bash
#
# Executable evidence for
# work/0005-merge-conflict-workflow/0003-shared-surface-reconcile
# (reconcile workflow for shared framework surfaces).
#
# Read-only against the repository: the deliverable is prompt/config/document
# content plus agent permission frontmatter. There is no runtime harness, so the
# automatable criteria (AC1-AC12) are encoded as content assertions over the
# delivered surfaces, and two live behavioral probes in scratch git repos exercise
# the documented git forms (merge-forward conflict resolution, abort-to-clean-tree,
# and the already-up-to-date no-op). AC13/AC14 are integration-verified by the
# canonical `bash tests/run.sh` plus inventory / unchanged-lifecycle invariants.
#
# Surfaces read:
#   - .opencode/skill/merge-conflict/SKILL.md   (ordered reconcile procedure)
#   - .opencode/agent/shipper.md                (permissions, preconditions, process, rules, handoff)
#   - .opencode/command/ship.md                 (work-item reconcile wiring)
#   - .opencode/skill/pr-workflow/SKILL.md      (PR `## Reconcile` record)
#   - docs/artifact-conventions.md              (ship.md `## Reconcile` template)
#   - README.md                                 (shipper Agents row)
#
# This mirrors the historical read-only item suites (work/**/verify-tests.sh). It
# is deliberately NOT a committed tests/checks/ guard: committed merge-integrity
# guards are sibling 0005-merge-integrity-guards, and the spec's ACs require only
# that the committed suite stays green.
#
# Usage: bash work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/verify-tests.sh [repo-root]
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
SHIPCMD=".opencode/command/ship.md"
PRSKILL=".opencode/skill/pr-workflow/SKILL.md"
CONV="docs/artifact-conventions.md"
README="README.md"
WF="docs/workflow.md"

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
echo "== AC1: ordered, agent-executable merge-forward procedure; never rebase/force-push =="
# ===========================================================================
needflat "$SKILL" 'determine the default branch and the merge base' "AC1 skill determines default branch + merge base"
needflat "$SKILL" 'git fetch <remote> <default>'                    "AC1 skill fetches the default branch"
needflat "$SKILL" 'git merge-base HEAD origin/<default>'            "AC1 skill computes the merge base"
needflat "$SKILL" 'git merge --no-edit origin/<default>'            "AC1 skill names the merge-forward command"
needflat "$SKILL" 'merge the default branch forward'                "AC1 skill merges forward"
needflat "$SKILL" 'never rebase'                                     "AC1 skill never rebases"
needflat "$SKILL" 'never force-push'                                 "AC1 skill never force-pushes"
# Ordering inside the reconcile sequence: fetch/base -> merge -> abort.
s_base="$(grep -n 'Determine the default branch and the merge base, then fetch' "$SKILL" | head -1 | cut -d: -f1)"
s_merge="$(grep -n 'Merge the default branch forward' "$SKILL" | head -1 | cut -d: -f1)"
s_abort="$(grep -n 'Stop and escalate a semantic conflict' "$SKILL" | head -1 | cut -d: -f1)"
if [ -n "$s_base" ] && [ -n "$s_merge" ] && [ -n "$s_abort" ] \
   && [ "$s_base" -lt "$s_merge" ] && [ "$s_merge" -lt "$s_abort" ]; then
  ok "AC1 skill sequence is ordered base/fetch < merge < escalate/abort ($s_base < $s_merge < $s_abort)"
else
  bad "AC1 skill sequence order wrong (base=$s_base merge=$s_merge abort=$s_abort)"
fi
# Shipper process carries the same executable literals.
needflat "$SHIPPER" 'git merge --no-edit origin/<default>' "AC1 shipper process names the merge-forward command"
needflat "$SHIPPER" 'never rebase'                          "AC1 shipper process never rebases"
needflat "$SHIPPER" 'never force-push'                      "AC1 shipper process never force-pushes"

# ===========================================================================
echo "== AC2: shipper bash allowlist grants merge-forward, inspection, abort; rebase/force-push/PR-merge constrained =="
# ===========================================================================
need   "$SHIPPER" '"git merge*": allow'      "AC2 git merge* allowed (covers merge, --continue, --abort)"
need   "$SHIPPER" '"git fetch*": allow'      "AC2 git fetch* allowed"
need   "$SHIPPER" '"git status*": allow'     "AC2 git status* allowed (conflict inspection)"
need   "$SHIPPER" '"git diff*": allow'       "AC2 git diff* allowed (conflict inspection)"
need   "$SHIPPER" '"git merge-base*": allow' "AC2 git merge-base* allowed"
need   "$SHIPPER" '"git rev-parse*": allow'  "AC2 git rev-parse* allowed (MERGE_HEAD probe)"
need   "$SHIPPER" '"git symbolic-ref*": allow' "AC2 git symbolic-ref* allowed (default branch)"
need   "$SHIPPER" '"git push*": ask'         "AC2 force-push remains confirmation-required (git push ask)"
need   "$SHIPPER" '"git mv*": allow'         "AC2 git mv* allowed (class (c) renumbering)"
absent "$SHIPPER" '"git rebase'              "AC2 no git rebase* allow pattern"
absent "$SHIPPER" 'gh pr merge'              "AC2 no gh pr merge grant"
# Resolve the effective bash permission for `git mv`: last-match-wins means the
# broad `*` deny must precede the allow for `git mv` to resolve to allow.
deny_last="$(grep -nF -- '"*": deny' "$SHIPPER" | tail -1 | cut -d: -f1)"
mv_line="$(grep -nF -- '"git mv*": allow' "$SHIPPER" | head -1 | cut -d: -f1)"
if [ -n "$deny_last" ] && [ -n "$mv_line" ] && [ "$deny_last" -lt "$mv_line" ]; then
  ok "AC2 shipper resolves git mv to allow (the last * deny precedes it; last-match-wins)"
else
  bad "AC2 shipper git mv resolution wrong (deny=$deny_last mv=$mv_line)"
fi
# The only allow-level git write the reconcile adds is merge; push is ask and none is rebase.
if grep -qE '^    "git rebase' "$SHIPPER"; then
  bad "AC2 found a git rebase pattern in shipper frontmatter"
else
  ok "AC2 no git rebase pattern in shipper frontmatter (rebase impermissible)"
fi
if grep -qE '^    "git pull' "$SHIPPER"; then
  bad "AC2 found a git pull pattern in shipper frontmatter"
else
  ok "AC2 no git pull pattern in shipper frontmatter"
fi

# ===========================================================================
echo "== AC3: shipper edit scope covers the class (a) shared surfaces in both path forms; README row agrees =="
# ===========================================================================
for p in \
  '"README.md": allow' '"**/README.md": allow' \
  '"AGENTS.md": allow' '"**/AGENTS.md": allow' \
  '"docs/*.md": allow' '"**/docs/*.md": allow' \
  '".opencode/agent/**": allow' '"**/.opencode/agent/**": allow' \
  '".opencode/command/**": allow' '"**/.opencode/command/**": allow' \
  '".opencode/skill/**": allow' '"**/.opencode/skill/**": allow' \
  '"template/**": allow' '"**/template/**": allow' \
  '"tests/checks/**": allow' '"**/tests/checks/**": allow' \
  '"work/**": allow' '"**/work/**": allow'; do
  need "$SHIPPER" "$p" "AC3 edit pattern present: $p"
done
need   "$SHIPPER" '"*": deny' "AC3 default edit deny retained"
# The README Agents row names work/ and a class (a) surface containing the literal 'test'.
readme_shipper_row="$(awk '
  /^\|/ { n=split($0,a,"|"); if (n<5) next; gsub(/^[ \t]+|[ \t]+$/,"",a[2]); gsub(/`/,"",a[2]); if (a[2]=="shipper") print $0 }
' "$README")"
if [ -n "$readme_shipper_row" ]; then
  ok "AC3 README has a shipper Agents row"
else
  bad "AC3 README shipper Agents row missing"
fi
case "$readme_shipper_row" in
  *tests/checks*) ok "AC3 README shipper row names tests/checks (derives tests+work)" ;;
  *)              bad "AC3 README shipper row does not name tests/checks" ;;
esac
case "$readme_shipper_row" in
  *README.md*) ok "AC3 README shipper row names the shared README surface" ;;
  *)           bad "AC3 README shipper row does not name README.md" ;;
esac
case "$readme_shipper_row" in
  *'work/**'*) ok "AC3 README shipper row retains work/**" ;;
  *)           bad "AC3 README shipper row does not retain work/**" ;;
esac
case "$readme_shipper_row" in
  *'git/gh'*) ok "AC3 README shipper bash cell stays git/gh allowlist" ;;
  *)          bad "AC3 README shipper bash cell changed" ;;
esac

# ===========================================================================
echo "== AC4: resolve shared-surface conflict preserving both sides; no markers remain =="
# ===========================================================================
needflat "$SKILL" "preserve **both** branches'" "AC4 skill preserves both branches' changes"
needflat "$SKILL" 'drop neither side'            "AC4 skill never drops a side"
needflat "$SKILL" 'class (a)'                    "AC4 skill names class (a)"
needflat "$SKILL" 'class (b)'                    "AC4 skill names class (b)"
# Live probe: a shared-file conflict, resolved preserving both intents, no markers.
scratch=""
if mkdir -p "$ROOT/scratch" 2>/dev/null && scratch="$(mktemp -d "$ROOT/scratch/verify-0003.XXXXXX" 2>/dev/null)"; then
  p_repo="$scratch/resolve"; mkdir -p "$p_repo"
  GIT() { git -C "$p_repo" -c user.email=t@t.t -c user.name=t "$@"; }
  {
    git init -q -b main "$p_repo"
    printf 'base\n'          > "$p_repo/README.md"; GIT add README.md; GIT commit -qm base
    GIT checkout -qb item
    printf 'base\nitem line\n' > "$p_repo/README.md"; GIT commit -qam item
    GIT checkout -q main
    printf 'base\nmain line\n' > "$p_repo/README.md"; GIT commit -qam main
    GIT checkout -q item
  } >/dev/null 2>&1
  GIT merge --no-edit main >/dev/null 2>&1; merge_rc=$?
  if [ "$merge_rc" -ne 0 ]; then
    ok "AC4 probe: documented merge-forward produces a conflict (rc=$merge_rc)"
  else
    bad "AC4 probe: expected a merge conflict, got clean merge"
  fi
  unmerged="$(GIT diff --name-only --diff-filter=U 2>/dev/null)"
  if printf '%s\n' "$unmerged" | grep -qx 'README.md'; then
    ok "AC4 probe: documented git diff --diff-filter=U lists the conflicted shared file"
  else
    bad "AC4 probe: conflicted shared file not listed (got '$unmerged')"
  fi
  # Resolve preserving both branches' intent.
  printf 'base\nitem line\nmain line\n' > "$p_repo/README.md"
  if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$p_repo/README.md"; then
    bad "AC4 probe: resolver left conflict markers"
  else
    ok "AC4 probe: resolved file contains no conflict markers"
  fi
  if grep -qx 'item line' "$p_repo/README.md" && grep -qx 'main line' "$p_repo/README.md"; then
    ok "AC4 probe: resolution preserves both branches' intent (neither side dropped)"
  else
    bad "AC4 probe: resolution dropped a branch's change"
  fi
  GIT add README.md >/dev/null 2>&1
  if GIT commit --no-edit -qm merge >/dev/null 2>&1; then
    ok "AC4 probe: resolved merge commits cleanly"
  else
    bad "AC4 probe: resolved merge did not commit"
  fi
  [ -n "$scratch" ] && rm -rf "$scratch"
else
  [ -n "$scratch" ] && rm -rf "$scratch"
  bad "AC4 could not create a scratch git repo for the behavioral probe"
fi

# ===========================================================================
echo "== AC5: mechanical/structural conflicts auto-resolve, subject to re-verification =="
# ===========================================================================
needflat "$SKILL" 'Auto-resolve only `mechanical or structural`' "AC5 skill scopes auto-resolve"
needflat "$SKILL" 'does not require choosing between competing' "AC5 excludes intent-judgment conflicts"
needflat "$SKILL" 'subject to sub-step 8'                       "AC5 subjects auto-resolve to re-verification"

# ===========================================================================
echo "== AC6: re-run the committed suite + item checks; green before commit/record/ship =="
# ===========================================================================
needflat "$SKILL" 'bash tests/run.sh'                              "AC6 skill runs the committed suite"
needflat "$SKILL" "the affected item's checks"                     "AC6 skill runs item checks"
needflat "$SKILL" 'before the resolved merge is committed, recorded, or shipped' "AC6 skill gates on green before commit/record/ship"
needflat "$SHIPPER" 'bash tests/run.sh'                            "AC6 shipper runs the committed suite"
needflat "$SHIPPER" "the item's checks"                            "AC6 shipper runs item checks"
needflat "$SHIPPER" 'before the merge is committed, recorded, or shipped' "AC6 shipper gates on green before commit/record/ship"
# M1: the shipper must be permitted to run what AC6 tells it to run.
need   "$SHIPPER" '"bash tests/run.sh*": allow'            "AC6 shipper allowlist permits re-running the committed suite"
need   "$SHIPPER" '"bash work/*/verify-tests.sh*": allow'  "AC6 shipper allowlist permits a standalone item's checks"
need   "$SHIPPER" '"bash work/*/*/verify-tests.sh*": allow' "AC6 shipper allowlist permits a nested child's checks"

# ===========================================================================
echo "== AC7: semantic conflict aborts to a clean tree and escalates; ship stays blocked =="
# ===========================================================================
needflat "$SKILL" 'semantic conflict'                  "AC7 skill names semantic conflict"
needflat "$SKILL" 'do not resolve it'                  "AC7 skill never resolves a semantic conflict"
needflat "$SKILL" 'git merge --abort'                  "AC7 skill aborts the merge"
needflat "$SKILL" 'clean working tree'                 "AC7 skill restores a clean working tree"
needflat "$SKILL" 'blocked path(s)'                    "AC7 skill reports the blocked paths"
needflat "$SKILL" 'blocked until the user responds'    "AC7 ship stays blocked until the user responds"
needflat "$SKILL" 'if the abort cannot complete'       "AC7 skill handles an abort that cannot complete"
needflat "$SHIPPER" 'git merge --abort'                "AC7 shipper runs git merge --abort"
needflat "$SHIPPER" 'stay blocked until the user responds' "AC7 shipper stays blocked until the user responds"
# Live probe: abort restores a clean tree with no in-progress merge.
scratch=""
if mkdir -p "$ROOT/scratch" 2>/dev/null && scratch="$(mktemp -d "$ROOT/scratch/verify-0003.XXXXXX" 2>/dev/null)"; then
  p_repo="$scratch/abort"; mkdir -p "$p_repo"
  GIT() { git -C "$p_repo" -c user.email=t@t.t -c user.name=t "$@"; }
  {
    git init -q -b main "$p_repo"
    printf 'base\n'          > "$p_repo/docs.md"; GIT add docs.md; GIT commit -qm base
    GIT checkout -qb item
    printf 'base\nitem\n'    > "$p_repo/docs.md"; GIT commit -qam item
    GIT checkout -q main
    printf 'base\nmain\n'    > "$p_repo/docs.md"; GIT commit -qam main
    GIT checkout -q item
  } >/dev/null 2>&1
  GIT merge --no-edit main >/dev/null 2>&1
  if [ -f "$p_repo/.git/MERGE_HEAD" ]; then
    ok "AC7 probe: conflict leaves an in-progress merge (MERGE_HEAD present)"
  else
    bad "AC7 probe: expected an in-progress merge before abort"
  fi
  GIT merge --abort >/dev/null 2>&1; abort_rc=$?
  if [ "$abort_rc" -eq 0 ] && [ -z "$(GIT status --porcelain 2>/dev/null)" ]; then
    ok "AC7 probe: git merge --abort restores a clean working tree"
  else
    bad "AC7 probe: abort did not leave a clean tree (rc=$abort_rc)"
  fi
  if [ ! -f "$p_repo/.git/MERGE_HEAD" ]; then
    ok "AC7 probe: no in-progress merge remains after abort"
  else
    bad "AC7 probe: MERGE_HEAD remains after abort"
  fi
  [ -n "$scratch" ] && rm -rf "$scratch"
else
  [ -n "$scratch" ] && rm -rf "$scratch"
  bad "AC7 could not create a scratch git repo for the behavioral probe"
fi

# ===========================================================================
echo "== AC8: work/ artifact conflicts preserve both records; duplicates defer to the renumbering rule =="
# ===========================================================================
needflat "$SKILL" 'class (b) `work/` records from both' "AC8 skill preserves both branches' work/ records"
needflat "$SKILL" 'rather than dropping one'             "AC8 skill does not drop one side's records"
needflat "$SKILL" 'Renumbering after a parallel merge'   "AC8 class (c) defers to the existing rule by name"
needflat "$SKILL" 'git mv'                               "AC8 class (c) renumbering uses git mv"
needflat "$SKILL" 'sibling `0004`'                       "AC8 automation remains sibling 0004"
needflat "$SKILL" 'roadmap `Children` / `Depends on`'     "AC8 classifies roadmap Children/Depends on conflicts"
needflat "$SKILL" 'never defines a second rule'          "AC8 skill forbids a second renumbering rule"

# ===========================================================================
echo "== AC9: reconcile recorded in ship.md and the PR description (resolved paths + re-verification) =="
# ===========================================================================
need   "$CONV" '## Reconcile'      "AC9 artifact-conventions documents the reconcile record"
needflat "$CONV" 'Resolved paths'  "AC9 ship.md record names resolved paths"
needflat "$CONV" 'Re-verification: `bash tests/run.sh`' "AC9 ship.md record names the re-verification evidence"
needflat "$PRSKILL" '## Reconcile'  "AC9 PR description template has the reconcile section"
needflat "$PRSKILL" 'Resolved paths' "AC9 PR template names resolved paths"
needflat "$PRSKILL" 'Re-verification: `bash tests/run.sh`' "AC9 PR template names the re-verification evidence"
needflat "$SKILL" '`## Reconcile` section of `ship.md`' "AC9 skill records into ship.md"
needflat "$SKILL" 'pull-request'                        "AC9 skill records into the PR description"
# The fix PR template must not gain a reconcile section.
fix_block="$(awk '/^## Fix PR description template/{f=1} /^## Commands/{f=0} f' "$PRSKILL")"
if printf '%s\n' "$fix_block" | grep -qF '## Reconcile'; then
  bad "AC9 fix PR template unexpectedly contains ## Reconcile"
else
  ok "AC9 fix PR template unchanged (no ## Reconcile)"
fi

# ===========================================================================
echo "== AC10: the ship.md template documents the reconcile record as part of the format =="
# ===========================================================================
need   "$CONV" '### `ship.md`' "AC10 ship.md template heading exists"
# Extract the ship.md template body: from its heading through the closing fence
# of the ```markdown block (the nested `## Reconcile` is inside that fence).
ship_block="$(awk '
  /^### `ship\.md`/ { f=1 }
  f { print }
  f && /^```markdown[ \t]*$/ { infence=1; next }
  f && infence && /^```[ \t]*$/ { exit }
' "$CONV")"
if printf '%s\n' "$ship_block" | grep -qF '## Reconcile'; then
  ok "AC10 ship.md template body contains the ## Reconcile record"
else
  bad "AC10 ship.md template body missing the ## Reconcile record"
fi
if printf '%s\n' "$ship_block" | grep -qF 'Result: <reconciled | no-op (already up to date) | blocked: <reason>>'; then
  ok "AC10 record documents the Result vocabulary (reconciled/no-op/blocked)"
else
  bad "AC10 record missing the Result vocabulary"
fi
if printf '%s\n' "$ship_block" | grep -qF 'Re-verification:'; then
  ok "AC10 record documents the re-verification evidence line"
else
  bad "AC10 record missing the re-verification evidence line"
fi

# ===========================================================================
echo "== AC11: reconcile runs after the pre-flight and before other ship operations; guardrails retained =="
# ===========================================================================
needflat "$SHIPPER" 'Reconcile first'                     "AC11 shipper process says reconcile first"
needflat "$SHIPPER" 'after the read-only pre-flight'      "AC11 shipper places reconcile after the pre-flight"
needflat "$SHIPPER" 'before the other ship operations'    "AC11 shipper places reconcile before other ship operations"
p_pre="$(grep -n 'read-only pre-flight per the `merge-conflict` skill before any ship' "$SHIPPER" | head -1 | cut -d: -f1)"
p_rec="$(grep -n 'Reconcile first' "$SHIPPER" | head -1 | cut -d: -f1)"
p_branch="$(grep -n 'Choose a branch name' "$SHIPPER" | head -1 | cut -d: -f1)"
if [ -n "$p_pre" ] && [ -n "$p_rec" ] && [ -n "$p_branch" ] \
   && [ "$p_pre" -lt "$p_rec" ] && [ "$p_rec" -lt "$p_branch" ]; then
  ok "AC11 shipper ordering pre-flight < reconcile < branch creation ($p_pre < $p_rec < $p_branch)"
else
  bad "AC11 shipper ordering wrong (pre=$p_pre reconcile=$p_rec branch=$p_branch)"
fi
needflat "$SHIPCMD" 'Reconcile first'                  "AC11 /ship says reconcile first"
needflat "$SHIPCMD" 'after the read-only pre-flight'   "AC11 /ship places reconcile after the pre-flight"
needflat "$SHIPCMD" 'before the other ship operations' "AC11 /ship places reconcile before other operations"
c_pre="$(grep -n 'Run the read-only pre-flight per the `merge-conflict` skill' "$SHIPCMD" | head -1 | cut -d: -f1)"
c_rec="$(grep -n 'Reconcile first' "$SHIPCMD" | head -1 | cut -d: -f1)"
c_next="$(grep -n 'Determine the default branch and current branch' "$SHIPCMD" | head -1 | cut -d: -f1)"
if [ -n "$c_pre" ] && [ -n "$c_rec" ] && [ -n "$c_next" ] \
   && [ "$c_pre" -lt "$c_rec" ] && [ "$c_rec" -lt "$c_next" ]; then
  ok "AC11 /ship ordering pre-flight < reconcile < other operations ($c_pre < $c_rec < $c_next)"
else
  bad "AC11 /ship ordering wrong (pre=$c_pre reconcile=$c_rec next=$c_next)"
fi
# Guardrails unchanged.
needflat "$SHIPPER" 'Never merge a PR'   "AC11 shipper never merges a PR"
needflat "$SHIPPER" 'Never force-push'   "AC11 shipper never force-pushes"
needflat "$SHIPCMD" 'Never merge, approve, force-push' "AC11 /ship closing guardrail retained"
needflat "$SHIPPER" 'Reconciled:'        "AC11 shipper handoff reports the reconcile line"

# ===========================================================================
echo "== AC12: already-up-to-date branch is a no-op that creates no merge commit =="
# ===========================================================================
needflat "$SKILL" 'already-up-to-date branch is a no-op' "AC12 skill names the up-to-date no-op"
needflat "$SKILL" 'report `no conflicts`'                "AC12 reports no conflicts"
needflat "$SKILL" 'no merge commit'                      "AC12 creates no merge commit"
needflat "$SKILL" 'does not error'                       "AC12 does not error"
needflat "$SHIPPER" 'no conflicts'                       "AC12 shipper reports no conflicts"
needflat "$SHIPPER" 'no merge commit'                    "AC12 shipper creates no merge commit"
# Live probe: merging an ancestor default branch is a no-op (no new commit).
scratch=""
if mkdir -p "$ROOT/scratch" 2>/dev/null && scratch="$(mktemp -d "$ROOT/scratch/verify-0003.XXXXXX" 2>/dev/null)"; then
  p_repo="$scratch/uptodate"; mkdir -p "$p_repo"
  GIT() { git -C "$p_repo" -c user.email=t@t.t -c user.name=t "$@"; }
  {
    git init -q -b main "$p_repo"
    printf 'one\n' > "$p_repo/f.txt"; GIT add f.txt; GIT commit -qm one
    GIT checkout -qb item
    printf 'two\n' > "$p_repo/g.txt"; GIT add g.txt; GIT commit -qm two
  } >/dev/null 2>&1
  base_eq="$(GIT merge-base HEAD main 2>/dev/null)"
  main_sha="$(GIT rev-parse main 2>/dev/null)"
  if [ -n "$base_eq" ] && [ "$base_eq" = "$main_sha" ]; then
    ok "AC12 probe: default branch is an ancestor (merge base equals default)"
  else
    bad "AC12 probe: default branch is not an ancestor (base=$base_eq main=$main_sha)"
  fi
  head_before="$(GIT rev-parse HEAD 2>/dev/null)"
  GIT merge --no-edit main >/dev/null 2>&1; noop_rc=$?
  head_after="$(GIT rev-parse HEAD 2>/dev/null)"
  if [ "$noop_rc" -eq 0 ] && [ "$head_before" = "$head_after" ]; then
    ok "AC12 probe: merge-forward of an ancestor is a no-op (no new commit, no error)"
  else
    bad "AC12 probe: up-to-date merge was not a no-op (rc=$noop_rc before=$head_before after=$head_after)"
  fi
  [ -n "$scratch" ] && rm -rf "$scratch"
else
  [ -n "$scratch" ] && rm -rf "$scratch"
  bad "AC12 could not create a scratch git repo for the behavioral probe"
fi

# ===========================================================================
echo "== AC13: committed suite passes, including permission + inventory agreements =="
# ===========================================================================
suite_out="$(bash tests/run.sh 2>&1)"; suite_rc=$?
if [ "$suite_rc" -eq 0 ] && ! printf '%s\n' "$suite_out" | grep -q '^FAIL'; then
  total_line="$(printf '%s\n' "$suite_out" | grep '^TOTAL:' | tail -1)"
  ok "AC13 bash tests/run.sh exits 0 with no FAIL ($total_line)"
else
  bad "AC13 bash tests/run.sh failed (rc=$suite_rc)"
  printf '%s\n' "$suite_out" | grep '^FAIL' | sed 's/^/      /'
fi
if printf '%s\n' "$suite_out" | grep -q 'AC8 shipper: mode=primary edit=tests+work bash=git-gh'; then
  ok "AC13 30-permissions.sh reports shipper edit=tests+work bash=git-gh"
else
  bad "AC13 30-permissions.sh did not report the expected shipper classes"
fi
if printf '%s\n' "$suite_out" | grep -q 'AC9 README Layout count for'; then
  ok "AC13 40-inventory.sh ran and asserted the README Layout counts"
else
  bad "AC13 40-inventory.sh inventory assertions not observed"
fi

# ===========================================================================
echo "== AC14: no new lifecycle/artifact-format/inventory surface beyond the ship.md reconcile record =="
# ===========================================================================
cmd_n="$(ls .opencode/command/*.md 2>/dev/null | wc -l | tr -d ' ')"
agent_n="$(ls .opencode/agent/*.md 2>/dev/null | wc -l | tr -d ' ')"
skill_n="$(ls -d .opencode/skill/*/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$cmd_n" = "12" ]   && ok "AC14 command count is 12"   || bad "AC14 command count is $cmd_n (expected 12)"
[ "$agent_n" = "14" ] && ok "AC14 agent count is 14"     || bad "AC14 agent count is $agent_n (expected 14)"
[ "$skill_n" = "11" ] && ok "AC14 skill count is 11"     || bad "AC14 skill count is $skill_n (expected 11)"
# No new (untracked) command/agent/skill file.
new_files="$(git status --porcelain -- .opencode/command .opencode/agent .opencode/skill 2>/dev/null | grep '^??' || true)"
if [ -z "$new_files" ]; then
  ok "AC14 no new command/agent/skill file added"
else
  bad "AC14 untracked command/agent/skill files:"; printf '%s\n' "$new_files" | sed 's/^/      /'
fi
# docs/workflow.md byte-identical.
if git diff --quiet -- "$WF" 2>/dev/null; then
  ok "AC14 docs/workflow.md is byte-identical to HEAD"
else
  bad "AC14 docs/workflow.md changed"
fi
# Artifact templates all retained; no template heading lost.
for h in '### `roadmap.md`' '### `spec.md`' '### `design.md`' '### `tasks.md`' '### `verify.md`' '### `review.md`' '### `ship.md`'; do
  need "$CONV" "$h" "AC14 artifact template retained: $h"
done
# Six-phase lifecycle intact, no seventh phase.
for p in '### 1. Requirements' '### 2. Design' '### 3. Build' '### 4. Test' '### 5. Review' '### 6. Ship'; do
  need "$WF" "$p" "AC14 phase retained: $p"
done
absent "$WF" '### 7.' "AC14 no seventh phase added"
# The production change set is exactly the six design-named surfaces plus the item dir.
changed="$(git status --porcelain 2>/dev/null | awk '{print $2}' | grep -v '^work/0005-merge-conflict-workflow/0003-shared-surface-reconcile/' | sort)"
expected=".opencode/agent/shipper.md
.opencode/command/ship.md
.opencode/skill/merge-conflict/SKILL.md
.opencode/skill/pr-workflow/SKILL.md
README.md
docs/artifact-conventions.md"
expected="$(printf '%s\n' "$expected" | sort)"
if [ "$changed" = "$expected" ]; then
  ok "AC14 production change set is exactly the six design-named surfaces"
else
  bad "AC14 unexpected production change set:"
  printf '%s\n' "$changed" | sed 's/^/      /'
fi
# No executable script added outside work/.
new_scripts="$(git status --porcelain 2>/dev/null | awk '$1=="??"{print $2}' | grep -v '^work/' || true)"
if [ -z "$new_scripts" ]; then
  ok "AC14 no new executable/script file added outside work/"
else
  bad "AC14 new files outside work/:"; printf '%s\n' "$new_scripts" | sed 's/^/      /'
fi

# ===========================================================================
echo "== Edge cases =="
# ===========================================================================
# Default branch undeterminable.
needflat "$SKILL" 'default branch cannot be determined' "EDGE default branch undeterminable reported"
needflat "$SKILL" 'do not mutate the branch'            "EDGE undeterminable does not mutate"
# Fetch unavailable or denied.
needflat "$SKILL" 'unavailable or denied'               "EDGE fetch unavailable/denied handled"
needflat "$SKILL" 'report the comparison as `skipped`'  "EDGE degraded fetch reports skipped"
# Behind but conflict-free: still re-verify.
needflat "$SKILL" 'clean merge is not evidence of correctness' "EDGE clean merge still verified"
# Markers remain after resolution.
needflat "$SKILL" 'unresolved'                          "EDGE remaining markers treated as unresolved"
needflat "$SKILL" 'must not be committed'               "EDGE unresolved file not committed"
# Already mid-merge at start.
needflat "$SKILL" 'Do not start a second merge'         "EDGE already mid-merge reported"
needflat "$SKILL" 'MERGE_HEAD'                          "EDGE MERGE_HEAD probe named"
# Re-verification fails after a mechanical resolution.
needflat "$SKILL" 're-verification fails is not accepted' "EDGE failed re-verification not accepted"
# Large conflict set.
needflat "$SKILL" 'never truncated'                     "EDGE conflict list never truncated"
# Semantic conflict mid-merge abort and abort failure.
needflat "$SKILL" 'restore a clean working tree'        "EDGE mid-merge abort restores clean tree"
needflat "$SKILL" 'rather than committing a partial merge' "EDGE abort failure stops rather than partial commit"

# ===========================================================================
echo "== Effective permission resolution (AC2/AC3/AC6) =="
# ===========================================================================
# Literal presence of a pattern is not proof the shipper may run the command:
# the map is last-match-wins, so the effective decision for a concrete target is
# the value of the last matching rule (docs/customization.md:163-165). Resolve
# each reconcile-critical command/path against the shipper's own map and assert
# the effective decision, with negative controls for the guardrails. The matcher
# treats `*` as a wildcard and `**` as one too (a deliberately permissive model);
# the required targets are inside the named surfaces, so a match here means the
# real glob matches as well.
perm_block() { # $1=file $2=capability
  awk -v want="  $2:" '
    /^permission:[ \t]*$/ { inperm=1; next }
    inperm && /^[^ ]/ { inperm=0 }
    !inperm { next }
    index($0, want)==1 { capon=1; next }
    capon && /^  [^ ]/ { capon=0 }
    capon { print }
  ' "$1"
}
resolve_perm() { # $1=map text $2=target -> allow|ask|deny|none
  awk -v target="$2" '
    function glob2re(p) { gsub(/\./, "\\.", p); gsub(/\*/, ".*", p); return "^" p "$" }
    BEGIN { result="none" }
    {
      line=$0
      if (line !~ /^[ \t]+"/) next
      i=index(line, ":"); if (i<2) next
      pat=substr(line,1,i-1); gsub(/^[ \t]+/,"",pat); gsub(/[ \t]+$/,"",pat); gsub(/"/,"",pat)
      val=substr(line,i+1); gsub(/^[ \t]+|[ \t]+$/,"",val); gsub(/"/,"",val)
      if (val=="allow" || val=="ask" || val=="deny") {
        if (target ~ glob2re(pat)) result=val
      }
    }
    END { print result }
  ' <<< "$1"
}
check_perm() { # $1=map $2=target $3=expected $4=label
  got="$(resolve_perm "$1" "$2")"
  if [ "$got" = "$3" ]; then
    ok "$4 (effective '$2' -> $got)"
  else
    bad "$4 (effective '$2' -> $got, expected $3)"
  fi
}
BASH_MAP="$(perm_block "$SHIPPER" bash)"
EDIT_MAP="$(perm_block "$SHIPPER" edit)"
# AC2/AC6/AC7/AC8: every command the reconcile runs resolves to allow.
check_perm "$BASH_MAP" 'git symbolic-ref refs/remotes/origin/HEAD' allow "AC2 default-branch probe permitted"
check_perm "$BASH_MAP" 'git merge-base HEAD origin/main'            allow "AC2 merge-base permitted"
check_perm "$BASH_MAP" 'git fetch origin main'                      allow "AC2 fetch permitted"
check_perm "$BASH_MAP" 'git rev-parse -q --verify MERGE_HEAD'       allow "AC2 in-progress probe permitted"
check_perm "$BASH_MAP" 'git merge --no-edit origin/main'            allow "AC2 merge-forward permitted"
check_perm "$BASH_MAP" 'git status --short'                         allow "AC2 conflict status permitted"
check_perm "$BASH_MAP" 'git diff --name-only --diff-filter=U'       allow "AC2 conflict diff permitted"
check_perm "$BASH_MAP" 'git mv work/a work/b'                       allow "AC8 class (c) git mv permitted"
check_perm "$BASH_MAP" 'git merge --abort'                          allow "AC7 merge abort permitted"
check_perm "$BASH_MAP" 'bash tests/run.sh'                          allow "AC6 committed suite permitted"
check_perm "$BASH_MAP" 'bash work/0005-x/verify-tests.sh'           allow "AC6 standalone item checks permitted"
check_perm "$BASH_MAP" 'bash work/0005-x/0003-y/verify-tests.sh'    allow "AC6 nested item checks permitted"
# Guardrail controls: push stays ask; rebase and PR-merge stay denied.
check_perm "$BASH_MAP" 'git push origin feat/x'    ask  "AC2 push remains confirmation-required"
check_perm "$BASH_MAP" 'git push --force origin x' ask  "AC2 force-push remains confirmation-required"
check_perm "$BASH_MAP" 'git rebase main'           deny "AC2 rebase is impermissible"
check_perm "$BASH_MAP" 'gh pr merge 1'             deny "AC2 merging a PR is forbidden"
# AC3: class (a) shared surfaces + work/** resolve to allow; others stay denied.
check_perm "$EDIT_MAP" 'README.md'                              allow "AC3 root README editable"
check_perm "$EDIT_MAP" '/repo/README.md'                        allow "AC3 absolute README editable"
check_perm "$EDIT_MAP" 'docs/workflow.md'                       allow "AC3 docs/*.md editable"
check_perm "$EDIT_MAP" '.opencode/agent/shipper.md'             allow "AC3 .opencode agent surface editable"
check_perm "$EDIT_MAP" '.opencode/skill/merge-conflict/SKILL.md' allow "AC3 .opencode skill surface editable"
check_perm "$EDIT_MAP" 'template/AGENTS.md'                     allow "AC3 template surface editable"
check_perm "$EDIT_MAP" 'tests/checks/30-permissions.sh'         allow "AC3 tests/checks surface editable"
check_perm "$EDIT_MAP" 'work/0005-x/0003-y/spec.md'             allow "AC3 work/ surface editable"
check_perm "$EDIT_MAP" '/repo/work/0005-x/spec.md'              allow "AC3 absolute work/ surface editable"
check_perm "$EDIT_MAP" 'src/main.ts'                            deny  "AC3 unrelated path remains denied"

# ===========================================================================
printf '\nTOTAL: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
