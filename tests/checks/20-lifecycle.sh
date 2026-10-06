#!/usr/bin/env bash
#
# AC7 — lifecycle and derived-state agreement.
#
# The phase list, the command routing, and the derived-state transitions are
# duplicated across the always-loaded contract (AGENTS.md), the workflow
# authority (docs/workflow.md), the README, and the workflow-lifecycle skill.
# This check asserts those surfaces agree: it fails when a phase or transition
# exists in one surface but is missing from or contradicted by another.
#
# It compares the phase *set* and *routing*, not command argument signatures
# (the `item-ref` usage strings are owned by 0009-surface-consistency).
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC7 token.

echo "== AC7 lifecycle / derived-state agreement =="

LIFECYCLE_SKILL="$SKILL_DIR/workflow-lifecycle/SKILL.md"
CORE_CMDS="/spec /plan /build /test /review /ship"

# (a) The six core phase commands appear in all four always-live surfaces.
for c in $CORE_CMDS; do
  for f in "$AGENTS" "$WF" "$README" "$LIFECYCLE_SKILL"; do
    need "$f" "$c" "AC7 $c appears in $f"
  done
done

# (b) Command -> agent pairs agree between the AGENTS.md lifecycle table and the
# README commands table for every command both tables name. Only markdown table
# rows (leading `|`) are considered, so prose mentioning a command is ignored.
pair_agent() {
  # $1 = file, $2 = command token with leading slash
  awk -v cmd="$2" '
    /^\|/ && index($0, "`" cmd) {
      n = split($0, a, "`")
      found = 0
      for (i = 1; i <= n; i++) {
        t = a[i]
        gsub(/^[ \t]+|[ \t]+$/, "", t)
        if (!found && t ~ ("^" cmd "( |$)")) { found = 1; continue }
        if (found && t ~ /^[a-z][a-z-]*$/) { print t; exit }
      }
    }
  ' "$1"
}

for c in $CORE_CMDS; do
  a_agent="$(pair_agent "$AGENTS" "$c")"
  r_agent="$(pair_agent "$README" "$c")"
  if [ -n "$a_agent" ] && [ -n "$r_agent" ] && [ "$a_agent" = "$r_agent" ]; then
    ok "AC7 $c -> $a_agent agrees between AGENTS.md and README.md"
  else
    bad "AC7 $c agent disagrees: AGENTS.md='${a_agent:-<none>}' README.md='${r_agent:-<none>}'"
  fi
done

# (c) The seven core routing conditions agree between the workflow derived-state
# table and the skill's "Which command now?" block.
route_case() {
  # $1 = label, $2 = workflow literal, $3 = skill literal
  need "$WF" "$2" "AC7 workflow routes $1"
  need "$LIFECYCLE_SKILL" "$3" "AC7 skill routes $1"
}
route_case "no spec -> /spec" \
  '`spec.md` missing' 'No spec.md?'
route_case "spec without design -> /plan" \
  '`spec.md` present, `design.md` missing' 'spec.md, no design.md?'
route_case "design without tasks -> /build" \
  '`design.md` present, `tasks.md` missing' 'design.md, tasks.md unchecked?'
route_case "all tasks checked without verify -> /test" \
  'all boxes checked, `verify.md` missing' 'all tasks checked, no verify.md?'
route_case "verify without review -> /review" \
  '`verify.md` present, `review.md` missing' 'verify.md, no review.md?'
route_case "review request-changes -> /build" \
  '`review.md` verdict `request-changes`' 'review.md verdict request-changes'
route_case "review approve without ship -> /ship" \
  '`review.md` verdict `approve`, no `ship.md`' 'review.md verdict approve, no ship.md?'

# (d) The core derived-state artifact names appear in the workflow, the README
# state diagram, and the skill. visual.md is the optional phase's artifact, so
# it is required only where that phase is described (workflow and README).
for a in spec.md design.md tasks.md verify.md review.md ship.md; do
  for f in "$WF" "$README" "$LIFECYCLE_SKILL"; do
    need "$f" "$a" "AC7 $a is named in $f"
  done
done
for f in "$WF" "$README"; do
  need "$f" 'visual.md' "AC7 visual.md is named in $f (optional phase)"
done
