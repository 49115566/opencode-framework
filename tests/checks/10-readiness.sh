#!/usr/bin/env bash
#
# AC6 — readiness / dependency-satisfaction agreement.
#
# The readiness algorithm has exactly one authoritative statement, in
# docs/workflow.md. Every other live readiness surface defers to that source by
# name rather than restating the branch sequence, and no live surface contradicts
# the approved-but-unshipped or ship.md-precedence semantics.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC6 token.

echo "== AC6 readiness / dependency-satisfaction agreement =="

# The explicit candidate set that could carry a readiness restatement. work/**
# is deliberately excluded: this suite must run on a fresh clone.
readiness_surfaces="$WF $AGENT_DIR/status.md $CMD_DIR/status.md $AGENT_DIR/product.md $CONV $SKILL_DIR/workflow-lifecycle/SKILL.md"

# (i) The algorithm marker occurs exactly once, and only in the authority.
algo_hits=0
algo_file=""
for f in $readiness_surfaces; do
  if [ -f "$f" ] && has "$f" 'satisfied(dep_local_id):'; then
    algo_hits=$((algo_hits+1))
    algo_file="$f"
  fi
done
if [ "$algo_hits" -eq 1 ] && [ "$algo_file" = "$WF" ]; then
  ok "AC6 readiness algorithm stated exactly once, in $WF"
else
  bad "AC6 readiness algorithm appears in $algo_hits candidate file(s): ${algo_file:-none}"
fi

# (ii) The other readiness surfaces defer to the authority by name.
for f in "$AGENT_DIR/status.md" "$CMD_DIR/status.md" "$AGENT_DIR/product.md"; do
  need "$f" 'Dependencies and readiness' "AC6 $f defers to the readiness authority"
done

# (iii) The authority states approved-but-unshipped satisfaction, that ship.md
# presence is the sole shipped signal, and that it takes precedence.
need "$WF" 'even if unshipped' "AC6 $WF states approved-but-unshipped is satisfied"
need "$WF" 'presence is the sole shipped signal' "AC6 $WF states ship.md presence is the sole shipped signal"
needE "$WF" 'ship\.md. presence takes precedence' "AC6 $WF states ship.md presence takes precedence"

# (iv) No live surface contradicts approved-but-unshipped semantics. Scans the
# candidate readiness surfaces plus every agent/command prompt; work/ history is
# never inspected.
contra=0
for f in $WF $AGENT_DIR/*.md $CMD_DIR/*.md $CONV $SKILL_DIR/workflow-lifecycle/SKILL.md $README; do
  if [ -f "$f" ] && grep -qiE -- 'approved-but-unshipped.*not satisfied|not satisfied.*approved-but-unshipped' "$f"; then
    bad "AC6 $f contradicts approved-but-unshipped"
    contra=$((contra+1))
  fi
done
[ "$contra" -eq 0 ] && ok "AC6 no live surface contradicts approved-but-unshipped"
