#!/usr/bin/env bash
#
# Executable evidence for work/0002-agentic-roadmaps.
# Read-only. Encodes the automatable (static) acceptance criteria for the
# roadmap capability. The LLM-driven halves of AC1, AC3, AC5-AC7, AC9, AC12,
# AC14, AC15 are exercised by real agent runs recorded in verify.md.
#
# This repo has no test runner (no root package.json/pyproject.toml); per
# design.md "Test strategy", framework verification is read-only shell
# assertions plus real agent invocation. This script lives under work/ with the
# rest of the artifacts, matching work/0001-framework-consistency-hardening.
#
# Usage: bash work/0002-agentic-roadmaps/verify-tests.sh [repo-root]
#   repo-root defaults to the git top level, so the same suite can be pointed
#   at a copy for mutation testing.
# Exit:  0 = pass, 1 = one or more failures.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

AGENT_DIR=".opencode/agent"; CMD_DIR=".opencode/command"; SKILL_DIR=".opencode/skill"
CONV="docs/artifact-conventions.md"; WF="docs/workflow.md"
pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
has()  { grep -qF -- "$2" "$1"; }              # literal presence
hasE() { grep -qE -- "$2" "$1"; }              # regex presence
fm()   { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; } # frontmatter
agent_names() { ls "$AGENT_DIR"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
cmd_names()   { ls "$CMD_DIR"/*.md   2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
skill_names() { ls -d "$SKILL_DIR"/*/ 2>/dev/null | xargs -n1 basename | sort; }
# Assert a token is present in a file, labelled.
need()  { has "$1" "$2" && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needE() { hasE "$1" "$2" && ok "$3" || bad "$3 (no /$2/ in $1)"; }

echo "== AC1: /roadmap command + autonomous authoring agent =="
[ -f "$CMD_DIR/roadmap.md" ] && ok "AC1 command/roadmap.md exists" || bad "AC1 command/roadmap.md missing"
fm "$CMD_DIR/roadmap.md" | grep -qF 'agent: roadmap' && ok "AC1 command routes to roadmap agent" || bad "AC1 command agent field"
fm "$AGENT_DIR/roadmap.md" | grep -qE '^mode: primary' && ok "AC1 roadmap agent is primary" || bad "AC1 roadmap agent mode"
fm "$AGENT_DIR/roadmap.md" | grep -qF '"work/**": allow' && fm "$AGENT_DIR/roadmap.md" | grep -qF '"**/work/**": allow' \
  && ok "AC1 roadmap agent may write both work path forms" || bad "AC1 roadmap agent work edit grant"
has "$AGENT_DIR/roadmap.md" 'next top-level `NNNN`' && ok "AC1 allocates next top-level NNNN" || bad "AC1 NNNN allocation text"
has "$CMD_DIR/roadmap.md" 'autonomous' && ok "AC1 command states autonomous, no approval gate" || bad "AC1 autonomy text"
has "$CMD_DIR/roadmap.md" 'pre-write approval gate' && ok "AC1 explicit no pre-write gate" || bad "AC1 no-gate text"

echo "== AC2: roadmap artifact identifies initiative/assumptions/children =="
for tok in 'phase: roadmap' '## Initiative' '## Assumptions' '## Children' '## Sequencing' '## Open issues'; do
  need "$CONV" "$tok" "AC2 template contains '$tok'"
done
for col in '| Local id |' 'Title' 'Scope' 'Depends on' 'Canonical reference'; do
  need "$CONV" "$col" "AC2 Children table column '$col'"
done
need "$AGENT_DIR/roadmap.md" 'unique local id' "AC2 agent requires unique local ids"
need "$AGENT_DIR/roadmap.md" 'scope sufficient to author a' "AC2 agent requires spec-sufficient scope"

echo "== AC3: child directories contain only .gitkeep, no phase artifact =="
need "$AGENT_DIR/roadmap.md" 'work/<NNNN-slug>/<MMMM-slug>/.gitkeep' "AC3 agent creates child .gitkeep"
need "$AGENT_DIR/roadmap.md" 'contains no phase artifact' "AC3 agent quality bar forbids phase artifact"
need "$AGENT_DIR/roadmap.md" 'no spec, design, tasks' "AC3 agent names forbidden child artifacts"
need "$AGENT_DIR/status.md" 'is a placeholder, not a phase' "AC3 .gitkeep treated as placeholder, not a phase artifact"

echo "== AC4: dependency integrity rules (existing, no self, acyclic) =="
need "$WF" 'may not name its own row' "AC4 workflow: no self-dependency"
need "$WF" 'must be acyclic' "AC4 workflow: acyclic graph"
need "$WF" 'records the cycle under' "AC4 workflow: cycle goes to Open issues"
need "$AGENT_DIR/roadmap.md" 'may not depend on itself' "AC4 agent: no self-dependency"
need "$AGENT_DIR/roadmap.md" 'stored graph must' "AC4 agent: stored graph acyclic"
need "$CONV" 'leave the stored graph acyclic' "AC4 conventions: cycle not stored"

echo "== AC5/AC6: readiness algorithm, single definition, boundary handling =="
for tok in 'satisfied(dep_local_id):' 'if child_dir/ship.md exists' 'and its verdict == "approve"' \
           'A child with no dependencies is `ready`' 'A child in a cycle is never `ready`'; do
  need "$WF" "$tok" "AC5/6 workflow algorithm token '$tok'"
  need "$AGENT_DIR/status.md" "$tok" "AC5/6 status algorithm token '$tok'"
done
need "$WF" 'a `request-changes` verdict' "AC6 workflow: request-changes not satisfied"
need "$AGENT_DIR/status.md" 'Only a `review.md` verdict of `approve`' "AC6 status: only approve/ship satisfies"
need "$AGENT_DIR/product.md" 'run the readiness algorithm' "AC9 product gate reuses readiness algorithm"

echo "== AC7: roadmap reported separately with ready count + phase tally =="
need "$AGENT_DIR/status.md" '<ready>/<total> ready' "AC7 status shows ready/total"
need "$AGENT_DIR/status.md" 'phases:' "AC7 status shows phase distribution tally"
need "$CMD_DIR/status.md" 'distribution tally' "AC7 command states distribution tally"
need "$WF" 'distribution tally' "AC7 docs state distribution tally"
need "$AGENT_DIR/status.md" 'never a child phase' "AC7 roadmap is parent-only phase"

echo "== AC8: canonical reference resolution across phases =="
need "$CONV" '## Work item references' "AC8 conventions reference section"
need "$CONV" '^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$' "AC8 reference grammar regex"
need "$WF" 'one-segment reference behaves exactly as' "AC8 workflow: one-segment unchanged"
for a in product architect builder tester reviewer shipper visual; do
  need "$AGENT_DIR/$a.md" 'NNNN-slug/MMMM-slug' "AC8 agent $a resolves nested ref"
done
need "$AGENT_DIR/status.md" 'canonical reference' "AC8 status handles canonical references"
for c in spec plan build test review ship visual; do
  need "$CMD_DIR/$c.md" 'NNNN-slug/MMMM-slug' "AC8 command /$c carries item-ref note"
done

echo "== AC9: blocked-start gate refuses, override records, touches nothing =="
need "$AGENT_DIR/product.md" 'report the specific blocking children and stop before writing' "AC9 product refuses and stops"
need "$AGENT_DIR/product.md" 'explicit user override' "AC9 product requires explicit override"
need "$AGENT_DIR/product.md" 'override and the blocking dependencies in the new' "AC9 override recorded in notes"
need "$AGENT_DIR/product.md" 'Refusing must touch no existing file' "AC9 refusal is non-destructive"
need "$WF" '### Starting a blocked child' "AC9 workflow documents blocked-start protocol"
need "$WF" 'status still reports the child' "AC9 override stays visible in status"

echo "== AC10: derived state, no state file, read-only status =="
fm "$AGENT_DIR/status.md" | grep -qF 'edit: deny' && ok "AC10 status edit: deny" || bad "AC10 status edit deny"
for w in '"git add' '"git commit' '"git push' '"rm ' '"mv ' '"mkdir' '"touch' '"tee ' '"sed -i'; do
  grep -qF -- "$w" "$AGENT_DIR/status.md" && bad "AC10 status has write-capable token: $w" || ok "AC10 status has no write token: $w"
done
need "$AGENT_DIR/status.md" 'derived live, never stored' "AC10 status: readiness derived live, not stored"
need "$WF" 'it is never stored' "AC10 workflow: readiness never stored"
need "$WF" 'Status is read-only and modifies nothing' "AC10 workflow: status read-only"
need "$WF" 'There is no state file.' "AC10 workflow: no state file"
need "$AGENT_DIR/status.md" 'Never write or refresh a readiness value' "AC10 status forbids storing readiness"

echo "== AC11: standalone items unchanged (parent optional, one-segment) =="
need "$CONV" '`parent` is optional' "AC11 conventions: parent optional"
need "$CONV" 'Standalone items omit it' "AC11 standalone omits parent"
need "$CONV" 'standalone items require no `parent`' "AC11 no dependency metadata required"
need "$WF" 'Phase commands accept either form' "AC11 workflow: one-segment reference unchanged"
# The spec.md template must NOT have gained a required parent field.
spec_block="$(awk '/^### `spec\.md` \(product\)/{f=1} f&&/^### /&&!/spec\.md/{exit} f' "$CONV")"
printf '%s' "$spec_block" | grep -qF 'parent:' && bad "AC11 spec template gained a parent field" || ok "AC11 spec template still has no parent field"
# Standalone derived-state rows must survive verbatim.
for row in '`spec.md` missing' '`review.md` verdict `approve`, no branch/PR recorded' '`ship.md` present with PR URL'; do
  need "$WF" "$row" "AC11 standalone derived-state row retained"
done

echo "== AC12: only roadmap artifact + child dirs, no source/child phase work =="
need "$AGENT_DIR/roadmap.md" 'Produce exactly one artifact' "AC12 exactly one artifact"
need "$AGENT_DIR/roadmap.md" 'Never modify source code' "AC12 never modifies source"
need "$AGENT_DIR/roadmap.md" 'you write no child specs' "AC12 no child specs"
need "$CMD_DIR/roadmap.md" 'Write no child specs and perform no' "AC12 command forbids child phase work"
# roadmap agent may not write anything outside work/
fm "$AGENT_DIR/roadmap.md" | grep -qF '"*": deny' && ok "AC12 roadmap edit default deny" || bad "AC12 roadmap edit default"
has "$AGENT_DIR/roadmap.md" 'Never touch `opencode.json`' "AC12 roadmap avoids config/source"

echo "== AC13: documented inventories and counts stay consistent =="
na=$(agent_names | wc -l | tr -d ' '); nc=$(cmd_names | wc -l | tr -d ' '); ns=$(skill_names | wc -l | tr -d ' ')
ra=$(grep -oE '# [0-9]+ role prompts' README.md | grep -oE '[0-9]+' | head -1)
rc=$(grep -oE '# [0-9]+ slash commands' README.md | grep -oE '[0-9]+' | head -1)
rs=$(grep -oE '# [0-9]+ knowledge skills' README.md | grep -oE '[0-9]+' | head -1)
[ "$ra" = "$na" ] && ok "AC13 role prompts $ra = $na" || bad "AC13 role prompts $ra != $na"
[ "$rc" = "$nc" ] && ok "AC13 slash commands $rc = $nc" || bad "AC13 slash commands $rc != $nc"
[ "$rs" = "$ns" ] && ok "AC13 knowledge skills $rs = $ns" || bad "AC13 knowledge skills $rs != $ns"
grep -qE '^\|[[:space:]]*`roadmap`' README.md && ok "AC13 roadmap row in README Agents table" || bad "AC13 roadmap agent undocumented"
has README.md '/roadmap' && ok "AC13 /roadmap in README" || bad "AC13 /roadmap missing from README"
has AGENTS.md '`roadmap`' && ok "AC13 roadmap named in AGENTS.md" || bad "AC13 roadmap missing from AGENTS.md"
has AGENTS.md '/roadmap' && ok "AC13 /roadmap named in AGENTS.md" || bad "AC13 /roadmap missing from AGENTS.md"
# Regression: every on-disk agent/command/skill still documented.
for a in $(agent_names); do grep -qE "^\\|[[:space:]]*\`$a\`" README.md || bad "AC13 agent $a missing from README"; done
ok "AC13 all $(agent_names | wc -l | tr -d ' ') agents checked against README"
for c in $(cmd_names); do grep -qF "/$c" README.md || bad "AC13 command /$c missing from README"; done
ok "AC13 all $(cmd_names | wc -l | tr -d ' ') commands checked against README"
for s in $(skill_names); do grep -qF "\`$s\`" README.md || bad "AC13 skill $s missing from README"; done
ok "AC13 all $(skill_names | wc -l | tr -d ' ') skills checked against README"

echo "== AC14: single-feature / vague / empty initiative never invents scope =="
need "$AGENT_DIR/roadmap.md" 'recommend `/spec <feature>`' "AC14 agent recommends /spec for single feature"
need "$AGENT_DIR/roadmap.md" 'fabricate no children' "AC14 agent fabricates no features"
need "$AGENT_DIR/roadmap.md" 'create an empty roadmap item' "AC14 agent declines empty initiative"
need "$AGENT_DIR/roadmap.md" 'possible duplicate' "AC14 agent surfaces duplicates"
need "$CMD_DIR/roadmap.md" 'recommend' "AC14 command recommends /spec for single feature"
need "$CMD_DIR/roadmap.md" 'ask the user for the initiative' "AC14 command asks on empty args"

echo "== AC15: integrity findings documented and non-fatal =="
for code in DANGLING-DEP MISSING-CHILD UNLISTED-CHILD CYCLIC-DEP; do
  need "$AGENT_DIR/status.md" "$code" "AC15 status documents $code"
  need "$WF" "$code" "AC15 workflow documents $code"
done
# Each code must be *defined*, not merely mentioned in the output example.
need "$AGENT_DIR/status.md" '`DANGLING-DEP` — a `Depends on` local id with no child' "AC15 status defines DANGLING-DEP"
need "$AGENT_DIR/status.md" '`MISSING-CHILD` — a Children-table row whose canonical reference/directory is' "AC15 status defines MISSING-CHILD"
need "$AGENT_DIR/status.md" '`UNLISTED-CHILD` — a child directory present under the parent but absent from' "AC15 status defines UNLISTED-CHILD"
need "$AGENT_DIR/status.md" '`CYCLIC-DEP` — a cycle in a manually edited dependency graph' "AC15 status defines CYCLIC-DEP"
need "$CMD_DIR/status.md" 'DANGLING-DEP' "AC15 command names findings"
need "$AGENT_DIR/status.md" 'never fatal' "AC15 findings are non-fatal"
need "$AGENT_DIR/status.md" 'never repair it' "AC15 status never auto-fixes a finding"

echo "== Edge cases (static halves) =="
need "$AGENT_DIR/roadmap.md" 'If it is empty or has no usable' "EDGE empty initiative handled"
need "$CONV" 'Never reuse' "EDGE top-level numbering collision-safe"
need "$CONV" 'never reused within that parent' "EDGE child numbering scoped to parent"
need "$AGENT_DIR/status.md" 'If it is empty (only `.gitkeep`)' "EDGE empty work tree handled"
need "$WF" 'proceed in parallel' "EDGE coexistence with flat items documented"
need "$AGENT_DIR/status.md" 'A child in a cycle is never' "EDGE cycle member never ready"
need "$AGENT_DIR/roadmap.md" 'possible duplicate' "EDGE duplicate initiative surfaced"
need "$AGENT_DIR/status.md" 'not from `updated` timestamps' "EDGE (AC10) derive from artifacts not time"

echo "== AC8: nested-reference sweep caught the review findings =="
# M1: the visual phase must resolve <item-ref>, not the ambiguous <slug>.
for f in "$AGENT_DIR/visual.md" "$CMD_DIR/visual.md" "$SKILL_DIR/browser-verification/SKILL.md"; do
  has "$f" 'work/<item-ref>' && ok "AC8 $(basename "$f") uses work/<item-ref>" || bad "AC8 $f missing work/<item-ref>"
  has "$f" 'work/<slug>' && bad "AC8 $f still uses work/<slug>" || ok "AC8 $(basename "$f") has no work/<slug>"
done
# m4: every phase agent/command must have dropped the stale work/<slug> token.
slug_hits=0
for f in "$AGENT_DIR"/*.md "$CMD_DIR"/*.md; do
  if has "$f" 'work/<slug>'; then bad "AC8 $f still uses work/<slug>"; slug_hits=$((slug_hits+1)); fi
done
[ "$slug_hits" -eq 0 ] && ok "AC8 no phase agent/command uses work/<slug>"
# m4: handoff blocks print the canonical reference, not a one-segment placeholder.
for a in product architect tester reviewer visual; do
  need "$AGENT_DIR/$a.md" 'work/<item-ref>/' "AC8 handoff $a names an item-ref path"
done
# m1: a nested child's branch must not collide with its parent's or siblings'.
for f in "$SKILL_DIR/conventional-commits/SKILL.md" "$CMD_DIR/ship.md" "$AGENT_DIR/shipper.md"; do
  need "$f" 'NNNN-slug-MMMM-slug' "AC8 $(basename "$f") maps nested ref to a single branch ref"
done

echo "== AC5/AC6: PR-detection branch of readiness (review m2) =="
need "$WF" 'if a PR is detected for the child' "AC6 workflow: detected PR satisfies a dependency"
need "$AGENT_DIR/status.md" 'if a PR is detected for the child' "AC6 status: detected PR satisfies a dependency"
need "$WF" 'or a PR detected for' "AC6 workflow: shipped via detected PR"

echo "== AC4: multi-dependency delimiter documented (review m3) =="
need "$WF" 'comma-separated when there are two or more' "AC4 workflow: multi-dep delimiter stated"
need "$CONV" 'comma-separated list when there are two or more' "AC4 conventions: multi-dep delimiter stated"

echo "== AC12: roadmap agent has no write-capable bash pattern =="
for w in '"git add' '"git commit' '"git push' '"rm ' '"mv ' '"mkdir' '"touch' '"tee ' '"sed -i'; do
  grep -qF -- "$w" "$AGENT_DIR/roadmap.md" && bad "AC12 roadmap has write-capable token: $w" || ok "AC12 roadmap has no write token: $w"
done

echo "== AC11 regression: existing agent permission blocks unchanged =="
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  perm_changes="$(git -C "$ROOT" diff HEAD -- .opencode/agent 2>/dev/null | grep -E '^[+-][[:space:]]*("[^"]+":|permission:|edit:|bash:)' | grep -vE '^(\+\+\+|---)' | wc -l | tr -d ' ')"
  [ "$perm_changes" = "0" ] && ok "AC11 no existing agent permission block changed vs HEAD" \
    || bad "AC11 $perm_changes permission-block line(s) changed vs HEAD"
else
  printf 'note  AC11 permission regression not checked (not a git repo)\n'
fi

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
