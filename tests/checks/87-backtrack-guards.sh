#!/usr/bin/env bash
#
# AC24 — backtracking, findings-challenge, and reopen guards.
#
# The reverse-transition model (the `backtracks.md` record and the `stale:`
# marker), the findings-challenge record (`challenges.md`) and its adjudication,
# parent-roadmap revision integrity, the post-ship `reopened:` recall marker and
# the resulting readiness revocation, and the new derived states are prompt
# behaviour in the framework; there is no committed checker. This area pins that
# behaviour to a committed fixture tree, the same way tests/checks/80-cycle-fixture.sh
# pins the prompt-only CYCLIC-DEP rule and tests/checks/85-conflict-guards.sh pins
# the prompt-only declared-conflict check.
#
# It is fixture-scoped test code, not a production checker: it implements no
# command, is invoked by no framework command, and never reads live work/**. Item
# references are resolved inside the fixture-local tree
# tests/fixtures/backtracking/items/, which shadows the live work/ root. The
# suite is read-only and fresh-clone-clean.
#
# It references the neighbouring agreement areas by name and restates none of
# their authority: tests/checks/10-readiness.sh owns the readiness single-source
# phrases (including the recalled-item branch), tests/checks/20-lifecycle.sh owns
# the core derived-state transitions, tests/checks/80-cycle-fixture.sh owns the
# roadmap cycle rule, tests/checks/85-conflict-guards.sh owns the declared-conflict
# model, and tests/checks/96-signature-sweep.sh owns the command signatures.
#
# Reads only tests/fixtures/** and live surfaces (never work/**); sourced by
# tests/run.sh, so it must not call exit. Prints ok/FAIL lines labelled AC24 plus
# a sub-area, so a mutation self-check (tests/mutation.sh) can name the guard it
# trips: reverse-edge, record-status, stale-downstream, challenge-loop,
# roadmap-revision, readiness-revocation, derived-state, contract-pins. Structural
# assertions (fixture-existence, read-only-contract, no-duplication) are labelled
# with the area but carry no mutation.
#
# Bash 3.2 compatible: no associative arrays, no mapfile, no empty-array
# expansion under `set -u`.

echo "== AC24 backtracking, findings-challenge, and reopen guards =="

BT_ROOT="tests/fixtures/backtracking"
BT_ITEMS="$BT_ROOT/items"

# --- helpers ---------------------------------------------------------------

bt_show_diff() {
  printf '    expected:\n%s\n    actual:\n%s\n' "$1" "$2"
}

bt_contains() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then ok "$3"; else bad "$3 (missing '$2')"; fi
}

# Frontmatter `stale:` value of a fixture artifact; empty when the field is
# absent or blank.
bt_stale_value() {  # $1 file
  awk '
    NR == 1 && $0 == "---" { f = 1; next }
    f && $0 == "---" { exit }
    f && /^stale:/ {
      v = $0
      sub(/^stale:[ \t]*/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      gsub(/^"|"$/, "", v)
      print v
      found = 1
      exit
    }
    END { if (!found) print "" }
  ' "$1"
}

# --- fixture discovery -----------------------------------------------------

# Every non-roadmap fixture item that carries a backtrack record.
bt_record_refs() {
  local d name
  for d in "$BT_ITEMS"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    case "$name" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    [ -f "$d/roadmap.md" ] && continue
    [ -f "$d/backtracks.md" ] || continue
    printf '%s\n' "$name"
  done | LC_ALL=C sort
}

# --- analyzers -------------------------------------------------------------
# Each emits newline-delimited, `|`-separated, sorted output; the expected blocks
# in the assertions below are the reviewed contract.

# <ref>|<finding-n>|<detecting>|<target>|<affected>|<status>
fixture_backtrack_findings() {
  local ref
  for ref in $(bt_record_refs); do
    awk -v ref="$ref" '
      function emit() {
        if (num != "") print ref "|" num "|" det "|" tgt "|" aff "|" st
      }
      /^## Finding [0-9]+/ {
        emit()
        num = $0
        sub(/^## Finding /, "", num)
        sub(/[^0-9].*$/, "", num)
        det = ""; tgt = ""; aff = ""; st = ""
        next
      }
      /^## / { if (num != "") { emit(); num = "" } next }
      num != "" && /^- detecting phase:/ {
        det = $0; sub(/^- detecting phase:[ \t]*/, "", det)
        gsub(/`/, "", det); gsub(/^[ \t]+|[ \t]+$/, "", det)
      }
      num != "" && /^- target phase:/ {
        tgt = $0; sub(/^- target phase:[ \t]*/, "", tgt)
        gsub(/`/, "", tgt); gsub(/^[ \t]+|[ \t]+$/, "", tgt)
      }
      num != "" && /^- affected:/ {
        aff = $0; sub(/^- affected:[ \t]*/, "", aff)
        gsub(/`/, "", aff); gsub(/^[ \t]+|[ \t]+$/, "", aff)
      }
      num != "" && /^- status:/ {
        st = $0; sub(/^- status:[ \t]*/, "", st)
        gsub(/`/, "", st); gsub(/^[ \t]+|[ \t]+$/, "", st)
      }
      END { emit() }
    ' "$BT_ITEMS/$ref/backtracks.md"
  done | LC_ALL=C sort
}

# <ref>|<finding-n>|<open|resolved>|<wellformed 0|1>
fixture_backtrack_status() {
  local ref
  for ref in $(bt_record_refs); do
    awk -v ref="$ref" '
      /^## Finding [0-9]+/ {
        n = $0; sub(/^## Finding /, "", n); sub(/[^0-9].*$/, "", n)
        finding[n] = ++ord
        next
      }
      /^## Resolution [0-9]+/ {
        n = $0; sub(/^## Resolution /, "", n); sub(/[^0-9].*$/, "", n)
        resorder[n] = ++ord
        next
      }
      END {
        for (n in finding) {
          status = (n in resorder) ? "resolved" : "open"
          wf = 1
          if (n in resorder && resorder[n] < finding[n]) wf = 0
          print ref "|" n "|" status "|" wf
        }
      }
    ' "$BT_ITEMS/$ref/backtracks.md"
  done | LC_ALL=C sort
}

# <ref> for every record whose entries are out of order (resolution before its
# finding).
fixture_backtrack_malformed() {
  fixture_backtrack_status | awk -F'|' '$4 == "0" { print $1 }' | LC_ALL=C sort -u
}

# <ref>|<artifact>|<stale-token|NONE> for the reverse-edge fixture items.
fixture_stale_map() {
  local ref art val
  for ref in 9101-build-design 9102-plan-spec 9103-test-plan \
             9104-test-spec 9105-test-build 9106-review-build; do
    for art in spec.md design.md tasks.md verify.md review.md; do
      [ -f "$BT_ITEMS/$ref/$art" ] || continue
      val="$(bt_stale_value "$BT_ITEMS/$ref/$art")"
      [ -n "$val" ] || val=NONE
      printf '%s|%s|%s\n' "$ref" "$art" "$val"
    done
  done | LC_ALL=C sort
}

# --- fixture existence and read-only contract ------------------------------

if [ -d "$BT_ITEMS" ]; then
  ok "AC24 fixture-existence: backtracking fixture tree exists at $BT_ITEMS"
else
  bad "AC24 fixture-existence: backtracking fixture tree missing at $BT_ITEMS"
fi

for bt_fixture in \
  "$BT_ITEMS/9101-build-design/backtracks.md" \
  "$BT_ITEMS/9102-plan-spec/backtracks.md" \
  "$BT_ITEMS/9103-test-plan/backtracks.md" \
  "$BT_ITEMS/9104-test-spec/backtracks.md" \
  "$BT_ITEMS/9105-test-build/tasks.md" \
  "$BT_ITEMS/9106-review-build/review.md" \
  "$BT_ITEMS/9107-resolved/backtracks.md" \
  "$BT_ITEMS/9108-malformed/backtracks.md" \
  "$BT_ITEMS/9109-challenge-open/challenges.md" \
  "$BT_ITEMS/9110-challenge-mixed/challenges.md" \
  "$BT_ITEMS/9111-challenge-malformed/challenges.md" \
  "$BT_ITEMS/9112-shipped-challenge/ship.md" \
  "$BT_ITEMS/9113-reopened/ship.md" \
  "$BT_ITEMS/9114-forward/tasks.md" \
  "$BT_ITEMS/9115-stale-challenge/backtracks.md" \
  "$BT_ITEMS/9115-stale-challenge/challenges.md" \
  "$BT_ITEMS/9116-empty/.gitkeep" \
  "$BT_ITEMS/9120-revised-roadmap/roadmap.md" \
  "$BT_ITEMS/9121-readiness/roadmap.md"; do
  if [ -f "$bt_fixture" ]; then
    ok "AC24 fixture-existence: $bt_fixture exists"
  else
    bad "AC24 fixture-existence: $bt_fixture missing"
  fi
done

if [ -d "$BT_ROOT" ] && ! grep -rq 'work/' "$BT_ROOT" 2>/dev/null; then
  ok "AC24 read-only-contract: fixture references no live work/ path"
else
  bad "AC24 read-only-contract: fixture references a live work/ path"
fi

if [ ! -d "$BT_ROOT/work" ]; then
  ok "AC24 read-only-contract: fixture tree contains no nested work/ directory"
else
  bad "AC24 read-only-contract: fixture tree contains a nested work/ directory"
fi

# Fixture self-containment: no absolute filesystem path and no `../` escape. The
# command tokens (`/build`, `/plan`, ...) are not absolute paths, so the absolute
# pattern matches only a known top-level directory (edge case: fixture
# self-containment).
if grep -rqE '\.\./|(^|[^A-Za-z0-9._/-])/(home|tmp|Users|etc|var|root|opt|mnt)/' "$BT_ROOT" 2>/dev/null; then
  bad "AC24 read-only-contract: fixture references an absolute or escaping path"
else
  ok "AC24 read-only-contract: fixture references no absolute or escaping path"
fi

# --- AC24 reverse-edge (AC1) ------------------------------------------------

BT_FINDINGS="$(fixture_backtrack_findings)"
BT_EXP_FINDINGS="$(cat <<'EOF'
9101-build-design|1|/build|/plan|design.md, tasks.md|open
9102-plan-spec|1|/plan|/spec|spec.md|open
9103-test-plan|1|/test|/plan|design.md, tasks.md|open
9104-test-spec|1|/test|/spec|spec.md|open
9107-resolved|1|/build|/plan|design.md|open
9108-malformed|1|/build|/plan|design.md|open
9115-stale-challenge|1|/build|/plan|design.md|open
EOF
)"

if [ "$BT_FINDINGS" = "$BT_EXP_FINDINGS" ]; then
  ok "AC24 reverse-edge: fixture finding fields match the expected block"
else
  bad "AC24 reverse-edge: fixture finding fields diverged from the expected block"
  bt_show_diff "$BT_EXP_FINDINGS" "$BT_FINDINGS"
fi

# The live authority states the five sanctioned intra-item edges as table rows.
for bt_edge in \
  '| `/build`→`/plan` |' \
  '| `/plan`→`/spec` |' \
  '| `/test`→`/plan` |' \
  '| `/test`→`/spec` |' \
  '| `/test`→`/build` |'; do
  need "$WF" "$bt_edge" "AC24 reverse-edge: $WF states the sanctioned edge $bt_edge"
done

# --- AC24 record-status (AC2) ----------------------------------------------

BT_STATUS="$(fixture_backtrack_status)"
BT_EXP_STATUS="$(cat <<'EOF'
9101-build-design|1|open|1
9102-plan-spec|1|open|1
9103-test-plan|1|open|1
9104-test-spec|1|open|1
9107-resolved|1|resolved|1
9108-malformed|1|resolved|0
9115-stale-challenge|1|open|1
EOF
)"

if [ "$BT_STATUS" = "$BT_EXP_STATUS" ]; then
  ok "AC24 record-status: effective status and order match the expected block"
else
  bad "AC24 record-status: effective status diverged from the expected block"
  bt_show_diff "$BT_EXP_STATUS" "$BT_STATUS"
fi

BT_MALFORMED="$(fixture_backtrack_malformed)"
BT_EXP_MALFORMED="$(cat <<'EOF'
9108-malformed
EOF
)"

if [ "$BT_MALFORMED" = "$BT_EXP_MALFORMED" ]; then
  ok "AC24 record-status: the out-of-order record is the only malformed one"
else
  bad "AC24 record-status: malformed-record set diverged from the expected block"
  bt_show_diff "$BT_EXP_MALFORMED" "$BT_MALFORMED"
fi

# --- AC24 stale-downstream (AC3) -------------------------------------------

BT_STALE="$(fixture_stale_map)"
BT_EXP_STALE="$(cat <<'EOF'
9101-build-design|design.md|NONE
9101-build-design|review.md|design
9101-build-design|spec.md|NONE
9101-build-design|tasks.md|NONE
9101-build-design|verify.md|design
9102-plan-spec|design.md|spec
9102-plan-spec|review.md|spec
9102-plan-spec|spec.md|NONE
9102-plan-spec|tasks.md|spec
9102-plan-spec|verify.md|spec
9103-test-plan|design.md|NONE
9103-test-plan|review.md|design
9103-test-plan|spec.md|NONE
9103-test-plan|tasks.md|NONE
9103-test-plan|verify.md|design
9104-test-spec|design.md|spec
9104-test-spec|review.md|spec
9104-test-spec|spec.md|NONE
9104-test-spec|tasks.md|spec
9104-test-spec|verify.md|spec
9105-test-build|design.md|NONE
9105-test-build|spec.md|NONE
9105-test-build|tasks.md|NONE
9105-test-build|verify.md|NONE
9106-review-build|design.md|NONE
9106-review-build|review.md|NONE
9106-review-build|spec.md|NONE
9106-review-build|tasks.md|NONE
9106-review-build|verify.md|NONE
EOF
)"

if [ "$BT_STALE" = "$BT_EXP_STALE" ]; then
  ok "AC24 stale-downstream: per-artifact stale markers match the expected block"
else
  bad "AC24 stale-downstream: per-artifact stale markers diverged from the expected block"
  bt_show_diff "$BT_EXP_STALE" "$BT_STALE"
fi

# The target phase's own artifact is never stale-marked by the detecting phase.
bt_contains "$BT_STALE" '9101-build-design|design.md|NONE' \
  "AC24 stale-downstream: a design-target edge does not stale-mark design.md"
bt_contains "$BT_STALE" '9101-build-design|tasks.md|NONE' \
  "AC24 stale-downstream: a design-target edge does not stale-mark tasks.md"
bt_contains "$BT_STALE" '9102-plan-spec|spec.md|NONE' \
  "AC24 stale-downstream: a spec-target edge does not stale-mark spec.md"

# The pre-existing rework edges force no stale marker.
if printf '%s\n' "$BT_STALE" | grep -qE '^910(5|6)-[a-z-]+\|[a-z]+\.md\|(spec|design|build|test|review)$'; then
  bad "AC24 stale-downstream: the rework edge forced a stale marker"
else
  ok "AC24 stale-downstream: the rework edges force no stale marker"
fi

# --- shared frontmatter reader ---------------------------------------------

# Frontmatter value of field $2 in file $1; empty when the field is absent or
# blank.
bt_fm_value() {  # $1 file, $2 field name
  awk -v field="$2" '
    NR == 1 && $0 == "---" { f = 1; next }
    f && $0 == "---" { exit }
    f && index($0, field ":") == 1 {
      v = $0
      sub("^" field ":[ \t]*", "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      gsub(/^"|"$/, "", v)
      print v
      found = 1
      exit
    }
    END { if (!found) print "" }
  ' "$1"
}

# --- AC24 challenge-loop (AC4) ---------------------------------------------

# Every non-roadmap fixture item carrying a challenge record.
bt_challenge_refs() {
  local d name
  for d in "$BT_ITEMS"/*/; do
    [ -d "$d" ] || continue
    name="${d%/}"; name="${name##*/}"
    case "$name" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    [ -f "$d/roadmap.md" ] && continue
    [ -f "$d/challenges.md" ] || continue
    printf '%s\n' "$name"
  done | LC_ALL=C sort
}

# <ref>|<kind>|<n>|<tokens> for every Challenge/Response/Withdrawal/Reversal
# entry. The tokens carry the entry's typed fields: a Challenge's `type`, a
# Response/Reversal's `adjudicator` and `decision`, a Withdrawal's `withdraws`.
fixture_challenge_entries() {
  local ref
  for ref in $(bt_challenge_refs); do
    awk -v ref="$ref" '
      function flush() {
        if (kind == "") return
        if (kind == "Challenge") tok = "type=" typ
        else if (kind == "Withdrawal") tok = "withdraws=" wd
        else tok = "adjudicator=" adj ";decision=" dec
        print ref "|" kind "|" n "|" tok
      }
      /^## Challenge [0-9]+/  { flush(); kind="Challenge";  n=$0; sub(/^## Challenge /,"",n);  sub(/[^0-9].*$/,"",n); typ=""; adj=""; dec=""; wd=""; next }
      /^## Response [0-9]+/   { flush(); kind="Response";   n=$0; sub(/^## Response /,"",n);   sub(/[^0-9].*$/,"",n); typ=""; adj=""; dec=""; wd=""; next }
      /^## Withdrawal [0-9]+/ { flush(); kind="Withdrawal"; n=$0; sub(/^## Withdrawal /,"",n); sub(/[^0-9].*$/,"",n); typ=""; adj=""; dec=""; wd=""; next }
      /^## Reversal [0-9]+/   { flush(); kind="Reversal";   n=$0; sub(/^## Reversal /,"",n);   sub(/[^0-9].*$/,"",n); typ=""; adj=""; dec=""; wd=""; next }
      /^## / { flush(); kind=""; next }
      kind == "Challenge" && /^- type:/ {
        v=$0; sub(/^- type:[ \t]*/,"",v); gsub(/^[ \t]+|[ \t]+$/,"",v); gsub(/`/,"",v); typ=v
      }
      (kind == "Response" || kind == "Reversal") && /^- adjudicator:/ {
        v=$0; sub(/^- adjudicator:[ \t]*/,"",v); gsub(/^[ \t]+|[ \t]+$/,"",v); gsub(/`/,"",v); adj=v
      }
      (kind == "Response" || kind == "Reversal") && /^- decision:/ {
        v=$0; sub(/^- decision:[ \t]*/,"",v); gsub(/^[ \t]+|[ \t]+$/,"",v); gsub(/`/,"",v); dec=v
      }
      kind == "Withdrawal" && /^- withdraws:/ {
        v=$0; sub(/^- withdraws:[ \t]*/,"",v); gsub(/^[ \t]+|[ \t]+$/,"",v); gsub(/`/,"",v); wd=v
      }
      END { flush() }
    ' "$BT_ITEMS/$ref/challenges.md"
  done | LC_ALL=C sort
}

# <ref>|<challenge-n>|<open|resolved|withdrawn>|<wellformed 0|1>. A challenge is
# resolved when a matching Response exists, withdrawn when a matching Withdrawal
# exists, and open otherwise; a Response/Withdrawal/Reversal recorded before its
# Challenge is malformed (wellformed 0) and is never reordered.
fixture_challenge_status() {
  local ref
  for ref in $(bt_challenge_refs); do
    awk -v ref="$ref" '
      /^## Challenge [0-9]+/  { n=$0; sub(/^## Challenge /,"",n);  sub(/[^0-9].*$/,"",n); ch[n]=++ord; next }
      /^## Response [0-9]+/   { n=$0; sub(/^## Response /,"",n);   sub(/[^0-9].*$/,"",n); rs[n]=++ord; next }
      /^## Withdrawal [0-9]+/ { n=$0; sub(/^## Withdrawal /,"",n); sub(/[^0-9].*$/,"",n); wd[n]=++ord; next }
      /^## Reversal [0-9]+/   { n=$0; sub(/^## Reversal /,"",n);   sub(/[^0-9].*$/,"",n); rv[n]=++ord; next }
      END {
        for (n in ch) {
          if (n in rs) st="resolved"; else if (n in wd) st="withdrawn"; else st="open"
          wf=1
          if ((n in rs) && rs[n] < ch[n]) wf=0
          if ((n in wd) && wd[n] < ch[n]) wf=0
          if ((n in rv) && rv[n] < ch[n]) wf=0
          print ref "|" n "|" st "|" wf
        }
      }
    ' "$BT_ITEMS/$ref/challenges.md"
  done | LC_ALL=C sort
}

# Refs whose challenge record is out of order.
fixture_challenge_malformed() {
  fixture_challenge_status | awk -F'|' '$4 == "0" { print $1 }' | LC_ALL=C sort -u
}

# Values of a `key=value` token key across an entry block, sorted.
bt_token_values() {  # $1 block, $2 key
  printf '%s\n' "$1" | tr '|;' '\n\n' | sed -n "s/^$2=//p" | LC_ALL=C sort -u
}

BT_CH_ENTRIES="$(fixture_challenge_entries)"
BT_EXP_CH_ENTRIES="$(cat <<'EOF'
9109-challenge-open|Challenge|1|type=severity
9110-challenge-mixed|Challenge|1|type=severity
9110-challenge-mixed|Challenge|2|type=finding
9110-challenge-mixed|Challenge|3|type=acceptance-criterion
9110-challenge-mixed|Response|1|adjudicator=/review;decision=sustained
9110-challenge-mixed|Response|3|adjudicator=user;decision=rejected
9110-challenge-mixed|Reversal|3|adjudicator=user;decision=sustained
9110-challenge-mixed|Withdrawal|2|withdraws=Challenge 2
9111-challenge-malformed|Challenge|1|type=severity
9111-challenge-malformed|Response|1|adjudicator=/review;decision=rejected
9112-shipped-challenge|Challenge|1|type=severity
9115-stale-challenge|Challenge|1|type=severity
EOF
)"

if [ "$BT_CH_ENTRIES" = "$BT_EXP_CH_ENTRIES" ]; then
  ok "AC24 challenge-loop: the four entry kinds and their tokens match the expected block"
else
  bad "AC24 challenge-loop: challenge entry kinds/tokens diverged from the expected block"
  bt_show_diff "$BT_EXP_CH_ENTRIES" "$BT_CH_ENTRIES"
fi

BT_CH_TYPES="$(bt_token_values "$BT_CH_ENTRIES" type | tr '\n' ' ')"
if [ "$BT_CH_TYPES" = "acceptance-criterion finding severity " ]; then
  ok "AC24 challenge-loop: the type token set is finding/severity/acceptance-criterion"
else
  bad "AC24 challenge-loop: the type token set diverged: '$BT_CH_TYPES'"
fi

BT_CH_DECISIONS="$(bt_token_values "$BT_CH_ENTRIES" decision | tr '\n' ' ')"
if [ "$BT_CH_DECISIONS" = "rejected sustained " ]; then
  ok "AC24 challenge-loop: the decision token set is sustained/rejected"
else
  bad "AC24 challenge-loop: the decision token set diverged: '$BT_CH_DECISIONS'"
fi

BT_CH_ADJ="$(bt_token_values "$BT_CH_ENTRIES" adjudicator | tr '\n' ' ')"
if [ "$BT_CH_ADJ" = "/review user " ]; then
  ok "AC24 challenge-loop: the adjudicator values are /review and user"
else
  bad "AC24 challenge-loop: the adjudicator values diverged: '$BT_CH_ADJ'"
fi

BT_CH_STATUS="$(fixture_challenge_status)"
BT_EXP_CH_STATUS="$(cat <<'EOF'
9109-challenge-open|1|open|1
9110-challenge-mixed|1|resolved|1
9110-challenge-mixed|2|withdrawn|1
9110-challenge-mixed|3|resolved|1
9111-challenge-malformed|1|resolved|0
9112-shipped-challenge|1|open|1
9115-stale-challenge|1|open|1
EOF
)"

if [ "$BT_CH_STATUS" = "$BT_EXP_CH_STATUS" ]; then
  ok "AC24 challenge-loop: effective challenge status and order match the expected block"
else
  bad "AC24 challenge-loop: challenge status diverged from the expected block"
  bt_show_diff "$BT_EXP_CH_STATUS" "$BT_CH_STATUS"
fi

BT_CH_MALFORMED="$(fixture_challenge_malformed)"
BT_EXP_CH_MALFORMED="$(cat <<'EOF'
9111-challenge-malformed
EOF
)"

if [ "$BT_CH_MALFORMED" = "$BT_EXP_CH_MALFORMED" ]; then
  ok "AC24 challenge-loop: the out-of-order challenge record is the only malformed one"
else
  bad "AC24 challenge-loop: malformed-challenge set diverged from the expected block"
  bt_show_diff "$BT_EXP_CH_MALFORMED" "$BT_CH_MALFORMED"
fi

# A Reversal supersedes a decision without reopening the challenge.
bt_contains "$BT_CH_STATUS" '9110-challenge-mixed|3|resolved|1' \
  "AC24 challenge-loop: a Reversal leaves the challenge resolved, not reopened"

# --- AC24 roadmap-revision (AC5) -------------------------------------------

# Normalized Children table row: `<id>|<dep>|<conflicts-with>|<canonical-ref>`.
bt_roadmap_rows() {  # $1 roadmap file
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^## Children[ \t]*$/ { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (!hdr) {
        for (i = 2; i < n; i++) { c = trim(a[i]); if (c != "") col[c] = i }
        hdr = 1; next
      }
      id = ""; dep = ""; cf = ""; ref = ""
      if ("Local id" in col) id = trim(a[col["Local id"]])
      if ("Depends on" in col) dep = trim(a[col["Depends on"]])
      if ("conflicts-with" in col) cf = trim(a[col["conflicts-with"]])
      if ("Canonical reference" in col) ref = trim(a[col["Canonical reference"]])
      if (id == "" || id ~ /^-+$/) next
      print id "|" dep "|" cf "|" ref
    }
  ' "$1"
}

# The Children header's column names, `|`-joined.
bt_roadmap_header() {  # $1 roadmap file
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^## Children[ \t]*$/ { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|"); out = ""
      for (i = 2; i < n; i++) out = (i == 2) ? trim(a[i]) : out "|" trim(a[i])
      print out; exit
    }
  ' "$1"
}

# Local ids in `## Sequencing`, in order.
bt_roadmap_seq() {  # $1 roadmap file
  awk '
    /^## Sequencing[ \t]*$/ { inseq = 1; next }
    inseq && /^## / { inseq = 0 }
    !inseq { next }
    /^[0-9]+\./ { s = $0; sub(/^[0-9]+\.[ \t]*/, "", s); gsub(/^[ \t]+|[ \t]+$/, "", s); if (s != "") print s }
  ' "$1"
}

# One line per failed revision-integrity check; empty when the fixture roadmap is
# integral. Instantiates docs/workflow.md -> "Revising a roadmap" on the
# fixture-local copy; the cycle proof follows tests/checks/80-cycle-fixture.sh
# and the positional/withdrawal checks defer to tests/checks/85-conflict-guards.sh,
# restating neither area's authority.
fixture_revision() {
  local rm="$BT_ITEMS/9120-revised-roadmap/roadmap.md"
  local parent="$BT_ITEMS/9120-revised-roadmap"
  [ -f "$rm" ] || { printf 'missing-roadmap|%s\n' "$rm"; return 0; }

  local hdr rows seq ids
  hdr="$(bt_roadmap_header "$rm")"
  [ "$hdr" = 'Local id|Title|Scope|Depends on|conflicts-with|Canonical reference' ] \
    || printf 'positional|%s\n' "$hdr"

  rows="$(bt_roadmap_rows "$rm")"
  seq="$(bt_roadmap_seq "$rm")"
  ids="$(printf '%s\n' "$rows" | awk -F'|' 'NF { print $1 }')"

  local id dep cf ref d seqpos_id seqpos_d child wd
  while IFS='|' read -r id dep cf ref; do
    [ -n "$id" ] || continue
    for d in $(printf '%s' "$dep" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'); do
      [ -n "$d" ] || continue
      [ "$d" = "—" ] && continue
      if [ "$d" = "$id" ]; then
        printf 'dep-self|%s\n' "$id"
      elif ! printf '%s\n' "$ids" | grep -qxF -- "$d"; then
        printf 'dep-names-row|%s|%s\n' "$id" "$d"
      fi
    done
  done <<EOF
$rows
EOF

  # Kahn, the same proof shape as tests/checks/80-cycle-fixture.sh.
  local cyc
  cyc="$(awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    /^## Children[ \t]*$/ { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (!hdr) { for (i = 2; i < n; i++) { c = trim(a[i]); if (c != "") col[c] = i } hdr = 1; next }
      id = trim(a[col["Local id"]]); dep = trim(a[col["Depends on"]])
      if (id == "" || id ~ /^-+$/) next
      nodes[id] = 1
      m = split(dep, ds, ",")
      for (i = 1; i <= m; i++) {
        d = trim(ds[i])
        if (d !~ /^[0-9][0-9][0-9][0-9]-[a-z0-9-]+$/) continue
        nodes[d] = 1
        edges[id] = edges[id] " " d
        indeg[d]++
      }
    }
    END {
      for (k in nodes) if (indeg[k] == 0) queue[++tail] = k
      removed = 0
      while (++head <= tail) {
        u = queue[head]; removed++
        m = split(edges[u], succ, " ")
        for (i = 1; i <= m; i++) { v = succ[i]; if (v == "") continue; indeg[v]--; if (indeg[v] == 0) queue[++tail] = v }
      }
      total = 0; for (k in nodes) total++
      if (removed < total) { out = ""; for (k in nodes) if (indeg[k] > 0) out = out " " k; print out }
    }
  ' "$rm")"
  [ -n "$cyc" ] && printf 'acyclic|%s\n' "${cyc# }"

  while IFS='|' read -r id dep cf ref; do
    [ -n "$id" ] || continue
    [ -n "$ref" ] || continue
    [ -d "$BT_ITEMS/$ref" ] || printf 'refs-resolve|%s|%s\n' "$id" "$ref"
  done <<EOF
$rows
EOF

  # Every active child directory appears as a row; a preserved-but-unlisted child
  # is recognised only by its `## Open issues` withdrawal record.
  for child in "$parent"/*/; do
    [ -d "$child" ] || continue
    child="${child%/}"; child="${child##*/}"
    case "$child" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    printf '%s\n' "$ids" | grep -qxF -- "$child" && continue
    grep -qF -- "Withdrawn child — \`$child\`" "$rm" && continue
    printf 'unlisted-child|%s\n' "$child"
  done

  for wd in $(sed -n 's/.*Withdrawn child — `\([0-9a-z-]*\)`.*/\1/p' "$rm"); do
    [ -d "$parent/$wd" ] || printf 'withdrawn-missing|%s\n' "$wd"
    if printf '%s\n' "$ids" | grep -qxF -- "$wd"; then
      printf 'withdrawn-listed|%s\n' "$wd"
    fi
  done

  while IFS='|' read -r id dep cf ref; do
    [ -n "$id" ] || continue
    seqpos_id="$(printf '%s\n' "$seq" | awk -v x="$id" 'BEGIN{p=0;n=0} {n++; if($0==x)p=n} END{print p}')"
    if [ "$seqpos_id" -eq 0 ]; then
      printf 'sequencing|%s|missing\n' "$id"
      continue
    fi
    for d in $(printf '%s' "$dep" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'); do
      [ -n "$d" ] || continue
      [ "$d" = "—" ] && continue
      seqpos_d="$(printf '%s\n' "$seq" | awk -v x="$d" 'BEGIN{p=0;n=0} {n++; if($0==x)p=n} END{print p}')"
      if [ "$seqpos_d" -eq 0 ]; then
        printf 'sequencing|%s|dep-missing|%s\n' "$id" "$d"
      elif [ "$seqpos_d" -gt "$seqpos_id" ]; then
        printf 'sequencing|%s|before-dep|%s\n' "$id" "$d"
      fi
    done
  done <<EOF
$rows
EOF
}

BT_RM="$BT_ITEMS/9120-revised-roadmap/roadmap.md"
BT_REVISION="$(fixture_revision)"
if [ -z "$BT_REVISION" ]; then
  ok "AC24 roadmap-revision: the revised fixture roadmap is integral (no fault)"
else
  bad "AC24 roadmap-revision: the revised fixture roadmap failed an integrity check"
  bt_show_diff "(no fault)" "$BT_REVISION"
fi

# The revision note and withdrawal record carry their documented fields.
need "$BT_RM" '**Withdrawn child — ' \
  "AC24 roadmap-revision: the withdrawal record is recorded"
need "$BT_RM" '**Revised ' \
  "AC24 roadmap-revision: the revision note is recorded"
needE "$BT_RM" '\*\*Revised [0-9]{4}-[0-9]{2}-[0-9]{2}\.\*\*' \
  "AC24 roadmap-revision: the revision note carries a date"
need "$BT_RM" 'Triggered by ' \
  "AC24 roadmap-revision: the revision note names the triggering child"
need "$BT_RM" 'Operations:' \
  "AC24 roadmap-revision: the revision note records the operations applied"
need "$BT_RM" 'Invalidated:' \
  "AC24 roadmap-revision: the revision note records the invalidated children"

# Defers to the neighbouring areas by name; restates neither one's authority.
# Resolve the sibling check files relative to this check, not the tested root:
# run.sh always sources checks from the suite directory, and the mutation
# self-check runs against a curated copy that stages no tests/checks/.
bt_checks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [ -f "$bt_checks_dir/80-cycle-fixture.sh" ] && [ -f "$bt_checks_dir/85-conflict-guards.sh" ]; then
  ok "AC24 roadmap-revision: defers to tests/checks/80-cycle-fixture.sh and tests/checks/85-conflict-guards.sh"
else
  bad "AC24 roadmap-revision: the referenced cycle/conflict-guard areas are missing"
fi

# --- AC24 readiness-revocation (AC6) ---------------------------------------

# <dep-ref>|<satisfied 0|1> for each fixture roadmap child. A child is satisfied
# when its ship record has no recall marker, or when its review verdict is
# approve; a recalled ship record is not satisfied. Readiness is derived live and
# never stored (the readiness algorithm itself is owned by tests/checks/10-readiness.sh).
fixture_readiness() {
  local rm="$BT_ITEMS/9121-readiness/roadmap.md"
  local rows id dep cf ref base sat
  rows="$(bt_roadmap_rows "$rm")"
  while IFS='|' read -r id dep cf ref; do
    [ -n "$id" ] || continue
    base="$BT_ITEMS/9121-readiness/$id"
    sat=0
    if [ -f "$base/ship.md" ]; then
      if [ -n "$(bt_fm_value "$base/ship.md" reopened)" ]; then sat=0; else sat=1; fi
    elif [ -f "$base/review.md" ] && grep -qF -- 'approve' "$base/review.md"; then
      sat=1
    fi
    printf '%s|%s\n' "$id" "$sat"
  done <<EOF
$rows
EOF
}

# <dependent-ref>|<blocked-by list> for each row with an unsatisfied dependency.
fixture_readiness_blocked() {
  local rm="$BT_ITEMS/9121-readiness/roadmap.md"
  local rows id dep cf ref d blocked sat ready
  rows="$(bt_roadmap_rows "$rm")"
  ready="$(fixture_readiness)"
  while IFS='|' read -r id dep cf ref; do
    [ -n "$id" ] || continue
    blocked=""
    for d in $(printf '%s' "$dep" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'); do
      [ -n "$d" ] || continue
      [ "$d" = "—" ] && continue
      sat="$(printf '%s\n' "$ready" | awk -F'|' -v x="$d" '$1 == x { print $2 }')"
      if [ "$sat" != "1" ]; then
        if [ -n "$blocked" ]; then blocked="$blocked, "; fi
        blocked="$blocked$d"
      fi
    done
    if [ -n "$blocked" ]; then printf '%s|%s\n' "$id" "$blocked"; fi
  done <<EOF
$rows
EOF
}

BT_READY="$(fixture_readiness)"
BT_EXP_READY="$(cat <<'EOF'
0001-recalled|0
0002-approved|1
0003-shipped|1
0004-dependent|0
EOF
)"

if [ "$BT_READY" = "$BT_EXP_READY" ]; then
  ok "AC24 readiness-revocation: recalled/approved/shipped satisfaction matches the expected block"
else
  bad "AC24 readiness-revocation: dependency satisfaction diverged from the expected block"
  bt_show_diff "$BT_EXP_READY" "$BT_READY"
fi

BT_BLOCKED="$(fixture_readiness_blocked)"
BT_EXP_BLOCKED="$(cat <<'EOF'
0004-dependent|0001-recalled
EOF
)"

if [ "$BT_BLOCKED" = "$BT_EXP_BLOCKED" ]; then
  ok "AC24 readiness-revocation: the recalled dependency blocks the dependent"
else
  bad "AC24 readiness-revocation: blocked-by set diverged from the expected block"
  bt_show_diff "$BT_EXP_BLOCKED" "$BT_BLOCKED"
fi

# No stored readiness value: the fixture roadmap keeps the six-column header.
if [ "$(bt_roadmap_header "$BT_ITEMS/9121-readiness/roadmap.md")" = 'Local id|Title|Scope|Depends on|conflicts-with|Canonical reference' ]; then
  ok "AC24 readiness-revocation: the fixture roadmap stores no readiness column"
else
  bad "AC24 readiness-revocation: the fixture roadmap header changed"
fi

# --- AC24 derived-state (AC7, AC8) -----------------------------------------

# An unshipped item with an open challenge (a Challenge n with no matching
# Response n/Withdrawal n) derives the challenged-and-blocked condition.
bt_has_open_challenge() {  # $1 ref
  printf '%s\n' "$BT_CH_STATUS" | awk -F'|' -v r="$1" '$1 == r && $3 == "open" { f = 1 } END { exit f ? 0 : 1 }'
}

# Derived-state label for a non-roadmap fixture item, applying the authority's
# precedence: earliest stale marker, then a reopened ship record, then the
# unshipped challenged overlay, then the artifact-presence/verdict rows.
bt_derive() {  # $1 ref
  local ref="$1" d="$BT_ITEMS/$1" art token phase
  for art in spec.md design.md tasks.md verify.md review.md; do
    [ -f "$d/$art" ] || continue
    token="$(bt_fm_value "$d/$art" stale)"
    if [ -n "$token" ]; then printf '%s (backtracked)\n' "$token"; return 0; fi
  done
  if [ -f "$d/ship.md" ]; then
    phase="$(bt_fm_value "$d/ship.md" reopened)"
    if [ -n "$phase" ]; then printf '%s (reopened)\n' "$phase"; return 0; fi
    printf 'shipped\n'; return 0
  fi
  if bt_has_open_challenge "$ref"; then printf 'challenged (blocked)\n'; return 0; fi
  [ -f "$d/spec.md" ] || { printf 'not started\n'; return 0; }
  [ -f "$d/design.md" ] || { printf 'spec\n'; return 0; }
  [ -f "$d/tasks.md" ] || { printf 'design\n'; return 0; }
  if grep -q '^- \[ \]' "$d/tasks.md" 2>/dev/null; then printf 'build\n'; return 0; fi
  [ -f "$d/verify.md" ] || { printf 'test\n'; return 0; }
  if [ ! -f "$d/review.md" ]; then printf 'review\n'; return 0; fi
  if grep -qF -- 'request-changes' "$d/review.md"; then printf 'build (rework)\n'; return 0; fi
  printf 'ship\n'
}

# <ref>|<label> for every non-roadmap top-level fixture item.
fixture_derived() {
  local d ref
  for d in "$BT_ITEMS"/*/; do
    [ -d "$d" ] || continue
    ref="${d%/}"; ref="${ref##*/}"
    case "$ref" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    [ -f "$d/roadmap.md" ] && continue
    printf '%s|%s\n' "$ref" "$(bt_derive "$ref")"
  done | LC_ALL=C sort
}

BT_DERIVED="$(fixture_derived)"
BT_EXP_DERIVED="$(cat <<'EOF'
9101-build-design|design (backtracked)
9102-plan-spec|spec (backtracked)
9103-test-plan|design (backtracked)
9104-test-spec|spec (backtracked)
9105-test-build|build
9106-review-build|build (rework)
9107-resolved|build
9108-malformed|build
9109-challenge-open|challenged (blocked)
9110-challenge-mixed|build
9111-challenge-malformed|build
9112-shipped-challenge|shipped
9113-reopened|design (reopened)
9114-forward|build
9115-stale-challenge|design (backtracked)
9116-empty|not started
EOF
)"

if [ "$BT_DERIVED" = "$BT_EXP_DERIVED" ]; then
  ok "AC24 derived-state: derived labels match the expected block"
else
  bad "AC24 derived-state: derived labels diverged from the expected block"
  bt_show_diff "$BT_EXP_DERIVED" "$BT_DERIVED"
fi

# A shipped item with an open challenge is never derived challenged.
bt_contains "$BT_DERIVED" '9112-shipped-challenge|shipped' \
  "AC24 derived-state: a shipped item with an open challenge stays shipped"
if printf '%s\n' "$BT_DERIVED" | grep -q '^9112-shipped-challenge|challenged'; then
  bad "AC24 derived-state: a shipped item was derived challenged"
else
  ok "AC24 derived-state: a shipped item is never derived challenged"
fi

# The structural marker derivation is evaluated before the challenged condition,
# so an item carrying both a `stale:` marker and an open challenge derives the
# backtracked label, never `challenged` (edge case: backtrack and challenge both
# present; the guard checks the order, not a second mechanism).
bt_contains "$BT_DERIVED" '9115-stale-challenge|design (backtracked)' \
  "AC24 derived-state: a stale marker outranks an open challenge"
if printf '%s\n' "$BT_DERIVED" | grep -q '^9115-stale-challenge|challenged'; then
  bad "AC24 derived-state: a backtrack-and-challenge item was derived challenged"
else
  ok "AC24 derived-state: the structural marker derivation precedes the challenged condition"
fi

# Absent records invent no backtracked/challenged/reopened state. The
# `.gitkeep`-only item derives the ordinary `not started` forward state and
# invents nothing (edge case: empty and `.gitkeep`-only item).
for bt_ref in 9107-resolved 9108-malformed 9114-forward 9116-empty; do
  if printf '%s\n' "$BT_DERIVED" | grep -qE "^$bt_ref\|(.*backtracked|challenged|reopened)"; then
    bad "AC24 derived-state: $bt_ref invented a backtracked/challenged/reopened state"
  else
    ok "AC24 derived-state: $bt_ref invents no backtracked/challenged/reopened state"
  fi
done

# --- AC24 contract-pins (AC9) ----------------------------------------------

# The documented record/field/marker/token/label shapes that cannot be computed
# from a fixture are pinned to their live single-source authorities by name:
# docs/artifact-conventions.md states the `backtracks.md`/`challenges.md` record
# shapes, and docs/workflow.md states the per-edge marker vocabulary and the
# derived-state labels. This restates neither the readiness algorithm nor the
# command signatures, both owned by tests/checks/10-readiness.sh and
# tests/checks/96-signature-sweep.sh respectively.

for bt_pin in \
  'record: backtracks' \
  'record: challenges' \
  '- detecting phase:' \
  '- target phase:' \
  '- affected:' \
  '- status: open' \
  '- resolves: Finding <n>' \
  '- revision:' \
  '## Challenge <n> — YYYY-MM-DD' \
  '## Withdrawal <n> — YYYY-MM-DD' \
  '## Reversal <n> — YYYY-MM-DD' \
  '- withdraws: Challenge <n>' \
  '- reverses: Response <n>' \
  '- adjudicator:' \
  '- decision:' \
  '`finding`' \
  '`severity`' \
  '`acceptance-criterion`' \
  'spec | design | build | test | review' \
  'stale: ""' \
  'reopened: ""'; do
  need "$CONV" "$bt_pin" "AC24 contract-pins: docs/artifact-conventions.md states '$bt_pin'"
done

for bt_pin in \
  '`P` (backtracked)' \
  '`P` (reopened)' \
  'challenged (blocked)' \
  'build (rework)' \
  'stale: design' \
  'stale: spec' \
  'finding | severity | acceptance-criterion' \
  'carrying a `reopened:` marker does not satisfy a' \
  'forces no finding record or'; do
  need "$WF" "$bt_pin" "AC24 contract-pins: docs/workflow.md states '$bt_pin'"
done

# --- AC24 no-duplication (AC12) --------------------------------------------

# This area extends the neighbouring agreement areas; it must not re-assert the
# exact literals those areas already own, and must reference them by name. The
# forbidden needles are assembled at run time from separate fragments so this
# assertion's own source does not contain them contiguously and cannot match
# itself. References are checked against the file header only (the section below
# that names the areas is deeper in the file), so the check is not satisfied by
# the assertion text itself.
bt_self="$bt_checks_dir/87-backtrack-guards.sh"
bt_head="$(sed -n '1,40p' "$bt_self" 2>/dev/null)"

for bt_area in 10-readiness 20-lifecycle 80-cycle-fixture 85-conflict-guards 96-signature-sweep; do
  if printf '%s\n' "$bt_head" | grep -qF -- "$bt_area"; then
    ok "AC24 no-duplication: references tests/checks/$bt_area.sh by name"
  else
    bad "AC24 no-duplication: does not reference tests/checks/$bt_area.sh by name"
  fi
done

bt_no_dup() {  # $1 forbidden literal, $2 owning area
  if grep -qF -- "$1" "$bt_self" 2>/dev/null; then
    bad "AC24 no-duplication: re-asserts a literal owned by tests/checks/$2.sh"
  else
    ok "AC24 no-duplication: does not re-assert a literal owned by tests/checks/$2.sh"
  fi
}

bt_own_a='satisfied(dep_local_id)'
bt_no_dup "${bt_own_a}:" 10-readiness

bt_own_b1='presence is the sole'
bt_own_b2='shipped signal'
bt_no_dup "$bt_own_b1 $bt_own_b2" 10-readiness

bt_own_c1='`spec.md`'
bt_own_c2='missing'
bt_no_dup "$bt_own_c1 $bt_own_c2" 20-lifecycle

bt_own_d1='No spec.md'
bt_own_d2='?'
bt_no_dup "$bt_own_d1$bt_own_d2" 20-lifecycle

bt_own_e1='/build [item-ref'
bt_own_e2=' or task-id]'
bt_no_dup "$bt_own_e1$bt_own_e2" 96-signature-sweep
