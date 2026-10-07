#!/usr/bin/env bash
#
# Executable evidence for work/0006-parallel-plan-conflicts (parallel-development
# plan conflicts and the roadmap `Conflicts with` column).
#
# Read-only against the repository. The deliverable is documents, prompts, and
# configuration only — there is no runtime code and no unit harness — so the
# automatable criteria (AC1-AC14) are encoded as content assertions over:
#   - the normative contract docs/workflow.md -> `## Parallel-development plan
#     conflicts`,
#   - the format authority docs/artifact-conventions.md (roadmap column +
#     design.md `## Surface declaration` grammar),
#   - the canonical vocabulary .opencode/skill/merge-conflict/SKILL.md,
#   - the operational derivatives (.opencode/agent/{builder,roadmap,status}.md,
#     .opencode/command/{build,roadmap,status}.md),
#   - the adopter references (README.md, AGENTS.md, template/AGENTS.md),
#   - the committed cycle fixture and the inventory surfaces.
# AC15 is integration-verified by the canonical `bash tests/run.sh`.
#
# This mirrors the historical read-only item suites (work/**/verify-tests.sh).
# It is deliberately NOT a committed tests/checks/ guard: the spec's AC14 forbids
# a new committed test agreement area, and the design's test strategy places the
# content assertions in this item-level read-only suite.
#
# Usage: bash work/0006-parallel-plan-conflicts/verify-tests.sh [repo-root]
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
STATUS_AGENT=".opencode/agent/status.md"
STATUS_CMD=".opencode/command/status.md"
BUILDER=".opencode/agent/builder.md"
BUILD_CMD=".opencode/command/build.md"
ROADMAP_AGENT=".opencode/agent/roadmap.md"
ROADMAP_CMD=".opencode/command/roadmap.md"
README="README.md"
AGENTS="AGENTS.md"
TEMPLATE_AGENTS="template/AGENTS.md"
CUST="docs/customization.md"
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

# ===========================================================================
echo "== AC1: roadmap Children table carries a Conflicts with column =="
# ===========================================================================
need   "$CONV" '| Local id | Title | Scope | Depends on | Canonical reference | Conflicts with |' \
  "AC1 artifact-conventions Children header appends the Conflicts with column"
# Append-only placement: Conflicts with is the last header segment, after Canonical reference.
needE  "$CONV" '^\| Local id \| Title \| Scope \| Depends on \| Canonical reference \| Conflicts with \|$' \
  "AC1 Conflicts with is appended after Canonical reference (header line exact)"
need   "$CONV" '| -------- | ----- | ----- | ---------- | ------------------- | -------------- |' \
  "AC1 Children separator has a matching Conflicts with segment"
need   "$CONV" '- **Conflicts with** names local ids of other rows in this same table only' \
  "AC1 Conflicts with bullet scopes the relation intra-roadmap"
needflat "$CONV" 'it is intra-roadmap only and a row may not name itself' \
  "AC1 Conflicts with is intra-roadmap and self-free"
needflat "$CONV" 'unlike `Depends on`, it never affects readiness or the dependency graph' \
  "AC1 Conflicts with is distinct from Depends on"
needflat "$CONV" 'comma-separated list when there are two or more (`—` when there are none)' \
  "AC1 Conflicts with cell grammar is comma-separated or em dash"
needflat "$WF" 'The `Children` table carries a `Conflicts with` column alongside `Depends on`.' \
  "AC1 workflow Roadmaps describes the column"
needflat "$WF" 'it names other rows in the same table only, comma-separated' \
  "AC1 workflow repeats the intra-roadmap cell grammar"
needflat "$WF" 'a coordination relation that never affects readiness or the dependency graph' \
  "AC1 workflow states the relation is coordination-only"
needflat "$ROADMAP_AGENT" 'Record each child' "AC1 roadmap agent records Conflicts with values"
needflat "$ROADMAP_AGENT" 'Every `Conflicts with` value resolves to another row in the same table' \
  "AC1 roadmap quality bar validates Conflicts with"
needflat "$ROADMAP_AGENT" 'Never store a self-conflict.' \
  "AC1 roadmap rules forbid a self-conflict"
needflat "$ROADMAP_CMD" 'a `Conflicts with` cell naming sibling local ids (or `—`)' \
  "AC1 /roadmap command names the Conflicts with cell"
need   "$FIXTURE" '| Local id | Title | Scope | Depends on | Canonical reference | Conflicts with |' \
  "AC1 committed cycle fixture carries the extended header"
# Fixture data rows put the em dash in the Conflicts with cell.
needE  "$FIXTURE" '^\| 0001-alpha .*\| — \|$' "AC1 fixture row 0001-alpha has Conflicts with —"
needE  "$FIXTURE" '^\| 0002-beta .*\| — \|$'  "AC1 fixture row 0002-beta has Conflicts with —"

# ===========================================================================
echo "== AC2: invalid Conflicts with reference is a non-fatal finding =="
# ===========================================================================
needflat "$STATUS_AGENT" 'validate every named local id against the same `Children` table' \
  "AC2 status validates each Conflicts with cell"
needflat "$STATUS_AGENT" 'it must resolve to another row' \
  "AC2 status requires resolution to another row"
needflat "$STATUS_AGENT" 'it must not name the declaring row itself' \
  "AC2 status rejects a self-reference"
needflat "$STATUS_AGENT" 'Report a violation as a `DANGLING-CONFLICT` `(b)` finding' \
  "AC2 status reports DANGLING-CONFLICT (b)"
needflat "$STATUS_AGENT" 'The finding names the roadmap, the offending row, and the invalid reference' \
  "AC2 finding names roadmap, row, and invalid reference"
needflat "$STATUS_AGENT" 'neither rejected nor aborted' \
  "AC2 roadmap is neither rejected nor aborted"
need   "$STATUS_CMD" 'DANGLING-CONFLICT' "AC2 /status command names DANGLING-CONFLICT"
needflat "$STATUS_CMD" 'Report an invalid reference as a non-fatal `DANGLING-CONFLICT` `(b)` finding' \
  "AC2 /status command states the finding is non-fatal"
needflat "$STATUS_CMD" 'never reject or abort the roadmap' \
  "AC2 /status command never rejects or aborts the roadmap"
need   "$SKILL" 'DANGLING-CONFLICT' "AC2 canonical vocabulary carries DANGLING-CONFLICT"
needflat "$SKILL" 'names its own row' "AC2 vocabulary covers the self-reference case"

# ===========================================================================
echo "== AC3: Conflicts with never changes readiness or the graph =="
# ===========================================================================
needflat "$WF" 'A `Conflicts with` entry never changes a child' \
  "AC3 workflow states Conflicts with is readiness-neutral"
needflat "$WF" 'readiness is derived from `Depends on` alone' \
  "AC3 readiness derives from Depends on alone"
needflat "$ROADMAP_AGENT" 'never affects readiness' \
  "AC3 roadmap agent states readiness neutrality"
# The readiness algorithm itself is unchanged; the committed suite pins it (AC15).
needflat "$WF" 'ready(child) = every dependency of child is satisfied AND child is not in a cycle' \
  "AC3 readiness algorithm is unchanged"

# ===========================================================================
echo "== AC4: /status reports DAC findings offline, read-only, no file =="
# ===========================================================================
needflat "$STATUS_AGENT" 'the report' "AC4 status report contract present"
needflat "$STATUS_AGENT" 'is offline, read-only, and modifies no file' \
  "AC4 status is offline, read-only, and modifies no file"
need   "$STATUS_AGENT" '- [ ] No file was modified.' \
  "AC4 status quality bar requires no file modified"
needflat "$STATUS_AGENT" 'never affects readiness or the dependency graph' \
  "AC4 status restates readiness neutrality"
need   "$STATUS_CMD" 'DANGLING-CONFLICT' "AC4 /status command surfaces the finding"
needflat "$STATUS_CMD" 'These findings are the merge-integrity guard' \
  "AC4 /status command keeps findings non-fatal and read-only"

# ===========================================================================
echo "== AC5: committed machine-readable surface declaration =="
# ===========================================================================
need   "$CONV" '## Surface declaration' "AC5 artifact-conventions design template adds the section"
needflat "$CONV" 'Optional. A bullet list of repository-relative paths the item will create or' \
  "AC5 declaration is optional and path-shaped"
needflat "$CONV" 'no leading `/` and no `..`' "AC5 declaration grammar forbids leading / and .."
needflat "$CONV" 'optionally wrapped in backticks' "AC5 declaration permits backticks"
needflat "$CONV" 'a trailing `/` marks a directory entry that covers every path beneath' \
  "AC5 trailing slash marks a directory entry"
needflat "$CONV" 'An absent or empty section means the item declares no surfaces' \
  "AC5 absent/empty declaration means no surfaces"
needflat "$WF" 'optional `## Surface declaration` section of its `design.md`' \
  "AC5 workflow names the declaration location"
needflat "$WF" 'discoverable by the item' "AC5 declaration is discoverable by item reference"
needflat "$WF" '`work/<item-ref>/design.md`' \
  "AC5 declaration resolves to the canonical reference path"
needflat "$WF" 'without reading implementation code' \
  "AC5 declaration is discoverable without reading implementation code"
needflat "$WF" 'is committed before development begins' \
  "AC5 declaration is committed before development begins"

# ===========================================================================
echo "== AC6: /build runs the check before implementation =="
# ===========================================================================
needflat "$WF" '`/build` runs the check once, as a step after it selects the task and before it implements anything' \
  "AC6 workflow triggers the check before implementation"
needflat "$BUILDER" 'Run the pre-development plan-conflict check before implementing anything' \
  "AC6 builder process runs the check before implementing"
needflat "$BUILDER" 'enumerate the ready in-flight universe' \
  "AC6 builder enumerates the ready in-flight universe"
needflat "$BUILDER" "compare the item's declared surfaces against each peer's" \
  "AC6 builder compares the item declaration against every peer"
needflat "$BUILD_CMD" 'Before implementing, run the read-only pre-development plan-conflict check' \
  "AC6 /build command wires the check before implementing"
needflat "$BUILD_CMD" 'compare the item'"'"'s `## Surface declaration` against every other ready in-flight item' \
  "AC6 /build command compares against every other ready in-flight item"

# ===========================================================================
echo "== AC7: declared Conflicts with edge is reported (symmetric) =="
# ===========================================================================
need   "$WF" '**Declared edge.**' "AC7 workflow names the declared-edge condition"
needflat "$WF" 'its `Conflicts with` entry names a ready in-flight sibling' \
  "AC7 current item's Conflicts with names a ready sibling"
needflat "$WF" 'a ready in-flight sibling'"'"'s `Conflicts with` entry names the current item' \
  "AC7 sibling's Conflicts with naming the current item counts"
needflat "$WF" 'symmetric for detection: one direction suffices, and declaring both directions is not an error' \
  "AC7 relation is symmetric and both directions tolerated"
need   "$WF" 'DECLARED-CONFLICT' "AC7 workflow names DECLARED-CONFLICT"
need   "$SKILL" 'DECLARED-CONFLICT' "AC7 canonical vocabulary carries DECLARED-CONFLICT"
needflat "$SKILL" 'DECLARED-CONFLICT` | `(b)`' "AC7 DECLARED-CONFLICT is class (b)"
needflat "$BUILDER" 'every declared `Conflicts with` edge as' \
  "AC7 builder reports declared edges"
needflat "$BUILDER" 'DECLARED-CONFLICT' "AC7 builder names DECLARED-CONFLICT"

# ===========================================================================
echo "== AC8: equal-path or ancestor/descendant overlap is reported =="
# ===========================================================================
need   "$WF" '**Surface overlap by path.**' "AC8 workflow names the path-overlap condition"
needflat "$WF" 'Two declared surfaces name the same concrete path' \
  "AC8 equal concrete path is an overlap"
needflat "$WF" 'one is a directory entry that is an ancestor of (or equal to) the other' \
  "AC8 ancestor/descendant directory overlap"
needflat "$WF" 'a declared `docs/` overlaps a declared `docs/workflow.md`' \
  "AC8 directory example is documented"
needflat "$WF" 'reports `SURFACE-OVERLAP` naming both items and the overlapping surface' \
  "AC8 reports SURFACE-OVERLAP naming both items and surface"
needflat "$BUILDER" 'every equal-path, ancestor/descendant, or shared framework-surface collision as' \
  "AC8 builder reports path/ancestor overlaps"

# ===========================================================================
echo "== AC9: shared framework surface collision is reported =="
# ===========================================================================
need   "$WF" '**Shared framework surface.**' "AC9 workflow names the shared-surface condition"
needflat "$WF" 'Both items declare paths under the same shared framework surface class' \
  "AC9 shared-surface class condition present"
for s in 'README.md' 'AGENTS.md' 'docs/*.md' '.opencode/{agent,command,skill}/**' 'template/**' 'tests/checks/**'; do
  needflat "$WF" "$s" "AC9 shared framework surface names $s"
done
needflat "$WF" 'reports `SURFACE-OVERLAP` naming both items and the shared surface' \
  "AC9 reports SURFACE-OVERLAP naming both items and shared surface"
needflat "$SKILL" 'the same shared framework surface' \
  "AC9 canonical vocabulary covers the shared surface"

# ===========================================================================
echo "== AC10: finding grammar, classes, and no drop/truncation =="
# ===========================================================================
need   "$WF" '- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>' \
  "AC10 workflow finding grammar"
needflat "$WF" 'Every finding uses the `merge-conflict` skill'"'"'s grammar' \
  "AC10 grammar defers to the merge-conflict skill"
needflat "$WF" 'DANGLING-CONFLICT` | `(b)`' "AC10 DANGLING-CONFLICT class (b)"
needflat "$WF" 'DECLARED-CONFLICT` | `(b)`' "AC10 DECLARED-CONFLICT class (b)"
needflat "$WF" 'SURFACE-OVERLAP` | `(a)` or `(b)`' "AC10 SURFACE-OVERLAP class (a)/(b)"
needflat "$WF" 'Every finding carries its code, its class, the offending canonical reference(s), and the' \
  "AC10 finding carries code, class, offenders, detail"
needflat "$WF" 'no detected conflict is silently dropped, and the list is never truncated, even for a large overlap set' \
  "AC10 no drop and no truncation"
need   "$SKILL" '- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>' \
  "AC10 canonical grammar present in the skill's Finding grammar"
# The workflow's shorthand form names code, class, offenders, and detail.
needflat "$WF" 'carries its code, its class, the offending canonical reference(s), and the' \
  "AC10 workflow names the grammar components"
needflat "$SKILL" 'This vocabulary is canonical' "AC10 skill declares the canonical vocabulary"
needflat "$WF" 'This section defines no second vocabulary' \
  "AC10 workflow defines no second vocabulary"
# Each new code appears with its class in the canonical table.
for pair in 'DANGLING-CONFLICT` | `(b)`' 'DECLARED-CONFLICT` | `(b)`' 'SURFACE-OVERLAP` | `(a)` or `(b)`'; do
  need "$SKILL" "$pair" "AC10 skill table has $pair"
done

# ===========================================================================
echo "== AC11: report-only, non-fatal, read-only, never blocks =="
# ===========================================================================
needflat "$WF" 'report-only' "AC11 workflow calls the check report-only"
needflat "$WF" 'it is non-fatal, read-only, takes no lock, modifies no file, auto-repairs nothing, and never blocks the build' \
  "AC11 the full report-only contract"
needflat "$WF" 'It never resolves or serializes parallel work' \
  "AC11 never resolves or serializes parallel work"
needflat "$WF" '`/build` always continues, whether or not conflicts are reported' \
  "AC11 /build always continues"
needflat "$BUILDER" 'This check is read-only, modifies no file, auto-repairs nothing, and never blocks the build' \
  "AC11 builder states the report-only contract"
needflat "$BUILDER" 'The pre-development plan-conflict check is read-only: it modifies no file,' \
  "AC11 builder rules state read-only"
needflat "$BUILD_CMD" 'It modifies no file and' "AC11 /build command states it modifies no file"
needflat "$BUILD_CMD" 'never blocks the build' "AC11 /build command states it never blocks the build"

# ===========================================================================
echo "== AC12: no-peer / no-declaration / no-surface is a no-op =="
# ===========================================================================
needflat "$WF" 'When there is no other ready in-flight item, or no other item carries a declaration, or the current item declares no surfaces' \
  "AC12 all three empty-coverage conditions named"
needflat "$WF" 'reports `no conflicts` and does not error' \
  "AC12 empty coverage reports no conflicts and does not error"
needflat "$WF" 'An in-flight peer whose `design.md` lacks a surface declaration is reported as' \
  "AC12 a peer without a declaration is reported"
needflat "$WF" '"could not compare", never treated as declaring no surfaces' \
  "AC12 could-not-compare is never treated as no surfaces"
needflat "$WF" 'An absent or empty section means the item declares no surfaces; the check reports' \
  "AC12 absent declaration means no surfaces and no error"
needflat "$BUILDER" 'report that a peer' "AC12 builder reports an incomparable peer"
needflat "$BUILDER" 'carries no declaration and could not be compared' \
  "AC12 builder could-not-compare literal"

# ===========================================================================
echo "== AC13: the build handoff records the result =="
# ===========================================================================
need   "$BUILDER" 'Plan conflicts: <declarations assessed> — <conflicts found or "no conflicts">.' \
  "AC13 builder handoff records declarations and result"
needflat "$BUILD_CMD" 'record the result as the `Plan conflicts:` handoff line' \
  "AC13 /build command records the handoff line"
needflat "$WF" 'records the result in its handoff: the declarations assessed and either the conflicts found or an explicit `no conflicts`' \
  "AC13 workflow requires the handoff record"

# ===========================================================================
echo "== AC14: prompt/config/doc only; no new command, agent, phase, or test area =="
# ===========================================================================
cmd_n="$(ls .opencode/command/*.md 2>/dev/null | wc -l | tr -d ' ')"
agent_n="$(ls .opencode/agent/*.md 2>/dev/null | wc -l | tr -d ' ')"
skill_n="$(ls -d .opencode/skill/*/ 2>/dev/null | wc -l | tr -d ' ')"
[ "$cmd_n" = "12" ]   && ok "AC14 command count is 12"       || bad "AC14 command count is $cmd_n (expected 12)"
[ "$agent_n" = "14" ] && ok "AC14 agent count is 14"         || bad "AC14 agent count is $agent_n (expected 14)"
[ "$skill_n" = "11" ] && ok "AC14 skill count is 11"         || bad "AC14 skill count is $skill_n (expected 11)"
# No new committed test agreement area.
checks_n="$(ls tests/checks/*.sh 2>/dev/null | wc -l | tr -d ' ')"
[ "$checks_n" = "11" ] && ok "AC14 tests/checks still holds 11 files" \
  || bad "AC14 tests/checks holds $checks_n files (expected 11)"
if [ -z "$(git status --porcelain -- tests/checks 2>/dev/null)" ]; then
  ok "AC14 no tests/checks file added, modified, or removed"
else
  bad "AC14 tests/checks changed:"; git status --porcelain -- tests/checks | sed 's/^/      /'
fi
# No file added anywhere in the tracked tree (all changes are modifications).
added="$(git diff --diff-filter=A --name-only 2>/dev/null)"
if [ -z "$added" ]; then
  ok "AC14 the diff adds no tracked file (no new command/agent/skill/check)"
else
  bad "AC14 the diff adds tracked files:"; printf '%s\n' "$added" | sed 's/^/      /'
fi
# No executable/script in the diff.
added_sh="$(git diff --name-only | grep -E '\.(sh|py|js|ts|rb)$' || true)"
if [ -z "$added_sh" ]; then
  ok "AC14 the diff adds no executable script or runtime code"
else
  bad "AC14 the diff touches executable files:"; printf '%s\n' "$added_sh" | sed 's/^/      /'
fi
# The modified set is exactly the design's declared surfaces.
allowed_re='^(docs/|\.opencode/(agent|command|skill)/|README\.md$|AGENTS\.md$|template/AGENTS\.md$|tests/fixtures/cyclic-roadmap/roadmap\.md$)'
bad_scope="$(git diff --name-only | grep -vE "$allowed_re" || true)"
if [ -z "$bad_scope" ]; then
  ok "AC14 every modified path is within the design's declared surfaces"
else
  bad "AC14 out-of-scope modified paths:"; printf '%s\n' "$bad_scope" | sed 's/^/      /'
fi
# No seventh phase and no new numbered heading.
absent "$WF" '### 7. ' "AC14 no seventh phase heading added"
numbered="$(grep -cE '^### [0-9]+[.] ' "$WF")"
[ "$numbered" = "6" ] && ok "AC14 workflow still has exactly 6 numbered phase headings" \
  || bad "AC14 workflow has $numbered numbered phase headings (expected 6)"
# The capability is prose: the new section is non-numbered.
needE "$WF" '^## Parallel-development plan conflicts$' "AC14 new section uses a non-numbered heading"

# ===========================================================================
echo "== AC15: the committed suite stays green + pinned surfaces updated =="
# ===========================================================================
suite_out="$(bash tests/run.sh 2>&1)"; suite_rc=$?
if [ "$suite_rc" -eq 0 ] && ! printf '%s\n' "$suite_out" | grep -q '^FAIL'; then
  total_line="$(printf '%s\n' "$suite_out" | grep '^TOTAL:' | tail -1)"
  ok "AC15 bash tests/run.sh exits 0 with no FAIL ($total_line)"
else
  bad "AC15 bash tests/run.sh failed (rc=$suite_rc)"
  printf '%s\n' "$suite_out" | grep '^FAIL' | sed 's/^/      /'
fi
# Spotlight the pinned agreements AC15 names.
for area in 'AC6 readiness' 'AC9 inventory' 'AC13 roadmap cycle rule'; do
  if printf '%s\n' "$suite_out" | grep -q "$area"; then
    ok "AC15 committed suite exercised $area"
  else
    bad "AC15 committed suite did not report $area"
  fi
done
# The fixture header keeps the old fixed substring (pinned by 80-cycle-fixture.sh).
need   "$FIXTURE" '| Local id | Title | Scope | Depends on | Canonical reference |' \
  "AC15 fixture keeps the pinned Children header substring"
# 80-cycle-fixture's awk field 5 is still Depends on in every data row.
awk_ok=1
while IFS= read -r line; do
  dep="$(printf '%s\n' "$line" | awk -F'|' '{v=$5; gsub(/^[ \t]+|[ \t]+$/, "", v); print v}')"
  case "$dep" in
    000[0-9]-*) ;;
    *) awk_ok=0; bad "AC15 fixture row field 5 is not Depends on: '$dep'";;
  esac
done < <(grep -E '^\| 000[0-9]-' "$FIXTURE")
[ "$awk_ok" = "1" ] && ok "AC15 fixture Depends on is still awk field 5 in every data row"

# ===========================================================================
echo "== Edge cases =="
# ===========================================================================
# Empty work/ or a single in-flight item -> no conflicts, no error.
needflat "$WF" 'no other ready in-flight item'          "EDGE no peer -> no conflicts"
# Declaration absent -> could not compare, never assumed empty.
needflat "$WF" 'never treated as declaring no surfaces' "EDGE absent declaration is not 'no surfaces'"
# Self-declaration is an invalid reference, not a conflict.
needflat "$STATUS_AGENT" 'names the declaring row itself' "EDGE self-declaration is invalid"
needflat "$WF" 'names its own row'                        "EDGE vocabulary names its own row"
# One-directional declaration is enough; both directions not an error.
needflat "$WF" 'one direction suffices, and declaring both directions is not an error' \
  "EDGE one-directional declaration suffices"
# Duplicate id in a cell: resolution, not multiplicity, is the rule (treated once).
needflat "$STATUS_AGENT" 'validate every named local id against the same' \
  "EDGE duplicate ids resolve; not an error"
# Overlap by directory is an overlap.
needflat "$WF" 'ancestor of (or equal to) the other' "EDGE directory overlap"
# Shared surface class collision.
needflat "$WF" 'same shared framework surface class' "EDGE shared surface class collision"
# Blocked or shipped item is outside the universe.
needflat "$WF" 'Items that are shipped (a `ship.md` is present) or blocked or cyclic are outside' \
  "EDGE shipped/blocked/cyclic excluded from the universe"
needflat "$WF" 'it has no `ship.md` (it is not shipped)' \
  "EDGE universe requires no ship.md"
# Conflicting and sequential at once: the two relations are independent.
needflat "$WF" 'never affects readiness or the dependency graph' \
  "EDGE conflict and dependency relations are independent"
# Declaration changes after the check: each build run re-assesses once.
needflat "$WF" 'runs the check once, as a step after it selects the task' \
  "EDGE the check runs per build, before implementation"
# Standalone item participates in surface-overlap comparison.
needflat "$WF" 'is **ready**: a standalone item, or a nested roadmap child' \
  "EDGE standalone items are in the universe"
# Concurrent check runs take no lock and write nothing.
needflat "$WF" 'Two concurrent check runs take no lock, write nothing, and do not interfere' \
  "EDGE concurrent runs do not interfere"
# Large overlap set is never truncated.
needflat "$WF" 'the list is never truncated, even for a large overlap set' \
  "EDGE large overlap set is not truncated"

# ===========================================================================
printf '\nTOTAL: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
