#!/usr/bin/env bash
#
# Executable evidence for work/0006-parallel-plan-conflicts/0002-plan-record
# (pre-development plan publication and the declared conflict record).
#
# Read-only against the repository. The deliverable is documents and prompts only:
# there is no runtime code and no unit harness, so the automatable criteria
# (AC1-AC13) and every spec edge case are encoded as content assertions over the
# ten changed surfaces:
#
#   docs/workflow.md                              -> authority: declaration home + ## Plan publication (T1, T5)
#   docs/artifact-conventions.md                  -> frontmatter rule + design.md template (T2)
#   .opencode/agent/architect.md                  -> author the declaration at /plan (T3)
#   .opencode/command/plan.md                     -> /plan declaration + publication handoff (T4)
#   .opencode/agent/shipper.md                    -> /ship plan mode (T6)
#   .opencode/command/ship.md                     -> /ship plan mode + grammar (T6)
#   .opencode/skill/pr-workflow/SKILL.md          -> plan PR template (T7)
#   .opencode/skill/conventional-commits/SKILL.md -> plan/<ref> branch prefix (T8)
#   .opencode/agent/builder.md                    -> /build plan gate (T9)
#   .opencode/command/build.md                    -> /build plan gate (T9)
#
# plus structural/regression invariants (AC6/AC8/AC10/AC13): the readiness
# algorithm and derived-state table are unchanged; the `Design conflicts`
# grammar stays single-sourced in docs/workflow.md; no committed tests/ file
# changed; and the change touches exactly the ten design-named surfaces.
#
# This is deliberately NOT a tests/checks/ agreement area or a mutation case: the
# spec's non-goals and the design's test strategy defer committed fixture-based
# guards to sibling 0004-conflict-guards. This item suite is the same item-level
# evidence pattern as work/0006-parallel-plan-conflicts/0001-conflict-declaration-model
# and work/0005-merge-conflict-workflow/0001-conflict-model.
#
# Usage: bash work/0006-parallel-plan-conflicts/0002-plan-record/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures, 2 = setup error.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

WF="docs/workflow.md"
CONV="docs/artifact-conventions.md"
ARCH=".opencode/agent/architect.md"
PLAN=".opencode/command/plan.md"
SHIP=".opencode/agent/shipper.md"
SHIPCMD=".opencode/command/ship.md"
PRS=".opencode/skill/pr-workflow/SKILL.md"
CCS=".opencode/skill/conventional-commits/SKILL.md"
BUILD=".opencode/agent/builder.md"
BUILDCMD=".opencode/command/build.md"

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
# absentflat: negative control after whitespace collapsing.
absentflat(){ if flat "$1" | grep -qF -- "$2"; then bad "$3 (found forbidden '$2' in $1)"; else ok "$3"; fi; }

# section: print the body of a `## <title>` section, stopping at the next `##`.
section() { awk -v h="$2" '$0 ~ "^## " h "[ \t]*$" { f=1; next } f && /^## / { f=0 } f' "$1"; }
# subsection: body of a `### <title>` subsection, stopping at the next `###`/`##`.
subsection() { awk -v h="$2" '$0 ~ "^### " h "[ \t]*$" { f=1; next } f && /^###? / { f=0 } f' "$1"; }

BRANCH_EXAMPLE='plan/0006-parallel-plan-conflicts-0002-plan-record'

# ===========================================================================
echo "== AC1: dedicated plan branch + pull request =="
# ===========================================================================
need "$WF" '## Plan publication' "AC1 authority section exists"
needflat "$WF" 'Publication is a **mode of `/ship`** — `/ship plan <item-ref>` — performed by the shipper, the only agent that writes git' "AC1 publication is a shipper-run /ship plan mode"
needflat "$WF" 'A dedicated `plan/<ref>` branch, where `<ref>` is the canonical reference with `/` replaced by `-`' "AC1 dedicated plan/<ref> branch"
needflat "$WF" 'committed as one conventional commit and pushed; a pull request is opened with the plan description template' "AC1 commit + PR opened"
needflat "$SHIP" 'Create or switch to the dedicated `plan/<ref>` branch' "AC1 shipper creates the dedicated plan branch"
needflat "$SHIPCMD" 'Create or switch to a dedicated `plan/<ref>` branch' "AC1 ship command creates the dedicated plan branch"
needflat "$CCS" 'uses a dedicated `plan/<ref>` branch' "AC1 conventional-commits names the plan branch prefix"
need "$WF" "$BRANCH_EXAMPLE" "AC1 branch-name example present in authority"
# No new command is introduced (decision: a mode of /ship, not a new command).
if grep -rIl --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules '/publish\b' docs .opencode/agent .opencode/command .opencode/skill >/dev/null 2>&1; then
  bad "AC1 a new /publish command was introduced"
else
  ok "AC1 no new publication command is introduced"
fi

# ===========================================================================
echo "== AC2: /build gate refuses while the plan is unmerged =="
# ===========================================================================
need "$WF" '### The `/build` plan gate' "AC2 gate subsection exists"
need "$WF" 'plan_gate(item_ref):' "AC2 gate algorithm present"
needflat "$WF" 'remote_plan = git ls-remote --heads origin plan/<ref> returns a ref' "AC2 gate probes the remote plan branch"
needE "$WF" 'REFUSE' "AC2 gate has a REFUSE outcome"
needflat "$WF" 'An unmerged `plan/<ref>` branch (case 2) refuses development: the builder stops before implementing and reports the plan branch or pull request that must be merged first' "AC2 unmerged plan refuses development"
needflat "$WF" 'the builder runs an offline-first, git-only gate — it requires no `gh` and never hard-fails' "AC2 gate is offline-first and git-only"
needflat "$BUILD" 'Plan gate: before selecting a task, run the `/build` plan gate in `docs/workflow.md` → "Plan publication"' "AC2 builder runs the gate from the authority"
needflat "$BUILD" 'refuse and report the plan pull request that must be merged first; do not implement' "AC2 builder refuses on unmerged plan"
needflat "$BUILDCMD" 'refuse and report the plan pull request that must be merged first' "AC2 build command refuses on unmerged plan"
# Step 0 refreshes refs best-effort, so a plan merged since the last fetch is not
# mistaken for an unmerged plan when a merged `plan/<ref>` branch is retained,
# and a later revision is not hidden behind a stale remote-tracking ref
# (reviewer M1). Without the plan-branch refresh the gate under-blocks a
# revision; the default-branch refresh alone cannot see it.
need "$WF" '# 0. Refresh refs best-effort (an offline fetch is ignored)' "AC2 gate step 0 refreshes refs best-effort"
needflat "$WF" 'if origin exists: git fetch origin <default>' "AC2 gate runs a best-effort fetch of the default branch"
needflat "$WF" 'if remote_plan: git fetch origin plan/<ref>' "AC2 gate fetches the plan branch when the remote advertises it"
needflat "$WF" 'Step 0 refreshes refs best-effort before the default-branch check: it fetches `origin/<default>`, and the `plan/<ref>` branch too when the remote advertises one' "AC2 authority explains the default + plan refresh precedes the published check"
needflat "$WF" 'a plan merged since the last fetch is seen even when the local `plan/<ref>` branch was retained and a later revision is not hidden by a stale remote-tracking ref' "AC2 refresh neutralizes a retained merged plan branch and a stale revision"
needflat "$WF" 'The refresh is ignored when `origin` is unreachable' "AC2 offline refresh is ignored, never fatal"
needflat "$BUILD" 'Refresh refs best-effort first — `git fetch origin <default>`, and, when the remote advertises one, the `plan/<ref>` branch too (an offline fetch ignored)' "AC2 builder refreshes the default and plan refs before the gate"
needflat "$BUILDCMD" 'refresh refs best-effort first — `git fetch origin <default>`, and, when the remote advertises one, the `plan/<ref>` branch too (an offline fetch ignored)' "AC2 build command refreshes the default and plan refs before the gate"
# The gate is content-aware: a plan branch whose plan artifacts differ from the
# default branch is an unmerged first publication OR a later revision and must be
# refused, while a retained branch already matching the default branch is not.
# Without this, a revised plan's open PR would not block /build once any
# design.md was on the default branch (reviewer M1: AC2/AC11).
need "$WF" 'unmerged_plan = false' "AC2 gate initializes the unmerged-plan flag"
need "$WF" 'plan_ref = "origin/plan/<ref>"' "AC2 gate prefers the remote plan branch"
need "$WF" 'plan_ref = "plan/<ref>"' "AC2 gate falls back to a local plan branch"
need "$WF" 'unmerged_plan = git diff --quiet <plan_ref> <default_ref> -- work/<item_ref>/ is false' "AC2 gate content-diffs the plan branch against the default branch"
needflat "$WF" 'if <default_ref> has work/<item_ref>/design.md and not unmerged_plan and not unresolved_plan -> PROCEED' "AC2 published check is gated on the plan not being unmerged or unresolvable"
needflat "$WF" 'a differing plan branch is not yet published' "AC2 gate comment distinguishes a differing branch from published"
# A plan branch the remote advertises but that does not resolve locally cannot be
# compared; the gate refuses rather than guess (reviewer M1). Without this, a
# failed fetch could be read as a match (under-block) or a diff (over-block).
need "$WF" 'unresolved_plan = false' "AC2 gate initializes the unresolved-plan flag"
need "$WF" 'unresolved_plan = true' "AC2 gate flags an unresolvable advertised plan branch"
needflat "$WF" 'if plan_ref is not none or unresolved_plan -> REFUSE' "AC2 refusal covers an unmerged or unresolvable plan branch"
needflat "$WF" 'cannot be compared, so the gate refuses rather than read it as matching or differing' "AC2 authority explains the unresolvable-ref fallback"
needflat "$BUILD" 'A plan branch the remote advertises but that has no resolvable local ref cannot be compared; refuse rather than guess' "AC2 builder refuses an unresolvable advertised plan branch"
needflat "$BUILDCMD" 'A plan branch the remote advertises but that has no resolvable local ref cannot be compared; refuse rather than guess' "AC2 build command refuses an unresolvable advertised plan branch"
needflat "$WF" 'Case 2 is content-aware, not mere branch existence' "AC2 refusal is content-aware, not branch-existence"
needflat "$WF" 'a `plan/<ref>` branch whose plan artifacts differ from the default branch — a first publication **or a later revision** — refuses development' "AC2 an unmerged revision refuses development"
needflat "$WF" 'An unmerged revision therefore blocks development even after the first plan merged.' "AC2 revision blocks development after a first plan merged"
needflat "$BUILD" 'carries plan artifacts that differ from the default branch (an unmerged publication or a later revision), refuse' "AC2 builder refuses a differing plan branch (unmerged/revision)"
needflat "$BUILDCMD" 'carries plan artifacts that differ from the default branch (an unmerged publication or a later revision), refuse' "AC2 build command refuses a differing plan branch (unmerged/revision)"
# The builder only reads git state for the gate (no git write instruction).
absent "$BUILD" 'git commit' "AC2 builder prompt issues no git commit"
absent "$BUILD" 'gh pr create' "AC2 builder prompt opens no PR"

# ===========================================================================
echo "== AC3: a merged plan is public on the default branch =="
# ===========================================================================
needflat "$WF" 'published to the shared default branch before development begins so other maintainers can cross-reference intended surfaces before any code exists' "AC3 plan is published to the shared default branch"
needflat "$WF" 'The PR links the plan artifacts by repository path and prints the item'"'"'s declared conflicts, or `—`.' "AC3 PR links artifacts and prints declared conflicts"
need "$PRS" '## Plan PR description template' "AC3 plan PR template exists"
need "$PRS" '- Spec: `work/<item-ref>/spec.md`' "AC3 template links spec by repository path"
need "$PRS" '- Design: `work/<item-ref>/design.md`' "AC3 template links design by repository path"
need "$PRS" '- Tasks: `work/<item-ref>/tasks.md`' "AC3 template links tasks by repository path"
# The plan PR template must carry the declaration and a testing note, so a
# maintainer cross-referencing the plan sees its declared conflicts in the PR.
need "$PRS" '## Declared conflicts' "AC3 template has a Declared conflicts section"
need "$PRS" 'plan-only; no code changed' "AC3 template's Testing section names the plan-only case"
needflat "$SHIP" 'This publishes the item'"'"'s plan to the shared default branch so other maintainers can cross-reference it before any code exists.' "AC3 shipper publishes the plan"

# ===========================================================================
echo "== AC4: declaration authored at /plan, stored in design.md frontmatter =="
# ===========================================================================
need "$CONV" '- `conflicts-with` is optional and appears only on `design.md`; it holds one' "AC4 frontmatter rule names design.md as the only home"
needE "$CONV" '^conflicts-with:' "AC4 design.md template shows the conflicts-with field"
needflat "$CONV" '`ConflictTargetList` declaring the item'"'"'s intended conflict targets' "AC4 field holds one ConflictTargetList"
needflat "$ARCH" 'Author the item'"'"'s declaration as the `conflicts-with` value in `design.md` frontmatter' "AC4 architect authors the declaration at /plan"
needflat "$PLAN" 'Author the plan'"'"'s declared conflict targets as the `conflicts-with` value in `design.md` frontmatter' "AC4 /plan command authors the declaration"
needflat "$WF" 'A child or standalone item'"'"'s own declaration is stored in its `design.md` frontmatter `conflicts-with` value' "AC4 authority states the declaration home"

# ===========================================================================
echo "== AC5: shipped 0001 grammar reused, not forked =="
# ===========================================================================
prod_count="$(grep -rIl --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules 'ConflictTargetList ::=' . 2>/dev/null | wc -l | tr -d ' ')"
if [ "$prod_count" = "1" ] && grep -qF 'ConflictTargetList ::=' "$WF"; then
  ok "AC5 grammar production is stated exactly once, in docs/workflow.md"
else
  bad "AC5 grammar production is not single-sourced (count=$prod_count)"
fi
needflat "$WF" 'the field is optional and holds one `ConflictTargetList`, the grammar defined below' "AC5 field references the shipped ConflictTargetList grammar"
needflat "$CONV" 'The grammar is defined in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)".' "AC5 artifact-conventions points to the grammar authority"
needflat "$ARCH" 'Choose targets using the grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC5 architect references the grammar authority"
needflat "$PLAN" 'using the grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC5 plan command references the grammar authority"
needflat "$SHIP" 'its `design.md` frontmatter `conflicts-with` value per `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC5 shipper references the grammar authority"
needflat "$SHIPCMD" 'its `design.md` frontmatter `conflicts-with` value per `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC5 ship command references the grammar authority"
needflat "$PRS" 'the grammar is the single authority in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC5 plan PR template references the grammar authority"
for f in "$CONV" "$ARCH" "$PLAN" "$SHIP" "$SHIPCMD" "$PRS"; do
  absent "$f" 'ConflictTargetList ::=' "AC5 $f does not restate the grammar"
done

# ===========================================================================
echo "== AC6: absence or — means none; no container; no migration =="
# ===========================================================================
needflat "$WF" 'Absence of the field or a `—` value means no declared conflicts, and no separate container or artifact is required.' "AC6 absence/— means none and needs no container"
needflat "$CONV" 'Absent or `—` means no declared conflicts, and the declaration is advisory' "AC6 artifact-conventions states absence/— = none"
needflat "$WF" 'is not blocked and needs no migration' "AC6 no migration for historical items"
needflat "$ARCH" 'default `—` when the plan declares none' "AC6 architect defaults to —"
needflat "$PLAN" '(`—` when the plan declares none)' "AC6 plan command defaults to —"

# ===========================================================================
echo "== AC7: child value ∪ parent Children cell; mismatch reported =="
# ===========================================================================
needflat "$WF" 'A roadmap child'"'"'s declared set is the **union** of that `design.md` value and its parent `Children` row'"'"'s `conflicts-with` cell' "AC7 declared set is the union"
needflat "$WF" 'when the two disagree, the later read-only check reports the disagreement rather than silently preferring one' "AC7 disagreement is reported, not silently resolved"
need "$CONV" '| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |' "AC7 parent Children column is untouched"

# ===========================================================================
echo "== AC8: advisory; readiness/derived state unchanged =="
# ===========================================================================
needflat "$WF" "The declaration is advisory: it adds no readiness edge, reorders no child, and changes no child's readiness." "AC8 authority states advisory + no readiness change"
needflat "$WF" "The declaration remains advisory throughout: it adds no readiness edge, reorders no child, and changes no child's readiness." "AC8 plan-publication repeats the advisory rule"
READY="$(subsection "$WF" 'Dependencies and readiness')"
if printf '%s' "$READY" | grep -qF 'satisfied(dep_local_id)'; then ok "AC8 readiness algorithm satisfied(dep_local_id) intact"; else bad "AC8 readiness algorithm missing satisfied(dep_local_id)"; fi
if printf '%s' "$READY" | grep -qF 'ready(child)'; then ok "AC8 readiness algorithm ready(child) intact"; else bad "AC8 readiness algorithm missing ready(child)"; fi
if printf '%s' "$READY" | grep -qF 'blocked_by(child)'; then ok "AC8 readiness algorithm blocked_by(child) intact"; else bad "AC8 readiness algorithm missing blocked_by(child)"; fi
if printf '%s' "$READY" | grep -qF 'conflicts-with'; then bad "AC8 readiness section gained a conflicts-with input"; else ok "AC8 readiness section has no conflicts-with input"; fi
# Derived-state table unchanged: no plan phase row.
DS="$(section "$WF" 'Derived state')"
if printf '%s' "$DS" | grep -qE '\|[[:space:]]*plan[[:space:]]*\|'; then bad "AC8 derived-state table gained a plan row"; else ok "AC8 derived-state table has no plan row"; fi
need "$CONV" 'phase: spec                   # spec | design | roadmap | tasks | test | visual | review | ship' "AC8 frontmatter phase vocabulary unchanged (no plan phase)"
needflat "$WF" 'process step, not a lifecycle phase: it adds no artifact, no `phase` value, and no derived-state row' "AC8 publication is not a phase and adds no state"

# ===========================================================================
echo "== AC9: shipper-only git writes, on explicit invocation =="
# ===========================================================================
needflat "$WF" 'performed by the shipper, the only agent that writes git' "AC9 authority attributes plan publication to the shipper only"
needflat "$SHIP" 'The user explicitly invoked `/ship plan <item-ref>`. That request is the consent to commit and push; without it, perform no git write.' "AC9 explicit invocation is the consent to write git"
needflat "$SHIP" 'the shipper neither approves nor merges' "AC9 shipper does not approve or merge"
needflat "$SHIPCMD" 'The shipper neither approves nor merges' "AC9 ship command states the shipper does not merge"
# Architect/plan prompts hand off to /ship; they carry no git write instruction.
absent "$ARCH" 'git commit' "AC9 architect issues no git commit"
absent "$ARCH" 'git push' "AC9 architect issues no git push"
absent "$ARCH" 'gh pr create' "AC9 architect opens no PR"
absent "$PLAN" 'git commit' "AC9 plan command issues no git commit"
absent "$PLAN" 'git push' "AC9 plan command issues no git push"
absent "$PLAN" 'gh pr create' "AC9 plan command opens no PR"

# ===========================================================================
echo "== AC10: historical / pre-flow items proceed, no migration =="
# ===========================================================================
needflat "$WF" 'No publication recorded (historical / pre-flow item)' "AC10 gate recognises no publication recorded"
need "$WF" 'PROCEED (note it)' "AC10 gate proceeds with a note"
needflat "$BUILD" 'If neither exists, proceed and note that no plan publication was found (historical/pre-flow item)' "AC10 builder proceeds and notes"
needflat "$BUILDCMD" 'proceed and note that no plan publication was found (historical/pre-flow item)' "AC10 build command proceeds and notes"
needflat "$WF" 'An unreachable `origin` degrades to the best-effort result and never hard-fails the build.' "AC10 unreachable origin never hard-fails"

# ===========================================================================
echo "== AC11: a revised plan is republished =="
# ===========================================================================
needflat "$WF" 'When a later `/plan` revision changes the intended surfaces or declared targets, it is republished through the same flow' "AC11 authority states revision is republished"
needflat "$WF" 'a commit is added to the existing `plan/<ref>` branch and its pull request updated' "AC11 revision reuses the plan branch/PR"
needflat "$SHIP" 'Revision: when a later `/plan` revision changes the intended surfaces or declared targets, add a commit to the existing `plan/<ref>` branch' "AC11 shipper revision rule"
needflat "$SHIP" 'Never force-push a pushed branch.' "AC11 revision never force-pushes"
needflat "$PLAN" '/ship plan <item-ref>' "AC11 /plan hands off to publication"
needflat "$ARCH" 'Next: `/ship plan <item-ref>` — publish the plan; development begins after it merges.' "AC11 architect handoff republishes before development"

# ===========================================================================
echo "== AC12: malformed/unresolved is reported, never auto-repaired =="
# ===========================================================================
needflat "$WF" 'A malformed or unresolved item value is likewise reported by the later check, never dropped or auto-repaired.' "AC12 unresolved item value reported, never dropped"
needflat "$WF" 'It is reported by a later read-only check and never silently dropped or auto-repaired.' "AC12 grammar unresolved rule intact"
needflat "$WF" 'a target that resolves to no sibling row, no `work/<ref>/` directory, and no existing path, is an **unresolved declaration**' "AC12 unresolved definition intact"

# ===========================================================================
echo "== AC13: cross-surface consistency; no second taxonomy/artifact =="
# ===========================================================================
# Branch-name example agrees across the authority, prompts, command, and skill.
for f in "$WF" "$SHIP" "$SHIPCMD" "$CCS"; do
  need "$f" "$BRANCH_EXAMPLE" "AC13 $f uses the same branch-name example"
done
# Every declaration surface points at the single authority and none restates it
# (the negative controls are in AC5). Here assert the authority reference is
# present on each owning surface.
needflat "$ARCH" 'docs/workflow.md' "AC13 architect references the authority"
needflat "$PLAN" 'docs/workflow.md' "AC13 plan command references the authority"
needflat "$SHIP" 'docs/workflow.md' "AC13 shipper references the authority"
needflat "$SHIPCMD" 'docs/workflow.md' "AC13 ship command references the authority"
needflat "$CONV" 'docs/workflow.md' "AC13 artifact-conventions references the authority"
needflat "$PRS" 'docs/workflow.md' "AC13 pr-workflow references the authority"
# No new artifact or phase value is introduced anywhere in the live docs/prompts.
if grep -rIn --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules 'phase: plan\b' docs .opencode/agent .opencode/command .opencode/skill >/dev/null 2>&1; then
  bad "AC13 a new phase: plan value was introduced"
else
  ok "AC13 no new phase: plan value is introduced"
fi
needflat "$WF" 'adds no artifact, no `phase` value, and no derived-state row' "AC13 authority states no new artifact/phase/state"
# The plan PR template omits the merge-time-only sections.
needflat "$PRS" 'It omits the ship-time `## Conflict detection` and `## Reconcile` sections' "AC13 plan template omits merge-time sections"
# The publication flow's safeguards are described across the authority, the
# shipper, and the ship command: at least one human approval before merge, and no
# shipped state (ship.md stays the sole shipped signal, so plan mode cannot mark
# the item shipped). A surface dropping either would make the flow inconsistent.
needflat "$WF" 'At least one human approval is required before the plan pull request is merged' "AC13 authority states the human-approval precondition"
needflat "$SHIP" 'At least one human approval is required before the plan PR is merged' "AC13 shipper states the human-approval precondition"
needflat "$SHIPCMD" 'At least one human approval is required before the plan PR is merged' "AC13 ship command states the human-approval precondition"
needflat "$WF" 'Plan mode never writes `ship.md`, never runs the ship pre-flight or reconcile, and never creates the final ship branch or pull request' "AC13 authority plan mode writes no shipped state"
needflat "$SHIP" 'it never writes `ship.md`, never runs the ship pre-flight or reconcile, and never creates the final ship branch' "AC13 shipper plan mode writes no shipped state"
needflat "$SHIPCMD" 'Never write `ship.md`, never run the ship pre-flight or reconcile, and never create the final ship branch' "AC13 ship command plan mode writes no shipped state"
# Negative control: the new section introduces no new conflict class or finding code.
PUB="$(section "$WF" 'Plan publication')"
if printf '%s' "$PUB" | grep -qE '\(e\)|DECLARED-|PLAN-CONFLICT|CONFLICT-[A-Z]'; then
  bad "AC13 plan-publication section introduces a new class/finding code"
else
  ok "AC13 plan-publication section introduces no new conflict taxonomy"
fi

# ===========================================================================
echo "== Spec edge cases =="
# ===========================================================================
needflat "$WF" 'an empty or whitespace-only cell is malformed, not equivalent to `—`' "EDGE empty/whitespace-only declaration is malformed"
needflat "$CONV" 'Absent or `—` means no declared conflicts' "EDGE absent declaration reads as none"
needflat "$WF" 'the field is optional' "EDGE the field is optional"
needflat "$WF" '`work/<item-ref>/spec.md` and `design.md` exist (the item has completed `/plan`; `tasks.md` is included when present)' "EDGE plan not ready: spec+design preconditions"
needflat "$WF" 'Re-invoking publication when the plan is already on the default branch and unchanged is a no-op: it reports that and creates nothing.' "EDGE already-merged plan is a no-op"
needflat "$SHIP" 'Idempotence: re-invoking publication when the plan is already on the default branch and unchanged is a no-op' "EDGE shipper idempotence rule"
needflat "$WF" 'A plan present on the default branch proceeds even if a merged `plan/<ref>` branch is retained' "EDGE retained merged plan branch is not a block"
needflat "$WF" 'Each item gets its own branch, so concurrent publications do not overwrite one another' "EDGE concurrent publications are independent"
needflat "$CCS" 'never reuse the plan branch for the ship' "EDGE plan branch is distinct from the ship branch"
needflat "$ARCH" 'with no self-reference and no duplicate target' "EDGE no self-reference and no duplicate target"
needflat "$WF" 'A reference may not name the declaring row' "EDGE self-reference rule intact"
needflat "$WF" 'a list may not repeat a target' "EDGE duplicate-target rule intact"
needflat "$CCS" 'A roadmap child keeps its joined reference' "EDGE nested child branch reference documented"
needflat "$WF" 'The plan diff contains no secrets.' "EDGE plan diff scanned for secrets"
needflat "$SHIP" 'The plan diff contains no secrets.' "EDGE shipper scans the plan diff for secrets"
needflat "$WF" 'A child or standalone item'"'"'s own declaration is stored in its `design.md` frontmatter' "EDGE roadmap parent (not a child/standalone) authors no design.md declaration"

# ===========================================================================
echo "== Structural / regression invariants =="
# ===========================================================================
# Scope: exactly the ten design-named surfaces are modified (tracked diff).
EXPECTED="$(printf '%s\n' \
  '.opencode/agent/architect.md' \
  '.opencode/agent/builder.md' \
  '.opencode/agent/shipper.md' \
  '.opencode/command/build.md' \
  '.opencode/command/plan.md' \
  '.opencode/command/ship.md' \
  '.opencode/skill/conventional-commits/SKILL.md' \
  '.opencode/skill/pr-workflow/SKILL.md' \
  'docs/artifact-conventions.md' \
  'docs/workflow.md' | sort)"
ACTUAL="$(git diff --name-only HEAD 2>/dev/null | sort)"
if [ "$EXPECTED" = "$ACTUAL" ]; then
  ok "STRUCT change touches exactly the ten design-named surfaces"
else
  bad "STRUCT modified surfaces differ from design: $(printf '%s' "$ACTUAL" | tr '\n' ' ')"
fi
# No committed tests/ file changed (guards are sibling 0004-conflict-guards).
if [ -z "$(git status --porcelain -- tests/ 2>/dev/null)" ]; then ok "STRUCT no committed tests/ file modified"; else bad "STRUCT tests/ has uncommitted changes"; fi
if [ -z "$(git diff --name-only HEAD -- tests/ 2>/dev/null)" ]; then ok "STRUCT tests/ diff against HEAD is empty"; else bad "STRUCT tests/ differs from HEAD"; fi
# Entry criteria: all tasks checked; item artifacts carry the right refs.
if grep -qE '^- \[ \]' work/0006-parallel-plan-conflicts/0002-plan-record/tasks.md; then
  bad "STRUCT tasks.md has unchecked items"
else
  ok "STRUCT tasks.md has no unchecked items"
fi
need 'work/0006-parallel-plan-conflicts/0002-plan-record/spec.md' 'feature: 0006-parallel-plan-conflicts/0002-plan-record' "STRUCT spec.md feature ref"
need 'work/0006-parallel-plan-conflicts/0002-plan-record/design.md' 'feature: 0006-parallel-plan-conflicts/0002-plan-record' "STRUCT design.md feature ref"
need 'work/0006-parallel-plan-conflicts/0002-plan-record/tasks.md' 'feature: 0006-parallel-plan-conflicts/0002-plan-record' "STRUCT tasks.md feature ref"

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
