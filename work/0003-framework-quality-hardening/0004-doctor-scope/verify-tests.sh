#!/usr/bin/env bash
#
# Executable evidence for
# work/0003-framework-quality-hardening/0004-doctor-scope
# (doctor audience and diagnostic accuracy).
#
# Read-only against the repository: the only writes are a throwaway quickstart
# fixture under scratch/ (gitignored), removed on exit. There is no test runner
# in this repo (no package.json test script, no pyproject.toml/Makefile); the
# framework's verification is read-only shell assertions plus real agent
# invocation, matching work/0001-framework-consistency-hardening,
# work/0002-agentic-roadmaps, and work/0003-.../0001-state-model.
#
# This suite covers the static halves of AC1-AC11 and the spec's edge cases.
# The prompt-behaviour halves (a real clean /doctor run for AC7/AC11, and a real
# missing-README /doctor run for AC6) are executed in verify.md; they need the
# model and are not reproducible from a shell script.
#
# Usage: bash work/0003-framework-quality-hardening/0004-doctor-scope/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

AGENT=".opencode/agent/doctor.md"
CMD=".opencode/command/doctor.md"
README="README.md"; AGENTS="AGENTS.md"; WF="docs/workflow.md"; CONFIG="opencode.json"
MARK="framework-maintainer only"
QS="scratch/qs-verify"

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
has()  { grep -qF -- "$2" "$1"; }
hasE() { grep -qE -- "$2" "$1"; }
need()  { has "$1" "$2" && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needE() { hasE "$1" "$2" && ok "$3" || bad "$3 (no /$2/ in $1)"; }
fm()   { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; } # frontmatter
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }                          # unwrap lines
# Extract the block between two literal HTML-ish tags, e.g. block <inputs> </inputs>.
block() { awk -v s="$2" -v e="$3" 'index($0,s){f=1} f{print} index($0,e){exit}' "$1"; }

cleanup() { rm -rf "$QS"; }
trap cleanup EXIT

echo "== AC1: maintainer-only marker on every live /doctor surface =="
need "$README" "$MARK" "AC1 README carries the marker"
need "$AGENTS" "$MARK" "AC1 AGENTS.md carries the marker"
need "$WF" "$MARK" "AC1 docs/workflow.md carries the marker"
fm "$AGENT" | grep -qF "$MARK" && ok "AC1 doctor agent description marks maintainer-only" \
  || bad "AC1 doctor agent description marks maintainer-only"
fm "$CMD" | grep -qF "$MARK" && ok "AC1 /doctor command description marks maintainer-only" \
  || bad "AC1 /doctor command description marks maintainer-only"

cmd_row="$(grep -E '^\|[[:space:]]*`/doctor`' "$README" | head -1)"
printf '%s' "$cmd_row" | grep -qF "$MARK" \
  && ok "AC1 README /doctor Commands row is marked" \
  || bad "AC1 README /doctor Commands row missing marker: $cmd_row"
printf '%s' "$cmd_row" | grep -qE '^\|[[:space:]]*`/doctor`[[:space:]]*\|[[:space:]]*`doctor`' \
  && ok "AC1 README /doctor name/agent cells unchanged" \
  || bad "AC1 README /doctor name/agent cells altered: $cmd_row"
agent_row="$(grep -E '^\|[[:space:]]*`doctor`' "$README" | head -1)"
printf '%s' "$agent_row" | grep -qE '^\|[[:space:]]*`doctor`[[:space:]]*\|[[:space:]]*primary' \
  && ok "AC1 README doctor name/mode cells unchanged" \
  || bad "AC1 README doctor name/mode cells altered: $agent_row"
printf '%s' "$agent_row" | grep -qE '^\|[[:space:]]*`doctor`[[:space:]]*\|[[:space:]]*primary[[:space:]]*\|[[:space:]]*none[[:space:]]*\|[[:space:]]*read-only allowlist[[:space:]]*\|$' \
  && ok "AC1 README doctor compared capability cell unchanged (scope label not in compared cell)" \
  || bad "AC1 README doctor capability cell altered (scope label leaked into a compared cell): $agent_row"

flat_agents="$(flat "$AGENTS")"
case "$flat_agents" in
  *'`/doctor` (read-only drift diagnostic; framework-maintainer only)'*)
    ok "AC1 AGENTS.md /doctor entry marked" ;;
  *) bad "AC1 AGENTS.md /doctor entry not marked as maintainer-only" ;;
esac
case "$flat_agents" in
  *'`doctor` (read-only consistency diagnostic; framework-maintainer only)'*)
    ok "AC1 AGENTS.md doctor entry marked" ;;
  *) bad "AC1 AGENTS.md doctor entry not marked as maintainer-only" ;;
esac

# Whole-tree sweep: the design's recon found exactly five live files mention
# /doctor, and each must carry the marker. A sixth surface that documents the
# command without the marker is drift this AC forbids.
sweep_bad=0; sweep_n=0
while IFS= read -r f; do
  if grep -qF -- '/doctor' "$f"; then
    sweep_n=$((sweep_n+1))
    grep -qF -- "$MARK" "$f" || { bad "AC1 live surface documents /doctor without marker: $f"; sweep_bad=$((sweep_bad+1)); }
  fi
done < <(find .opencode docs -type f -name '*.md' -not -path './work/*' -not -path '*/node_modules/*'; printf '%s\n' "$AGENTS" "$README")
[ "$sweep_bad" -eq 0 ] && [ "$sweep_n" -ge 5 ] \
  && ok "AC1 broad sweep: all $sweep_n live /doctor surfaces carry the marker" \
  || bad "AC1 broad sweep: $sweep_bad of $sweep_n live /doctor surfaces lack the marker"

echo "== AC2: documented quickstart installs no doctor agent/command =="
need "$README" 'rm -f .opencode/agent/doctor.md .opencode/command/doctor.md' \
  "AC2 quickstart contains the doctor removal step"
# Run the documented copy sequence verbatim into a scratch dir and assert the
# target has neither file (AC2) and the framework still has both (sanity).
rm -rf "$QS"; mkdir -p "$QS"
(
  FRAMEWORK="$ROOT"
  cd "$QS" || exit 1
  mkdir -p .opencode
  cp -r "$FRAMEWORK/.opencode/agent" "$FRAMEWORK/.opencode/command" "$FRAMEWORK/.opencode/skill" .opencode/
  rm -f .opencode/agent/doctor.md .opencode/command/doctor.md
  cp "$FRAMEWORK/AGENTS.md" "$FRAMEWORK/$CONFIG" "$FRAMEWORK/.gitignore" .
  mkdir -p docs && cp "$FRAMEWORK"/docs/*.md docs/
  mkdir -p work && touch work/.gitkeep
)
if [ ! -e "$QS/.opencode/agent/doctor.md" ] && [ ! -e "$QS/.opencode/command/doctor.md" ]; then
  ok "AC2 quickstart result has no doctor agent and no /doctor command"
else
  bad "AC2 quickstart result still contains a doctor file"
fi
[ -e "$AGENT" ] && [ -e "$CMD" ] \
  && ok "AC2 sanity: the framework repo itself still has both doctor files" \
  || bad "AC2 sanity: framework repo lost a doctor file"

echo "== AC3: docs explain maintainer-only scope, adoption absence, misreporting =="
flat_readme="$(flat "$README")"
case "$flat_readme" in
  *'framework-maintainer only'*) ok "AC3 README states maintainer-only" ;;
  *) bad "AC3 README does not state maintainer-only" ;;
esac
case "$flat_readme" in
  *'this quickstart never copies'*) ok "AC3 README explains the framework-only surface is not copied" ;;
  *) bad "AC3 README does not explain why the diagnostic is absent" ;;
esac
case "$flat_readme" in
  *'they are not authoritative outside the framework repository'*)
    ok "AC3 README warns the files are not authoritative elsewhere" ;;
  *) bad "AC3 README lacks the not-authoritative warning" ;;
esac
case "$flat_readme" in
  *'adopted before this change'*) ok "AC3 README addresses an existing (pre-change) adoption" ;;
  *) bad "AC3 README does not address existing adopters" ;;
esac
case "$flat_readme" in
  *'remove or ignore'*) ok "AC3 README tells existing adopters to remove or ignore" ;;
  *) bad "AC3 README does not tell existing adopters what to do" ;;
esac
case "$flat_readme" in
  *'will make `/doctor` misreport'*) ok "AC3 README warns an out-of-band copy misreports" ;;
  *) bad "AC3 README lacks the out-of-band misreport warning" ;;
esac
need "$WF" 'framework-maintainer only' "AC3 workflow routing bullet marks maintainer-only"

echo "== AC4: examples use symbolic locations, no counts or file:line =="
ff="$(block "$AGENT" '<finding_format>' '</finding_format>')"
if printf '%s' "$ff" | grep -qE '[0-9]'; then
  bad "AC4 finding examples assert a concrete integer: $(printf '%s' "$ff" | grep -nE '[0-9]' | head -1)"
else
  ok "AC4 finding examples contain no integer at all"
fi
if grep -qE '\.md:[0-9]+' "$AGENT" "$CMD"; then
  bad "AC4 a doctor file still cites a file:line location"
else
  ok "AC4 no file:line citations in the doctor agent or command"
fi
if grep -qE '[0-9]+ (files|role prompts|agents|commands|skills|slash commands|knowledge skills)' "$AGENT" "$CMD"; then
  bad "AC4 a doctor file asserts a concrete inventory count"
else
  ok "AC4 no concrete inventory counts in the doctor agent or command"
fi
printf '%s' "$ff" | grep -qF 'count on disk' \
  && ok "AC4 COUNT-MISMATCH example is symbolic ('count on disk')" \
  || bad "AC4 COUNT-MISMATCH example is not symbolic"
printf '%s' "$ff" | grep -qF 'README.md Layout comment' \
  && ok "AC4 COUNT-MISMATCH example names the Layout comment, not a line" \
  || bad "AC4 COUNT-MISMATCH example does not name the Layout comment"
printf '%s' "$ff" | grep -qF '.opencode/skill/<skill>/SKILL.md scratch guidance' \
  && ok "AC4 TEMP-PATH example is symbolic over a placeholder skill" \
  || bad "AC4 TEMP-PATH example is not symbolic over a placeholder skill"
printf '%s' "$ff" | grep -qF '[SURFACE-MISSING]' \
  && ok "AC4 a SURFACE-MISSING example is present" \
  || bad "AC4 no SURFACE-MISSING example"

echo "== AC5: completeness rule derives classification, no inline snapshot =="
cr="$(block "$AGENT" '<completeness_rule>' '</completeness_rule>')"
cr_flat="$(printf '%s' "$cr" | tr '\n' ' ' | tr -s ' ')"
if printf '%s' "$cr" | grep -qE '\(ask, doctor|non-lifecycle agents|the `ask` agent intentionally'; then
  bad "AC5 completeness rule still carries the inline agent enumeration"
else
  ok "AC5 completeness rule has no inline non-lifecycle agent snapshot"
fi
printf '%s' "$cr" | grep -qF 'docs/workflow.md' \
  && ok "AC5 classification derives from docs/workflow.md" \
  || bad "AC5 classification does not name docs/workflow.md"
printf '%s' "$cr" | grep -qE 'phase table' \
  && ok "AC5 classification keys on the phase tables" \
  || bad "AC5 classification does not key on phase tables"
printf '%s' "$cr_flat" | grep -qF 'command-less agent is not a finding' \
  && ok "AC5 rule states a command-less agent is not a finding" \
  || bad "AC5 rule lacks the command-less-agent statement"
for n in ask scout scribe bootstrap; do
  printf '%s' "$cr" | grep -qF "$n" \
    && bad "AC5 completeness rule still hard-codes agent name '$n'" \
    || ok "AC5 completeness rule does not hard-code agent name '$n'"
done
need "$CMD" 'command-less agent is not a finding' "AC5 command agrees a command-less agent is not a finding"

echo "== AC6: one SURFACE-MISSING finding, never a per-item cascade =="
need "$AGENT" 'SURFACE-MISSING' "AC6 agent defines the SURFACE-MISSING code"
need "$CMD" 'SURFACE-MISSING' "AC6 command defines the SURFACE-MISSING code"
printf '%s' "$cr" | grep -qF 'exactly one' \
  && ok "AC6 rule emits exactly one finding per missing surface" \
  || bad "AC6 rule does not say exactly one finding"
printf '%s' "$cr" | grep -qF 'Never emit one finding per inventory item' \
  && ok "AC6 rule forbids the per-item cascade" \
  || bad "AC6 rule does not forbid the per-item cascade"
need "$CMD" 'exactly one' "AC6 command emits exactly one finding per missing surface"
need "$CMD" 'never a per-item cascade' "AC6 command forbids the per-item cascade"

echo "== AC7/AC11: static preconditions for the clean diagnostic =="
# The real clean run is executed in verify.md. These assert the facts that run
# checks, so the suite still fails if the repository drifts.
disk_agents="$(ls .opencode/agent/*.md | wc -l | tr -d ' ')"
disk_cmds="$(ls .opencode/command/*.md | wc -l | tr -d ' ')"
disk_skills="$(ls -d .opencode/skill/*/ | wc -l | tr -d ' ')"
printf '%s' "$(grep -F '# '"$disk_agents"' role prompts' "$README")" | grep -q . \
  && ok "AC7 README layout comment agrees: $disk_agents role prompts" \
  || bad "AC7 README role-prompts count disagrees with disk ($disk_agents)"
printf '%s' "$(grep -F '# '"$disk_cmds"' slash commands' "$README")" | grep -q . \
  && ok "AC7 README layout comment agrees: $disk_cmds slash commands" \
  || bad "AC7 README slash-commands count disagrees with disk ($disk_cmds)"
printf '%s' "$(grep -F '# '"$disk_skills"' knowledge skills' "$README")" | grep -q . \
  && ok "AC7 README layout comment agrees: $disk_skills knowledge skills" \
  || bad "AC7 README knowledge-skills count disagrees with disk ($disk_skills)"
# The whole catalogue of existing check codes survives the rewrite (AC11).
for code in AGENT-UNDOCUMENTED AGENT-PHANTOM COMMAND-UNDOCUMENTED COMMAND-PHANTOM \
            SKILL-UNDOCUMENTED SKILL-PHANTOM COUNT-MISMATCH PERMISSION-WORK-PATTERN \
            PERMISSION-TABLE-MISMATCH IGNORE-MISSING TEMP-PATH-OUTSIDE-WORKSPACE \
            SKILL-NAME-MISMATCH; do
  has "$AGENT" "$code" || bad "AC11 agent lost check code $code"
done
ok "AC11 agent retains the full check-code catalogue"

echo "== AC8: README stays out of the always-loaded instruction set =="
if grep -qF '"README.md"' "$CONFIG"; then
  bad "AC8 opencode.json instructions still name README.md"
else
  ok "AC8 opencode.json instructions do not include README.md"
fi
git diff --quiet HEAD -- "$CONFIG" 2>/dev/null \
  && ok "AC8 opencode.json is unchanged by this item" \
  || bad "AC8 opencode.json was modified by this item"
need "$AGENT" 'README.md' "AC8 the diagnostic still reads README.md on demand"
printf '%s' "$(block "$AGENT" '<inputs>' '</inputs>')" | grep -qF '`README.md`' \
  && ok "AC8 README.md is a declared diagnostic input" \
  || bad "AC8 README.md is not a declared diagnostic input"

echo "== AC9: read-only guarantee unchanged =="
if diff <(git show HEAD:"$AGENT" 2>/dev/null | sed -n '/^permission:/,/^---/p') \
        <(sed -n '/^permission:/,/^---/p' "$AGENT") >/dev/null 2>&1; then
  ok "AC9 doctor permission block is byte-identical to HEAD"
else
  bad "AC9 doctor permission block changed vs HEAD"
fi
fm "$AGENT" | grep -qF 'edit: deny' && ok "AC9 edit stays denied" || bad "AC9 edit no longer denied"
fm "$AGENT" | grep -qF '"*": deny' && ok "AC9 bash catch-all stays denied" || bad "AC9 bash catch-all no longer denied"
need "$AGENT" 'Never edit any file' "AC9 read-only rule preserved in the agent"
need "$CMD" 'do not edit any file' "AC9 read-only rule preserved in the command"

echo "== AC10: no lifecycle, phase, or command behaviour changed =="
# The change-set check is transient by nature: while the item is uncommitted it
# compares the working tree to HEAD, and once the item is committed the same tree
# is clean. Accept either state so the suite stays green on a committed branch
# and a fresh clone; the content checks below are the durable invariant.
changed="$(git diff --name-only HEAD 2>/dev/null | sort | tr '\n' ' ')"
expected="$(printf '%s\n' "$AGENT" "$CMD" "$AGENTS" "$README" "$WF" | sort | tr '\n' ' ')"
if [ -z "$changed" ]; then
  ok "AC10 working tree clean vs HEAD (committed item); change set verified by content"
elif [ "$changed" = "$expected" ]; then
  ok "AC10 only the five expected files changed: $changed"
else
  bad "AC10 unexpected change set: got [$changed] want [$expected]"
fi
if diff <(git show HEAD:"$WF" 2>/dev/null | sed -n '/^## Phases/,/^## Derived state/p') \
        <(sed -n '/^## Phases/,/^## Derived state/p' "$WF") >/dev/null 2>&1; then
  ok "AC10 docs/workflow.md Phases..Derived-state section is byte-identical"
else
  bad "AC10 the lifecycle phase section changed"
fi
cmd_changed="$(git diff --name-only HEAD 2>/dev/null -- .opencode/command | sort | tr '\n' ' ')"
if [ -z "$cmd_changed" ]; then
  ok "AC10 no command change pending vs HEAD (committed item)"
elif [ "$cmd_changed" = "$CMD " ]; then
  ok "AC10 no other command file changed"
else
  bad "AC10 other command files changed: $cmd_changed"
fi
git diff --quiet HEAD -- docs/artifact-conventions.md 2>/dev/null \
  && ok "AC10 artifact conventions unchanged" \
  || bad "AC10 artifact conventions changed"

echo "== Edge cases =="
need "$AGENT" 'AGENT-PHANTOM' "EDGE documented item with no file is still reported (agent phantom)"
need "$AGENT" 'COMMAND-PHANTOM' "EDGE command phantom still reported"
need "$AGENT" 'SKILL-PHANTOM' "EDGE skill phantom still reported"
need "$AGENT" 'git rev-parse --show-toplevel' "EDGE wrong working directory resolved from repo root"
block "$AGENT" '<inputs>' '</inputs>' | grep -qF 'work/' \
  && bad "EDGE doctor now reads work/ (empty work/ would affect the run)" \
  || ok "EDGE doctor's declared inputs do not read work/"

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
