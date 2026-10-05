#!/usr/bin/env bash
#
# Executable evidence for work/0003-framework-quality-hardening/0001-state-model
# (artifact persistence and state model).
#
# Read-only against the repository. Encodes the automatable (static + fixture)
# acceptance criteria AC1-AC7 and AC9-AC12. AC8 (fresh-clone parity) and the
# two-branch half of AC10 require a real merge/`/ship` and are covered manually
# in verify.md.
#
# There is no test runner in this repository (no package.json/pyproject.toml;
# AGENTS.md Project profile is an unfilled template). Framework verification is
# read-only shell assertions plus real agent invocation, matching
# work/0001-framework-consistency-hardening/verify-tests.sh and
# work/0002-agentic-roadmaps/verify-tests.sh.
#
# Fixtures (allocation durability, adoption repair, parallel-merge renumber) are
# created under the git-ignored scratch/ tree in /tmp-free temporary repos and
# torn down on exit.
#
# Usage: bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh [repo-root]
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
ITEM="work/0003-framework-quality-hardening/0001-state-model"
pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
note(){ printf 'note  %s\n' "$1"; }
has()  { grep -qF -- "$2" "$1"; }
hasE() { grep -qE -- "$2" "$1"; }
need()  { has "$1" "$2" && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needE() { hasE "$1" "$2" && ok "$3" || bad "$3 (no /$2/ in $1)"; }
# Fill: collapse newlines/whitespace so a literal survives line wrapping.
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
# In an isolated git repo, print the greatest top-level `NNNN` prefix that has
# ever appeared in `work/` history — the documented allocation source set.
max_top_prefix() {
  {
    ls "$1/work" 2>/dev/null
    git -C "$1" log --all --name-only --pretty=format: -- work/ 2>/dev/null \
      | sed -n 's#^work/\([0-9]\{4\}\)-.*#\1#p'
  } | grep -oE '^[0-9]{4}' | sort -n | tail -1
}
next_number() { # $1 = greatest prefix (possibly empty) -> zero-padded next
  if [ -z "${1:-}" ]; then printf '0001'; else printf '%04d' $((10#$1 + 1)); fi
}

FIX_ROOT="$ROOT/scratch/state-model-verify.$$"
mkdir -p "$FIX_ROOT" || { echo "cannot create fixture dir"; exit 2; }
cleanup() { rm -rf "$FIX_ROOT"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
echo "== AC1: lifecycle artifact paths are trackable, not ignored =="
# Representative paths for every phase artifact plus a nested child path.
for p in \
  work/example/spec.md \
  work/example/design.md \
  work/example/tasks.md \
  work/example/verify.md \
  work/example/review.md \
  work/example/ship.md \
  work/example/roadmap.md \
  work/0003-framework-quality-hardening/roadmap.md \
  work/0003-framework-quality-hardening/0002-readiness-ship-state/spec.md; do
  git check-ignore -q "$p" && bad "AC1 $p is ignored" || ok "AC1 $p trackable"
done
# Real artifacts already on disk appear as untracked (trackable) files.
for p in "$ITEM/spec.md" "$ITEM/design.md" "$ITEM/tasks.md"; do
  if [ -f "$p" ]; then
    git status --porcelain --untracked-files=all -- "$p" | grep -q . \
      && ok "AC1 $p listed by git status" || bad "AC1 $p not listed by git status"
  else bad "AC1 $p missing on disk"; fi
done
# No `.gitignore` rule matches the artifact root.
git check-ignore -v work/example/spec.md >/dev/null 2>&1 && bad "AC1 a rule matches work/" || ok "AC1 no ignore rule matches work/"

echo "== AC2: only non-artifact paths stay ignored =="
for p in scratch/y .playwright-mcp/x .opencode/state/x .opencode/cache/x .opencode/node_modules/x node_modules/x dist/x; do
  git check-ignore -q "$p" && ok "AC2 $p ignored" || bad "AC2 $p not ignored"
done
for p in work/x work/0003-framework-quality-hardening/0001-state-model/x.md; do
  git check-ignore -q "$p" && bad "AC2 $p should be trackable" || ok "AC2 $p not ignored"
done

echo "== AC3: reservation placeholders persist in version control =="
gitkeep_count=0; gitkeep_ignored=0
while IFS= read -r f; do
  gitkeep_count=$((gitkeep_count+1))
  git check-ignore -q "$f" && gitkeep_ignored=$((gitkeep_ignored+1))
done < <(find work -name '.gitkeep' 2>/dev/null | sort)
[ "$gitkeep_count" -gt 0 ] && ok "AC3 found $gitkeep_count .gitkeep placeholders" || bad "AC3 no .gitkeep placeholders"
[ "$gitkeep_ignored" -eq 0 ] && ok "AC3 all $gitkeep_count .gitkeep placeholders trackable" || bad "AC3 $gitkeep_ignored .gitkeep placeholder(s) ignored"
for f in work/0003-framework-quality-hardening/0002-readiness-ship-state/.gitkeep \
         work/0003-framework-quality-hardening/0009-surface-consistency/.gitkeep; do
  git check-ignore -q "$f" && bad "AC3 $f ignored" || ok "AC3 $f trackable"
done
git status --porcelain --untracked-files=all work/ | grep -q '0002-readiness-ship-state/.gitkeep' \
  && ok "AC3 nested child .gitkeep appears in git status" || bad "AC3 nested child .gitkeep not in git status"

echo "== AC4: every current surface states the committed model =="
# No artifact-persistence claim of the old model remains on a current surface.
claims="$(grep -rInE 'git-ignored|gitignored|not deliverable|working state, not' \
  AGENTS.md README.md docs .opencode 2>/dev/null \
  | grep -viE 'scratch|playwright|opencode|node_modules|generated|cache' || true)"
[ -z "$claims" ] && ok "AC4 no old artifact-persistence claim on current surfaces" \
  || { bad "AC4 stale artifact-persistence claim(s) remain:"; printf '%s\n' "$claims"; }
# Explicit absence of the exact old literals.
for spec in \
  'AGENTS.md:Artifacts are working state and are git-ignored' \
  'docs/workflow.md:Artifacts are git-ignored. They are working state, not deliverables.' ; do
  f="${spec%%:*}"; s="${spec#*:}"
  has "$f" "$s" && bad "AC4 $f still contains old literal" || ok "AC4 $f dropped old literal"
done
has README.md 'per-feature artifacts (git-ignored)' && bad "AC4 README still calls work/ git-ignored" || ok "AC4 README calls work/ committed"
# Every persistence surface carries the committed model.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  if flat "$f" | grep -qF 'committed working state'; then
    ok "AC4 $f states committed model"
  else
    bad "AC4 $f missing committed model"
  fi
done <<'SURFACES'
AGENTS.md
docs/workflow.md
docs/artifact-conventions.md
README.md
.opencode/agent/status.md
.opencode/agent/shipper.md
.opencode/agent/visual.md
.opencode/agent/bootstrap.md
.opencode/skill/workflow-lifecycle/SKILL.md
.opencode/skill/pr-workflow/SKILL.md
.opencode/skill/browser-verification/SKILL.md
SURFACES
# "complete state" is qualified as committed and visible beyond one machine.
need "$WF" 'committed `work/` directory plus the code' "AC4 workflow complete-state qualified committed"
need "$WF" 'visible to a fresh clone, a teammate' "AC4 workflow complete-state visible to fresh clone"
need AGENTS.md 'version-controlled so a fresh clone' "AC4 AGENTS states fresh-clone derivability"

echo "== AC5: adoption yields the committed model =="
need "$AGENT_DIR/bootstrap.md" 'does not ignore `work/`' "AC5 bootstrap postcondition: work/ not ignored"
need "$AGENT_DIR/bootstrap.md" 'remove any existing rule that matches `work/`' "AC5 bootstrap repairs an existing work/ rule"
need "$AGENT_DIR/bootstrap.md" 'Keep `scratch/` and `.playwright-mcp/` ignored' "AC5 bootstrap keeps tooling/scratch ignored"
need "$AGENT_DIR/bootstrap.md" 'local-only posture' "AC5 bootstrap states local-only is unsupported"
need "$CMD_DIR/bootstrap.md" 'does not ignore it' "AC5 bootstrap command aligned"
need README.md 'The framework does not ignore `work/`' "AC5 README quickstart states committed model"
need README.md 'local-only posture is' "AC5 README quickstart names unsupported override"
# The old "ignore work/" requirement must be gone.
has "$AGENT_DIR/bootstrap.md" 'ignores `work/`' && bad "AC5 bootstrap still says ignore work/" || ok "AC5 bootstrap no longer requires ignoring work/"
has "$AGENT_DIR/bootstrap.md" '.gitignore` ignores `work/` and keeps' && bad "AC5 bootstrap keeps the old ignore work/ quality-bar line" || ok "AC5 bootstrap dropped the old ignore work/ quality-bar line"
# Fixture: documented correction of an adopter's pre-existing rule.
fix="$FIX_ROOT/adopt"; mkdir -p "$fix/work"; ( cd "$fix"
  git init -q -b main
  printf 'work/*\n!work/.gitkeep\nscratch/\n.playwright-mcp/\n' > .gitignore
  # Documented correction: remove any rule matching work/.
  grep -vE '^!?/?work(/|\*|$)' .gitignore > .gitignore.new && mv .gitignore.new .gitignore
  git check-ignore -q work/x && exit 3 || exit 0
)
if [ $? -eq 0 ]; then ok "AC5 fixture: repaired .gitignore leaves work/ trackable"; else bad "AC5 fixture: work/ still ignored after repair"; fi
( cd "$fix" && git check-ignore -q scratch/y && git check-ignore -q .playwright-mcp/x ) \
  && ok "AC5 fixture: scratch/ and .playwright-mcp/ stay ignored" || bad "AC5 fixture: non-artifact ignores lost"

echo "== AC6: consistency audit policy stays clean =="
if git rev-parse --git-dir >/dev/null 2>&1; then
  git diff --quiet HEAD -- "$AGENT_DIR/doctor.md" "$CMD_DIR/doctor.md" \
    && ok "AC6 doctor agent/command catalogue unchanged vs HEAD" \
    || bad "AC6 doctor agent/command changed vs HEAD"
fi
need "$AGENT_DIR/doctor.md" '.playwright-mcp/' "AC6 doctor requires .playwright-mcp/ ignore"
need "$AGENT_DIR/doctor.md" 'scratch/' "AC6 doctor requires scratch/ ignore"
need "$AGENT_DIR/doctor.md" 'IGNORE-MISSING' "AC6 doctor keep IGNORE-MISSING check"
need "$CMD_DIR/doctor.md" '.playwright-mcp/' "AC6 doctor command names .playwright-mcp/"
need "$CMD_DIR/doctor.md" 'scratch/' "AC6 doctor command names scratch/"
( git check-ignore -q .playwright-mcp/x && git check-ignore -q scratch/y && ! git check-ignore -q work/x ) \
  && ok "AC6 IGNORE-MISSING inputs match: tooling ignored, work/ not" \
  || bad "AC6 IGNORE-MISSING inputs drifted"

echo "== AC7: PR handoff links resolve from the branch =="
need "$AGENT_DIR/shipper.md" 'work/<item-ref>/` artifacts' "AC7 shipper stages work/<item-ref>/ artifacts"
need "$AGENT_DIR/shipper.md" 'repository path' "AC7 shipper links artifacts by repository path"
need "$SKILL_DIR/pr-workflow/SKILL.md" 'resolve for a reviewer who does not share' "AC7 pr-workflow states links resolve"
need "$SKILL_DIR/pr-workflow/SKILL.md" 'work/<item-ref>/spec.md' "AC7 pr-workflow lists spec path"
note "AC7 post-ship: run 'git ls-tree -r <branch> -- work/<item-ref>/' and open the PR links — deferred to after /ship (see verify.md)."

echo "== AC9: numbers are unique and durable =="
top_dups="$(ls work 2>/dev/null | grep -oE '^[0-9]{4}' | sort | uniq -d)"
[ -z "$top_dups" ] && ok "AC9 no duplicate top-level 4-digit prefix at HEAD" || bad "AC9 duplicate top-level prefix(es): $top_dups"
for parent in work/*/; do
  [ -d "$parent" ] || continue
  d="$(ls "$parent" 2>/dev/null | grep -oE '^[0-9]{4}' | sort | uniq -d)"
  [ -z "$d" ] || bad "AC9 duplicate child prefix(es) under $parent: $d"
done
ok "AC9 no duplicate child prefixes under any roadmap parent"
need "$CONV" 'greatest 4-digit prefix that has **ever**' "AC9 allocation uses ever-committed prefix"
need "$CONV" 'git log --all --name-only --pretty=format: -- work/' "AC9 documented history command present"
need "$CONV" 'Never reuse' "AC9 never-reuse literal preserved"
need "$CONV" 'never reused within that parent' "AC9 child never-reuse literal preserved"
# The documented rule yields a number greater than every top-level number present.
max="$(max_top_prefix "$ROOT")"
nxt="$(next_number "$max")"
if [ -z "$max" ] || [ "$((10#$nxt))" -gt "$((10#$max))" ]; then
  ok "AC9 documented rule yields $nxt > present max ${max:-none}"
else
  bad "AC9 documented rule yields $nxt, not greater than $max"
fi
ls work 2>/dev/null | grep -qE "^${nxt}-" && bad "AC9 next number $nxt already exists" || ok "AC9 next number $nxt is free"
# Fixture: empty root starts at 0001.
fx="$FIX_ROOT/empty"; mkdir -p "$fx/work"; ( cd "$fx"
  git init -q -b main; git config user.email t@t; git config user.name t
  : > work/.gitkeep; git add -A; git commit -qm base ) >/dev/null
[ "$(next_number "$(max_top_prefix "$fx")")" = "0001" ] \
  && ok "AC9 fixture: empty root allocates 0001" || bad "AC9 fixture: empty root did not allocate 0001"
# Fixture: a deleted directory's number is never reused.
fd="$FIX_ROOT/deleted"; mkdir -p "$fd/work/0005-old"; ( cd "$fd"
  git init -q -b main; git config user.email t@t; git config user.name t
  printf 'x\n' > work/0005-old/spec.md; git add -A; git commit -qm add
  git rm -qr work/0005-old; git commit -qm delete ) >/dev/null
deleted_next="$(next_number "$(max_top_prefix "$fd")")"
[ "$deleted_next" = "0006" ] \
  && ok "AC9 fixture: deleted 0005 stays spent, next 0006" \
  || bad "AC9 fixture: after deleting 0005 next was $deleted_next, expected 0006"

echo "== AC10: parallel branches reconcile without collisions =="
need "$WF" 'duplicate 4-digit prefixes' "AC10 workflow documents duplicate-prefix scan"
need "$WF" 'Renumbering after a parallel merge' "AC10 workflow points at renumber procedure"
need "$CONV" '### Renumbering after a parallel merge' "AC10 conventions has renumber section"
need "$CONV" 'any two canonical references that differ only' "AC10 conventions detects same-number different-slug"
need "$CONV" 'Update every reference in the same change' "AC10 conventions updates every reference"
need "$CONV" 'never reused' "AC10 renumber keeps the old number spent"
# Fixture: two branches each allocate 0004; merge then apply the documented renumber.
fm="$FIX_ROOT/merge"; mkdir -p "$fm/work"; ( cd "$fm"
  git init -q -b main; git config user.email t@t; git config user.name t
  : > work/.gitkeep; git add -A; git commit -qm base
  git checkout -q -b branch-a
  mkdir -p work/0004-alpha; printf -- '---\nfeature: 0004-alpha\n---\n' > work/0004-alpha/spec.md
  git add -A; git commit -qm a
  git checkout -q main
  git checkout -q -b branch-b
  mkdir -p work/0004-beta; printf -- '---\nfeature: 0004-beta\n---\n' > work/0004-beta/spec.md
  git add -A; git commit -qm b
  git checkout -q branch-a
  git merge -q --no-edit branch-b ) >/dev/null 2>&1
if [ -d "$fm/work/0004-alpha" ] && [ -d "$fm/work/0004-beta" ]; then
  dup="$(cd "$fm" && ls work | grep -oE '^[0-9]{4}' | sort | uniq -d)"
  [ "$dup" = "0004" ] && ok "AC10 fixture: merge leaves duplicate prefix 0004" || bad "AC10 fixture: duplicate not detected ($dup)"
  # Documented renumber: move the later/unshipped item and update references.
  ( cd "$fm"
    git mv work/0004-beta work/0005-beta
    sed -i 's/^feature: 0004-beta/feature: 0005-beta/' work/0005-beta/spec.md
    git add -A; git commit -qm renumber ) >/dev/null 2>&1
  after="$(cd "$fm" && ls work | grep -oE '^[0-9]{4}' | sort | uniq -d)"
  [ -z "$after" ] && ok "AC10 fixture: no duplicate prefix after renumber" || bad "AC10 fixture: duplicate remains ($after)"
  ( cd "$fm" && grep -q '^feature: 0005-beta' work/0005-beta/spec.md ) \
    && ok "AC10 fixture: frontmatter reference updated to new number" \
    || bad "AC10 fixture: frontmatter reference not updated"
else
  bad "AC10 fixture: two-branch merge did not produce both items"
fi

echo "== AC11: visual evidence is committed =="
for p in work/example/visual/desktop.png work/example/visual/mobile.png; do
  git check-ignore -q "$p" && bad "AC11 $p ignored" || ok "AC11 $p trackable"
done
need "$AGENT_DIR/visual.md" 'committed working state' "AC11 visual agent states evidence committed"
need "$SKILL_DIR/browser-verification/SKILL.md" 'committed working state' "AC11 browser skill states evidence committed"
need "$SKILL_DIR/browser-verification/SKILL.md" 'transient output under `scratch/`' "AC11 transient output stays in scratch/"

echo "== AC12: derived state preserved; no state file or registry =="
need "$WF" 'There is no state file.' "AC12 workflow states no state file"
need "$WF" 'it is never stored' "AC12 readiness never stored"
need "$WF" 'derived live' "AC12 state derived live"
need "$AGENT_DIR/status.md" 'State is derived, never assumed' "AC12 status derives state"
need "$CONV" 'Do not create a registry' "AC12 conventions forbids registry file"
# No allocation/state/ledger file was introduced under work/.
stray="$(find work -type f \( -iname '*ledger*' -o -iname '*.alloc' -o -iname '*allocations*' -o -iname '*registry*' \) 2>/dev/null)"
[ -z "$stray" ] && ok "AC12 no ledger/registry/allocation file under work/" || bad "AC12 stray state file(s): $stray"
git status --porcelain --untracked-files=all work/ | grep -qE 'ledger|registry|allocations' \
  && bad "AC12 git status shows a new state/ledger path" || ok "AC12 git status shows no state/ledger path"

echo "== Edge cases (static halves) =="
# Placeholder retained next to a real artifact: the directory stays tracked.
if [ -f "$ITEM/.gitkeep" ] && [ -f "$ITEM/spec.md" ]; then
  git check-ignore -q "$ITEM/.gitkeep" && bad "EDGE placeholder beside real artifact ignored" \
    || ok "EDGE placeholder beside real artifact stays trackable"
else
  note "EDGE placeholder-beside-artifact not present in this corpus"
fi
need "$CONV" 'When the set is empty,' "EDGE empty root documented"
need "$CONV" 'even' "EDGE deleted-number durability documented"
need "$CONV" 'Renumbering is the one sanctioned mechanical cross-phase edit' "EDGE renumber scope documented"
# Historical artifacts are excluded from the AC4 sweep: the sweep above reads
# only current surfaces. Positive control: the historical `work/` corpus still
# contains the old wording, so the exclusion is load-bearing, not vacuous.
hist="$(grep -rIlE 'git-ignored|not deliverable' work/ 2>/dev/null \
  | grep -v '0003-framework-quality-hardening/0001-state-model' | head -1)"
[ -n "$hist" ] && ok "EDGE historical work/ artifacts still carry old wording ($hist) and are excluded from AC4" \
  || note "EDGE no historical work/ artifact carries the old wording; exclusion untested"

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
