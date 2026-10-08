#!/usr/bin/env bash
#
# Executable evidence for work/0006-parallel-plan-conflicts/0001-conflict-declaration-model
# (declared planning-time conflict model and `conflicts-with` column).
#
# Read-only against the repository. The deliverable is documents and prompts only:
# there is no runtime code and no unit harness, so the automatable criteria
# (AC1-AC12) and every spec edge case are encoded as content assertions over the
# four changed surfaces:
#
#   docs/workflow.md                          -> the single authority (T1)
#   docs/artifact-conventions.md              -> the roadmap template + column note (T2)
#   .opencode/agent/roadmap.md                -> the roadmap agent prompt (T3)
#   .opencode/command/roadmap.md              -> the roadmap command (T4)
#
# plus structural/regression invariants (AC6/AC10): the readiness algorithm is
# unchanged, `Depends on` keeps its positional index in the committed parser, and
# no committed tests/ file changed.
#
# This is deliberately NOT a tests/checks/ agreement area or a mutation case: the
# spec's non-goals and the design's test strategy defer committed fixture-based
# guards to sibling 0004-conflict-guards. This item suite is the same item-level
# evidence pattern as work/0005-merge-conflict-workflow/0001-conflict-model.
#
# Usage: bash work/0006-parallel-plan-conflicts/0001-conflict-declaration-model/verify-tests.sh [repo-root]
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
AGENT=".opencode/agent/roadmap.md"
CMD=".opencode/command/roadmap.md"
CHECK="tests/checks/80-cycle-fixture.sh"
FIXTURE="tests/fixtures/cyclic-roadmap/roadmap.md"

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

# section: print the body of a `### <title>` subsection, stopping at the next `###`.
section() { awk -v h="$2" '$0 ~ "^### " h "[ \t]*$" { f=1; next } f && /^### / { f=0 } f' "$1"; }

# ===========================================================================
echo "== AC1: authority defines the planning-time conflict =="
# ===========================================================================
need "$WF" '### Declared conflicts (`conflicts-with`)' "AC1 authority subsection exists"
needflat "$WF" 'A **planning-time conflict** is a *declared, committed claim* by one plan that it expects to collide with one or more targets.' "AC1 defines planning-time conflict as declared committed claim"
needflat "$WF" 'distinct from the merge-time `## Merge conflicts` contract, which acts on branches after they exist' "AC1 explicitly distinct from the merge-time contract"
needflat "$WF" 'distinct from `Depends on`, which is a readiness edge' "AC1 explicitly distinct from Depends on"
need "$WF" 'shipped `(a)`–`(d)` class labels' "AC1 references the shipped classes rather than restating a taxonomy"

# ===========================================================================
echo "== AC2: roadmap template carries the column and its note =="
# ===========================================================================
need "$CONV" '| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |' "AC2 template header includes conflicts-with"
need "$CONV" '| 0001-model | Core model | <scope sufficient to author a spec> | — | — | NNNN-slug/0001-model |' "AC2 example row 0001-model has a conflicts-with —"
need "$CONV" '| 0002-api   | API layer  | ...                                 | 0001-model | — | NNNN-slug/0002-api |' "AC2 example row 0002-api has a conflicts-with —"
needflat "$CONV" '**conflicts-with** declares the targets the row expects to collide with.' "AC2 note explains the column meaning"
need "$CONV" 'Use `—`' "AC2 note states the empty value is —"
need "$CONV" 'in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)".' "AC2 note points to the workflow authority"

# ===========================================================================
echo "== AC3: three target kinds, comma separation, — empty value =="
# ===========================================================================
need "$WF" 'ConflictTargetList ::= "—"' "AC3 grammar names ConflictTargetList with — empty value"
need "$WF" 'ConflictTarget     ::= SiblingOrItemRef | SurfacePath' "AC3 ConflictTarget is a sibling/item ref or a surface path"
needflat "$WF" 'an **intra-roadmap sibling local id** (`MMMM-slug`) naming a different row in the same `Children` table' "AC3 kind 1: sibling local id"
needflat "$WF" 'a **canonical work-item reference** — a top-level `NNNN-slug` (including a roadmap parent) or a nested `NNNN-slug/MMMM-slug`' "AC3 kind 2: canonical work-item reference"
needflat "$WF" 'or a **repository-relative surface path**, an exact file or directory path' "AC3 kind 3: repository-relative surface path"
need "$WF" 'Targets are comma-separated' "AC3 multiple targets are comma-separated"
needflat "$WF" 'A cell that is `—` (em dash, the same convention as `Depends on`) declares no conflicts' "AC3 — declares no conflicts"
needflat "$WF" 'Repository paths and references contain no comma, so a comma always separates targets.' "AC3 comma always separates"

# ===========================================================================
echo "== AC4: same grammar for a child/standalone item, storage-independent =="
# ===========================================================================
needflat "$WF" 'The same grammar defines the intended conflict set of a child or standalone work item' "AC4 grammar applies to child/standalone declarations"
needflat "$WF" "that grammar is independent of where such an item's declaration is stored" "AC4 grammar defined independently of storage location"
# Negative control: this item does not decide the item-level storage/container.
absent "$WF" 'phase: conflicts' "AC4 no new declaration phase value is defined"

# ===========================================================================
echo "== AC5: one-sided declaration is a declared conflict =="
# ===========================================================================
needflat "$WF" 'A pair is a declared conflict when at least one side names the other' "AC5 at least one side suffices"
needflat "$WF" 'so a declaration does not require a reciprocal declaration' "AC5 no reciprocal declaration required"

# ===========================================================================
echo "== AC6: advisory only; no readiness change =="
# ===========================================================================
needflat "$WF" 'A declaration is advisory — it adds, removes, or reorders no `Depends on` edge and changes no child' "AC6 adds/removes/reorders no Depends on edge"
needflat "$WF" 'only `Depends on` gates readiness' "AC6 only Depends on gates readiness"
needflat "$CONV" 'The declaration is advisory and never changes `Depends on` or readiness.' "AC6 template note repeats the advisory rule"
needflat "$AGENT" 'it never adds, removes, or reorders a `Depends on` edge and never changes a child' "AC6 agent prompt repeats the advisory rule"
needflat "$CMD" 'they never change `Depends on` or a child' "AC6 command repeats the advisory rule"
# Readiness algorithm unchanged: the section still carries its algorithm and does
# NOT acquire a conflicts-with input.
READY="$(section "$WF" 'Dependencies and readiness')"
if printf '%s' "$READY" | grep -qF 'satisfied(dep_local_id)'; then ok "AC6 readiness algorithm satisfied(dep_local_id) intact"; else bad "AC6 readiness algorithm missing satisfied(dep_local_id)"; fi
if printf '%s' "$READY" | grep -qF 'ready(child)'; then ok "AC6 readiness algorithm ready(child) intact"; else bad "AC6 readiness algorithm missing ready(child)"; fi
if printf '%s' "$READY" | grep -qF 'blocked_by(child)'; then ok "AC6 readiness algorithm blocked_by(child) intact"; else bad "AC6 readiness algorithm missing blocked_by(child)"; fi
if printf '%s' "$READY" | grep -qF 'conflicts-with'; then bad "AC6 readiness section gained a conflicts-with input"; else ok "AC6 readiness section has no conflicts-with input"; fi

# ===========================================================================
echo "== AC7: shipped vocabulary reused; no new class/code/policy =="
# ===========================================================================
needflat "$WF" 'uses the shipped `(a)`–`(d)` class labels and the finding-line grammar defined in `## Merge conflicts` and `.opencode/skill/merge-conflict/SKILL.md`' "AC7 reuses shipped classes and finding-line grammar"
needflat "$WF" 'There is no new class, finding code, or policy defined for declarations.' "AC7 states no new class/code/policy"
needflat "$WF" 'It is reported by a later read-only check and never silently dropped or auto-repaired.' "AC7 unresolved declarations are reported, never dropped"
# Negative controls: the new subsection invents no class label or finding code.
DECL="$(section "$WF" 'Declared conflicts (`conflicts-with`)')"
if printf '%s' "$DECL" | grep -qF '(e)'; then bad "AC7 new subsection defines class (e)"; else ok "AC7 no class (e) is introduced"; fi
if printf '%s' "$DECL" | grep -qE 'DECLARED-CONFLICT|PLAN-CONFLICT|CONFLICT-DECL'; then bad "AC7 new subsection defines a new finding code"; else ok "AC7 no new planning-conflict finding code"; fi

# ===========================================================================
echo "== AC8: well-formedness — no self-reference, no duplicate =="
# ===========================================================================
needflat "$WF" 'A reference may not name the declaring row' "AC8 forbids self-reference"
needflat "$WF" 'own local id (no self-reference)' "AC8 states no self-reference explicitly"
needflat "$WF" 'a list may not repeat a target' "AC8 forbids a duplicate target"
needflat "$AGENT" 'with no self-reference and no duplicate' "AC8 agent quality bar carries both constraints"
# The reference-vs-path discriminator lets a sibling local id resolve to a row.
needflat "$WF" 'A target matching `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$` is a reference' "AC8 sibling references are discriminated from surface paths"

# ===========================================================================
echo "== AC9: roadmap agent prompt and command describe the column =="
# ===========================================================================
need "$AGENT" 'conflicts-with' "AC9 agent prompt names the conflicts-with cell"
needflat "$AGENT" 'using the `ConflictTargetList` grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC9 agent prompt references the authority grammar"
needflat "$AGENT" 'A declaration is advisory: it never adds, removes, or reorders a `Depends on` edge' "AC9 agent prompt states the advisory rule"
need "$AGENT" 'Every `conflicts-with` cell is `—` or a well-formed `ConflictTargetList`' "AC9 agent quality bar checks the cell"
need "$CMD" 'conflicts-with' "AC9 command names the conflicts-with cell"
needflat "$CMD" 'using the `ConflictTargetList` grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC9 command references the authority grammar"
needflat "$CMD" 'Declarations are advisory — they never change `Depends on` or a child' "AC9 command states the advisory rule"
# Negative control: neither prompt states a conflicting grammar production.
absent "$AGENT" 'ConflictTargetList ::=' "AC9 agent prompt does not restate the grammar"
absent "$CMD" 'ConflictTargetList ::=' "AC9 command does not restate the grammar"

# ===========================================================================
echo "== AC10: Depends on parsing and readiness behavior unchanged =="
# ===========================================================================
need "$CHECK" 'dep = a[5]' "AC10 committed parser still reads Depends on at pipe-field 5"
need "$CHECK" '| Local id | Title | Scope | Depends on | Canonical reference |' "AC10 committed check still asserts the fixture header it reads"
need "$FIXTURE" '| Local id | Title | Scope | Depends on | Canonical reference |' "AC10 committed fixture header unchanged (5 columns; fixture/check skew owned by 0004)"
# No positional consumer moved: inserting conflicts-with after Depends on keeps index 5.
needE "$CHECK" 'dep = a\[5\]' "AC10 Depends on retains its positional index"
# No committed test file changed by this item.
if [ -z "$(git status --porcelain -- tests/ 2>/dev/null)" ]; then ok "AC10 no committed tests/ file modified"; else bad "AC10 tests/ has uncommitted changes"; fi
if [ -z "$(git diff --name-only HEAD -- tests/ 2>/dev/null)" ]; then ok "AC10 tests/ diff against HEAD is empty"; else bad "AC10 tests/ differs from HEAD"; fi

# ===========================================================================
echo "== AC11: unresolved declarations are reported, never dropped =="
# ===========================================================================
needflat "$WF" 'A malformed cell, or a target that resolves to no sibling row, no `work/<ref>/` directory, and no existing path, is an **unresolved declaration**.' "AC11 defines an unresolved declaration"
needflat "$WF" 'It is reported by a later read-only check' "AC11 reported by a later read-only check"
needflat "$WF" 'never silently dropped or auto-repaired' "AC11 never silently dropped or auto-repaired"

# ===========================================================================
echo "== AC12: one authoritative grammar, referenced elsewhere =="
# ===========================================================================
NEEDLES=('ConflictTargetList ::=' 'ConflictTarget     ::=' 'SiblingOrItemRef   ::=' 'SurfacePath        ::=')
prod_count="$(grep -rIl --exclude-dir=.git --exclude-dir=work 'ConflictTargetList ::=' . 2>/dev/null | wc -l | tr -d ' ')"
if [ "$prod_count" = "1" ] && grep -qF 'ConflictTargetList ::=' "$WF"; then
  ok "AC12 grammar production is stated exactly once, in docs/workflow.md"
else
  bad "AC12 grammar production is not single-sourced (count=$prod_count)"
fi
absent "$CONV" 'ConflictTargetList ::=' "AC12 template references the grammar rather than restating it"
absent "$AGENT" 'ConflictTargetList ::=' "AC12 agent prompt references the grammar rather than restating it"
absent "$CMD" 'ConflictTargetList ::=' "AC12 command references the grammar rather than restating it"
needflat "$CONV" 'The grammar is defined in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)".' "AC12 template points to the authority"
needflat "$AGENT" 'using the `ConflictTargetList` grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC12 agent prompt points to the authority"
needflat "$CMD" 'using the `ConflictTargetList` grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)"' "AC12 command points to the authority"

# ===========================================================================
echo "== Spec edge cases =="
# ===========================================================================
needflat "$WF" 'an empty or whitespace-only cell is malformed, not equivalent to `—`' "EDGE empty/whitespace-only cell is malformed"
needflat "$WF" 'A roadmap authored before the column existed has no `conflicts-with` column' "EDGE absent column is recognised"
needflat "$WF" 'its absence is treated as no declared conflicts (`—` for every row)' "EDGE absent column = no declared conflicts"
needflat "$WF" 'a target that resolves to no sibling row, no `work/<ref>/` directory, and no existing path' "EDGE unresolved sibling/top-level/surface all covered"
needflat "$WF" 'no self-reference' "EDGE self-reference"
needflat "$WF" 'may not repeat a target' "EDGE duplicate target"
needflat "$WF" 'at least one side names the other' "EDGE one side declares (and both-sides collapse to a pair)"
needflat "$WF" 'a comma always separates targets' "EDGE comma separates; targets contain no comma"
needflat "$WF" 'resolution precedence is the **sibling row in the same table first, then `work/<token>/`**' "EDGE bare-reference resolution precedence"
needflat "$WF" 'or a nested `NNNN-slug/MMMM-slug`' "EDGE nested child reference allowed"
needflat "$WF" 'a top-level `NNNN-slug` (including a roadmap parent)' "EDGE top-level / cross-roadmap reference allowed"

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
