#!/usr/bin/env bash
#
# Executable evidence for
# work/0003-framework-quality-hardening/0002-readiness-ship-state
# (readiness semantics and shipped-state detection).
#
# Read-only against the repository. There is no test runner in this repo (no
# package.json/pyproject.toml; AGENTS.md Project profile is an unfilled
# template). Framework verification is read-only shell assertions plus real
# agent invocation, matching work/0001-framework-consistency-hardening,
# work/0002-agentic-roadmaps, and 0003/0001-state-model.
#
# This suite is a focused, independent complement to the assertions T5 added to
# work/0002-agentic-roadmaps/verify-tests.sh. It covers the facts that guard
# AC1-AC10 but were not asserted there: the derived-state precedence order
# (ship.md row before the request-changes row), the README-vs-frontmatter
# permission agreement, the required ship.md write, that the ship.md signal is
# committed on the branch (not left uncommitted after the push/PR), the read-only
# status agent's freedom from gh/PR, and the obsolete-assertion cleanup.
#
# Usage: bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh [repo-root]
# Exit:  0 = pass, 1 = one or more failures.

set -u

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not a git repo"; exit 2; }
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

WF="docs/workflow.md"; CONV="docs/artifact-conventions.md"
SAG=".opencode/agent/status.md"; SC=".opencode/command/status.md"
SHIP=".opencode/agent/shipper.md"; SHIPC=".opencode/command/ship.md"
PROD=".opencode/agent/product.md"; README="README.md"; AGENTS="AGENTS.md"
SKILL=".opencode/skill/workflow-lifecycle/SKILL.md"
SUITE="work/0002-agentic-roadmaps/verify-tests.sh"

pass=0; fail=0
ok()  { pass=$((pass+1)); printf 'ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf 'FAIL  %s\n' "$1"; }
has()  { grep -qF -- "$2" "$1"; }
hasE() { grep -qE -- "$2" "$1"; }
need()  { has "$1" "$2" && ok "$3" || bad "$3 (missing '$2' in $1)"; }
needE() { hasE "$1" "$2" && ok "$3" || bad "$3 (no /$2/ in $1)"; }
fm()   { awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f' "$1"; } # frontmatter
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }                          # unwrap lines
line_of() { grep -nF -- "$2" "$1" | head -1 | cut -d: -f1; }         # 1-based line

echo "== AC1: exactly one surface states the readiness algorithm =="
algo_hits=0; algo_file=""
for f in "$WF" "$SAG" "$SC" "$PROD" "$CONV" "$SKILL"; do
  if has "$f" 'satisfied(dep_local_id):'; then algo_hits=$((algo_hits+1)); algo_file="$f"; fi
done
[ "$algo_hits" -eq 1 ] && [ "$algo_file" = "$WF" ] \
  && ok "AC1 algorithm stated exactly once, in $WF" \
  || bad "AC1 algorithm appears in $algo_hits candidate file(s): ${algo_file:-none}"
for f in "$SAG" "$SC" "$PROD"; do
  need "$f" 'Dependencies and readiness' "AC1 $f defers to the authority by name"
done

echo "== AC2: approve-but-unshipped is satisfied; no surface denies it =="
need "$WF" 'even if unshipped' "AC2 workflow: approve satisfies even if unshipped"
flat_sag="$(flat "$SAG")"
case "$flat_sag" in
  *'even when unshipped'*) ok "AC2 status agent: approve satisfies even when unshipped" ;;
  *) bad "AC2 status agent: approve-unshipped clause missing" ;;
esac
flat_sc="$(flat "$SC")"
case "$flat_sc" in
  *'even when unshipped'*) ok "AC2 /status command: approve satisfies even when unshipped" ;;
  *) bad "AC2 /status command: approve-unshipped clause missing" ;;
esac
contra=0
for f in "$WF" "$SAG" "$SC" "$PROD" "$CONV"; do
  if grep -qiE -- 'approved-but-unshipped.*not satisfied|not satisfied.*approved-but-unshipped' "$f"; then
    bad "AC2 $f contradicts the approve-unshipped semantics"; contra=$((contra+1))
  fi
done
[ "$contra" -eq 0 ] && ok "AC2 no candidate surface contradicts approve-unshipped"

echo "== AC3: every surface agrees branch-for-branch with the authority =="
need "$WF" 'presence is the sole shipped signal' "AC3 authority: presence is the sole shipped signal"
flat_wf="$(flat "$WF")"
case "$flat_wf" in
  *'keyed on presence rather than contents'*) ok "AC3 authority keys on presence, not contents" ;;
  *) bad "AC3 authority presence-vs-contents clause missing" ;;
esac
need "$WF" 'takes precedence' "AC3 authority: ship.md presence takes precedence over request-changes"
case "$flat_sag" in
  *'never restate its branch sequence'*) ok "AC3 status agent forbids restating the branch sequence" ;;
  *) bad "AC3 status agent does not forbid restating the branch sequence" ;;
esac
need "$SC" 'Do not restate its branch sequence' "AC3 /status command forbids restating the branch sequence"
has "$WF" 'or a PR detected for' && bad "AC3 authority still groups the removed PR branch" \
  || ok "AC3 authority no longer groups an approved-but-unshipped dep as unsatisfied"

echo "== AC4: ship.md presence is the sole shipped condition; no PR signal =="
need "$WF" 'if child_dir/ship.md exists' "AC4 authority: ship.md presence satisfies a dependency"
ship_ln="$(line_of "$WF" 'if child_dir/ship.md exists')"
appr_ln="$(line_of "$WF" 'and its verdict == "approve"')"
[ -n "$ship_ln" ] && [ -n "$appr_ln" ] && [ "$ship_ln" -lt "$appr_ln" ] \
  && ok "AC4 algorithm: ship.md branch precedes the review branch" \
  || bad "AC4 algorithm branch order wrong (ship=$ship_ln review=$appr_ln)"
row_ship="$(line_of "$WF" '| `ship.md` present')"
row_rc="$(line_of "$WF" '| `review.md` verdict `request-changes`')"
[ -n "$row_ship" ] && [ -n "$row_rc" ] && [ "$row_ship" -lt "$row_rc" ] \
  && ok "AC4 derived-state: ship.md row precedes the request-changes row" \
  || bad "AC4 derived-state precedence order wrong (ship=$row_ship request-changes=$row_rc)"
needE "$WF" '^\| `ship\.md` present +\| shipped' "AC4 derived-state: ship.md present -> shipped"
# A shipped UI item retains visual.md; the derived table is read top-down, so the
# ship.md row must outrank the visual.md row or the item is misderived as review.
row_vis="$(line_of "$WF" '| `visual.md` present')"
[ -n "$row_ship" ] && [ -n "$row_vis" ] && [ "$row_ship" -lt "$row_vis" ] \
  && ok "AC4 derived-state: ship.md row precedes the visual.md row" \
  || bad "AC4 derived-state: visual.md outranks ship.md (ship=$row_ship visual=$row_vis)"
pr_hits=0
for f in "$WF" "$SAG" "$SC" "$PROD" "$CONV" "$SKILL" "$README"; do
  if grep -qiE -- 'PR is detected|PR detected|detected PR' "$f"; then
    bad "AC4 $f credits a detected PR as a shipped signal"; pr_hits=$((pr_hits+1))
  fi
done
[ "$pr_hits" -eq 0 ] && ok "AC4 no live surface credits a detected PR"
# Broad sweep of every live .md surface outside work/ (the explicit list above is
# the curated set; this catches the review-M1 class: a surface that keeps routing
# on the removed PR signal with wording the curated tokens miss).
broad_pr=0; broad_scanned=0
while IFS= read -r f; do
  broad_scanned=$((broad_scanned+1))
  if grep -qiE -- 'PR is detected|PR detected|detected PR|no PR\?' "$f"; then
    bad "AC4 broad sweep: $f still keys on the removed PR signal"; broad_pr=$((broad_pr+1))
  fi
done < <(find .opencode docs -type f -name '*.md' -not -path './work/*'; printf '%s\n' AGENTS.md README.md)
[ "$broad_pr" -eq 0 ] && [ "$broad_scanned" -gt 0 ] \
  && ok "AC4 broad sweep: $broad_scanned live surfaces carry no PR signal" \
  || bad "AC4 broad sweep: $broad_pr of $broad_scanned live surfaces carry a PR signal"

echo "== AC3: lifecycle skill routes on ship.md, not the removed PR signal =="
need "$SKILL" 'no ship.md?' "AC3 skill routes the ship transition on ship.md"
has "$SKILL" 'no PR?' && bad "AC3 skill still routes the ship transition on a PR" \
  || ok "AC3 skill no longer routes on a PR"

echo "== AC5: shipper may write ship.md and the permission docs agree =="
fm "$SHIP" | grep -qF '"work/**": allow' && ok "AC5 shipper frontmatter grants work/**" \
  || bad "AC5 shipper frontmatter grants work/**"
fm "$SHIP" | grep -qF '"**/work/**": allow' && ok "AC5 shipper frontmatter grants **/work/**" \
  || bad "AC5 shipper frontmatter grants **/work/**"
ship_row="$(grep -E '^\|[[:space:]]*`shipper`' "$README" | head -1)"
printf '%s' "$ship_row" | grep -qF '`work/**` + `**/work/**`' \
  && ok "AC5 README shipper row documents the work grant" \
  || bad "AC5 README shipper row missing work grant: $ship_row"
printf '%s' "$ship_row" | grep -qF 'none' \
  && bad "AC5 README shipper row still advertises no edit" \
  || ok "AC5 README shipper row no longer advertises no edit"
need "$SHIP" 'This is required, not optional' "AC5 shipper agent makes the ship.md write required"
need "$SHIPC" 'This is required' "AC5 /ship command makes the ship.md write required"
need "$SHIPC" 'even when `gh` is unavailable' "AC5 /ship command requires the write without gh"
flat_conv="$(flat "$CONV")"
case "$flat_conv" in
  *'is the one shipped signal consumed by readiness'*) ok "AC5 conventions names ship.md presence as the consumed signal" ;;
  *) bad "AC5 conventions does not name ship.md presence as the consumed signal" ;;
esac

echo "== AC4/AC5: the ship.md signal is committed on the branch =="
# Review M1: ship.md is the sole shipped signal, so the Ship instructions must
# write it AND commit it (not leave it uncommitted after the push/PR) for it to
# travel to a fresh clone, the PR, and CI.
need "$WF" 'docs(work): record ship state' "AC4 workflow commits the ship.md signal"
need "$SHIP" 'docs(work): record ship state' "AC5 shipper agent commits the ship.md signal"
need "$SHIPC" 'docs(work): record ship state' "AC5 /ship command commits the ship.md signal"
need "$WF" 'no uncommitted `ship.md`' "AC4 workflow forbids an uncommitted ship.md"
need "$SHIP" 'no uncommitted `ship.md`' "AC5 shipper agent forbids an uncommitted ship.md"
need "$SHIPC" 'no uncommitted `ship.md`' "AC5 /ship command forbids an uncommitted ship.md"

echo "== AC6: status agent derives shipped state with its own permissions (no gh) =="
need "$SAG" 'Dependencies and readiness' "AC6 status defers to the authority"
has "$SAG" '<readiness_algorithm>' && bad "AC6 status still carries the old algorithm block" \
  || ok "AC6 status dropped the old algorithm block"
has "$SAG" '<readiness>' && ok "AC6 status has a referenced readiness note" \
  || bad "AC6 status missing the referenced readiness note"
fm "$SAG" | grep -qE '"gh ' && bad "AC6 status bash allowlist grants gh" \
  || ok "AC6 status bash allowlist has no gh"
grep -qE 'gh (pr|auth|repo|api)' "$SAG" && bad "AC6 status body invokes gh" \
  || ok "AC6 status body invokes no gh command"
grep -qiE 'pull request|detected pr|PR is detected' "$SAG" && bad "AC6 status body references a PR" \
  || ok "AC6 status body references no PR"
need "$SC" 'any `ship.md`' "AC6 /status command names only ship.md as ship state"
has "$SC" 'or detected' && bad "AC6 /status command still says 'or detected PR'" \
  || ok "AC6 /status command dropped the detected-PR state"

echo "== AC7: documented permission and resolved grant agree =="
if fm "$SHIP" | grep -qF '"work/**": allow' \
   && fm "$SHIP" | grep -qF '"**/work/**": allow' \
   && printf '%s' "$ship_row" | grep -qF '`work/**` + `**/work/**`' \
   && ! printf '%s' "$ship_row" | grep -qF 'none'; then
  ok "AC7 shipper frontmatter and README row agree (doctor PERMISSION-TABLE-MISMATCH clean)"
else
  bad "AC7 shipper permission surfaces disagree"
fi
# Doctor's PERMISSION-WORK-PATTERN: every agent granting any work pattern grants both forms.
wp_bad=0
for a in .opencode/agent/*.md; do
  if fm "$a" | grep -qF '"work/**"'; then
    fm "$a" | grep -qF '"**/work/**"' || { bad "AC7 $(basename "$a") grants work/** without **/work/**"; wp_bad=$((wp_bad+1)); }
  fi
done
[ "$wp_bad" -eq 0 ] && ok "AC7 every work-granting agent grants both path forms"

echo "== AC8: standalone phase derivation and no state file =="
need "$WF" '`review.md` verdict `approve`, no `ship.md`' "AC8 approve + no ship.md -> ship"
needE "$WF" '^\| `ship\.md` present +\| shipped' "AC8 ship.md present -> shipped"
need "$WF" 'There is no state file.' "AC8 no state file introduced"

echo "== AC9/AC10: the existing suite guards the definition and is current =="
need "$SUITE" '== AC9: one authoritative readiness definition ==' "AC9 suite carries the agreement block"
need "$SUITE" 'satisfied(dep_local_id):' "AC9 suite asserts the algorithm token"
flat_suite="$(flat "$SUITE")"
case "$flat_suite" in
  *'algorithm stated exactly once'*) ok "AC9 suite asserts exactly-once" ;;
  *) bad "AC9 suite missing the exactly-once assertion" ;;
esac
has "$SUITE" 'if a PR is detected for the child' && bad "AC10 suite still asserts the removed PR branch" \
  || ok "AC10 suite dropped the detected-PR assertion"
has "$SUITE" 'no existing agent permission block changed' && bad "AC10 suite still freezes agent permissions" \
  || ok "AC10 suite dropped the blanket permission freeze"

echo "== Edge cases =="
need "$WF" 'A child with no dependencies is `ready`' "EDGE no dependencies -> ready"
need "$WF" 'A child in a cycle is never `ready`' "EDGE cycle member never ready"
need "$WF" 'blocked_by(child)' "EDGE unsatisfied dependencies named by local id"
need "$WF" 'dangling; not satisfied' "EDGE dangling dependency -> not satisfied"
need "$WF" 'comma-separated when there are two or more' "EDGE multi-dependency delimiter documented"
# A hand-shipped item with no ship.md is not satisfied: the authority must not
# credit any PR/git signal, and the derived-state table must leave it at ship.
need "$WF" 'never stored' "EDGE readiness derived live, never stored"
need "$WF" 'Status is read-only and modifies nothing' "EDGE /status mid-ship is read-only, not an error"

echo "== AC1/AC2 broad sweep: one algorithm and no contradicting surface anywhere live =="
# The curated candidate list above is intentional, but AC1 ("exactly one
# surface states the algorithm") is a whole-tree invariant. Sweep every live
# Markdown surface outside work/ so a restatement in README/AGENTS/doctor/etc.
# is caught too. work/ history and scratch/ are never inspected.
algo_broad=0; algo_broad_files=""
while IFS= read -r f; do
  if grep -qF -- 'satisfied(dep_local_id):' "$f"; then
    algo_broad=$((algo_broad+1)); algo_broad_files="$algo_broad_files $f"
  fi
done < <(find .opencode docs -type f -name '*.md' -not -path './work/*'; printf '%s\n' "$AGENTS" "$README")
if [ "$algo_broad" -eq 1 ] && printf '%s\n' $algo_broad_files | grep -qxF "docs/workflow.md"; then
  ok "AC1 broad sweep: algorithm token on exactly one live surface (docs/workflow.md)"
else
  bad "AC1 broad sweep: algorithm token on $algo_broad live surface(s):${algo_broad_files:- none}"
fi
contra_broad=0
while IFS= read -r f; do
  if grep -qiE -- 'approved-but-unshipped.*not satisfied|not satisfied.*approved-but-unshipped' "$f"; then
    bad "AC2 broad sweep: $f contradicts approve-but-unshipped"; contra_broad=$((contra_broad+1))
  fi
done < <(find .opencode docs -type f -name '*.md' -not -path './work/*'; printf '%s\n' "$AGENTS" "$README")
[ "$contra_broad" -eq 0 ] && ok "AC2 broad sweep: no live surface contradicts approve-but-unshipped"

echo "== AC4: the derived-state table keys shipped state only on ship.md =="
derived_block="$(awk '/^## Derived state/{f=1} f&&/^## /&&!/Derived state/{exit} f' "$WF")"
if printf '%s' "$derived_block" | grep -qiE 'detected|branch/PR|with PR|PR URL'; then
  bad "AC4 derived-state table still credits a PR/branch signal"
else
  ok "AC4 derived-state table has no PR/branch shipped signal"
fi

echo "== AC5: every documented lifecycle surface names ship.md =="
need "$AGENTS" 'branch, commits, PR, `ship.md`' "AC5 AGENTS.md Ship row names ship.md"
need "$README" 'branch, commits, PR, ship.md' "AC5 README lifecycle names ship.md"
need "$README" 'Ship: branch + PR + ship.md' "AC5 README state diagram names ship.md"

echo "== AC6: the /status command is as network-free as the status agent =="
if grep -qE '\bgh\b' "$SC"; then
  bad "AC6 /status command references gh"
else
  ok "AC6 /status command references no gh"
fi

printf '\nTOTAL: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
