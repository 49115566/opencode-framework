#!/usr/bin/env bash
#
# Executable evidence for
# work/0005-merge-conflict-workflow/0004-artifact-reconcile
# (reconcile workflow for work/ artifacts and sequence numbers).
#
# Read-only against the repository: the deliverable is prompt/config/document
# content (the merge-conflict skill, the shipper agent, and the /ship command).
# There is no runtime harness, so the criteria are encoded two ways:
#   * content assertions over the delivered surfaces (the skill, shipper, /ship,
#     the PR template, and the artifact-conventions ship.md record), and
#   * live behavioral probes in scratch git repos that exercise the documented
#     git forms: cross-branch collision detection, the choose -> git mv ->
#     reference-sweep sequence, a roadmap Children/Depends on union with a graph
#     re-check, a structural sweep repair versus an ambiguous dangling dep, an
#     abort to a clean tree, the deleted-number allocation rule, and the
#     up-to-date no-op.
# AC13/AC14 are integration-verified by the canonical `bash tests/run.sh` plus
# inventory / unchanged-lifecycle / unchanged-permission invariants.
#
# Surfaces read:
#   - .opencode/skill/merge-conflict/SKILL.md   (ordered work/ reconcile procedure)
#   - .opencode/agent/shipper.md                (preconditions, process, rules, handoff)
#   - .opencode/command/ship.md                 (work-item reconcile wiring)
#   - .opencode/skill/pr-workflow/SKILL.md      (PR `## Reconcile` record)
#   - docs/artifact-conventions.md              (ship.md `## Reconcile` template + renumber rule)
#   - docs/workflow.md                          (normative contract, unchanged)
#
# This mirrors the historical read-only item suites (work/**/verify-tests.sh). It
# is deliberately NOT a committed tests/checks/ guard: committed merge-integrity
# guards are sibling 0005-merge-integrity-guards, and the spec's ACs require only
# that the committed suite stays green.
#
# Usage: bash work/0005-merge-conflict-workflow/0004-artifact-reconcile/verify-tests.sh [repo-root]
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
# absent: literal must NOT appear (negative control).
absent()    { if grep -qF -- "$2" "$1"; then bad "$3 (found forbidden '$2' in $1)"; else ok "$3"; fi; }

# ===========================================================================
echo "== AC1: ordered, agent-executable work/ reconcile that preserves both records =="
# ===========================================================================
need   "$SKILL" '### `work/` artifact reconcile' "AC1 skill adds the work/ artifact reconcile subsection"
needflat "$SKILL" 'after the conflict set is listed' "AC1 subsection runs after the conflict set is listed"
needflat "$SKILL" 'before the re-verification'       "AC1 subsection runs before the re-verification"
needflat "$SKILL" 'preserve both branches'"'"' records' "AC1 content merge preserves both branches' records"
needflat "$SKILL" 'drop neither side'                "AC1 content merge drops neither side"
needflat "$SKILL" 'artifact frontmatter'             "AC1 merges artifact frontmatter"
needflat "$SKILL" 'Roadmap `Children` rows'          "AC1 merges roadmap Children rows"
needflat "$SKILL" '`Depends on` cells'               "AC1 merges Depends on cells"
# Sub-step 6 (Resolve) routes class (b)/(c) into the subsection.
needflat "$SKILL" 'run the `work/` artifact reconcile' "AC1 resolve sub-step invokes the work/ reconcile"
# M1 (review fix): entering the work/ reconcile is keyed on the merge having
# touched any work/ path, not on a pre-flight class (b)/(c) finding, because the
# pre-flight ran before the merge and a work/ graph fault can surface only after.
needflat "$SKILL" 'touched no `work/` path' "AC1 a clean merge that touched no work/ path short-circuits"
needflat "$SKILL" 'clean merge that touched any `work/` path or carries a pre-flight class' "AC1 a clean merge touching work/ or a pre-flight finding is not finished"
needflat "$SKILL" 'the pre-flight ran before the merge' "AC1 entry is not gated on a pre-flight finding (the pre-flight ran before the merge)"
needflat "$SKILL" 'Continue to sub-step 1.6' "AC1 the clean-merge path continues to the work/ reconcile (sub-step 1.6)"
needflat "$SKILL" 'auto-committed' "AC1 the clean-merge path reconciles the already-merged tree"
needflat "$SHIPPER" 'touched any `work/` path, or that carries a pre-flight class' "AC1 shipper routes a clean merge touching work/ or a pre-flight finding to the reconcile"
needflat "$SHIPCMD" 'clean merge that touched' "AC1 /ship routes a clean merge touching work/ to the reconcile"
# Shipper preconditions name the work/ sequence collision / graph fault handling.
needflat "$SHIPPER" 'artifact reconcile'             "AC1 shipper preconditions reference the work/ reconcile"
needflat "$SHIPPER" 'never shipped unresolved'       "AC1 shipper preconditions forbid shipping a collision"
# The sibling 0004 deferral is replaced.
absent "$SKILL" 'remain sibling `0004`'              "AC1 the sibling 0004 deferral is removed"
absent "$SKILL" 'sibling `0004`'                     "AC1 no leftover sibling 0004 reference"

# ===========================================================================
echo "== AC2: union roadmap Children rows and Depends on cells; neither branch dropped =="
# ===========================================================================
needflat "$SKILL" "union of both branches' rows"          "AC2 Children rows are unioned"
needflat "$SKILL" 'de-duplicated to one'                  "AC2 identical Children rows de-duplicate to one"
needflat "$SKILL" "never silently discard a branch's dependency" "AC2 no branch dependency is silently discarded"
needflat "$SKILL" "union of both branches' dependencies"  "AC2 Depends on cells are unioned"
needflat "$SKILL" 'collapsed to one'                      "AC2 a duplicated dependency collapses to one"
needflat "$SKILL" 'judgment about intent'                 "AC2 a differing duplicate row is an intent judgment"
needflat "$SKILL" 'to different values'                   "AC2 a divergent same-row Depends on escalates rather than unions"

# ===========================================================================
echo "== AC3: re-check every roadmap graph; structural auto-repair, intent escalate =="
# ===========================================================================
needflat "$SKILL" 'resolves to an existing row and child directory' "AC3 every Depends on resolves to a row + child dir"
needflat "$SKILL" 'acyclic'                       "AC3 the stored graph must be acyclic"
needflat "$SKILL" 'structural fault'             "AC3 a structural fault is auto-repaired"
needflat "$SKILL" 'unambiguous structural repair' "AC3 only an unambiguous repair is auto-applied"
needflat "$SKILL" 'DANGLING-DEP'                 "AC3 graph re-check names DANGLING-DEP"
needflat "$SKILL" 'CYCLIC-DEP'                   "AC3 graph re-check names CYCLIC-DEP"
needflat "$SKILL" 'MISSING-CHILD'                "AC3 graph re-check names MISSING-CHILD"
needflat "$SKILL" 'UNLISTED-CHILD'               "AC3 graph re-check names UNLISTED-CHILD"
needflat "$SKILL" 'deliberately removed child'   "AC3 a deliberately removed child escalates"

# ===========================================================================
echo "== AC4: detect top-level NNNN, per-parent MMMM, and cross-branch collisions =="
# ===========================================================================
needflat "$SKILL" 'top-level'                       "AC4 detects top-level collisions"
needflat "$SKILL" 'NNNN'                            "AC4 names the top-level NNNN prefix"
needflat "$SKILL" 'MMMM'                            "AC4 names the per-parent MMMM prefix"
needflat "$SKILL" 'git ls-tree --name-only origin/<default>:work' "AC4 reads the default branch tree for cross-branch collisions"
needflat "$SKILL" 'canonical reference(s)'          "AC4 reports each collision with its canonical reference(s)"
needflat "$SKILL" 'never truncated'                "AC4 reports every colliding prefix, never truncated"

# ===========================================================================
echo "== AC5: choose by the existing rule and allocate without reuse =="
# ===========================================================================
needflat "$SKILL" 'not yet approved or shipped'     "AC5 chooses the item not yet approved or shipped"
needflat "$SKILL" 'ship.md'                         "AC5 shipped signal is ship.md presence"
needflat "$SKILL" 'review.md'                       "AC5 approved signal is a review.md verdict"
needflat "$SKILL" 'approve'                         "AC5 approval verdict is approve"
needflat "$SKILL" 'added later by commit time'      "AC5 tie-break is added later by commit time"
needflat "$SKILL" 'git log --diff-filter=A'         "AC5 uses git log --diff-filter=A"
needflat "$SKILL" 'slug order'                      "AC5 final tie-break is slug order"
needflat "$SKILL" 'next number'                     "AC5 allocates the next number"
needflat "$SKILL" 'never reuse'                     "AC5 never reuses a spent number"
needflat "$SKILL" 'ever appeared in the committed'  "AC5 allocates from the ever-committed history"
needflat "$SKILL" 'that parent'"'"'s committed `work/<parent>/` history' "AC5 per-parent MMMM allocation uses the parent's own history"

# ===========================================================================
echo "== AC6: move and rewrite every reference in the same change =="
# ===========================================================================
needflat "$SKILL" 'git mv work/<old> work/<new>'    "AC6 moves with git mv"
needflat "$SKILL" 'in the same change'              "AC6 rewrites references in the same change"
needflat "$SKILL" '`feature` frontmatter'           "AC6 updates the feature frontmatter"
needflat "$SKILL" 'nested child'"'"'s `parent`'          "AC6 updates a nested child's parent"
needflat "$SKILL" 'Local id'                        "AC6 updates the Children Local id cell"
needflat "$SKILL" 'Canonical reference'             "AC6 updates the Children Canonical reference cell"
needflat "$SKILL" 'every `Depends on`'              "AC6 updates every Depends on cell naming the old local id"
needflat "$SKILL" 'PR/handoff'                      "AC6 updates the PR/handoff paths"
needflat "$SKILL" 'prose'                           "AC6 updates prose naming the old reference"
needflat "$SKILL" 'no reference to the old canonical reference remains' "AC6 asserts the old reference is gone"
# The shipper rules carry the same reference sweep.
needflat "$SHIPPER" 'Local id'                      "AC6 shipper rules name the Children Local id"
needflat "$SHIPPER" 'Canonical'                     "AC6 shipper rules name the Canonical reference"
needflat "$SHIPPER" 'PR/handoff paths'              "AC6 shipper rules name the PR/handoff paths"
needflat "$SHIPPER" 'no reference to the old canonical reference remains' "AC6 shipper rules assert the old reference is gone"

# ===========================================================================
echo "== AC7: an undecidable renumber escalates instead of guessing =="
# ===========================================================================
needflat "$SKILL" 'both are already shipped'        "AC7 both-shipped is undecidable"
needflat "$SKILL" 'cannot be determined'            "AC7 indeterminate state is undecidable"
needflat "$SKILL" 'shallow clone'                   "AC7 a shallow clone is undecidable"
needflat "$SKILL" 'unavailable'                     "AC7 unavailable history is undecidable"
needflat "$SKILL" 'two different new numbers'       "AC7 two conflicting new numbers is undecidable"
needflat "$SKILL" 'do not reassign a number arbitrarily' "AC7 never reassigns a number arbitrarily"
needflat "$SHIPPER" 'undecidable renumber'          "AC7 shipper names an undecidable renumber"

# ===========================================================================
echo "== AC8: an intent fault escalates by aborting to a clean tree =="
# ===========================================================================
needflat "$SKILL" 'git merge --abort'               "AC8 escalates with git merge --abort"
needflat "$SKILL" 'blocked reference(s)'            "AC8 reports the blocked reference(s)"
needflat "$SKILL" 'decision the user must make'     "AC8 reports the decision the user must make"
needflat "$SKILL" 'blocked until the user responds' "AC8 stays blocked until the user responds"
needflat "$SKILL" 'no in-progress merge to abort'   "AC8 the clean-merge escalation does not attempt git merge --abort"
needflat "$SHIPPER" 'abort a conflicted, in-progress merge and escalate' "AC8 shipper aborts a conflicted in-progress merge and escalates"
needflat "$SHIPPER" 'when the merge already auto-committed cleanly' "AC8 shipper does not abort a clean auto-committed merge"
needflat "$SHIPPER" 'stay blocked until the user responds' "AC8 shipper stays blocked until the user responds"

# ===========================================================================
echo "== AC9: re-run the committed suite + item checks; green before commit/record/ship =="
# ===========================================================================
needflat "$SKILL" 'bash tests/run.sh'               "AC9 skill runs the committed suite"
needflat "$SKILL" "the affected item's checks"      "AC9 skill runs the affected item's checks"
needflat "$SKILL" 'green'                           "AC9 requires green"
needflat "$SKILL" 'before the merge is recorded or shipped' "AC9 gates on green before record/ship"
needflat "$SKILL" 'do not rewrite an already-created merge commit' "AC9 an auto-committed clean merge is not rewritten without confirmation"
needflat "$SKILL" 'a failing check is the blocker'  "AC9 a failing check is the blocker"
needflat "$SHIPPER" 'bash tests/run.sh'             "AC9 shipper runs the committed suite"
needflat "$SHIPPER" "the item's checks"             "AC9 shipper runs the item checks"

# ===========================================================================
echo "== AC10: record resolved paths and any renumber in ship.md ## Reconcile and the PR =="
# ===========================================================================
needflat "$SKILL" '`## Reconcile`'                  "AC10 skill records into the ## Reconcile record"
needflat "$SKILL" 'Resolved paths'                  "AC10 skill records a Resolved paths entry"
needflat "$SKILL" '<old> → <new>'                   "AC10 skill names the <old> → <new> renumber form"
needflat "$SKILL" 'pull-request'                    "AC10 skill records into the pull-request"
need    "$CONV" '## Reconcile'                      "AC10 artifact-conventions still documents the ## Reconcile record"
needflat "$CONV" 'Resolved paths'                   "AC10 ship.md record names Resolved paths"
needflat "$PRSKILL" '## Reconcile'                  "AC10 PR template has the ## Reconcile section"
needflat "$PRSKILL" 'Resolved paths'                "AC10 PR template names Resolved paths"
needflat "$SHIPPER" '<old> → <new>'                 "AC10 shipper handoff reports the renumbered reference"

# ===========================================================================
echo "== AC11: an up-to-date branch with no collision is a no-op =="
# ===========================================================================
needflat "$SKILL" 'no conflicts'                    "AC11 no-op reports no conflicts"
needflat "$SKILL" 'no renumber'                     "AC11 no-op performs no renumber"
needflat "$SKILL" 'no move'                         "AC11 no-op performs no move"
needflat "$SKILL" 'does not error'                  "AC11 no-op does not error"
needflat "$SKILL" 'no merge commit'                 "AC11 no-op creates no merge commit"
needflat "$SHIPPER" 'no conflicts'                  "AC11 shipper reports no conflicts"
needflat "$SHIPPER" 'no merge commit'               "AC11 shipper creates no merge commit"
needflat "$SHIPCMD" 'work/` artifact reconcile'     "AC11 /ship wires the work/ reconcile"

# ===========================================================================
echo "== AC12: the normative renumbering rule is unchanged; no second rule =="
# ===========================================================================
needflat "$SKILL" 'Renumbering after a parallel merge'        "AC12 skill references the normative rule by name"
needflat "$SKILL" 'never defines a second renumbering rule'   "AC12 skill defines no second renumbering rule"
need   "$CONV" '### Renumbering after a parallel merge'       "AC12 normative section heading exists"
if git diff --quiet -- "$CONV" 2>/dev/null; then
  ok "AC12 docs/artifact-conventions.md is byte-identical (renumbering section unchanged)"
else
  bad "AC12 docs/artifact-conventions.md changed"
fi

# ===========================================================================
echo "== AC13: committed suite passes, including permission + inventory + signature =="
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
if printf '%s\n' "$suite_out" | grep -qE 'AC22 .*ship\.md usage string states canonical /ship'; then
  ok "AC13 96-signature-sweep.sh ran and asserted the /ship signature"
else
  bad "AC13 96-signature-sweep.sh signature assertions not observed"
fi

# ===========================================================================
echo "== AC14: no new command/agent/skill/executable; lifecycle + permissions unchanged =="
# ===========================================================================
cmd_n="$(ls .opencode/command/*.md 2>/dev/null | wc -l | tr -d ' ')"
agent_n="$(ls .opencode/agent/*.md 2>/dev/null | wc -l | tr -d ' ')"
skill_n="$(ls -d .opencode/skill/*/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$cmd_n" = "12" ]   && ok "AC14 command count is 12"   || bad "AC14 command count is $cmd_n (expected 12)"
[ "$agent_n" = "14" ] && ok "AC14 agent count is 14"     || bad "AC14 agent count is $agent_n (expected 14)"
[ "$skill_n" = "11" ] && ok "AC14 skill count is 11"     || bad "AC14 skill count is $skill_n (expected 11)"
if git diff --quiet -- "$WF" 2>/dev/null; then
  ok "AC14 docs/workflow.md is byte-identical to HEAD"
else
  bad "AC14 docs/workflow.md changed"
fi
for h in '### `roadmap.md`' '### `spec.md`' '### `design.md`' '### `tasks.md`' '### `verify.md`' '### `review.md`' '### `ship.md`'; do
  need "$CONV" "$h" "AC14 artifact template retained: $h"
done
for p in '### 1. Requirements' '### 2. Design' '### 3. Build' '### 4. Test' '### 5. Review' '### 6. Ship'; do
  need "$WF" "$p" "AC14 phase retained: $p"
done
absent "$WF" '### 7.' "AC14 no seventh phase added"
# The shipper permission frontmatter is byte-identical to HEAD.
head_front="$(git show HEAD:"$SHIPPER" 2>/dev/null | awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}')"
work_front="$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$SHIPPER")"
if [ "$head_front" = "$work_front" ]; then
  ok "AC14 shipper permission frontmatter is byte-identical to HEAD"
else
  bad "AC14 shipper permission frontmatter changed"
fi
# No new command/agent/skill file.
new_files="$(git status --porcelain -- .opencode/command .opencode/agent .opencode/skill 2>/dev/null | grep '^??' || true)"
if [ -z "$new_files" ]; then
  ok "AC14 no new command/agent/skill file added"
else
  bad "AC14 untracked command/agent/skill files:"; printf '%s\n' "$new_files" | sed 's/^/      /'
fi
# No executable/script file added outside work/.
new_scripts="$(git status --porcelain 2>/dev/null | awk '$1=="??"{print $2}' | grep -v '^work/' || true)"
if [ -z "$new_scripts" ]; then
  ok "AC14 no new file added outside work/"
else
  bad "AC14 new files outside work/:"; printf '%s\n' "$new_scripts" | sed 's/^/      /'
fi
# The production change set is exactly the three design-named surfaces + this item dir.
changed="$(git status --porcelain 2>/dev/null | awk '{print $2}' | grep -v '^work/0005-merge-conflict-workflow/0004-artifact-reconcile/' | sort)"
expected=".opencode/agent/shipper.md
.opencode/command/ship.md
.opencode/skill/merge-conflict/SKILL.md"
expected="$(printf '%s\n' "$expected" | sort)"
if [ "$changed" = "$expected" ]; then
  ok "AC14 production change set is exactly the three design-named surfaces"
else
  bad "AC14 unexpected production change set:"
  printf '%s\n' "$changed" | sed 's/^/      /'
fi

# ===========================================================================
echo "== Edge cases (content) =="
# ===========================================================================
# Same number, different slug is still a collision.
needflat "$SKILL" 'under different slugs'           "EDGE same number under different slugs is a collision"
# Same canonical reference, differing content escalates.
needflat "$SKILL" 'duplicate local id'              "EDGE duplicate local id is an intent fault"
# Dangling dep: repair only when unambiguous, otherwise escalate.
needflat "$SKILL" 'correct target is'               "EDGE dangling dep is repaired only if unambiguous"
needflat "$SKILL" 'ambiguous'                       "EDGE ambiguous dangling target escalates"
# Cycle cannot be mechanically broken.
needflat "$SKILL" 'cannot be mechanically broken'   "EDGE a cycle cannot be mechanically broken"
# Unlisted child needing title/scope escalates.
needflat "$SKILL" 'title/scope/intent'              "EDGE an unlisted child needing title/scope escalates"
# Missing child reconciled via the renumber sweep when unambiguous.
needflat "$SKILL" 'MISSING-CHILD'                   "EDGE missing child is named"
# Renumbered child is a dependency: every Depends on updated.
needflat "$SKILL" 'every `Depends on`'              "EDGE renumbered dependency updates every Depends on"
# Number already spent is not reused.
needflat "$SKILL" 'never reallocate a number whose directory was deleted' "EDGE a deleted number is never reused"
# Re-verification fails is not accepted.
needflat "$SKILL" 'is the blocker'                  "EDGE a failed re-verification is reported as the blocker"
# Large collision set is never truncated.
needflat "$SKILL" 'even for a large set'            "EDGE a large collision set is never truncated"

# ===========================================================================
echo "== Live probes (scratch git repos) =="
# ===========================================================================
scratch=""
if mkdir -p "$ROOT/scratch" 2>/dev/null && scratch="$(mktemp -d "$ROOT/scratch/verify-0004.XXXXXX" 2>/dev/null)"; then
  :
else
  scratch=""
fi

# graph_faults <roadmap> <parent-dir> : print faults, exit 0 clean / 1 fault.
graph_faults() {
  local rm="$1" parent="$2"
  local -A deps=()
  local line id dep d faults=0
  while IFS= read -r line; do
    case "$line" in '|'*) ;; *) continue ;; esac
    id="$(printf '%s' "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')"
    case "$id" in [0-9][0-9][0-9][0-9]-*) ;; *) continue ;; esac
    dep="$(printf '%s' "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$5); print $5}')"
    deps["$id"]="$dep"
  done < "$rm"
  for id in "${!deps[@]}"; do
    dep="${deps[$id]}"
    [ "$dep" = "—" ] && continue
    local oldifs="$IFS"; IFS=','
    for d in $dep; do
      IFS="$oldifs"
      d="$(printf '%s' "$d" | tr -d '[:space:]')"
      [ -z "$d" ] && continue
      [ "$d" = "—" ] && continue
      if [ -z "${deps[$d]:-}" ] || [ ! -d "$parent/$d" ]; then
        printf 'DANGLING-DEP %s -> %s\n' "$id" "$d"; faults=1
      fi
    done
    IFS="$oldifs"
  done
  local cyc
  cyc="$(for id in "${!deps[@]}"; do printf '%s %s\n' "$id" "${deps[$id]}"; done | awk '
    { id=$1; dep=$2; name[id]=1; n=split(dep,parts,","); for(i=1;i<=n;i++){ d=parts[i]; gsub(/[ \t]/,"",d); if(d==""||d=="—") continue; name[d]=1; adj[id]=adj[id] " " d } }
    END {
      for(nm in name) indeg[nm]=0
      for(nm in adj){ m=split(adj[nm],a," "); for(k=1;k<=m;k++){ if(a[k]!="") indeg[a[k]]++ } }
      qn=0
      for(nm in name) if(indeg[nm]==0) q[++qn]=nm
      done=0
      for(qi=1;qi<=qn;qi++){ nm=q[qi]; done++; m=split(adj[nm],a," "); for(k=1;k<=m;k++){ if(a[k]=="") continue; indeg[a[k]]--; if(indeg[a[k]]==0) q[++qn]=a[k] } }
      c=0; for(nm in name) c++
      if(done<c) print "CYCLIC-DEP"
    }')"
  if [ -n "$cyc" ]; then
    [ -n "$cyc" ] && faults=1
    printf '%s %s\n' "$cyc" "(cycle)"
  fi
  return "$faults"
}

# ---- Probe 1: two branches allocate the same NNNN; detect cross-branch, then
#      merge, choose, git mv, and sweep every reference (AC4, AC5, AC6). ----
p_repo="$scratch/collision"; mkdir -p "$p_repo"
G() { git -C "$p_repo" -c user.email=t@t.t -c user.name=t "$@"; }
{
  git init -q -b main "$p_repo"
  mkdir -p "$p_repo/work/0001-base"
  printf 'feature: 0001-base\n' > "$p_repo/work/0001-base/spec.md"
  G add -A; GIT_AUTHOR_DATE='2026-01-01T00:00:00' GIT_COMMITTER_DATE='2026-01-01T00:00:00' G commit -qm base
  G checkout -qb item
  mkdir -p "$p_repo/work/0005-alpha"
  printf 'feature: 0005-alpha\nbody\n' > "$p_repo/work/0005-alpha/spec.md"
  G add -A; GIT_AUTHOR_DATE='2026-01-02T00:00:00' GIT_COMMITTER_DATE='2026-01-02T00:00:00' G commit -qm alpha
  G checkout -q main
  mkdir -p "$p_repo/work/0005-beta"
  printf 'feature: 0005-beta\nbody\n' > "$p_repo/work/0005-beta/spec.md"
  G add -A; GIT_AUTHOR_DATE='2026-01-03T00:00:00' GIT_COMMITTER_DATE='2026-01-03T00:00:00' G commit -qm beta
  G checkout -q item
} >/dev/null 2>&1
# Cross-branch detection: local 0005-alpha vs origin/main tree 0005-beta.
local_names="$(ls "$p_repo/work" 2>/dev/null)"
main_names="$(G ls-tree --name-only main:work 2>/dev/null)"
dup_prefix=""
for n in $local_names; do
  p="${n%%-*}"
  for m in $main_names; do
    if [ "${m%%-*}" = "$p" ] && [ "$n" != "$m" ]; then dup_prefix="$p"; fi
  done
done
if [ -n "$dup_prefix" ]; then
  ok "Probe1 AC4 cross-branch collision detected between item and default branch (prefix $dup_prefix)"
else
  bad "Probe1 AC4 cross-branch collision not detected (local='$local_names' main='$main_names')"
fi
# Merge the default branch forward: distinct dirs, so clean.
if G merge --no-edit main >/dev/null 2>&1; then
  ok "Probe1 documented merge-forward completes (distinct directories)"
else
  bad "Probe1 merge-forward failed"
fi
# Post-merge duplicate top-level prefix detection.
post_prefixes="$(ls "$p_repo/work" | sed 's/-.*//' | sort | uniq -d)"
if [ "$post_prefixes" = "0005" ]; then
  ok "Probe1 AC4 post-merge duplicate top-level prefix detected (0005)"
else
  bad "Probe1 AC4 duplicate prefix not detected (got '$post_prefixes')"
fi
# Choose: both unshipped; beta added later by commit time -> renumber beta.
t_alpha="$(G log --diff-filter=A --format=%ct -- work/0005-alpha | tail -1)"
t_beta="$(G log --diff-filter=A --format=%ct -- work/0005-beta | tail -1)"
if [ -n "$t_beta" ] && [ -n "$t_alpha" ] && [ "$t_beta" -gt "$t_alpha" ]; then
  ok "Probe1 AC5 'added later by commit time' picks beta ($t_beta > $t_alpha)"
else
  bad "Probe1 AC5 commit-time comparison failed (alpha=$t_alpha beta=$t_beta)"
fi
# Allocate next number from the ever-committed history (max 0005 -> 0006).
max_ever="$(G log --all --name-only --pretty=format: -- work/ 2>/dev/null \
  | sed -n 's#^work/\([0-9][0-9][0-9][0-9]\)-.*#\1#p' | sort -u | tail -1)"
next_num="$(printf '%04d' $((10#$max_ever + 1)))"
if [ "$next_num" = "0006" ]; then
  ok "Probe1 AC5 allocation picks the next number 0006 (max ever $max_ever)"
else
  bad "Probe1 AC5 allocation wrong (max=$max_ever next=$next_num)"
fi
# git mv + reference sweep.
if G mv work/0005-beta "work/$next_num-beta" >/dev/null 2>&1; then
  ok "Probe1 AC6 git mv moves the chosen item"
else
  bad "Probe1 AC6 git mv failed"
fi
if grep -rl '0005-beta' "$p_repo/work" >/dev/null 2>&1; then
  grep -rl '0005-beta' "$p_repo/work" | while IFS= read -r f; do
    sed -i 's/0005-beta/0006-beta/g' "$f"
  done
fi
if grep -rq '0005-beta' "$p_repo/work" 2>/dev/null; then
  bad "Probe1 AC6 old canonical reference 0005-beta still present after the sweep"
else
  ok "Probe1 AC6 no reference to the old canonical reference remains"
fi
if grep -qx 'feature: 0006-beta' "$p_repo/work/0006-beta/spec.md" 2>/dev/null; then
  ok "Probe1 AC6 feature frontmatter updated by the sweep"
else
  bad "Probe1 AC6 feature frontmatter not updated"
fi
post_prefixes2="$(ls "$p_repo/work" | sed 's/-.*//' | sort | uniq -d)"
if [ -z "$post_prefixes2" ]; then
  ok "Probe1 AC5 no duplicate prefix remains after the renumber"
else
  bad "Probe1 AC5 duplicate prefix remains: $post_prefixes2"
fi

# ---- Probe 2: roadmap Children/Depends on union + graph re-check (AC2, AC3). ----
p2="$scratch/union"; mkdir -p "$p2"
G2() { git -C "$p2" -c user.email=t@t.t -c user.name=t "$@"; }
roadmap="$p2/work/0001-road/roadmap.md"
{
  git init -q -b main "$p2"
  mkdir -p "$p2/work/0001-road/0001-a"
  printf 'feature: 0001-road\nphase: roadmap\n\n## Children\n\n| Local id | Title | Scope | Depends on | Canonical reference |\n| --- | --- | --- | --- | --- |\n| 0001-a | A | scope | — | 0001-road/0001-a |\n' > "$roadmap"
  G2 add -A; G2 commit -qm base
  G2 checkout -qb item
  mkdir -p "$p2/work/0001-road/0002-b"
  printf '| 0002-b | B | scope | 0001-a | 0001-road/0002-b |\n' >> "$roadmap"
  G2 add -A; G2 commit -qm b
  G2 checkout -q main
  mkdir -p "$p2/work/0001-road/0003-c"
  printf '| 0003-c | C | scope | 0001-a | 0001-road/0003-c |\n' >> "$roadmap"
  G2 add -A; G2 commit -qm c
  G2 checkout -q item
} >/dev/null 2>&1
G2 merge --no-edit main >/dev/null 2>&1
# Documented union resolution: keep both branches' rows and deps.
{
  printf 'feature: 0001-road\nphase: roadmap\n\n## Children\n\n| Local id | Title | Scope | Depends on | Canonical reference |\n| --- | --- | --- | --- | --- |\n'
  printf '| 0001-a | A | scope | — | 0001-road/0001-a |\n'
  printf '| 0002-b | B | scope | 0001-a | 0001-road/0002-b |\n'
  printf '| 0003-c | C | scope | 0001-a | 0001-road/0003-c |\n'
} > "$roadmap"
if grep -qF '| 0002-b |' "$roadmap" && grep -qF '| 0003-c |' "$roadmap"; then
  ok "Probe2 AC2 union preserves both branches' Children rows"
else
  bad "Probe2 AC2 union dropped a branch's Children row"
fi
if grep -qF '0001-a' "$roadmap"; then
  ok "Probe2 AC2 union preserves the shared Depends on dependency"
else
  bad "Probe2 AC2 union dropped the Depends on dependency"
fi
if graph_faults "$roadmap" "$p2/work/0001-road" >/dev/null 2>&1; then
  ok "Probe2 AC3 graph re-check passes for the unioned acyclic graph"
else
  bad "Probe2 AC3 graph re-check failed for a clean graph"
fi

# ---- Probe 3: structural sweep repair vs ambiguous dangling dep (AC3, AC8). ----
# Structural: a Depends on stale by the renumber sweep is repaired to the new id.
sed -i 's/| 0002-b | B | scope | 0001-a |/| 0002-b | B | scope | 0001-a-old |/' "$roadmap"
f_out="$(graph_faults "$roadmap" "$p2/work/0001-road" 2>&1)"
if printf '%s\n' "$f_out" | grep -q 'DANGLING-DEP 0002-b -> 0001-a-old'; then
  ok "Probe3 AC3 a stale Depends on is detected as DANGLING-DEP"
else
  bad "Probe3 AC3 stale Depends on not detected (got '$f_out')"
fi
sed -i 's/0001-a-old/0001-a/' "$roadmap"   # the renumber reference sweep
if graph_faults "$roadmap" "$p2/work/0001-road" >/dev/null 2>&1; then
  ok "Probe3 AC3 the sweep repair resolves the structural fault"
else
  bad "Probe3 AC3 the sweep repair did not resolve the structural fault"
fi
# Intent: an ambiguous dangling dep has no unambiguous target, so it is not
# silently repaired; the documented action is to escalate (Probe 4 proves abort).
sed -i 's/| 0003-c | C | scope | 0001-a |/| 0003-c | C | scope | 9999-ghost |/' "$roadmap"
if graph_faults "$roadmap" "$p2/work/0001-road" 2>&1 | grep -q 'DANGLING-DEP'; then
  ok "Probe3 AC8 an ambiguous dangling dep is detected and not silently repaired"
else
  bad "Probe3 AC8 ambiguous dangling dep was not detected"
fi
# Cycle: two children depend on each other; a cycle cannot be mechanically broken,
# so the documented action is to escalate rather than store a circular graph.
cycle_rm="$p2/work/0001-road/cycle.md"
mkdir -p "$p2/work/0001-road/0004-x" "$p2/work/0001-road/0005-y"
{
  printf '| 0004-x | X | scope | 0005-y | 0001-road/0004-x |\n'
  printf '| 0005-y | Y | scope | 0004-x | 0001-road/0005-y |\n'
} > "$cycle_rm"
if graph_faults "$cycle_rm" "$p2/work/0001-road" 2>&1 | grep -q 'CYCLIC-DEP'; then
  ok "Probe3 AC3 a cycle is detected as CYCLIC-DEP (cannot be mechanically broken)"
else
  bad "Probe3 AC3 a cycle was not detected"
fi

# ---- Probe 4: abort restores a clean tree and leaves no in-progress merge (AC8). ----
p3="$scratch/abort"; mkdir -p "$p3"
G3() { git -C "$p3" -c user.email=t@t.t -c user.name=t "$@"; }
{
  git init -q -b main "$p3"
  printf 'base\n' > "$p3/docs.md"; G3 add docs.md; G3 commit -qm base
  G3 checkout -qb item
  printf 'base\nitem\n' > "$p3/docs.md"; G3 commit -qam item
  G3 checkout -q main
  printf 'base\nmain\n' > "$p3/docs.md"; G3 commit -qam main
  G3 checkout -q item
} >/dev/null 2>&1
G3 merge --no-edit main >/dev/null 2>&1
if [ -f "$p3/.git/MERGE_HEAD" ]; then
  ok "Probe4 AC8 conflict leaves an in-progress merge (MERGE_HEAD present)"
else
  bad "Probe4 AC8 expected an in-progress merge before abort"
fi
G3 merge --abort >/dev/null 2>&1; abort_rc=$?
if [ "$abort_rc" -eq 0 ] && [ -z "$(G3 status --porcelain 2>/dev/null)" ] && [ ! -f "$p3/.git/MERGE_HEAD" ]; then
  ok "Probe4 AC8 git merge --abort restores a clean tree with no in-progress merge"
else
  bad "Probe4 AC8 abort did not leave a clean tree (rc=$abort_rc)"
fi

# ---- Probe 5: a spent/deleted number is never reused by the allocation (AC5). ----
p4="$scratch/alloc"; mkdir -p "$p4"
G4() { git -C "$p4" -c user.email=t@t.t -c user.name=t "$@"; }
{
  git init -q -b main "$p4"
  mkdir -p "$p4/work/0001-base"; printf 'x\n' > "$p4/work/0001-base/spec.md"
  G4 add -A; G4 commit -qm base
  mkdir -p "$p4/work/0006-gone"; printf 'x\n' > "$p4/work/0006-gone/spec.md"
  G4 add -A; G4 commit -qm gone
  G4 rm -rq work/0006-gone; G4 commit -qm remove
} >/dev/null 2>&1
max_ever4="$(G4 log --all --name-only --pretty=format: -- work/ 2>/dev/null \
  | sed -n 's#^work/\([0-9][0-9][0-9][0-9]\)-.*#\1#p' | sort -u | tail -1)"
next4="$(printf '%04d' $((10#$max_ever4 + 1)))"
if [ "$next4" = "0007" ]; then
  ok "Probe5 AC5 a deleted number (0006) is spent and the next free number is 0007"
else
  bad "Probe5 AC5 deleted-number allocation wrong (max=$max_ever4 next=$next4)"
fi

# ---- Probe 6: an up-to-date branch and an empty work/ tree are no-ops (AC11). ----
p5="$scratch/uptodate"; mkdir -p "$p5"
G5() { git -C "$p5" -c user.email=t@t.t -c user.name=t "$@"; }
{
  git init -q -b main "$p5"
  printf 'one\n' > "$p5/f.txt"; G5 add f.txt; G5 commit -qm one
  G5 checkout -qb item
  printf 'two\n' > "$p5/g.txt"; G5 add g.txt; G5 commit -qm two
} >/dev/null 2>&1
base_eq="$(G5 merge-base HEAD main 2>/dev/null)"
main_sha="$(G5 rev-parse main 2>/dev/null)"
head_before="$(G5 rev-parse HEAD 2>/dev/null)"
G5 merge --no-edit main >/dev/null 2>&1; noop_rc=$?
head_after="$(G5 rev-parse HEAD 2>/dev/null)"
if [ "$base_eq" = "$main_sha" ] && [ "$noop_rc" -eq 0 ] && [ "$head_before" = "$head_after" ]; then
  ok "Probe6 AC11 an up-to-date merge-forward is a no-op (no new commit, no error)"
else
  bad "Probe6 AC11 up-to-date merge was not a no-op (rc=$noop_rc)"
fi
# Empty work/ tree: no directories -> no prefix collision.
empty_dups="$(ls "$p5/work" 2>/dev/null | sed 's/-.*//' | sort | uniq -d)"
if [ -z "$empty_dups" ]; then
  ok "Probe6 EDGE an empty/absent work/ tree has no prefix collision (no-op)"
else
  bad "Probe6 EDGE empty work/ tree reported a collision"
fi

# ---- Probe 7: per-parent MMMM cross-branch collision, the per-parent allocation,
#      and the child-reference sweep (Children Local id/Canonical reference plus a
#      dependent's Depends on cell) resolved by the graph re-check
#      (AC4 per-parent, AC5 per-parent allocation, AC6 child references, AC3). ----
p6="$scratch/childcollision"; mkdir -p "$p6"
G6() { git -C "$p6" -c user.email=t@t.t -c user.name=t "$@"; }
rm6="$p6/work/0001-road/roadmap.md"
{
  git init -q -b main "$p6"
  mkdir -p "$p6/work/0001-road/0001-a"
  printf 'feature: 0001-road\nphase: roadmap\n\n## Children\n\n| Local id | Title | Scope | Depends on | Canonical reference |\n| --- | --- | --- | --- | --- |\n| 0001-a | A | scope | — | 0001-road/0001-a |\n' > "$rm6"
  G6 add -A; G6 commit -qm base
  G6 checkout -qb item
  mkdir -p "$p6/work/0001-road/0002-b"
  printf 'feature: 0001-road/0002-b\n' > "$p6/work/0001-road/0002-b/spec.md"
  printf '| 0002-b | B | scope | 0001-a | 0001-road/0002-b |\n' >> "$rm6"
  G6 add -A; GIT_AUTHOR_DATE='2026-01-02T00:00:00' GIT_COMMITTER_DATE='2026-01-02T00:00:00' G6 commit -qm b
  G6 checkout -q main
  mkdir -p "$p6/work/0001-road/0002-c" "$p6/work/0001-road/0004-d"
  printf 'feature: 0001-road/0002-c\n' > "$p6/work/0001-road/0002-c/spec.md"
  printf 'feature: 0001-road/0004-d\n' > "$p6/work/0001-road/0004-d/spec.md"
  printf '| 0002-c | C | scope | 0001-a | 0001-road/0002-c |\n' >> "$rm6"
  printf '| 0004-d | D | scope | 0002-c | 0001-road/0004-d |\n' >> "$rm6"
  G6 add -A; GIT_AUTHOR_DATE='2026-01-03T00:00:00' GIT_COMMITTER_DATE='2026-01-03T00:00:00' G6 commit -qm c
  G6 checkout -q item
} >/dev/null 2>&1
# Cross-branch per-parent collision: local 0002-b vs default branch 0002-c.
local_children="$(ls "$p6/work/0001-road" 2>/dev/null)"
main_children="$(G6 ls-tree --name-only main:work/0001-road 2>/dev/null)"
dup_child=""
for n in $local_children; do
  p="${n%%-*}"
  for m in $main_children; do
    if [ "${m%%-*}" = "$p" ] && [ "$n" != "$m" ]; then dup_child="$p"; fi
  done
done
if [ "$dup_child" = "0002" ]; then
  ok "Probe7 AC4 per-parent MMMM cross-branch collision detected (0002)"
else
  bad "Probe7 AC4 per-parent collision not detected (local='$local_children' main='$main_children')"
fi
G6 merge --no-edit main >/dev/null 2>&1
# Per-parent allocation from the parent's own ever-committed history: max 0004 -> 0005.
max_child="$(G6 log --all --name-only --pretty=format: -- work/0001-road/ 2>/dev/null \
  | sed -n 's#^work/0001-road/\([0-9][0-9][0-9][0-9]\)-.*#\1#p' | sort -u | tail -1)"
next_child="$(printf '%04d' $((10#$max_child + 1)))"
if [ "$next_child" = "0005" ]; then
  ok "Probe7 AC5 per-parent MMMM allocation picks 0005 (max ever $max_child)"
else
  bad "Probe7 AC5 per-parent allocation wrong (max=$max_child next=$next_child)"
fi
# Choose the later-added 0002-c (main, 2026-01-03 > item 2026-01-02); git mv + sweep.
G6 mv work/0001-road/0002-c "work/0001-road/${next_child}-c" >/dev/null 2>&1
grep -rl '0002-c' "$p6/work/0001-road" 2>/dev/null | while IFS= read -r f; do
  sed -i "s#0002-c#${next_child}-c#g" "$f"
done
if grep -rq '0002-c' "$p6/work/0001-road" 2>/dev/null; then
  bad "Probe7 AC6 old child reference 0002-c remains after the sweep"
else
  ok "Probe7 AC6 no reference to the old child reference remains"
fi
if grep -qF "| ${next_child}-c | C | scope | 0001-a | 0001-road/${next_child}-c |" "$rm6"; then
  ok "Probe7 AC6 Children Local id and Canonical reference updated for the renumbered row"
else
  bad "Probe7 AC6 Children row not updated for the renumbered child"
fi
if grep -qF "| 0004-d | D | scope | ${next_child}-c |" "$rm6"; then
  ok "Probe7 AC6 the dependent Depends on cell was updated to the new local id"
else
  bad "Probe7 AC6 dependent Depends on cell not updated"
fi
if grep -qF "feature: 0001-road/${next_child}-c" "$p6/work/0001-road/${next_child}-c/spec.md" 2>/dev/null; then
  ok "Probe7 AC6 the moved child's feature frontmatter was updated"
else
  bad "Probe7 AC6 the moved child's feature frontmatter was not updated"
fi
post_child_dups="$(ls "$p6/work/0001-road" 2>/dev/null | grep -E '^[0-9]{4}-' | sed 's/-.*//' | sort | uniq -d)"
if [ -z "$post_child_dups" ]; then
  ok "Probe7 AC5 no duplicate per-parent prefix remains after the renumber"
else
  bad "Probe7 AC5 duplicate per-parent prefix remains: $post_child_dups"
fi
if graph_faults "$rm6" "$p6/work/0001-road" >/dev/null 2>&1; then
  ok "Probe7 AC3 graph re-check passes after the child renumber sweep"
else
  bad "Probe7 AC3 graph left dangling/cyclic after the child renumber sweep"
fi

[ -n "$scratch" ] && rm -rf "$scratch"

# ===========================================================================
printf '\nTOTAL: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
