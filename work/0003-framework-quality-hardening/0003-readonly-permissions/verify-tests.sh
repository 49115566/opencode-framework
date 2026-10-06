#!/usr/bin/env bash
#
# Executable evidence for
# work/0003-framework-quality-hardening/0003-readonly-permissions
# (read-only agent permissions and enforcement claims).
#
# Read-only against the repository (git status/diff/check-ignore plus file
# reads). This repo has no test runner (no root package.json/pyproject.toml;
# AGENTS.md Project profile is an unfilled template). Matching
# work/0002-agentic-roadmaps, work/0001-framework-consistency-hardening, and
# work/0003-.../0002-readiness-ship-state, framework verification is read-only
# shell assertions plus real agent invocation.
#
# Usage: bash work/0003-framework-quality-hardening/0003-readonly-permissions/verify-tests.sh [repo-root]
#   repo-root defaults to the git top level, so the same suite can be pointed
#   at a throwaway copy for mutation testing.
# Exit:  0 = pass, 1 = one or more failures.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

AGENT_DIR=".opencode/agent"
README="README.md"; CUSTOM="docs/customization.md"
READONLY_AGENTS="product architect roadmap status reviewer doctor"
EXPECTED_CHANGED="README.md
docs/customization.md
.opencode/agent/product.md
.opencode/agent/architect.md
.opencode/agent/roadmap.md
.opencode/agent/status.md
.opencode/agent/reviewer.md
.opencode/agent/doctor.md
.opencode/agent/tester.md"

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
has()  { grep -qF -- "$2" "$1"; }
hasE() { grep -qE -- "$2" "$1"; }
need()  { has "$1" "$2" && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needE() { hasE "$1" "$2" && ok "$3" || bad "$3 (no /$2/ in $1)"; }
# frontmatter (between the first two --- lines)
fm()  { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; }
# the permission.bash block of the frontmatter
fm_bash() { awk '
  NR==1 && $0=="---" {fm=1; next}
  fm && $0=="---" {exit}
  fm && $0=="  bash:" {inb=1; next}
  fm && inb && $0 ~ /^  [^ ]/ {inb=0}
  fm && inb {print}
' "$1"; }
# the permission.edit block of the frontmatter
fm_edit() { awk '
  NR==1 && $0=="---" {fm=1; next}
  fm && $0=="---" {exit}
  fm && $0=="  edit:" {ine=1; next}
  fm && ine && $0 ~ /^  [^ ]/ {ine=0}
  fm && ine {print}
' "$1"; }
# allowed patterns from a permission block, one per line, sorted
allow_patterns() { sed -n 's/^[[:space:]]*"\(.*\)": allow$/\1/p' | sort; }
# first non-blank content line of a block
first_line() { awk 'NF{print; exit}'; }
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }

# The exact inspection/git-read allowlists the design pins down.
expected_bash() {
  case "$1" in
    product|architect|roadmap)
      printf '%s\n' 'git log*' 'git diff*' 'git show*' 'ls*' 'cat*' 'tree*' | sort ;;
    status)
      printf '%s\n' 'git status*' 'git log*' 'git show*' 'git diff*' 'git branch*' 'ls*' 'cat*' | sort ;;
    reviewer)
      printf '%s\n' 'git diff*' 'git log*' 'git show*' 'git status*' 'git merge-base*' 'git rev-parse*' 'git blame*' 'ls*' 'cat*' | sort ;;
    doctor)
      printf '%s\n' 'git rev-parse*' 'git status*' 'git diff*' 'git check-ignore*' 'ls*' 'cat*' 'tree*' | sort ;;
  esac
}

CANON_GUARD='**Read-only guard.** Your bash allowlist is a best-effort guard, not a sandbox: opencode matches bash rules by command prefix and cannot stop shell redirection or output-to-file flags. Never use bash to create, write, move, or delete a file, and never use it to execute an arbitrary program. Use the Read, Grep, and Glob tools for inspection instead of shell commands.'

echo "== AC1: the six read-only agents grant neither find* nor rg* =="
for a in $READONLY_AGENTS; do
  f="$AGENT_DIR/$a.md"
  if fm_bash "$f" | grep -qE '"(rg|find)\*"'; then
    bad "AC1 $a still grants rg*/find*"
  else
    ok "AC1 $a grants no rg*/find*"
  fi
  # Catch-all is the first rule in the bash block (last-match-wins ordering).
  fl="$(fm_bash "$f" | first_line)"
  [ "$fl" = '    "*": deny' ] && ok "AC1 $a leading bash rule is \"*\": deny" \
    || bad "AC1 $a leading bash rule is '$fl', not \"*\": deny"
  # And it is a real deny rule in the frontmatter.
  fm_bash "$f" | grep -qxF '    "*": deny' && ok "AC1 $a has an explicit '*' deny" \
    || bad "AC1 $a missing explicit '*' deny"
done

echo "== AC2: every remaining allowed entry is read-only inspection =="
for a in $READONLY_AGENTS; do
  f="$AGENT_DIR/$a.md"
  got="$(fm_bash "$f" | allow_patterns)"
  want="$(expected_bash "$a")"
  if [ "$got" = "$want" ]; then
    ok "AC2 $a allowlist matches the pinned read-only set"
  else
    bad "AC2 $a allowlist drifted"
    printf '      want: %s\n' "$(printf '%s' "$want" | tr '\n' ',')"
    printf '      got:  %s\n' "$(printf '%s' "$got" | tr '\n' ',')"
  fi
  # No allowed entry may be a command whose primary purpose writes or executes.
  if printf '%s\n' "$got" | grep -qiE '(^|[^a-z])(rm|mv|cp|mkdir|rmdir|touch|tee|dd|chmod|chown|ln|truncate|sed|awk|perl|ruby|python|node|bash|sh|zsh|curl|wget|nc|ssh|scp|rsync|make|patch|find|rg)([^a-z]|$)'; then
    bad "AC2 $a grants a write/execute-capable command"
  else
    ok "AC2 $a grants no write/execute-capable command"
  fi
done

echo "== AC3: prompts do not route the removed commands through bash; use search tools =="
for a in $READONLY_AGENTS; do
  f="$AGENT_DIR/$a.md"
  if grep -nE '`(rg|find) ' "$f" | grep -vq 'permission'; then
    bad "AC3 $a still instructs a bash \`rg\`/\`find\` invocation"
  else
    ok "AC3 $a names no bash \`rg\`/\`find\` invocation"
  fi
  # The guard must point inspection at the file-search tools.
  flat_f="$(flat "$f")"
  case "$flat_f" in
    *'Use the Read, Grep, and Glob tools'*) ok "AC3 $a directs inspection to Read/Grep/Glob" ;;
    *) bad "AC3 $a does not direct inspection to Read/Grep/Glob" ;;
  esac
done

echo "== AC4: all six carry the identical guard; explicit no-write prohibition =="
for a in $READONLY_AGENTS; do
  f="$AGENT_DIR/$a.md"
  flat_f="$(flat "$f")"
  case "$flat_f" in
    *"$CANON_GUARD"*) ok "AC4 $a carries the canonical guard verbatim" ;;
    *) bad "AC4 $a guard wording drifted from the canonical block" ;;
  esac
  case "$flat_f" in
    *'Never use bash to create, write, move, or delete a file'*) ok "AC4 $a forbids bash writes" ;;
    *) bad "AC4 $a does not forbid bash writes" ;;
  esac
  case "$flat_f" in
    *'not a sandbox'*) ok "AC4 $a frames the allowlist as a guard, not a sandbox" ;;
    *) bad "AC4 $a does not frame the allowlist as a guard, not a sandbox" ;;
  esac
done

echo "== AC5: README no longer claims read-only agents 'cannot touch source' =="
has "$README" 'cannot touch source' && bad "AC5 README still says 'cannot touch source'" \
  || ok "AC5 README dropped 'cannot touch source'"
need "$README" 'cannot create, modify, or delete source through' "AC5 README scopes the claim to the file tools"

echo "== AC6: README table no longer presents a 'read-only allowlist' guarantee =="
has "$README" 'read-only allowlist' && bad "AC6 README still says 'read-only allowlist'" \
  || ok "AC6 README dropped 'read-only allowlist'"
cells="$(grep -cF 'read-only, best-effort †' "$README")"
[ "$cells" -eq 6 ] && ok "AC6 six read-only rows are 'read-only, best-effort †'" \
  || bad "AC6 expected 6 best-effort cells, found $cells"
for a in $READONLY_AGENTS; do
  row="$(grep -E "^\\|[[:space:]]*\`$a\`" "$README" | head -1)"
  case "$row" in
    *'read-only, best-effort'*) ok "AC6 README row $a marks bash best-effort" ;;
    *) bad "AC6 README row $a does not mark bash best-effort: $row" ;;
  esac
done
need "$README" 'not a sandbox' "AC6 README footnote says not a sandbox"
need "$README" 'docs/customization.md' "AC6 README footnote points at the customization guide"

echo "== AC7: README scopes enforcement to file tools; bash is prefix-based =="
need "$README" 'File-tool permissions are enforced by opencode' "AC7 README scopes enforcement to file tools"
need "$README" 'command prefix' "AC7 README says bash rules match a command prefix"
need "$README" 'redirection' "AC7 README names shell redirection as unpreventable"
need "$README" 'best-effort' "AC7 README calls bash restrictions best-effort"
need "$README" 'output-to-file flags' "AC7 README names output-to-file flags"

echo "== AC8: customization caveat lists broad-bash agents and the scout residual =="
caveat="$(awk '/These blocks restrict opencode/{f=1} f{print} f&&/permission blocks\./{exit}' "$CUSTOM")"
flat_cav="$(printf '%s\n' "$caveat" | tr '\n' ' ' | tr -s ' ')"
for tok in 'bootstrap' 'scout' 'tester' 'visual'; do
  case "$flat_cav" in
    *"\`$tok\`"*) ok "AC8 caveat names broad-bash agent $tok" ;;
    *) bad "AC8 caveat omits broad-bash agent $tok" ;;
  esac
done
case "$flat_cav" in
  *'not a sandbox for `bash`'*) ok "AC8 caveat states the blocks are not a bash sandbox" ;;
  *) bad "AC8 caveat does not state the blocks are not a bash sandbox" ;;
esac
case "$flat_cav" in
  *'deliberate, accepted'*'residual'*|*'residual'*'deliberate, accepted'*)
    ok "AC8 caveat names scout's broad access as a deliberate, accepted residual" ;;
  *) bad "AC8 caveat missing the scout residual framing" ;;
esac
case "$flat_cav" in
  *'output-to-file'*) ok "AC8 caveat names output-to-file flags" ;;
  *) bad "AC8 caveat missing output-to-file flags" ;;
esac
case "$flat_cav" in
  *'`ask`'*) bad "AC8 caveat wrongly lists ask as a broad-bash agent" ;;
  *) ok "AC8 caveat does not list ask as broad-bash" ;;
esac

echo "== AC9: tester's file-tool allowlist covers the five common test layouts =="
tester_edit="$(fm_edit "$AGENT_DIR/tester.md")"
for d in e2e spec integration cypress playwright; do
  printf '%s\n' "$tester_edit" | grep -qxF "    \"$d/**\": allow" \
    && ok "AC9 tester edit allows $d/**" || bad "AC9 tester edit missing $d/**"
  printf '%s\n' "$tester_edit" | grep -qxF "    \"**/$d/**\": allow" \
    && ok "AC9 tester edit allows **/$d/**" || bad "AC9 tester edit missing **/$d/**"
done

echo "== AC11: scope — no lifecycle doc or global permission default changed =="
changed="$(git diff --name-only HEAD 2>/dev/null)"
for f in opencode.json docs/workflow.md docs/artifact-conventions.md AGENTS.md; do
  if printf '%s\n' "$changed" | grep -qxF "$f"; then
    bad "AC11 protected file changed: $f"
  else
    ok "AC11 $f unchanged"
  fi
done
extras=0
while IFS= read -r p; do
  [ -z "$p" ] && continue
  if printf '%s\n' "$EXPECTED_CHANGED" | grep -qxF "$p"; then :; else
    bad "AC11 unexpected changed file: $p"; extras=$((extras+1))
  fi
done <<< "$changed"
[ "$extras" -eq 0 ] && ok "AC11 all changed tracked files are within the nine expected"

echo "== Edge cases =="
need "$README" 'tree -o file' "EDGE README names tree -o as an accepted write path"
need "$README" 'output=file' "EDGE README names git --output as an accepted write path"
need "$CUSTOM" 'output-to-file flags' "EDGE customization names output-to-file flags"
# tester is broad-bash and must not be documented as sandboxed.
flat_readme="$(flat "$README")"
case "$flat_readme" in
  *'Agents with broad bash'*'tester'*) ok "EDGE README names tester as broad bash" ;;
  *) bad "EDGE README does not name tester as broad bash" ;;
esac
# The catch-all ordering edge: assert the deny precedes every allow in each block.
for a in $READONLY_AGENTS; do
  deny_ln="$(fm_bash "$AGENT_DIR/$a.md" | grep -nF '    "*": deny' | head -1 | cut -d: -f1)"
  allow_ln="$(fm_bash "$AGENT_DIR/$a.md" | grep -n ': allow' | head -1 | cut -d: -f1)"
  [ -n "$deny_ln" ] && [ -n "$allow_ln" ] && [ "$deny_ln" -lt "$allow_ln" ] \
    && ok "EDGE $a deny precedes the first allow" \
    || bad "EDGE $a catch-all ordering wrong (deny=$deny_ln allow=$allow_ln)"
done

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
