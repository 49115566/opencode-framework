#!/usr/bin/env bash
#
# Executable evidence for work/0006-parallel-plan-conflicts/0003-conflict-check
# (pre-development parallel-plan conflict check).
#
# Read-only against the repository. The deliverable is documents and prompts only
# (no runtime code, no committed checker), so the automatable criteria AC1-AC16
# and every spec edge case are encoded as content assertions over the changed
# surfaces:
#
#   docs/workflow.md                              -> authority: ## Declared-conflict
#                                                    check + routing bullet (T1)
#   .opencode/skill/merge-conflict/SKILL.md       -> planning-time finding meanings (T2)
#   .opencode/agent/status.md                     -> reporting owner (T3)
#   .opencode/command/status.md                   -> /status window (T3)
#   .opencode/agent/builder.md                    -> /build gate surfacing (T4)
#   .opencode/command/build.md                    -> /build gate surfacing (T4)
#   .opencode/command/conflicts.md                -> new read-only command (T5)
#   README.md / AGENTS.md / template/AGENTS.md    -> command inventories (T5)
#   .opencode/skill/workflow-lifecycle/SKILL.md   -> routing (T5)
#   tests/checks/96-signature-sweep.sh            -> signature registry (T5)
#
# This is deliberately NOT a tests/checks/ agreement area or a mutation case: the
# spec's non-goals and the design's test strategy defer committed fixture-based
# guards and mutation coverage to sibling 0004-conflict-guards, and the authority
# states the check is prompt behavior only with no committed checker. This item
# suite is the same item-level evidence pattern as sibling
# 0006-parallel-plan-conflicts/0001-conflict-declaration-model and
# 0006-parallel-plan-conflicts/0002-plan-record.
#
# Usage: bash work/0006-parallel-plan-conflicts/0003-conflict-check/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures, 2 = setup error.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

WF="docs/workflow.md"
SKILL=".opencode/skill/merge-conflict/SKILL.md"
STATUS=".opencode/agent/status.md"
STATUSCMD=".opencode/command/status.md"
BUILD=".opencode/agent/builder.md"
BUILDCMD=".opencode/command/build.md"
CONFLICTS=".opencode/command/conflicts.md"
ROUTING=".opencode/skill/workflow-lifecycle/SKILL.md"
README="README.md"
AGENTS="AGENTS.md"
TAGENTS="template/AGENTS.md"
SWEEP="tests/checks/96-signature-sweep.sh"
ITEM="work/0006-parallel-plan-conflicts/0003-conflict-check"

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
# section: body of a `## <title>` section, stopping at the next `##`.
section() { awk -v h="$2" '$0 ~ "^## " h "[ \t]*$" { f=1; next } f && /^## / { f=0 } f' "$1"; }
# subsection: body of a `### <title>` subsection, stopping at the next `###`/`##`.
subsection() { awk -v h="$2" '$0 ~ "^### " h "[ \t]*$" { f=1; next } f && /^###? / { f=0 } f' "$1"; }

# ===========================================================================
echo "== AC1: no-argument global read-only report; writes no file =="
# ===========================================================================
need "$WF" '## Declared-conflict check' "AC1 authority section exists"
needflat "$WF" 'With no argument it reports every declared conflict, unresolved declaration, and declaration discrepancy across the whole `work/` tree.' "AC1 authority states the no-argument global report"
needflat "$CONFLICTS" 'With no argument, report every declared conflict, unresolved declaration, and parent/item declaration discrepancy across the whole `work/` tree.' "AC1 command states the no-argument global report"
needflat "$CONFLICTS" 'This is read-only: do not edit any file.' "AC1 command is explicitly read-only"
needflat "$WF" 'The check is **advisory, offline, local, and read-only**. It performs no fetch, remote read, merge, or dry-run merge; it takes no lock; and it modifies no file.' "AC1 authority states read-only / no write"
# The reporting owner cannot write.
need "$STATUS" 'edit: deny' "AC1 status agent cannot edit a file"
# Negative control: the new command carries no git-write instruction.
absent "$CONFLICTS" 'git commit' "AC1 /conflicts issues no git commit"
absent "$CONFLICTS" 'git push' "AC1 /conflicts issues no git push"
absent "$CONFLICTS" 'gh pr' "AC1 /conflicts opens no PR"

# ===========================================================================
echo "== AC2: item-ref focus names each counterpart =="
# ===========================================================================
needflat "$WF" 'With an item-ref it reports only the findings that involve that item and names each counterpart.' "AC2 authority states the focused mode"
needflat "$CONFLICTS" 'With an item-ref, report only the findings that involve that item and name each counterpart.' "AC2 command states the focused mode"
needflat "$STATUS" 'When the user named an item, report only the findings that involve it and name each counterpart.' "AC2 status agent states the focused mode"
needflat "$WF" 'it blocks no phase and names each counterpart for a focused item' "AC2 routing bullet names counterparts"

# ===========================================================================
echo "== AC3: ship.md excludes; absence includes; shipped still resolves =="
# ===========================================================================
needflat "$WF" 'A child whose `work/<parent>/<local-id>/ship.md` exists is **excluded**; a child with no `ship.md` is included.' "AC3 child ship.md excludes, absence includes"
needflat "$WF" 'frontmatter `conflicts-with`. A `ship.md` excludes it.' "AC3 standalone ship.md excludes"
needflat "$WF" 'A **shipped** item still **resolves** as a target but is not a counterpart: naming it produces neither a conflict nor an unresolved finding.' "AC3 shipped item resolves but is not a counterpart"

# ===========================================================================
echo "== AC4: pair predicate (shared target or one-sided naming), once per pair =="
# ===========================================================================
need "$WF" '### The pair predicate' "AC4 pair-predicate subsection exists"
needflat "$WF" 'some target of `A` and some target of `B` are the same target' "AC4 shared-target clause"
needflat "$WF" "a target of \`A\` resolves to \`B\`'s canonical reference, or a target of \`B\` resolves to \`A\`'s. A one-sided declaration suffices; no reciprocity is required." "AC4 one-side-names-the-other clause; one-sided suffices"
needflat "$WF" 'The named item need not declare anything itself: an unshipped item with an empty declared set is still a counterpart under this clause, so a declaration that names it is reported even though that item contributes no target of its own.' "AC4 one-sided naming reports a silent unshipped counterpart"
# The core of the [B1] fix: the compared set is every unshipped item, not only
# the ones that themselves declare something, so a silent item can be a
# one-sided counterpart.
needflat "$WF" 'It considers every **unshipped item** under `work/`' "AC4 authority considers every unshipped item, not only declaring ones"
needflat "$WF" 'Two targets share identity when their trimmed repository-relative paths are equal (surface targets) or when both resolve to the same canonical item reference (reference targets).' "AC4 identity is by resolution, not literal token"
needflat "$WF" 'Equal trimmed tokens that resolve to *different* items — for example the same `MMMM-slug` in two different roadmaps — are **not** the same target.' "AC4 cross-roadmap same-token is not a shared target"
needflat "$WF" 'Each unordered pair is reported **once**: reciprocal naming, or a pair that both shares a target and names the other, yields exactly one finding.' "AC4 one finding per unordered pair"
# Every operative prompt that runs the check must not narrow the compared set to
# plans that themselves declare something: the authority's compared set is every
# unshipped item, and a silent unshipped item named by another plan is still a
# counterpart under the one-sided clause (AC4; consumed 0001 authority
# docs/workflow.md and 0001 spec AC5). [B1] first appeared in the status agent's
# prompt, so guard every surface that could reintroduce it.
for f in "$STATUS" "$SKILL" "$CONFLICTS" "$STATUSCMD" "$BUILD" "$BUILDCMD"; do
  absentflat "$f" 'unshipped plans with a non-empty declaration' "AC4 $f does not drop silent unshipped plans from the compared set"
done

# ===========================================================================
echo "== AC5: child declared set = own union parent cell; cell alone when no own =="
# ===========================================================================
need "$WF" '- The child'\''s declared set is `own ∪ cell`.' "AC5 child declared set is own union cell"
needflat "$WF" '`own` is the child'\''s `design.md` frontmatter `conflicts-with` (absent or `—` → empty); `cell` is the row'\''s `conflicts-with` cell (absent column or `—` → empty).' "AC5 own/cell definitions; absent/— -> empty, so cell alone is used"
needflat "$WF" 'Its `Children` table supplies each row'\''s declaration. A roadmap authored before the `conflicts-with` column existed has no column, treated as `—` for every row.' "AC5 parent cell is the row source; absent column is —"

# ===========================================================================
echo "== AC6: shipped grammar + (a)-(d) class; no new class or policy =="
# ===========================================================================
needflat "$WF" 'Findings use the shipped finding-line grammar `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` and a class label from the shipped `(a)`–`(d)` set' "AC6 authority renders in the shipped grammar"
needflat "$WF" 'no new class, code, or policy is introduced' "AC6 authority adds no new class/code/policy"
needflat "$WF" '| Two unshipped plans share a surface target outside `work/` | `TEXTUAL-CONFLICT` | `(a)` |' "AC6 shared surface -> TEXTUAL-CONFLICT (a)"
needflat "$WF" '| Two unshipped plans share a `work/` path or name each other | `TEXTUAL-CONFLICT` | `(b)` |' "AC6 shared work/ path or naming -> TEXTUAL-CONFLICT (b)"
needflat "$WF" '| A declared target is malformed or resolves to nothing | `DANGLING-DEP` | `(b)` |' "AC6 unresolved -> DANGLING-DEP (b)"
needflat "$WF" '| A child'\''s own declaration and parent cell disagree (both non-`—`, sets unequal) | `DRIFT-FACT` | `(d)` |' "AC6 discrepancy -> DRIFT-FACT (d)"
needflat "$SKILL" 'Three of these codes also carry a **planning-time** meaning' "AC6 skill records the planning-time meanings"
needflat "$SKILL" 'their merge-time meanings above are unchanged and no code is added' "AC6 skill adds no code"
needflat "$STATUS" 'The planning-time **declared-conflict check**' "AC6 status agent describes the planning-time findings"
# Negative control: the new authority section introduces no new class/code.
DCHECK="$(section "$WF" 'Declared-conflict check')"
if printf '%s' "$DCHECK" | grep -qE '\(e\)|DECLARED-CONFLICT|UNRESOLVED-DECLARATION|PLAN-CONFLICT'; then
  bad "AC6 authority section introduces a new class/finding code"
else
  ok "AC6 authority section introduces no new class/finding code"
fi

# ===========================================================================
echo "== AC7: malformed/unresolvable target reported, never dropped or repaired =="
# ===========================================================================
needflat "$WF" 'A token that is malformed (empty or whitespace-only, a glob metacharacter, `..`, or absolute) or that resolves to no sibling row, no `work/<ref>/`, and no existing repository path is an **unresolved declaration**: it is reported (`DANGLING-DEP`, below) and never dropped or auto-repaired.' "AC7 authority states the unresolved rule"
needflat "$SKILL" 'a declared `conflicts-with` target is malformed or resolves to no sibling row, no `work/<ref>/`, and no existing repository path.' "AC7 skill carries the planning-time DANGLING-DEP meaning"
needflat "$STATUS" 'a declared `conflicts-with` target is malformed or resolves to no sibling row, no `work/<ref>/`, and no existing repository path.' "AC7 status agent carries the planning-time DANGLING-DEP meaning"

# ===========================================================================
echo "== AC8: parent/item discrepancy reported, preferring neither =="
# ===========================================================================
needflat "$WF" 'When `own` and `cell` are **both present** (neither `—`) and the two sets are **not identical** — a subset relationship still counts — the check reports the discrepancy (`DRIFT-FACT`, below) and prefers neither. A one-sided record is the union and is not a discrepancy.' "AC8 authority states the discrepancy rule"
needflat "$SKILL" 'a roadmap child'\''s own `design.md` declaration and its parent `Children` `conflicts-with` cell are both present and their target sets disagree.' "AC8 skill carries the planning-time DRIFT-FACT meaning"
needflat "$STATUS" 'a roadmap child'\''s own `design.md` declaration and its parent `Children` `conflicts-with` cell are both present and their target sets disagree.' "AC8 status agent carries the planning-time DRIFT-FACT meaning"

# ===========================================================================
echo "== AC9: advisory; no phase blocked; readiness unchanged =="
# ===========================================================================
needflat "$WF" "It is distinct from \`Depends on\` as well: a declared conflict adds no readiness edge, reorders no child, and changes no child's readiness, so no phase is blocked." "AC9 authority states no phase is blocked"
needflat "$BUILD" 'The findings are advisory: they never change the gate outcome and never stop the build' "AC9 builder prompt: advisory, gate unchanged"
needflat "$BUILDCMD" 'The findings are advisory: they never change the gate outcome and never stop the build' "AC9 build command: advisory, gate unchanged"
needflat "$STATUS" 'It is advisory: it adds no readiness edge, reorders no child, and blocks no phase.' "AC9 status agent: advisory, no readiness edge"
needflat "$CONFLICTS" 'adds no readiness edge, and blocks no phase' "AC9 /conflicts: advisory, no readiness edge"
# Readiness algorithm remains single-sourced and gained no declaration input.
READY="$(subsection "$WF" 'Dependencies and readiness')"
if printf '%s' "$READY" | grep -qF 'satisfied(dep_local_id)'; then ok "AC9 readiness algorithm satisfied(dep_local_id) intact"; else bad "AC9 readiness algorithm missing satisfied(dep_local_id)"; fi
if printf '%s' "$READY" | grep -qF 'conflicts-with'; then bad "AC9 readiness section gained a conflicts-with input"; else ok "AC9 readiness section has no conflicts-with input"; fi

# ===========================================================================
echo "== AC10: /status reports the same findings, read-only =="
# ===========================================================================
needflat "$STATUS" 'You also run the read-only declared-conflict check and report its declared-conflict, unresolved-declaration, and declaration-discrepancy findings in the same finding vocabulary.' "AC10 status agent mission reports the check"
needflat "$STATUS" 'Run the declared-conflict check (`docs/workflow.md` → `## Declared-conflict check`)' "AC10 status process runs the check"
needflat "$STATUSCMD" 'Run the read-only **declared-conflict check**' "AC10 /status command surfaces the check"
needflat "$STATUSCMD" 'It is advisory, offline, local-only, and read-only: it adds no readiness edge and blocks no phase.' "AC10 /status command states the contract"
needflat "$CONFLICTS" 'The same findings appear in the `/status` report.' "AC10 /conflicts notes the /status parity"

# ===========================================================================
echo "== AC11: /build gate surfaces focused findings after PROCEED, advisory =="
# ===========================================================================
needflat "$BUILD" 'After a **PROCEED** outcome, run the read-only focused declared-conflict check for the item (`docs/workflow.md` → `## Declared-conflict check`) and print the findings that involve it before selecting a task.' "AC11 builder runs the focused check post-PROCEED"
needflat "$BUILD" 'the check itself performs no fetch (the gate'\''s own best-effort ref refresh is separate).' "AC11 builder: check performs no fetch"
needflat "$BUILDCMD" 'After a **PROCEED** outcome from that gate, run the read-only focused declared-conflict check for the item (`docs/workflow.md` → `## Declared-conflict check`) and print the findings that involve it before selecting a task.' "AC11 build command runs the focused check post-PROCEED"
needflat "$WF" 'after a `PROCEED` outcome the builder runs the focused check for the item and prints the findings before selecting a task; the findings never change the gate outcome and never stop the build.' "AC11 authority states the gate surfacing and non-blocking outcome"

# ===========================================================================
echo "== AC12: offline/local/read-only; no fetch, remote, merge, dry-run, lock, write =="
# ===========================================================================
needflat "$WF" 'The check reads only committed `work/` state and the local repository (for target resolution).' "AC12 authority: committed work/ + local repo only"
needflat "$CONFLICTS" 'it reads committed `work/` state and the local repository for target resolution, performs no fetch, remote read, merge, or dry-run merge, takes no lock, modifies no file' "AC12 /conflicts states no fetch/remote/merge/dry-run/lock/write"
# Negative controls: the check descriptions carry no git read/write command tokens.
for f in "$CONFLICTS" "$STATUSCMD"; do
  absent "$f" 'git fetch' "AC12 $f issues no git fetch"
  absent "$f" 'git ls-remote' "AC12 $f issues no remote read"
  absent "$f" 'git merge' "AC12 $f issues no merge"
  absent "$f" 'gh ' "AC12 $f issues no gh call"
done
# The status agent's detection is local-only (existing invariant preserved).
needflat "$STATUS" 'It fetches nothing, hits no remote, runs no dry-run merge, takes no lock, and writes nothing.' "AC12 status agent stays local-only"

# ===========================================================================
echo "== AC13: planning-time only; does not reproduce pre-ship branch detection =="
# ===========================================================================
needflat "$WF" 'It operates on committed plan declarations only and does **not** perform or reproduce the shipped pre-ship branch/textual detection of `## Merge conflicts`: that contract acts on branches at merge time, while this check compares declarations at planning time.' "AC13 authority distinguishes planning-time from pre-ship detection"
needflat "$WF" 'that contract acts on branches at merge time, while this check compares declarations at planning time.' "AC13 planning-time vs merge-time stated"
needflat "$SKILL" '`docs/workflow.md` → `## Declared-conflict check`; their merge-time meanings above are unchanged' "AC13 skill scopes the planning-time meaning to the authority"
needflat "$SKILL" '`TEXTUAL-CONFLICT` is pre-flight-only for the `dry-run-detected` case' "AC13 skill scopes the pre-flight-only note to the detected case"

# ===========================================================================
echo "== AC14: no declaration yields no finding; historical items valid =="
# ===========================================================================
needflat "$WF" 'contributes no declared target of its own, so it yields no finding **from its own declaration** and historical items remain valid with no migration.' "AC14 no-declaration yields no finding from its own declaration, no migration"
needflat "$WF" 'A roadmap authored before the `conflicts-with` column existed has no column, treated as `—` for every row.' "AC14 absent column treated as —"
needflat "$CONFLICTS" 'If `work/` has no unshipped plan with a declaration, report no findings and do not error.' "AC14 empty declaration set is a no-op, not an error"

# ===========================================================================
echo "== AC15: command + signature appear in every inventory; suite agreements =="
# ===========================================================================
need "$CONFLICTS" 'agent: status' "AC15 /conflicts routes to the status agent"
needE "$CONFLICTS" '^description: .*Usage: /conflicts \[item-ref\]' "AC15 /conflicts description carries the canonical usage"
need "$README" '| `/conflicts [item-ref]` | `status`' "AC15 README Commands table row present"
need "$README" '  command/   # 13 slash commands' "AC15 README Layout count is 13"
need "$AGENTS" '/conflicts [item-ref]' "AC15 root AGENTS.md supporting-commands list includes /conflicts"
need "$TAGENTS" '/conflicts [item-ref]' "AC15 template/AGENTS.md supporting-commands list includes /conflicts"
need "$ROUTING" '/conflicts [item-ref]' "AC15 workflow-lifecycle skill routes /conflicts"
need "$SWEEP" '/conflicts [item-ref]' "AC15 signature-sweep registry carries the canonical signature"
need "$WF" '`/conflicts [item-ref]`' "AC15 workflow routing-heuristics bullet present"
# The generic inventory check and the signature sweep must name /conflicts.
need "$SWEEP" 'README_REQUIRED=' "AC15 signature-sweep README required set present"
if grep -qF '/conflicts' "$SWEEP"; then ok "AC15 signature-sweep names /conflicts"; else bad "AC15 signature-sweep omits /conflicts"; fi

# ===========================================================================
echo "== AC16: one authoritative statement, referenced elsewhere =="
# ===========================================================================
# Exactly one live surface carries the `## Declared-conflict check` authority.
auth_count="$(grep -rIl --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules '^## Declared-conflict check' docs .opencode README.md AGENTS.md template/AGENTS.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$auth_count" = "1" ] && grep -qF '## Declared-conflict check' "$WF"; then
  ok "AC16 authority stated exactly once, in docs/workflow.md"
else
  bad "AC16 authority is not single-sourced (count=$auth_count)"
fi
# The grammar production and the predicate production stay single-sourced.
gram_count="$(grep -rIl --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules 'ConflictTargetList ::=' . 2>/dev/null | wc -l | tr -d ' ')"
if [ "$gram_count" = "1" ] && grep -qF 'ConflictTargetList ::=' "$WF"; then
  ok "AC16 declaration grammar production single-sourced in docs/workflow.md"
else
  bad "AC16 declaration grammar is not single-sourced (count=$gram_count)"
fi
pred_count="$(grep -rIl --exclude-dir=.git --exclude-dir=work --exclude-dir=node_modules 'conflict(A, B)' docs .opencode README.md AGENTS.md template/AGENTS.md 2>/dev/null | wc -l | tr -d ' ')"
if [ "$pred_count" = "1" ] && grep -qF 'conflict(A, B)' "$WF"; then
  ok "AC16 pair predicate stated once on a live surface, in docs/workflow.md"
else
  bad "AC16 pair predicate is not single-sourced (count=$pred_count)"
fi
# Each other surface references the authority by name.
for f in "$CONFLICTS" "$STATUS" "$STATUSCMD" "$BUILD" "$BUILDCMD"; do
  needflat "$f" '## Declared-conflict check' "AC16 $f references the authority"
done

# ===========================================================================
echo "== Spec edge cases =="
# ===========================================================================
needflat "$WF" 'An empty compared set — no unshipped plans, no declarations, or all plans already shipped — reports no findings and does not error.' "EDGE empty compared set (none unshipped / all shipped) reports nothing and does not error"
needflat "$WF" 'A **shipped** item still **resolves** as a target but is not a counterpart: naming it produces neither a conflict nor an unresolved finding.' "EDGE a shipped target resolves but yields no conflict/unresolved"
needflat "$WF" 'the sibling-first precedence for a bare `MMMM-slug`' "EDGE bare-reference ambiguity uses the shipped sibling-first precedence"
needflat "$WF" 'exact repository-relative surface paths' "EDGE surface paths are exact"
needflat "$WF" 'a glob metacharacter, `..`, or absolute' "EDGE malformed surface target (glob / .. / absolute) is malformed"
needflat "$WF" 'even when the child directory holds only `.gitkeep` (the parent cell still represents it).' "EDGE unspecced child with a parent declaration is compared"
needflat "$WF" 'The finding list is never truncated' "EDGE many conflicts are all reported"
needflat "$WF" 'concurrent runs take no lock and write nothing' "EDGE concurrent invocations take no lock, write nothing"
needflat "$WF" 'repeated runs on unchanged plans yield identical findings' "EDGE repeated runs are deterministic"
needflat "$WF" 'across the whole `work/` tree' "EDGE cross-roadmap / global scan"
# Consumed grammar edge cases remain intact (owned by 0001).
needflat "$WF" 'an empty or whitespace-only cell is malformed, not equivalent to `—`' "EDGE empty/whitespace-only cell is malformed (grammar intact)"
needflat "$WF" 'a list may not repeat a target after trimming' "EDGE duplicate target is malformed (grammar intact)"
needflat "$WF" 'repository-relative file or directory path' "EDGE an existing directory path is a valid surface target (grammar intact)"

# ===========================================================================
echo "== Structural / regression invariants =="
# ===========================================================================
# All tasks ticked; the item's own artifacts carry the right reference.
if grep -qE '^- \[ \]' "$ITEM/tasks.md"; then
  bad "STRUCT tasks.md has unchecked items"
else
  ok "STRUCT tasks.md has no unchecked items"
fi
need "$ITEM/spec.md" 'feature: 0006-parallel-plan-conflicts/0003-conflict-check' "STRUCT spec.md feature ref"
need "$ITEM/design.md" 'feature: 0006-parallel-plan-conflicts/0003-conflict-check' "STRUCT design.md feature ref"
need "$ITEM/tasks.md" 'feature: 0006-parallel-plan-conflicts/0003-conflict-check' "STRUCT tasks.md feature ref"

# The design-named surfaces that must have changed.
CHANGED="$(git status --porcelain | awk '{print $2}' | sort)"
REQUIRED="$(printf '%s\n' "$CONFLICTS" "$WF" "$SKILL" "$STATUS" "$STATUSCMD" "$BUILD" "$BUILDCMD" "$ROUTING" "$README" "$AGENTS" "$TAGENTS" "$SWEEP" | sort)"
missing=""
for f in $REQUIRED; do
  printf '%s\n' "$CHANGED" | grep -qxF -- "$f" || missing="$missing $f"
done
if [ -z "$missing" ]; then
  ok "STRUCT every design-named surface changed"
else
  bad "STRUCT design-named surface(s) not changed:$missing"
fi
# Forbidden surfaces must be untouched (deferred to 0004 / not in scope).
FORBIDDEN="docs/artifact-conventions.md opencode.json tests/checks/80-cycle-fixture.sh tests/checks/40-inventory.sh tests/fixtures/cyclic-roadmap/roadmap.md"
bad_forbidden=""
for f in $FORBIDDEN; do
  if printf '%s\n' "$CHANGED" | grep -qxF -- "$f"; then bad_forbidden="$bad_forbidden $f"; fi
done
if [ -z "$bad_forbidden" ]; then
  ok "STRUCT no out-of-scope surface changed"
else
  bad "STRUCT out-of-scope surface(s) changed:$bad_forbidden"
fi
# No new agent file (the check reuses the status agent).
new_agents="$(git status --porcelain -- .opencode/agent/ | grep '^??' || true)"
if [ -z "$new_agents" ]; then ok "STRUCT no new agent added"; else bad "STRUCT new agent file(s): $new_agents"; fi
# No committed checker/script was added under tests/ for the prompt-only check.
new_test_files="$(git status --porcelain -- tests/ | grep '^??' || true)"
if [ -z "$new_test_files" ]; then ok "STRUCT no new committed tests/ file added"; else bad "STRUCT new tests/ file(s): $new_test_files"; fi

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
