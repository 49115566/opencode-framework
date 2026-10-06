#!/usr/bin/env bash
#
# Executable evidence for work/0003-framework-quality-hardening/0005-fix-landing.
# Read-only. Encodes the static halves of AC1-AC12 and the fix-track edge cases.
#
# This item is a prompt/documentation change with no runtime code. There is no
# test runner in this repository (AGENTS.md Project profile is an unfilled
# template); framework verification is read-only shell assertions, matching the
# sibling suites. These assertions fail if a landing-path fact is missing or if
# a surface drifts back to the un-landable dead end.
#
# Usage: bash work/0003-framework-quality-hardening/0005-fix-landing/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

FIX=".opencode/command/fix.md"
BUILDER=".opencode/agent/builder.md"
SHIPPER=".opencode/agent/shipper.md"
SHIPCMD=".opencode/command/ship.md"
AGENTS="AGENTS.md"
WF="docs/workflow.md"
README="README.md"
SKILL_WL=".opencode/skill/workflow-lifecycle/SKILL.md"
SKILL_PR=".opencode/skill/pr-workflow/SKILL.md"
SKILL_CC=".opencode/skill/conventional-commits/SKILL.md"

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
# Match a literal against a file (raw).
has() { grep -qF -- "$2" "$1"; }
# Match a literal against a file with newlines collapsed, so wrapped prose matches.
hasFlat() { tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"; }
# Assert raw / flattened literals, labelled.
need()     { has "$1" "$2"     && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needFlat() { hasFlat "$1" "$2" && ok "$3" || bad "$3 (missing flat '$2' in $1)"; }
# Assert a literal is absent.
needAbsent() { has "$1" "$2" && bad "$3 (found '$2' in $1)" || ok "$3"; }
agent_names() { ls .opencode/agent/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
cmd_names()   { ls .opencode/command/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort; }
skill_names() { ls -d .opencode/skill/*/ 2>/dev/null | xargs -n1 basename | sort; }
fm() { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; }

echo "== AC1: a verified fix has a documented landing path =="
needFlat "$FIX" 'Next: /ship fix' "AC1 /fix handoff names /ship fix as the next action"
need "$FIX" 'Done: <fix summary>; files changed (<paths>).' "AC1 /fix handoff carries the fix summary and files"
need "$FIX" 'Reproduction: <failing regression test or exact repro>' "AC1 /fix handoff carries reproduction"
need "$FIX" 'Root cause: <one sentence>' "AC1 /fix handoff carries root cause"
needFlat "$FIX" 'the user explicitly requests `/ship fix` and the shipper performs' "AC1 /fix handoff names the shipper as the landing actor"
needFlat "$FIX" 'omit `Next: /ship fix`' "AC1 /fix omits the landing step when verification fails"
need "$BUILDER" '/ship fix' "AC1 builder names the shipper-on-request landing"
needFlat "$BUILDER" 'a verified fix lands only' "AC1 builder scopes landing to a verified fix"
# The builder is the agent `/fix` actually runs (command/fix.md `agent: builder`),
# so its own <handoff> block must be mode-aware: a /fix run must not be sent to
# the work-item block's `/test` (review M1). Scope the assertions to the fix block
# so the work-item block's `/test` is not mistaken for a fix landing.
fix_block="$(awk '/^For a fix/{f=1} f' "$BUILDER")"
if [ -n "$fix_block" ]; then
  ok "AC1 builder handoff has a fix-mode block"
else
  bad "AC1 builder handoff has no fix-mode block"
fi
printf '%s\n' "$fix_block" | grep -qE '^Next: /ship fix$' \
  && ok "AC1 builder fix-mode handoff ends Next: /ship fix" \
  || bad "AC1 builder fix-mode handoff does not end Next: /ship fix"
printf '%s\n' "$fix_block" | grep -qF -- 'do not use the work-item block' \
  && ok "AC1 builder fix-mode handoff forbids the work-item block" \
  || bad "AC1 builder fix-mode handoff does not forbid the work-item block"
printf '%s\n' "$fix_block" | grep -qF -- 'do not name `tasks.md` or' \
  && ok "AC1 builder fix-mode handoff forbids tasks.md / /test" \
  || bad "AC1 builder fix-mode handoff does not forbid tasks.md / /test"
printf '%s\n' "$fix_block" | grep -qE '^Next:.*/test' \
  && bad "AC1 builder fix-mode handoff still routes a fix to /test" \
  || ok "AC1 builder fix-mode handoff does not route a fix to /test"
printf '%s\n' "$fix_block" | grep -qE '^Done:.*tasks\.md' \
  && bad "AC1 builder fix-mode handoff still requires tasks.md" \
  || ok "AC1 builder fix-mode handoff drops the tasks.md requirement"
printf '%s\n' "$fix_block" | grep -qE 'omit `Next: /ship fix`' \
  && ok "AC1 builder omits the fix landing step on failure" \
  || bad "AC1 builder does not omit the fix landing step on failure"

echo "== AC2: landing requires an explicit user request =="
need "$SHIPPER" 'The user explicitly invoked `/ship fix`' "AC2 shipper requires the explicit invocation"
needFlat "$SHIPPER" 'without it, perform no git write' "AC2 shipper: no request -> no git write"
needFlat "$SHIPCMD" 'explicit `/ship fix` request is the consent' "AC2 ship command makes the request the consent"
needFlat "$SHIPCMD" 'without it, perform no git write' "AC2 ship command: no request -> no git write"

echo "== AC3: a verified fix can land =="
need "$SHIPPER" 'fix/<short-description>' "AC3 shipper names the fix/ branch"
needFlat "$SHIPPER" 'logical conventional commits' "AC3 shipper commits conventionally"
needFlat "$SHIPPER" '`gh` is unavailable' "AC3 shipper handles gh unavailable"
needFlat "$SHIPPER" 'exact commands the user must run to push and' "AC3 shipper reports exact push/PR commands"
need "$SHIPCMD" 'fix/<short-description>' "AC3 ship command names the fix/ branch"
needFlat "$SHIPCMD" 'as conventional commits' "AC3 ship command commits conventionally"
needFlat "$SHIPCMD" '`gh` is unavailable' "AC3 ship command handles gh unavailable"
needFlat "$SHIPCMD" 'exact commands to push and open the PR' "AC3 ship command reports exact push/PR commands"
need "$SKILL_CC" 'fix/<short-description>' "AC3 conventional-commits skill names the fix/ branch"
needFlat "$SKILL_CC" 'A fix with no work item' "AC3 skill scopes the branch note to a work-item-less fix"

echo "== AC4: no review artifact is required for a fix =="
need "$SHIPPER" 'No independent `review.md` is required' "AC4 shipper waives the review precondition"
needFlat "$SHIPPER" 'documented exception to the' "AC4 shipper states it is a documented exception"
need "$SHIPCMD" 'No independent `review.md`' "AC4 ship command waives the review precondition"
needFlat "$SHIPCMD" 'documented exception' "AC4 ship command states the exception"
needFlat "$SKILL_PR" 'this precondition does not apply to it' "AC4 pr-workflow skill scopes out review.md for a fix"

echo "== AC5: only the shipper performs git writes =="
need "$BUILDER" 'Never commit, push, or open a PR' "AC5 builder still never commits"
needFlat "$BUILDER" 'the `shipper` does, on request' "AC5 builder defers git writes to the shipper"
needFlat "$AGENTS" 'Only the `shipper` agent performs git write operations' "AC5 contract names the shipper as the only git writer"
needFlat "$AGENTS" 'Every other agent never writes git' "AC5 contract bars every other agent from git writes"
for f in "$SHIPPER" "$BUILDER"; do
  if diff -q <(fm "$f") <(git show "HEAD:$f" | awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f') >/dev/null 2>&1; then
    ok "AC5 $f frontmatter (permissions) unchanged from HEAD"
  else
    bad "AC5 $f frontmatter changed from HEAD"
  fi
done

echo "== AC6: the fix consumes no work item =="
needFlat "$WF" 'It has **no work item**' "AC6 fix track: no work item"
needFlat "$WF" 'It consumes no sequence number' "AC6 fix track: no sequence number"
needFlat "$WF" 'A landed fix creates no work item and no shipped-state record' "AC6 fix track: no shipped-state record"
needFlat "$SHIPPER" 'Do **not** write `ship.md`' "AC6 shipper skips ship.md in fix mode"
needFlat "$SHIPCMD" 'Do **not** write `ship.md`' "AC6 ship command skips ship.md in fix mode"
# No tracked file under work/ is modified, and no new work/ path other than this
# item's own phase artifacts appears.
if git diff --name-only | grep -q '^work/'; then bad "AC6 tracked work/ file modified"; else ok "AC6 no tracked work/ file modified"; fi
if git status --porcelain -uall | grep '^?? work/' | grep -qv '/0005-fix-landing/'; then
  bad "AC6 an unexpected new path appeared under work/"
else
  ok "AC6 no unexpected new path under work/"
fi

echo "== AC7: evidence travels with the fix PR =="
# Temp file lives under the in-repo, git-ignored scratch/ (AGENTS.md working
# agreement: never write a temporary file outside the workspace) and is always
# removed via the EXIT trap.
mkdir -p scratch
FX_TMP="$(mktemp -p scratch -t fix-pr-template.XXXXXX)"
trap 'rm -f "$FX_TMP"' EXIT
awk '/^## Fix PR description template/{f=1} f&&/^## Commands/{exit} f' "$SKILL_PR" > "$FX_TMP"
for s in '## Summary' '## Reproduction' '## Root cause' '## Change' '## Testing' '## Risks'; do
  grep -qF -- "$s" "$FX_TMP" && ok "AC7 fix PR template has '$s'" || bad "AC7 fix PR template missing '$s'"
done
if grep -qE '^## Artifacts' "$FX_TMP"; then bad "AC7 fix PR template has an Artifacts section"; else ok "AC7 fix PR template has no Artifacts section"; fi
needFlat "$SHIPPER" "Scan the fix's changed content for secrets before staging" "AC7 shipper scans before staging"
needFlat "$SHIPPER" 'Scan staged content before committing' "AC7 shipper standing principle scans staged content before committing"
needFlat "$SHIPPER" 'commit nothing' "AC7 shipper commits nothing on a secret"
needFlat "$SHIPPER" 'reproduction, root cause, change, and check results' "AC7 shipper PR carries the fix evidence"
needFlat "$SHIPCMD" 'scan them for secrets before committing' "AC7 ship command scans before committing"
needFlat "$SKILL_PR" 'state that acceptance' "AC7 accepted-gap is recorded in the PR"

echo "== AC8: no surface still dead-ends the fix track =="
for f in "$FIX" "$BUILDER" "$SHIPPER" "$SHIPCMD" "$AGENTS" "$WF" "$README" "$SKILL_WL" "$SKILL_PR" "$SKILL_CC"; do
  need "$f" '/ship fix' "AC8 $f states/reaches the /ship fix path"
done
needAbsent "$FIX" 'Never commit. End with the handoff block' "AC8 /fix no longer ends with a bare commit prohibition"
needAbsent "$README" 'only when you run `/ship`' "AC8 README no longer claims /ship-only landing"

echo "== AC9: guardrails and shipper preconditions agree =="
needFlat "$AGENTS" 'verified fix on `/ship fix`' "AC9 contract guardrail names the verified-fix exception"
needFlat "$AGENTS" 'when the user explicitly requests it' "AC9 contract guardrail requires the explicit request"
needFlat "$SHIPPER" 'That request is the consent to commit,' "AC9 shipper preconditions agree on consent"
needFlat "$SHIPPER" 'the only agent permitted to perform git write operations' "AC9 shipper restates the single-writer boundary"
needFlat "$SKILL_WL" 'Every other agent never writes git' "AC9 lifecycle skill restates the single-writer boundary"

echo "== AC10: failed verification blocks landing =="
needFlat "$FIX" 'omit `Next: /ship fix`' "AC10 /fix drops the landing step on failure"
needFlat "$FIX" 'report the failure as the blocker' "AC10 /fix reports the blocker instead"
needFlat "$SHIPPER" 'defect that could not be reproduced, blocks landing' "AC10 shipper blocks on an unreproduced defect"
needFlat "$SHIPPER" 'A failed check' "AC10 shipper blocks on a failed check"
needFlat "$SHIPCMD" 'blocks landing' "AC10 ship command blocks on failed verification"
needFlat "$BUILDER" 'When a check fails or the defect was not reproduced' "AC10 builder presents no landing on failure"
needFlat "$BUILDER" 'present no landing path' "AC10 builder omits the landing path on failure"

echo "== AC11: the track stays lightweight =="
needFlat "$WF" 'no `spec.md`, `design.md`, `tasks.md`' "AC11 fix track names the artifacts it does not create"
needFlat "$WF" 'no directory under `work/`' "AC11 fix track creates no work directory"
needFlat "$WF" 'Fixes never introduce new behavior' "AC11 fix track stays scoped to defects"
na=$(agent_names | wc -l | tr -d ' '); nc=$(cmd_names | wc -l | tr -d ' '); ns=$(skill_names | wc -l | tr -d ' ')
ra=$(grep -oE '# [0-9]+ role prompts' "$README" | grep -oE '[0-9]+' | head -1)
rc=$(grep -oE '# [0-9]+ slash commands' "$README" | grep -oE '[0-9]+' | head -1)
rs=$(grep -oE '# [0-9]+ knowledge skills' "$README" | grep -oE '[0-9]+' | head -1)
[ "$ra" = "$na" ] && ok "AC11 role prompts $ra = $na (no agent added)" || bad "AC11 role prompts $ra != $na"
[ "$rc" = "$nc" ] && ok "AC11 slash commands $rc = $nc (no command added)" || bad "AC11 slash commands $rc != $nc"
[ "$rs" = "$ns" ] && ok "AC11 knowledge skills $rs = $ns (no skill added)" || bad "AC11 knowledge skills $rs != $ns"
expected=".opencode/agent/builder.md
.opencode/agent/shipper.md
.opencode/command/fix.md
.opencode/command/ship.md
.opencode/skill/conventional-commits/SKILL.md
.opencode/skill/pr-workflow/SKILL.md
.opencode/skill/workflow-lifecycle/SKILL.md
AGENTS.md
README.md
docs/workflow.md"
extra="$(git diff --name-only | grep -vxF "$expected" || true)"
if [ -z "$extra" ]; then ok "AC11 diff touches only the surfaces named in design.md"; else bad "AC11 unexpected changed file(s): $extra"; fi

echo "== AC12: the documentation surfaces agree =="
# Every surface states the no-review / no-ship.md fix contract.
need "$SHIPPER" 'No independent `review.md` is required' "AC12 shipper states the no-review rule"
need "$SHIPCMD" 'No independent `review.md`' "AC12 ship command states the no-review rule"
needFlat "$SKILL_WL" 'no review artifact and no `ship.md`' "AC12 lifecycle skill states the no-review/no-ship.md rule"
needFlat "$WF" 'no shipped-state record' "AC12 workflow states the no-record rule"
needFlat "$SKILL_PR" 'A fix-landing PR (`/ship fix`) has no work item and no `review.md`' "AC12 pr-workflow agrees with the shipper"
needFlat "$SKILL_WL" 'a verified fix on `/ship fix`' "AC12 lifecycle skill agrees on the landing command"
needFlat "$README" '/ship fix' "AC12 README agrees on the landing command"
# No surface re-introduces a review requirement for a fix.
for f in "$SHIPPER" "$SHIPCMD" "$SKILL_PR"; do
  if grep -qiE 'fix[^\n]*requires a `?review\.md`?' "$f"; then bad "AC12 $f requires review.md for a fix"; else ok "AC12 $f does not require review.md for a fix"; fi
done

echo "== Edge cases =="
needFlat "$SHIPPER" '`gh` is unavailable' "EDGE gh unavailable fallback (shipper)"
needFlat "$SHIPCMD" '`gh` is unavailable' "EDGE gh unavailable fallback (ship command)"
needFlat "$SKILL_PR" 'If gh is unavailable' "EDGE gh unavailable fallback (pr skill)"
needFlat "$SHIPPER" 'commit nothing' "EDGE secret blocks the commit"
needFlat "$SHIPPER" 'never `git add -A`' "EDGE unrelated changes are not swept in (shipper)"
needFlat "$SHIPCMD" 'never `git add -A`' "EDGE unrelated changes are not swept in (ship command)"
needFlat "$SHIPPER" 'never the default branch' "EDGE fix branch not the default branch"
needFlat "$SHIPCMD" 'never the default' "EDGE fix branch not the default (ship command)"
needFlat "$FIX" 'recommend `/spec`' "EDGE a growing fix routes to /spec (command)"
needFlat "$BUILDER" 'route to `/spec`' "EDGE a growing fix routes to /spec (builder)"
needFlat "$FIX" 'could not be reproduced' "EDGE unreproduced defect blocks landing"
needFlat "$SHIPPER" 'If no regression test exists, landing is blocked unless the user' "EDGE missing regression test blocks unless accepted"
needFlat "$SHIPCMD" 'no regression test exists, landing is blocked unless the user' "EDGE missing regression test blocks (ship command)"
needFlat "$SKILL_PR" 'If the user explicitly accepts a missing regression test' "EDGE accepted gap is recorded in the PR"
needFlat "$SHIPPER" 'Stage only the fix' "EDGE several fixes: only the named fix's files are staged (shipper)"
needFlat "$SHIPCMD" 'Stage only the fix' "EDGE several fixes: only the named fix's files are staged (ship command)"
needFlat "$SHIPPER" 'One logical change per commit' "EDGE several fixes: each fix is its own logical commit"
needFlat "$WF" 'cannot collide with or renumber a work item even when both are in flight' "EDGE concurrent lifecycle work item safe"
needFlat "$SHIPCMD" 'ask which work item to ship' "EDGE empty /ship unchanged"
needFlat "$SHIPPER" 'empty — ask which work item to ship' "EDGE empty argument behavior unchanged (shipper)"

echo "== Preserved invariants from design.md (regression guard) =="
for tok in 'This is required, not optional' '`work/<item-ref>/` artifacts' 'repository path' \
           'docs(work): record ship state' 'no uncommitted `ship.md`' 'NNNN-slug-MMMM-slug'; do
  need "$SHIPPER" "$tok" "PRESERVE shipper.md '$tok'"
done
for tok in 'This is required' 'even when `gh` is unavailable' 'docs(work): record ship state' \
           'no uncommitted `ship.md`' 'NNNN-slug/MMMM-slug' 'NNNN-slug-MMMM-slug'; do
  need "$SHIPCMD" "$tok" "PRESERVE ship.md '$tok'"
done
for tok in 'satisfied(dep_local_id):' 'presence is the sole shipped signal' 'committed working state'; do
  need "$WF" "$tok" "PRESERVE workflow.md '$tok'"
done
for tok in 'committed working state' 'no ship.md?'; do
  need "$SKILL_WL" "$tok" "PRESERVE lifecycle skill '$tok'"
done
needAbsent "$SKILL_WL" 'no PR?' "PRESERVE skill does not route on a PR"
for tok in 'committed working state' 'resolve for a reviewer who does not share' 'work/<item-ref>/spec.md'; do
  need "$SKILL_PR" "$tok" "PRESERVE pr skill '$tok'"
done
need "$SKILL_CC" 'NNNN-slug-MMMM-slug' "PRESERVE conventional-commits skill nested ref"

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
