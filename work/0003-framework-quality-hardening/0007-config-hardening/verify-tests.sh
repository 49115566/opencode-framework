#!/usr/bin/env bash
#
# Executable evidence for
# work/0003-framework-quality-hardening/0007-config-hardening
# (default config safety and reproducibility).
#
# Read-only against the repository. There is no committed test runner in this
# repo (no root package.json/pyproject.toml/Makefile; AGENTS.md "Project
# profile" is an unfilled template), so framework verification is read-only
# shell assertions plus the framework's own `opencode debug` commands, matching
# work/0001-framework-consistency-hardening, work/0002-agentic-roadmaps, and
# 0003/0001-state-model and 0003/0002-readiness-ship-state.
#
# It covers AC1-AC8 and the spec's edge cases:
#   AC1  default agent is `product`, an enabled primary with edit limited to work/
#   AC2  every live default-agent mention agrees; none still says builder
#   AC3  Playwright MCP pinned to one exact published version everywhere
#   AC4  always-loaded instructions are exactly the three quickstart-copied files
#   AC5  documented purpose + per-request cost for each entry and the total
#   AC6  default model documented vision-capable/strongest, no per-agent overrides
#   AC7  no agent declares a `model:` override
#   AC8  config parses and the default resolves without a disabled agent
#
# Usage: bash work/0003-framework-quality-hardening/0007-config-hardening/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures (skips do not fail).

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }
ROOT="$(pwd)"

CFG="opencode.json"
CUST="docs/customization.md"
README="README.md"
AGENTS="AGENTS.md"
WF="docs/workflow.md"
CONV="docs/artifact-conventions.md"
SKILL=".opencode/skill/browser-verification/SKILL.md"
BUILDER=".opencode/agent/builder.md"

# Live surfaces: everything that ships or is discoverable to a reader/adopter.
# Historical work/** artifacts and scratch/ are deliberately excluded.
live_files() {
  find .opencode/agent .opencode/command .opencode/skill -type f -name '*.md' 2>/dev/null
  find docs -type f -name '*.md' 2>/dev/null
  printf '%s\n' "$README" "$AGENTS" "$CFG"
}

pass=0; fail=0; skip=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
skp() { skip=$((skip+1)); printf 'skip  %s\n' "$1"; }
need()  { if grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3 (missing '$2' in $1)"; fi; }
needE() { if grep -qE -- "$2" "$1"; then ok "$3"; else bad "$3 (no /$2/ in $1)"; fi; }
flat()  { tr '\n' ' ' < "$1" | tr -s ' '; }

# JSON helpers (python3 is present in this repo's environment; degrade to grep
# only if it is missing).
have_py=0; command -v python3 >/dev/null 2>&1 && have_py=1
jget() { # jget <file> <expr-on-d>
  python3 - "$1" "$2" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
print(eval(sys.argv[2], {"d": d}))
PY
}

have_opencode=0; command -v opencode >/dev/null 2>&1 && have_opencode=1
SCRATCH="scratch"
mkdir -p "$SCRATCH"
CFG_OUT="$SCRATCH/verify-0007.debug-config.txt"
AGENT_OUT="$SCRATCH/verify-0007.debug-agent-product.txt"
cleanup() { rm -f "$CFG_OUT" "$AGENT_OUT"; }
trap cleanup EXIT

echo "== AC1: shipped default agent is the least-privilege entry =="
if [ "$have_py" -eq 1 ]; then
  da="$(jget "$CFG" "d['default_agent']" 2>/dev/null)"
  [ "$da" = "product" ] && ok "AC1 opencode.json default_agent is product" \
    || bad "AC1 opencode.json default_agent is '${da}' (expected product)"
  disabled="$(jget "$CFG" "[k for k,v in d.get('agent',{}).items() if v.get('disable')]" 2>/dev/null)"
  case "$disabled" in
    *"'product'"*) bad "AC1 product is listed among the disabled built-ins: $disabled" ;;
    *) ok "AC1 product is not among the disabled built-ins ($disabled)" ;;
  esac
else
  skp "AC1 JSON parse (python3 missing)"
fi

if [ "$have_opencode" -eq 1 ]; then
  if opencode debug config >"$CFG_OUT" 2>"$SCRATCH/verify-0007.debug-config.err"; then
    ok "AC1 'opencode debug config' exits 0"
  else
    bad "AC1 'opencode debug config' exited non-zero"
  fi
  if [ "$have_py" -eq 1 ] && python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$CFG_OUT" 2>/dev/null; then
    ok "AC1/AC8 resolved config is valid JSON"
    rda="$(jget "$CFG_OUT" "d['default_agent']" 2>/dev/null)"
    [ "$rda" = "product" ] && ok "AC1/AC8 resolved default_agent is product" \
      || bad "AC1/AC8 resolved default_agent is '${rda}'"
  else
    bad "AC1/AC8 resolved config did not parse as JSON"
  fi

  if opencode debug agent product >"$AGENT_OUT" 2>"$SCRATCH/verify-0007.debug-agent-product.err"; then
    ok "AC1 'opencode debug agent product' resolves"
  else
    bad "AC1 'opencode debug agent product' failed to resolve"
  fi
  needE "$AGENT_OUT" '"mode": *"primary"' "AC1 product resolves as mode primary"
  needE "$AGENT_OUT" '"name": *"product"' "AC1 product debug names product"
  grep -qE '"disable": *true' "$AGENT_OUT" && bad "AC1 product debug marks product disabled" \
    || ok "AC1 product debug is not disabled"
  if [ "$have_py" -eq 1 ]; then
    perm="$(python3 - "$AGENT_OUT" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
rules=d.get("permission",[])
edit=[(r.get("pattern"),r.get("action")) for r in rules if r.get("permission")=="edit"]
print(";".join(f"{p}={a}" for p,a in edit))
PY
)"; else perm=""; fi
  case "$perm" in
    '*=deny;work/**=allow;**/work/**=allow') ok "AC1 product edit is * deny then work/** and **/work/** allow" ;;
    *) bad "AC1 product edit rule is '${perm:-<unparsed>}' (expected * deny; work/** allow; **/work/** allow)" ;;
  esac
else
  skp "AC1/AC8 opencode debug commands (opencode not installed)"
fi

echo "== AC2: every live default-agent mention agrees; no builder-as-default =="
flat_cfg="$(flat "$README")"
case "$flat_cfg" in
  *'default agent (`product`)'*) ok "AC2 README Configuration names product as the default agent" ;;
  *) bad "AC2 README Configuration does not name product as the default agent" ;;
esac
need "$README" '`product`   | primary (default)' "AC2 README Agents table marks product primary (default)"
grep -qE '^description:.*\(default\)' "$BUILDER" && bad "AC2 builder.md description still carries (default)" \
  || ok "AC2 builder.md description dropped (default)"
grep -qiE 'default agent' "$BUILDER" && bad "AC2 builder.md still claims default-agent status" \
  || ok "AC2 builder.md no longer claims to be the default agent"
# Broad sweep: any live line pairing builder with default status is a stale claim.
ac2_hits=0; ac2_scanned=0
while IFS= read -r f; do
  ac2_scanned=$((ac2_scanned+1))
  if grep -qiE 'builder.*\(default\)|default agent.*builder|builder.*default agent' "$f"; then
    bad "AC2 stale builder-as-default claim in $f: $(grep -inE 'builder.*\(default\)|default agent.*builder|builder.*default agent' "$f" | head -1)"
    ac2_hits=$((ac2_hits+1))
  fi
done < <(live_files)
[ "$ac2_hits" -eq 0 ] && ok "AC2 broad sweep: $ac2_scanned live surfaces say product, never builder" \
  || bad "AC2 broad sweep: $ac2_hits surface(s) still call builder the default"

echo "== AC3: Playwright MCP pinned to one exact published version =="
specs="$(grep -rhoE '@playwright/mcp@[^"'"'"' ,]+' "$CFG" "$CUST" "$SKILL" | sort -u)"
n_specs="$(printf '%s\n' "$specs" | grep -c .)"
[ "$n_specs" -eq 1 ] && ok "AC3 one distinct Playwright spec across config + docs ($specs)" \
  || bad "AC3 $n_specs distinct Playwright specs: $(printf '%s ' $specs)"
exact="$(printf '%s' "$specs" | grep -cE '^@playwright/mcp@[0-9]+\.[0-9]+\.[0-9]+$')"
[ "$exact" -eq 1 ] && ok "AC3 spec is an exact semver pin ($specs)" \
  || bad "AC3 spec is not an exact published version: $specs"
float_hits="$(grep -rnE '@playwright/mcp@[^"'"'"' ,]*(latest|\*|\^|~)' "$CFG" "$CUST" "$SKILL" 2>/dev/null)"
[ -z "$float_hits" ] && ok "AC3 no floating tag (@latest/*/^/~) in any Playwright command" \
  || bad "AC3 floating tag remains: $float_hits"
need "$CUST" '@playwright/mcp@0.0.83' "AC3 customization.md mirrors the exact pin"
need "$SKILL" '@playwright/mcp@0.0.83' "AC3 browser-verification SKILL mirrors the exact pin"
if command -v npm >/dev/null 2>&1; then
  ver="$(timeout 60 npm view @playwright/mcp@0.0.83 version 2>/dev/null)"
  if [ "$ver" = "0.0.83" ]; then ok "AC3 pin @playwright/mcp@0.0.83 is published (npm)"
  elif [ -z "$ver" ]; then skp "AC3 npm registry unreachable; pin not install-verified"
  else bad "AC3 npm reports version '$ver' for @0.0.83"; fi
else
  skp "AC3 npm not installed; pin not install-verified"
fi

echo "== AC4: always-loaded instructions are exactly the quickstart-copied files =="
if [ "$have_py" -eq 1 ]; then
  ins="$(jget "$CFG" "d['instructions']" 2>/dev/null)"
  [ "$ins" = "['AGENTS.md', 'docs/workflow.md', 'docs/artifact-conventions.md']" ] \
    && ok "AC4 instructions are exactly the three contract files" \
    || bad "AC4 instructions are '$ins'"
else
  skp "AC4 JSON parse (python3 missing)"
fi
for p in "$AGENTS" "$WF" "$CONV"; do
  [ -f "$p" ] && ok "AC4 instruction path exists: $p" || bad "AC4 instruction path missing: $p"
done
qk="$(sed -n '38,47p' "$README")"
printf '%s' "$qk" | grep -qF 'AGENTS.md' && ok "AC4 quickstart copies AGENTS.md" \
  || bad "AC4 quickstart does not copy AGENTS.md"
printf '%s' "$qk" | grep -qF 'docs/*.md' && ok "AC4 quickstart copies docs/*.md (covers both docs instructions)" \
  || bad "AC4 quickstart does not copy docs/*.md"

echo "== AC5: instruction set purpose and per-request cost documented =="
need "$CUST" '## Always-loaded instructions' "AC5 customization has an Always-loaded instructions section"
for p in 'AGENTS.md' 'docs/workflow.md' 'docs/artifact-conventions.md'; do
  need "$CUST" "\`$p\`" "AC5 section names $p"
done
need "$CUST" 'workflow contract every agent needs' "AC5 AGENTS.md purpose stated"
need "$CUST" 'Authoritative lifecycle' "AC5 workflow.md purpose stated"
need "$CUST" 'Exact frontmatter and templates for every artifact' "AC5 artifact-conventions.md purpose stated"
cost_rows="$(grep -cE '~[0-9.]+k tokens \(~[0-9.]+ KB\)' "$CUST")"
[ "$cost_rows" -ge 3 ] && ok "AC5 at least three per-entry cost figures present ($cost_rows)" \
  || bad "AC5 per-entry cost figures missing (found $cost_rows)"
needE "$CUST" '~9\.3k tokens' "AC5 section states the total per-request cost"
need "$CUST" 'Every request loads all three' "AC5 section states the always-loaded cost model"

echo "== AC6: model capability documented; no text-only-degradation claim =="
need "$CUST" 'vision-capable' "AC6 customization states the default is vision-capable"
need "$CUST" 'strongest model the framework ships' "AC6 customization states it is the strongest shipped option"
flat_cust="$(flat "$CUST")"
case "$flat_cust" in
  *'`/visual` and `/reviewer` therefore need no per-agent model override'*)
    ok "AC6 customization states /visual and /reviewer need no overrides" ;;
  *) bad "AC6 customization does not state the no-override decision for /visual and /reviewer" ;;
esac
flat_readme="$(flat "$README")"
case "$flat_readme" in
  *'vision-capable and the strongest'*'no per-agent model overrides'*)
    ok "AC6 README states vision-capable, strongest, and no per-agent overrides" ;;
  *) bad "AC6 README does not carry the vision/strongest/no-override summary" ;;
esac
ac6_hits=0; ac6_scanned=0
while IFS= read -r f; do
  ac6_scanned=$((ac6_scanned+1))
  if grep -qiE 'text-only.*(degrad|worse|fails|cannot)|(degrad|worse|fails|cannot).*text-only' "$f"; then
    bad "AC6 $f claims text-only degradation"; ac6_hits=$((ac6_hits+1))
  fi
done < <(live_files)
[ "$ac6_hits" -eq 0 ] && ok "AC6 broad sweep: $ac6_scanned live surfaces carry no text-only-degradation claim" \
  || bad "AC6 broad sweep: $ac6_hits surface(s) claim text-only degradation"

echo "== AC7: no agent declares its own model override =="
model_hits=0
for a in .opencode/agent/*.md; do
  if awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$a" | grep -qE '^model:'; then
    bad "AC7 $(basename "$a") declares a model override"; model_hits=$((model_hits+1))
  fi
done
[ "$model_hits" -eq 0 ] && ok "AC7 no agent frontmatter declares model:; all inherit the default" \
  || bad "AC7 $model_hits agent(s) declare a model override"

echo "== AC8: config parses and the default resolves without a disabled agent =="
if [ "$have_opencode" -eq 1 ]; then
  if [ -s "$CFG_OUT" ] && [ "$have_py" -eq 1 ] \
     && python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$CFG_OUT" 2>/dev/null; then
    ok "AC8 'opencode debug config' parses without error"
  else
    bad "AC8 resolved config did not parse"
  fi
  if [ -s "$AGENT_OUT" ] && grep -qE '"name": *"product"' "$AGENT_OUT"; then
    ok "AC8 default agent resolves and names no disabled agent"
  else
    bad "AC8 default agent did not resolve"
  fi
else
  skp "AC8 opencode not installed; validation not executed"
fi

echo "== Edge cases =="
need "$README" 'merge rather than overwrite' "EDGE merged config: README documents merge-not-overwrite"
if [ "$have_py" -eq 1 ]; then
  mm="$(jget "$CFG" "(d['model'], d['small_model'])" 2>/dev/null)"
  [ "$mm" = "('deepseek/deepseek-flash', 'deepseek/deepseek-flash')" ] \
    && ok "EDGE small_model unchanged and equal to model" \
    || bad "EDGE model/small_model drifted: $mm"
fi
# Partial instruction copy: every instruction path is one the quickstart copies.
partial_bad=0
for p in "$AGENTS" "$WF" "$CONV"; do
  case "$p" in
    AGENTS.md) printf '%s' "$qk" | grep -qF 'AGENTS.md' || partial_bad=$((partial_bad+1)) ;;
    docs/*.md) printf '%s' "$qk" | grep -qF 'docs/*.md' || partial_bad=$((partial_bad+1)) ;;
    *) partial_bad=$((partial_bad+1)) ;;
  esac
done
[ "$partial_bad" -eq 0 ] && ok "EDGE partial copy: every instruction path is quickstart-copied" \
  || bad "EDGE partial copy: $partial_bad instruction path(s) not guaranteed by the quickstart"
# No-vision fallback: headless/isolated QA is documented and unchanged.
need "$CUST" '--headless' "EDGE no-vision fallback: headless browser QA documented"
need "$CUST" '--isolated' "EDGE no-vision fallback: isolated profile documented"
# Pin supersession: docs must make bumping the pin the sanctioned path, never a
# return to a floating tag. Require both halves of that guidance so the guard
# fails if the prose is removed or reduced to an incidental occurrence of a word.
if grep -qiE 'bump the pin|bump the .?@x\.y\.z' "$CUST" \
   && grep -qiE 'never restore a floating tag|never .*floating tag' "$CUST"; then
  ok "EDGE supersession: docs make bumping the pin the sanctioned path and forbid floating tags"
else
  bad "EDGE supersession: $CUST must say to bump the pin and never restore a floating tag"
fi

printf '\nTOTAL: %s passed, %s failed, %s skipped\n' "$pass" "$fail" "$skip"
[ "$fail" -eq 0 ]
