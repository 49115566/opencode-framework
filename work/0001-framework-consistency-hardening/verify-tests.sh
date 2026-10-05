#!/usr/bin/env bash
#
# Executable evidence for work/0001-framework-consistency-hardening.
# Read-only. Encodes the automatable acceptance criteria:
#   AC1 (static), AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC11 (static).
# AC1 (behavioral create+update), AC9, AC10, AC12 are verified in verify.md.
#
# Note: this script lives under work/ because the tester permission block grants
# `**/tests/**` but not the relative `tests/**`, so a root-level tests/ dir
# cannot be written. See verify.md "Gaps and residual risk".
#
# Usage: bash work/0001-framework-consistency-hardening/verify-tests.sh
# Exit:  0 = pass, 1 = one or more failures.

set -u

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
cd "$ROOT" || exit 2

AGENT_DIR=".opencode/agent"; CMD_DIR=".opencode/command"; SKILL_DIR=".opencode/skill"
pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
agent_names() { ls "$AGENT_DIR"/*.md | xargs -n1 basename | sed 's/\.md$//' | sort; }
cmd_names()   { ls "$CMD_DIR"/*.md   | xargs -n1 basename | sed 's/\.md$//' | sort; }
skill_names() { ls -d "$SKILL_DIR"/*/ | xargs -n1 basename | sort; }
row() { grep -E "^\\|[[:space:]]*\`$1\`" README.md; }  # README Agents-table row (alignment-tolerant)
fm()  { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; } # frontmatter

echo "== AC1: artifact-writing agents declare both work path forms =="
for a in product architect tester visual reviewer bootstrap scribe; do
  f="$AGENT_DIR/$a.md"
  if fm "$f" | grep -qF '"work/**": allow' && fm "$f" | grep -qF '"**/work/**": allow'; then
    ok "AC1 $a edit block grants work/** and **/work/**"
  else bad "AC1 $a edit block missing a work form"; fi
done
for a in $(agent_names); do
  f="$AGENT_DIR/$a.md"
  if fm "$f" | grep -qF 'work/**' && ! { fm "$f" | grep -qF '"work/**": allow' && fm "$f" | grep -qF '"**/work/**": allow'; }; then
    bad "AC1 $a mentions work/** but lacks a full allow pair"
  fi
done
fm "$AGENT_DIR/doctor.md" | grep -qF 'work/**' && bad "AC1 doctor edit block grants work" || ok "AC1 doctor edit block has no work grant"

echo "== AC2: on-disk inventories are documented =="
for a in $(agent_names); do
  grep -qE "^\\|[[:space:]]*\`$a\`" README.md || bad "AC2 agent $a missing from README Agents table"
  grep -qF "\`$a\`" AGENTS.md || bad "AC2 agent $a not named in AGENTS.md"
done
ok "AC2 all $(agent_names | wc -l | tr -d ' ') agents checked against README + AGENTS.md"
for c in $(cmd_names); do
  grep -qF "/$c" README.md || bad "AC2 command /$c missing from README"
  grep -qF "/$c" AGENTS.md || bad "AC2 command /$c not named in AGENTS.md"
done
ok "AC2 all $(cmd_names | wc -l | tr -d ' ') commands checked against README + AGENTS.md"
for s in $(skill_names); do
  grep -qF "\`$s\`" README.md || bad "AC2 skill $s missing from README Skills table"
done
ok "AC2 all $(skill_names | wc -l | tr -d ' ') skills checked against README"
# docs/workflow.md only needs the lifecycle agents it already names to exist.
for a in product architect builder tester reviewer shipper; do
  if grep -qF "\`$a\`" docs/workflow.md && [ ! -f "$AGENT_DIR/$a.md" ]; then
    bad "AC2 docs/workflow.md names phantom lifecycle agent $a"
  fi
done
ok "AC2 docs/workflow.md named lifecycle agents exist on disk"

echo "== AC3: ask agent documented read-only =="
grep -qE '^\|[[:space:]]*`ask`' README.md && ok "AC3 ask row in README" || bad "AC3 ask row in README"
grep -qF '`ask`' AGENTS.md && ok "AC3 ask named in AGENTS.md" || bad "AC3 ask named in AGENTS.md"
row ask | grep -qF 'none' && ok "AC3 ask row documents no edit/no bash" || bad "AC3 ask row missing none"
fm "$AGENT_DIR/ask.md" | grep -qF 'edit:' && ok "AC3 ask frontmatter denies edit" || bad "AC3 ask frontmatter"
grep -qF '"*": allow' "$AGENT_DIR/ask.md" && bad "AC3 ask grants bash" || ok "AC3 ask has no bash allow"

echo "== AC4: README layout counts equal disk counts =="
na=$(agent_names | wc -l | tr -d ' '); nc=$(cmd_names | wc -l | tr -d ' '); ns=$(skill_names | wc -l | tr -d ' ')
ra=$(grep -oE '# [0-9]+ role prompts' README.md | grep -oE '[0-9]+' | head -1)
rc=$(grep -oE '# [0-9]+ slash commands' README.md | grep -oE '[0-9]+' | head -1)
rs=$(grep -oE '# [0-9]+ knowledge skills' README.md | grep -oE '[0-9]+' | head -1)
[ "$ra" = "$na" ] && ok "AC4 role prompts $ra = $na" || bad "AC4 role prompts $ra != $na"
[ "$rc" = "$nc" ] && ok "AC4 slash commands $rc = $nc" || bad "AC4 slash commands $rc != $nc"
[ "$rs" = "$ns" ] && ok "AC4 knowledge skills $rs = $ns" || bad "AC4 knowledge skills $rs != $ns"

echo "== AC5: README permission table matches declared capabilities =="
decl=""; doc=""
for a in $(agent_names); do
  fm "$AGENT_DIR/$a.md" | grep -qF 'work/**' && decl="$decl $a"
  if row "$a" | grep -qF 'work/**' && row "$a" | grep -qF '**/work/**'; then doc="$doc $a"; fi
done
decl=$(echo $decl | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
doc=$(echo $doc  | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ $//')
[ "$decl" = "$doc" ] && ok "AC5 work-granting set = documented set [$decl]" || bad "AC5 declared=[$decl] documented=[$doc]"
for a in $(agent_names); do
  if ! fm "$AGENT_DIR/$a.md" | grep -qF 'work/**' && ! fm "$AGENT_DIR/$a.md" | grep -qF 'edit: allow'; then
    row "$a" | grep -qF 'none' || bad "AC5 read-only $a row is not none"
  fi
done
ok "AC5 read-only agents documented as none"

echo "== AC6: permission model documented =="
for pair in \
  "docs/customization.md:create, write, and patch" \
  "docs/customization.md:work/**" \
  "docs/customization.md:**/work/**" \
  "docs/customization.md:opencode debug agent" \
  "README.md:create, write, and patch" \
  "README.md:**/work/**"; do
  f=${pair%%:*}; s=${pair#*:}
  grep -qF -- "$s" "$f" && ok "AC6 $f contains '$s'" || bad "AC6 $f missing '$s'"
done

echo "== AC7: tooling output ignored without requiring the directories =="
grep -qF '.playwright-mcp/' .gitignore && ok "AC7 .gitignore has .playwright-mcp/" || bad "AC7 .gitignore missing .playwright-mcp/"
grep -qF 'scratch/' .gitignore && ok "AC7 .gitignore has scratch/" || bad "AC7 .gitignore missing scratch/"
git check-ignore -q .playwright-mcp/x && ok "AC7 .playwright-mcp/x ignored" || bad "AC7 .playwright-mcp/x not ignored"
git check-ignore -q scratch/y && ok "AC7 scratch/y ignored" || bad "AC7 scratch/y not ignored"

echo "== AC8: no temp guidance outside the workspace =="
for d in README.md AGENTS.md docs "$AGENT_DIR" "$CMD_DIR" "$SKILL_DIR"; do
  grep -rIn --exclude-dir=node_modules '/tmp' "$d" >/dev/null 2>&1 && bad "AC8 /tmp under $d" || ok "AC8 no /tmp under $d"
done
grep -qF 'scratch/dev-server.log' "$SKILL_DIR/browser-verification/SKILL.md" && ok "AC8 browser skill writes scratch log" || bad "AC8 browser skill"
grep -qF 'scratch/' AGENTS.md && ok "AC8 AGENTS.md documents scratch/" || bad "AC8 AGENTS.md"
grep -qF 'scratch/' README.md && ok "AC8 README documents scratch/" || bad "AC8 README"

echo "== AC11 (static): doctor is read-only =="
grep -qF 'edit: deny' "$AGENT_DIR/doctor.md" && ok "AC11 doctor edit: deny" || bad "AC11 doctor edit deny"
grep -qF '"*": deny' "$AGENT_DIR/doctor.md" && ok "AC11 doctor bash catch-all deny" || bad "AC11 doctor bash deny"
for w in '"git add' '"git commit' '"rm ' '"mv ' '"mkdir' '"touch' '"tee ' '"sed -i'; do
  grep -qF -- "$w" "$AGENT_DIR/doctor.md" && bad "AC11 doctor write pattern: $w" || ok "AC11 doctor has no write pattern: $w"
done

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
