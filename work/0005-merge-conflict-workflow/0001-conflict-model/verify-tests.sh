#!/usr/bin/env bash
#
# Executable evidence for work/0005-merge-conflict-workflow/0001-conflict-model
# (merge-conflict model and resolution contract).
#
# Read-only against the repository. The deliverable is documents plus one skill:
# there is no runtime code and no unit harness, so the automatable criteria
# (AC1-AC12) are encoded as content assertions over the normative contract
# (docs/workflow.md -> `## Merge conflicts`), the operational derivative
# (.opencode/skill/merge-conflict/SKILL.md), the inventory surfaces (README.md,
# AGENTS.md, template/AGENTS.md), the bidirectional renumbering pointer
# (docs/artifact-conventions.md), and the structural invariants (AC11 suite run,
# AC12 no command/agent/lifecycle-model change).
#
# This mirrors the historical read-only item suites (work/**/verify-tests.sh).
# It is deliberately NOT a committed tests/checks/ guard: the design defers
# committed merge-integrity guards to sibling 0005-merge-integrity-guards, and
# the spec's ACs require only that the committed suite stays green.
#
# Usage: bash work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh [repo-root]
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
SKILL=".opencode/skill/merge-conflict/SKILL.md"
README="README.md"
AGENTS="AGENTS.md"
TEMPLATE_AGENTS="template/AGENTS.md"
CUST="docs/customization.md"

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
echo "== AC1: conflict taxonomy names four classes and affected surfaces =="
# ===========================================================================
need   "$WF" '## Merge conflicts'                 "AC1 normative section exists"
need   "$WF" '### Conflict taxonomy'              "AC1 taxonomy subsection exists"
need   "$WF" '(a) shared-surface textual conflict' "AC1 class (a) shared-surface textual conflict"
need   "$WF" '(b) `work/` artifact conflict'       "AC1 class (b) work/ artifact conflict"
need   "$WF" '(c) duplicate sequence number'       "AC1 class (c) duplicate sequence number"
need   "$WF" '(d) derived-agreement drift'         "AC1 class (d) derived-agreement drift"
# Class (a) surfaces.
for s in 'README.md' 'AGENTS.md' 'docs/*.md' '.opencode/{agent,command,skill}/**' 'template/**' 'tests/checks/**'; do
  needflat "$WF" "$s" "AC1 class (a) names surface $s"
done
# Class (b) surfaces.
needflat "$WF" 'Roadmap `Children` / `Depends on` tables' "AC1 class (b) names roadmap Children/Depends on"
needflat "$WF" 'artifact frontmatter'                     "AC1 class (b) names artifact frontmatter"
needflat "$WF" 'nested-child intersections'               "AC1 class (b) names nested-child intersections"
# Class (c) surfaces (both sequence scopes).
needflat "$WF" 'Top-level `work/<NNNN-slug>`'                          "AC1 class (c) names top-level work/<NNNN-slug>"
needflat "$WF" 'per-parent `work/<NNNN-slug>/<MMMM-slug>`'            "AC1 class (c) names per-parent child path"
# Class (d) surfaces.
needflat "$WF" 'README Layout counts' "AC1 class (d) names README Layout counts"
needflat "$WF" 'README Skills table'  "AC1 class (d) names README Skills table"
# Section order: normative contract sits after Multiple work items, before Resuming.
mc_line="$(grep -n '^## Merge conflicts$' "$WF" | head -1 | cut -d: -f1)"
mw_line="$(grep -n '^## Multiple work items$' "$WF" | head -1 | cut -d: -f1)"
ri_line="$(grep -n '^## Resuming and interruption$' "$WF" | head -1 | cut -d: -f1)"
if [ -n "$mc_line" ] && [ -n "$mw_line" ] && [ -n "$ri_line" ] \
   && [ "$mw_line" -lt "$mc_line" ] && [ "$mc_line" -lt "$ri_line" ]; then
  ok "AC1 section placed after Multiple work items and before Resuming"
else
  bad "AC1 section order wrong (multiple=$mw_line merge=$mc_line resuming=$ri_line)"
fi
# Cross-reference from Multiple work items for the non-renumbering classes.
needflat "$WF" 'for every other class' "AC1 Multiple work items points to the other classes"
needflat "$WF" 'shared-surface textual conflicts' "AC1 cross-reference names textual class"
needflat "$WF" 'derived-agreement drift'          "AC1 cross-reference names drift class"

# ===========================================================================
echo "== AC2: lifecycle placement (pre-ship reconcile + post-merge integrity) =="
# ===========================================================================
need   "$WF" '### Lifecycle placement'    "AC2 lifecycle placement subsection exists"
needflat "$WF" 'pre-ship reconcile' 'AC2 names pre-ship reconcile'
needflat "$WF" 'before the shipper performs any ship operation' 'AC2 pre-ship runs before shipper operations'
needflat "$WF" 'post-merge integrity pass' 'AC2 names post-merge integrity pass'
needflat "$WF" 'after a merge to the default branch' 'AC2 post-merge runs after a default-branch merge'
needflat "$WF" 'merges the default branch forward into the item branch' 'AC2 pre-ship merges forward'
# Edge: nothing to reconcile -> no-op, no error.
needflat "$WF" 'both steps are no-ops and do not error' 'AC2 (edge) up-to-date is a no-op'
# Edge: overlapping work/ artifact edits -> re-check graph for dangling/missing/unlisted/cyclic.
needflat "$WF" 're-check every roadmap `Depends on` against its `Children` table' 'AC2 post-merge re-checks Depends on'
needflat "$WF" 'dangling, missing, unlisted, or cyclic references' 'AC2 post-merge checks all four reference faults'
needflat "$WF" 'duplicate 4-digit prefixes' 'AC2 post-merge scans duplicate prefixes'
# Cross-reference from the Ship process.
needflat "$WF" 'Reconcile first' 'AC2 Ship process says reconcile first'
needflat "$WF" 'resolve conflicts per `## Merge conflicts`' 'AC2 Ship process points at the contract'

# ===========================================================================
echo "== AC3: ownership (shipper, step inside /ship, no new command/agent) =="
# ===========================================================================
need   "$WF" '### Ownership'                        "AC3 ownership subsection exists"
needflat "$WF" 'The `shipper` is the single owner of reconciliation' 'AC3 names shipper as single owner'
needflat "$WF" 'a step inside `/ship`'              'AC3 reconcile is a step inside /ship'
needflat "$WF" 'adds no new command or agent'        'AC3 adds no new command or agent'

# ===========================================================================
echo "== AC4: merge forward; never rebase a pushed branch; never force-push =="
# ===========================================================================
need   "$WF" '### Resolution principles'  "AC4 resolution principles subsection exists"
needflat "$WF" 'Merge the default branch forward' 'AC4 requires merge-forward'
needflat "$WF" 'Never rebase a pushed branch'     'AC4 forbids rebasing a pushed branch'
needflat "$WF" 'never force-push'                 'AC4 forbids force-push'

# ===========================================================================
echo "== AC5: preserve intent; never silently accept semantic conflict; escalate =="
# ===========================================================================
needflat "$WF" "Preserve both branches' intent"                 'AC5 requires preserving both intents'
needflat "$WF" 'Keep both sides'                                'AC5 keeps both sides records'
needflat "$WF" 'rather than dropping one'                       'AC5 (edge) does not drop a side (deleted-file case)'
needflat "$WF" 'semantic conflict'                              'AC5 names semantic conflict'
needflat "$WF" 'never silently accept it'                       'AC5 never silently accepts a semantic conflict'
needflat "$WF" 'escalate it to the user for explicit approval'  'AC5 escalates to the user for approval'
needflat "$WF" 'before proceeding'                              'AC5 escalation precedes proceeding'

# ===========================================================================
echo "== AC6: auto-resolve mechanical/structural, subject to re-verification =="
# ===========================================================================
needflat "$WF" 'Auto-resolve the mechanical'                      'AC6 permits auto-resolving mechanical conflicts'
needflat "$WF" 'mechanical or structural'                         'AC6 scopes auto-resolve to mechanical/structural'
needflat "$WF" 'does not require choosing between competing intents' 'AC6 excludes intent-judgment conflicts'
needflat "$WF" 'subject to the re-verification below'             'AC6 subjects auto-resolve to re-verification'

# ===========================================================================
echo "== AC7: re-run suite + item checks, green before record/ship =="
# ===========================================================================
need   "$WF" '### Verification'                                    "AC7 verification subsection exists"
needflat "$WF" 're-run `bash tests/run.sh` and the affected item'  'AC7 re-runs suite and item checks'
needflat "$WF" "Both must be green before the resolved merge is recorded or shipped" 'AC7 green required before record/ship'
needflat "$WF" 'A clean merge is not evidence of correctness'       'AC7 (edge) clean merge still verified'
needflat "$WF" 'even a merge that produced no conflict markers still runs the suite' 'AC7 (edge) conflict-free merge runs suite'

# ===========================================================================
echo "== AC8: duplicate sequence numbers defer to the existing renumber rule =="
# ===========================================================================
need   "$WF" '### Relationship to renumbering'          "AC8 relationship subsection exists"
needflat "$WF" 'Duplicate sequence numbers'              'AC8 names duplicate sequence numbers'
needflat "$WF" 'Renumbering after a parallel merge'      'AC8 defers to the existing rule by name'
needflat "$WF" 'defers to and extends that rule'         'AC8 defers to and extends it'
needflat "$WF" 'never defines a second renumbering rule' 'AC8 forbids a second renumbering rule'
# Bidirectional pointer from artifact-conventions.
needflat "$CONV" 'Duplicate sequence numbers are one class of merge conflict' 'AC8 conventions names merge-conflict class'
needflat "$CONV" '`## Merge conflicts`'                                       'AC8 conventions points to the contract'
# Class (c) must reference the existing rule (no fork).
needflat "$WF" 'class (c) — are handled by "Renumbering after a parallel merge"' 'AC8 class (c) routed to existing rule'
needE "$CONV" '^### Renumbering after a parallel merge' 'AC8 conventions retains the existing rule'

# ===========================================================================
echo "== AC9: merge-conflict skill encodes the shipper procedure =="
# ===========================================================================
if [ -f "$SKILL" ]; then ok "AC9 skill file exists: $SKILL"; else bad "AC9 skill file missing: $SKILL"; fi
need   "$SKILL" 'name: merge-conflict' 'AC9 frontmatter name matches folder'
for t in 'merge conflict' 'reconcile' 'conflict' 'branch behind' '/ship'; do
  needflat "$SKILL" "$t" "AC9 description/body carries trigger '$t'"
done
needflat "$SKILL" 'docs/workflow.md' 'AC9 skill names the source of truth'
needflat "$SKILL" 'source of truth'  'AC9 skill declares source of truth'
need   "$SKILL" '### Conflict taxonomy' 'AC9 skill cites the taxonomy'
# Ordered steps.
needflat "$SKILL" '**Detect.**'                  'AC9 step detect present'
needflat "$SKILL" '**Classify**'                 'AC9 step classify present'
needflat "$SKILL" '**Resolve.**'                 'AC9 step resolve present'
needflat "$SKILL" '**Re-verify.**'               'AC9 step re-verify present'
needflat "$SKILL" '**Record**'                   'AC9 step record present'
needflat "$SKILL" '**Post-merge integrity pass.**' 'AC9 step post-merge pass present'
needflat "$SKILL" '**Stop and escalate.**'       'AC9 step stop-and-escalate present'
# Step content: resolution split, re-verification command, recording, escalation block.
needflat "$SKILL" 'Mechanical or structural'      'AC9 auto-resolves mechanical/structural'
needflat "$SKILL" 'never accepted silently'       'AC9 semantic conflicts never silently accepted'
needflat "$SKILL" 'bash tests/run.sh'             'AC9 re-verification runs the suite'
needflat "$SKILL" "the affected item's checks"    'AC9 re-verification runs item checks'
needflat "$SKILL" 'resolved paths'                'AC9 records resolved paths'
needflat "$SKILL" 're-verification evidence'      'AC9 records re-verification evidence'
needflat "$SKILL" 'do not resolve silently to proceed' 'AC9 refuses to proceed silently'
needflat "$SKILL" 'stays blocked until the user responds' 'AC9 (edge) escalation with no response stays blocked'
# Principles restated.
needflat "$SKILL" 'never rebase a pushed branch' 'AC9 skill forbids rebase'
needflat "$SKILL" 'force-push'                    'AC9 skill forbids force-push'
needflat "$SKILL" 'Renumbering after a parallel merge' 'AC9 skill defers class (c)'
needflat "$SKILL" 'never defines a second rule'  'AC9 skill forbids a second renumber rule'

# ===========================================================================
echo "== AC10: AGENTS.md and README.md reference the contract/skill =="
# ===========================================================================
needE "$README" '^\| `merge-conflict`'                 'AC10 README Skills table names merge-conflict'
needflat "$README" 'Reconciling a branch behind the default branch' 'AC10 README row has a real description'
need   "$AGENTS" 'merge-conflict'                       'AC10 AGENTS.md Reference names the skill'
needflat "$AGENTS" '## Merge conflicts'                 'AC10 AGENTS.md Reference points at the contract'
need   "$TEMPLATE_AGENTS" 'merge-conflict'              'AC10 template/AGENTS.md carries the reference to adopters'
needflat "$TEMPLATE_AGENTS" '## Merge conflicts'        'AC10 template/AGENTS.md points at the contract'

# ===========================================================================
echo "== AC11: committed suite passes, including the skill inventory =="
# ===========================================================================
suite_out="$(bash tests/run.sh 2>&1)"; suite_rc=$?
if [ "$suite_rc" -eq 0 ] && ! printf '%s\n' "$suite_out" | grep -q '^FAIL'; then
  total_line="$(printf '%s\n' "$suite_out" | grep '^TOTAL:' | tail -1)"
  ok "AC11 bash tests/run.sh exits 0 with no FAIL ($total_line)"
else
  bad "AC11 bash tests/run.sh failed (rc=$suite_rc)"
  printf '%s\n' "$suite_out" | grep '^FAIL' | sed 's/^/      /'
fi
needE "$README" '# 11 knowledge skills' 'AC11 README Layout count is 11'
if [ -d .opencode/skill/merge-conflict ] \
   && [ "$(ls -d .opencode/skill/*/ | wc -l | tr -d ' ')" = "11" ]; then
  ok "AC11 on-disk skill set has 11 entries including merge-conflict"
else
  bad "AC11 on-disk skill count/set mismatch"
fi

# ===========================================================================
echo "== AC12: no lifecycle, artifact-format, readiness/state, command, or agent change =="
# ===========================================================================
# No command or agent file added, removed, or modified.
modified_cmd_agent="$(git status --porcelain -- .opencode/command .opencode/agent 2>/dev/null)"
if [ -z "$modified_cmd_agent" ]; then
  ok "AC12 no .opencode/command or .opencode/agent file changed"
else
  bad "AC12 command/agent surface changed:"; printf '%s\n' "$modified_cmd_agent" | sed 's/^/      /'
fi
cmd_n="$(ls .opencode/command/*.md 2>/dev/null | wc -l | tr -d ' ')"
agent_n="$(ls .opencode/agent/*.md 2>/dev/null | wc -l | tr -d ' ')"
[ "$cmd_n" = "12" ] && ok "AC12 command count is 12" || bad "AC12 command count is $cmd_n (expected 12)"
[ "$agent_n" = "14" ] && ok "AC12 agent count is 14" || bad "AC12 agent count is $agent_n (expected 14)"
# Phase list unchanged: the six phases, no seventh.
for p in '### 1. Requirements' '### 2. Design' '### 3. Build' '### 4. Test' '### 5. Review' '### 6. Ship'; do
  need "$WF" "$p" "AC12 phase present: $p"
done
absent "$WF" '### 7.' 'AC12 no seventh phase added'
# Derived-state table unchanged (spot-check both ends plus a routing literal).
needflat "$WF" '`spec.md` missing'                               'AC12 derived state: no spec -> /spec'
needflat "$WF" '`spec.md` present, `design.md` missing'          'AC12 derived state: spec -> /plan'
needflat "$WF" 'all boxes checked, `verify.md` missing'          'AC12 derived state: tasks -> /test'
needflat "$WF" '`review.md` verdict `request-changes`'           'AC12 derived state: request-changes -> /build'
needflat "$WF" '`review.md` verdict `approve`, no `ship.md`'     'AC12 derived state: approve -> /ship'
needflat "$WF" 'There is no state file.'                         'AC12 no state file introduced'
# Artifact templates unchanged: every template heading still present.
for h in '### `roadmap.md`' '### `spec.md`' '### `design.md`' '### `tasks.md`' '### `verify.md`' '### `review.md`' '### `ship.md`'; do
  need "$CONV" "$h" "AC12 artifact template retained: $h"
done
# Readiness/shipped signal unchanged.
needflat "$WF" 'presence is the sole shipped signal' 'AC12 shipped signal unchanged'
# The workflow.md diff is confined to the new section + wiring + ship reconcile line.
need "$WF" '## Merge conflicts' 'AC12 (diff) contract section is the change'
needflat "$WF" 'Reconcile first — if the branch has fallen behind the default' 'AC12 (diff) only Ship-process wiring added'
# Customization cost table is refreshed and internally sum-consistent.
doc_wf_kb="$(awk -F'[()]' '/`docs\/workflow.md`/{print $2}' "$CUST")"
case "$doc_wf_kb" in
  *KB*) ok "AC12 customization.md lists a refreshed docs/workflow.md size ($doc_wf_kb)";;
  *)    bad "AC12 customization.md docs/workflow.md size row missing";;
esac
needflat "$CUST" '~10.6k tokens (~42.2 KB)' 'AC12 customization total row updated'

# ===========================================================================
echo "== Edge cases =="
# ===========================================================================
# Duplicate top-level and per-parent numbers defer to the renumbering rule.
needflat "$WF" 'Both branches allocate the same `NNNN`'      'EDGE duplicate top-level NNNN named'
needflat "$WF" 'or the same per-parent `MMMM`'               'EDGE duplicate per-parent MMMM named'
# Contradictory contract rules require intent judgment -> escalate (AC5 literal).
needflat "$WF" 'judgment about competing intents'            'EDGE contradictory rules escalate'

# ===========================================================================
printf '\nTOTAL: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
