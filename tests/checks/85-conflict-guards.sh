#!/usr/bin/env bash
#
# AC23 — declared-conflict declaration model and check guards.
#
# The declared-conflict model (`conflicts-with` column, target grammar, target
# resolution, pair predicate, drift, shipped exclusion) and the read-only
# declared-conflict check are prompt behaviour in the framework; there is no
# committed checker. This area pins that behaviour to a committed fixture, the
# same way tests/checks/80-cycle-fixture.sh pins the prompt-only CYCLIC-DEP rule.
#
# It is fixture-scoped test code, not a production checker: it implements no
# command, is invoked by no framework command, and never reads live work/**.
# Item references are resolved inside the fixture-local tree
# tests/fixtures/declared-conflicts/items/, which shadows the live work/ root;
# surface paths resolve against the repository copy root. The suite is read-only
# and fresh-clone-clean.
#
# It also asserts the shipped reporting vocabulary (finding grammar, codes, and
# classes) on the live authority and the operative prompts, so a dropped code,
# class, or grammar is caught and named. The residual — that a live `/conflicts`,
# `/status`, or `/build`-gate model run actually emits the findings — is not
# executable in CI and is documented in tests/README.md and verify.md, exactly
# as the cycle diagnostic's LLM-run residual is.
#
# Reads only tests/fixtures/** and live surfaces (never work/**); sourced by
# tests/run.sh, so it must not call exit. Prints ok/FAIL lines labelled AC23 plus
# a sub-area, so a mutation self-check (tests/mutation.sh) can name the guard it
# trips: column-layout, positional-parse, cell-resolution, pair-predicate,
# reporting-vocabulary.

echo "== AC23 declared-conflict declaration model and check guards =="

GUARD_ROOT="tests/fixtures/declared-conflicts"
GUARD_ITEMS="$GUARD_ROOT/items"
GUARD_CANON_HEADER='| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |'
GUARD_LEGACY_HEADER='| Local id | Title | Scope | Depends on | Canonical reference |'

# --- helpers ---------------------------------------------------------------

guard_is_blank() {  # 0 if $1 is empty or only whitespace
  case "$1" in
    *[![:space:]]*) return 1 ;;
    *) return 0 ;;
  esac
}

# Own declaration record: "PRESENT|<value>" when design.md carries a
# conflicts-with line (value may be empty), else "ABSENT".
guard_own_record() {
  if [ ! -f "$1" ]; then
    printf 'ABSENT\n'
    return 0
  fi
  awk '
    NR == 1 && $0 == "---" { f = 1; next }
    f && $0 == "---" { exit }
    f && /^conflicts-with:/ {
      v = $0
      sub(/^conflicts-with:[ \t]*/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      gsub(/^"|"$/, "", v)
      print "PRESENT|" v
      found = 1
      exit
    }
    END { if (!found) print "ABSENT" }
  ' "$1"
}

# Parse a roadmap Children table by header name (not fixed positions), so both
# the current 6-column header and the legacy 5-column header parse. Emits
# "<local-id>|<depends-on>|<conflicts-with-or-ABSENT>" per data row.
guard_children_rows() {
  awk '
    /^## Children[ \t]*$/ { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (!hdr) {
        for (i = 2; i < n; i++) {
          c = a[i]
          gsub(/^[ \t]+|[ \t]+$/, "", c)
          if (c != "") col[c] = i
        }
        hdr = 1
        next
      }
      idcell = ""; dep = ""; cf = "ABSENT"
      if ("Local id" in col) idcell = a[col["Local id"]]
      if ("Depends on" in col) dep = a[col["Depends on"]]
      if ("conflicts-with" in col) cf = a[col["conflicts-with"]]
      gsub(/^[ \t]+|[ \t]+$/, "", idcell)
      gsub(/^[ \t]+|[ \t]+$/, "", dep)
      gsub(/^[ \t]+|[ \t]+$/, "", cf)
      if (idcell == "" || idcell ~ /^-+$/) next
      print idcell "|" dep "|" cf
    }
  ' "$1"
}

# Candidate tokens for a present, non-`—` declaration value. A whole-value
# malformation (blank value, or a repeated target) is reported as one FORCED
# token; otherwise each comma-separated token is a PLAIN candidate.
guard_candidates() {
  if [ "$1" = "—" ]; then return 0; fi
  if [ -z "$1" ] || guard_is_blank "$1"; then
    printf 'FORCED|\n'
    return 0
  fi
  printf '%s' "$1" | awk '
    {
      n = split($0, a, ",")
      dupe = 0
      for (i = 1; i <= n; i++) {
        t = a[i]
        gsub(/^[ \t]+|[ \t]+$/, "", t)
        tok[i] = t
      }
      for (i = 1; i <= n; i++)
        for (j = i + 1; j <= n; j++)
          if (tok[i] == tok[j]) dupe = 1
      if (dupe) { print "FORCED|" $0; next }
      for (i = 1; i <= n; i++) print "PLAIN|" tok[i]
    }
  '
}

# Token list used for the drift set comparison (blank value -> one empty token).
guard_value_tokenlist() {
  if [ "$1" = "—" ]; then return 0; fi
  if guard_is_blank "$1"; then printf '\n'; return 0; fi
  printf '%s' "$1" | awk '
    {
      n = split($0, a, ",")
      for (i = 1; i <= n; i++) {
        t = a[i]
        gsub(/^[ \t]+|[ \t]+$/, "", t)
        print t
      }
    }
  '
}

# Structural malformation independent of resolution: blank, glob metacharacter,
# `..` traversal, absolute path, or self-reference.
guard_malformed() {  # $1 token, $2 entity ref, $3 local id
  guard_is_blank "$1" && return 0
  case "$1" in
    *'*'* | *'?'* | *'['*) return 0 ;;
    *..*) return 0 ;;
    /*) return 0 ;;
  esac
  if [ "$1" = "$2" ] || [ "$1" = "$3" ]; then return 0; fi
  return 1
}

# Resolve one token. Prints "item|<canonical-ref>" or "surface|<path>", or
# "unresolved|". $2 is the parent ref (empty for standalone), $3 the local id,
# $4 the parent's parsed Children rows.
guard_resolve() {
  if printf '%s' "$1" | grep -qE '^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)?$'; then
    case "$1" in
      */*)
        if [ -d "$GUARD_ITEMS/$1" ]; then printf 'item|%s\n' "$1"; else printf 'unresolved|\n'; fi
        return 0
        ;;
      *)
        if [ -n "$2" ] && [ "$1" != "$3" ] &&
           printf '%s\n' "$4" | awk -F'|' -v id="$1" '$1==id{ found=1 } END { exit !found }'; then
          printf 'item|%s/%s\n' "$2" "$1"
        elif [ -d "$GUARD_ITEMS/$1" ]; then
          printf 'item|%s\n' "$1"
        else
          printf 'unresolved|\n'
        fi
        return 0
        ;;
    esac
  fi
  if [ -e "$1" ]; then printf 'surface|%s\n' "$1"; else printf 'unresolved|\n'; fi
}

guard_show_diff() {
  printf '    expected:\n%s\n    actual:\n%s\n' "$1" "$2"
}

guard_contains() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then ok "$3"; else bad "$3 (missing '$2')"; fi
}

guard_absent() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then bad "$3 (found '$2')"; else ok "$3"; fi
}

# --- fixture discovery and event stream ------------------------------------

# Emit a normalized event stream consumed by the four analyzers:
#   E|<entity-ref>|<shipped 0|1>
#   T|<owner-ref>|<resolved|unresolved>|<item|surface>|<identity>|<token>
#   D|<child-ref>                                  (own/cell declaration drift)
guard_emit_entity() {  # $1 ref, $2 dir, $3 parent, $4 local id, $5 rows
  local ref="$1" dir="$2" parent="$3" localid="$4" rows="$5"
  local shipped=0 own_rec own_present=0 own_val="" cell_present=0 cell_val=""
  local row cf cand c ctype ctoken res rkind rid

  [ -f "$dir/ship.md" ] && shipped=1
  GUARD_EVENTS="$GUARD_EVENTS
E|$ref|$shipped"

  own_rec="$(guard_own_record "$dir/design.md")"
  case "$own_rec" in
    PRESENT*) own_present=1; own_val="${own_rec#PRESENT|}" ;;
    *) own_present=0; own_val="" ;;
  esac

  if [ -n "$rows" ]; then
    row="$(printf '%s\n' "$rows" | awk -F'|' -v id="$localid" '$1==id{ print; exit }')"
    if [ -n "$row" ]; then
      cf="$(printf '%s\n' "$row" | awk -F'|' '{ print $3 }')"
      if [ "$cf" != "ABSENT" ]; then cell_present=1; cell_val="$cf"; fi
    fi
  fi

  # Parent/own drift: both records present (neither `—`) and their token sets
  # differ. A one-sided record is not drift.
  if [ "$own_present" = 1 ] && [ "$own_val" != "—" ] &&
     [ "$cell_present" = 1 ] && [ "$cell_val" != "—" ]; then
    if [ "$(guard_value_tokenlist "$own_val" | LC_ALL=C sort -u)" != \
         "$(guard_value_tokenlist "$cell_val" | LC_ALL=C sort -u)" ]; then
      GUARD_EVENTS="$GUARD_EVENTS
D|$ref"
    fi
  fi

  # Candidate tokens from the own record and the parent cell, in that order.
  cand=""
  if [ "$own_present" = 1 ] && [ "$own_val" != "—" ]; then cand="$(guard_candidates "$own_val")"; fi
  if [ "$cell_present" = 1 ] && [ "$cell_val" != "—" ]; then
    cand="$cand
$(guard_candidates "$cell_val")"
  fi

  # Here-string (not a pipe) so the loop runs in the current shell and the
  # GUARD_EVENTS appends are visible to the analyzers.
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    ctype="${c%%|*}"
    ctoken="${c#*|}"
    if [ "$ctype" = "FORCED" ]; then
      GUARD_EVENTS="$GUARD_EVENTS
T|$ref|unresolved|||$ctoken"
      continue
    fi
    if guard_malformed "$ctoken" "$ref" "$localid"; then
      GUARD_EVENTS="$GUARD_EVENTS
T|$ref|unresolved|||$ctoken"
      continue
    fi
    res="$(guard_resolve "$ctoken" "$parent" "$localid" "$rows")"
    rkind="${res%%|*}"
    rid="${res#*|}"
    if [ "$rkind" = "unresolved" ]; then
      GUARD_EVENTS="$GUARD_EVENTS
T|$ref|unresolved|||$ctoken"
    else
      GUARD_EVENTS="$GUARD_EVENTS
T|$ref|resolved|$rkind|$rid|$ctoken"
    fi
  done <<< "$cand"
}

guard_build_events() {
  GUARD_EVENTS=""
  local pd pname rows cd lname sd sname
  for pd in "$GUARD_ITEMS"/*/; do
    [ -d "$pd" ] || continue
    pname="${pd%/}"; pname="${pname##*/}"
    case "$pname" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    [ -f "$pd/roadmap.md" ] || continue
    rows="$(guard_children_rows "$pd/roadmap.md")"
    for cd in "$pd"/*/; do
      [ -d "$cd" ] || continue
      lname="${cd%/}"; lname="${lname##*/}"
      case "$lname" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
      guard_emit_entity "$pname/$lname" "$cd" "$pname" "$lname" "$rows"
    done
  done
  for sd in "$GUARD_ITEMS"/*/; do
    [ -d "$sd" ] || continue
    sname="${sd%/}"; sname="${sname##*/}"
    case "$sname" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    [ -f "$sd/roadmap.md" ] && continue
    [ -f "$sd/spec.md" ] || continue
    guard_emit_entity "$sname" "$sd" "" "$sname" ""
  done
}

# --- analyzers --------------------------------------------------------------
# guard_emit_entity appends to GUARD_EVENTS from the current shell (its token
# loop is fed by a here-string, not a pipe), so the analyzers below see the
# complete stream.

fixture_resolution() {
  printf '%s\n' "$GUARD_EVENTS" | awk -F'|' '$1=="T"{ print $2"|"$6"|"$3"|"$4"|"$5 }' | LC_ALL=C sort -u
}

fixture_unresolved() {
  printf '%s\n' "$GUARD_EVENTS" | awk -F'|' '$1=="T" && $3=="unresolved"{ print $2"|"$6 }' | LC_ALL=C sort -u
}

fixture_drift() {
  printf '%s\n' "$GUARD_EVENTS" | awk -F'|' '$1=="D"{ print $2 }' | LC_ALL=C sort -u
}

fixture_conflicts() {
  printf '%s\n' "$GUARD_EVENTS" | awk -F'|' '
    $1 == "E" { shipped[$2] = $3; ents[$2] = 1; next }
    $1 == "T" && $3 == "resolved" {
      key = ($4 == "item" ? "I:" : "S:") $5
      set[$2] = set[$2] "\n" key "\n"
      next
    }
    END {
      n = 0
      for (e in ents) if (shipped[e] == "0") list[++n] = e
      for (i = 1; i <= n; i++)
        for (j = i + 1; j <= n; j++)
          if (list[i] > list[j]) { t = list[i]; list[i] = list[j]; list[j] = t }
      for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
          A = list[i]; B = list[j]
          shared = 0; has_a = 0
          na = split(set[A], ka, "\n")
          for (x = 1; x <= na; x++) {
            k = ka[x]
            if (k == "") continue
            if (index(set[B], "\n" k "\n") > 0) {
              shared = 1
              if (substr(k, 1, 2) == "S:" && substr(k, 3, 5) != "work/") has_a = 1
            }
          }
          cls = ""
          if (has_a) cls = "(a)"
          else if (shared) cls = "(b)"
          if (cls == "" && (index(set[A], "\nI:" B "\n") > 0 || index(set[B], "\nI:" A "\n") > 0)) cls = "(b)"
          if (cls != "") print A "|" B "|" cls
        }
      }
    }
  ' | LC_ALL=C sort
}

# --- fixture existence and read-only contract ------------------------------

if [ -d "$GUARD_ITEMS" ]; then
  ok "AC23 fixture-existence: declared-conflicts fixture tree exists"
else
  bad "AC23 fixture-existence: declared-conflicts fixture tree missing at $GUARD_ITEMS"
fi

for guard_file in \
  "$GUARD_ITEMS/9001-roadmap-a/roadmap.md" \
  "$GUARD_ITEMS/9001-roadmap-a/0004-shipped/ship.md" \
  "$GUARD_ITEMS/9003-roadmap-old/roadmap.md"; do
  if [ -f "$guard_file" ]; then
    ok "AC23 fixture-existence: $guard_file exists"
  else
    bad "AC23 fixture-existence: $guard_file missing"
  fi
done

if [ -d "$GUARD_ITEMS" ] && ! grep -rq 'work/' "$GUARD_ROOT" 2>/dev/null; then
  ok "AC23 read-only-contract: fixture references no live work/ path"
else
  bad "AC23 read-only-contract: fixture references a live work/ path"
fi

# --- AC23 column-layout -----------------------------------------------------

if [ -f "$GUARD_ITEMS/9001-roadmap-a/roadmap.md" ]; then
  need "$GUARD_ITEMS/9001-roadmap-a/roadmap.md" "$GUARD_CANON_HEADER" \
    "AC23 column-layout: fixture roadmap has the 6-column Children header"
  need "$GUARD_ITEMS/9003-roadmap-old/roadmap.md" "$GUARD_LEGACY_HEADER" \
    "AC23 column-layout: legacy fixture roadmap has the 5-column Children header"
else
  bad "AC23 column-layout: fixture roadmap missing"
fi

# --- AC23 positional-parse --------------------------------------------------

guard_hdr_line=""
if [ -f "$GUARD_ITEMS/9001-roadmap-a/roadmap.md" ]; then
  guard_hdr_line="$(grep -F -- "$GUARD_CANON_HEADER" "$GUARD_ITEMS/9001-roadmap-a/roadmap.md" | head -n1)"
fi
guard_parse="$(printf '%s' "$guard_hdr_line" | awk -F'|' '{ gsub(/^[ \t]+|[ \t]+$/, "", $5); gsub(/^[ \t]+|[ \t]+$/, "", $6); print $5 "|" $6 }')"
if [ "$guard_parse" = "Depends on|conflicts-with" ]; then
  ok "AC23 positional-parse: Depends on is pipe-field 5 and conflicts-with field 6"
else
  bad "AC23 positional-parse: 6-column header does not place Depends on at pipe-field 5 (got '$guard_parse')"
fi

# --- analyzers and expected outcome blocks ----------------------------------

guard_build_events

ACT_RESOLUTION="$(fixture_resolution)"
ACT_UNRESOLVED="$(fixture_unresolved)"
ACT_DRIFT="$(fixture_drift)"
ACT_CONFLICTS="$(fixture_conflicts)"

EXP_RESOLUTION="$(cat <<'EOF'
9001-roadmap-a/0001-shared|0002-sibling|resolved|item|9001-roadmap-a/0002-sibling
9001-roadmap-a/0001-shared|docs/artifact-conventions.md|resolved|surface|docs/artifact-conventions.md
9001-roadmap-a/0002-sibling|0001-shared|resolved|item|9001-roadmap-a/0001-shared
9001-roadmap-a/0003-drift|docs/customization.md|resolved|surface|docs/customization.md
9001-roadmap-a/0003-drift|docs/workflow.md|resolved|surface|docs/workflow.md
9001-roadmap-a/0004-shipped|docs/artifact-conventions.md|resolved|surface|docs/artifact-conventions.md
9001-roadmap-a/0005-self|0005-self|unresolved||
9001-roadmap-a/0006-unspecced|tests/fixtures|resolved|surface|tests/fixtures
9002-roadmap-b/0002-sibling|0001-shared|resolved|item|9002-roadmap-b/0001-shared
9010-surface-shared|docs/artifact-conventions.md|resolved|surface|docs/artifact-conventions.md
9011-names-silent|9012-silent|resolved|item|9012-silent
9013-names-shipped|9001-roadmap-a/0004-shipped|resolved|item|9001-roadmap-a/0004-shipped
9014-dir-surface|docs|resolved|surface|docs
9015-bad-targets|../escape|unresolved||
9015-bad-targets|/abs.md|unresolved||
9015-bad-targets|9999-nope|unresolved||
9015-bad-targets|docs/*.md|unresolved||
9016-self|9016-self|unresolved||
9017-duplicate|README.md, README.md|unresolved||
9018-empty||unresolved||
9020-shares-silent|9012-silent|resolved|item|9012-silent
EOF
)"

EXP_UNRESOLVED="$(cat <<'EOF'
9001-roadmap-a/0005-self|0005-self
9015-bad-targets|../escape
9015-bad-targets|/abs.md
9015-bad-targets|9999-nope
9015-bad-targets|docs/*.md
9016-self|9016-self
9017-duplicate|README.md, README.md
9018-empty|
EOF
)"

EXP_DRIFT="$(cat <<'EOF'
9001-roadmap-a/0003-drift
EOF
)"

EXP_CONFLICTS="$(cat <<'EOF'
9001-roadmap-a/0001-shared|9001-roadmap-a/0002-sibling|(b)
9001-roadmap-a/0001-shared|9010-surface-shared|(a)
9002-roadmap-b/0001-shared|9002-roadmap-b/0002-sibling|(b)
9011-names-silent|9012-silent|(b)
9011-names-silent|9020-shares-silent|(b)
9012-silent|9020-shares-silent|(b)
EOF
)"

# --- AC23 cell-resolution (AC2, AC5, AC6) -----------------------------------

if [ "$ACT_RESOLUTION" = "$EXP_RESOLUTION" ]; then
  ok "AC23 cell-resolution: fixture token resolution matches the expected block"
else
  bad "AC23 cell-resolution: fixture token resolution diverged from the expected block"
  guard_show_diff "$EXP_RESOLUTION" "$ACT_RESOLUTION"
fi

if [ "$ACT_UNRESOLVED" = "$EXP_UNRESOLVED" ]; then
  ok "AC23 cell-resolution: malformed/unresolved declarations match the expected block"
else
  bad "AC23 cell-resolution: malformed/unresolved declarations diverged from the expected block"
  guard_show_diff "$EXP_UNRESOLVED" "$ACT_UNRESOLVED"
fi

if [ "$ACT_DRIFT" = "$EXP_DRIFT" ]; then
  ok "AC23 cell-resolution: declaration drift matches the expected block"
else
  bad "AC23 cell-resolution: declaration drift diverged from the expected block"
  guard_show_diff "$EXP_DRIFT" "$ACT_DRIFT"
fi

# AC5: sibling-first precedence wins over the same-named top-level decoy.
guard_contains "$ACT_RESOLUTION" \
  '9001-roadmap-a/0002-sibling|0001-shared|resolved|item|9001-roadmap-a/0001-shared' \
  "AC23 cell-resolution: a bare MMMM-slug resolves to its sibling row first"
# AC6: the drift child's union includes both the own and the parent sets.
guard_contains "$ACT_RESOLUTION" \
  '9001-roadmap-a/0003-drift|docs/customization.md|resolved|surface|docs/customization.md' \
  "AC23 cell-resolution: drift union includes the child's own declaration"
guard_contains "$ACT_RESOLUTION" \
  '9001-roadmap-a/0003-drift|docs/workflow.md|resolved|surface|docs/workflow.md' \
  "AC23 cell-resolution: drift union includes the parent cell's declaration"
# AC5: `—` and an absent column declare nothing (no resolution lines for them).
if printf '%s\n' "$ACT_RESOLUTION" | grep -qE '^(9002-roadmap-b/0001-shared|9003-roadmap-old/0001-old|9019-none)\|'; then
  bad "AC23 cell-resolution: an em-dash/absent declaration produced a target"
else
  ok "AC23 cell-resolution: an em-dash and an absent column declare no targets"
fi

# --- AC23 pair-predicate (AC3, AC4, AC7) ------------------------------------

if [ "$ACT_CONFLICTS" = "$EXP_CONFLICTS" ]; then
  ok "AC23 pair-predicate: declared conflict pairs match the expected block"
else
  bad "AC23 pair-predicate: declared conflict pairs diverged from the expected block"
  guard_show_diff "$EXP_CONFLICTS" "$ACT_CONFLICTS"
fi

guard_contains "$ACT_CONFLICTS" \
  '9001-roadmap-a/0001-shared|9010-surface-shared|(a)' \
  "AC23 pair-predicate: shared surface target is a class (a) conflict"
guard_contains "$ACT_CONFLICTS" \
  '9001-roadmap-a/0001-shared|9001-roadmap-a/0002-sibling|(b)' \
  "AC23 pair-predicate: reciprocal naming yields exactly one class (b) conflict"
guard_contains "$ACT_CONFLICTS" \
  '9011-names-silent|9012-silent|(b)' \
  "AC23 pair-predicate: one-sided naming of a silent counterpart is a conflict"
guard_contains "$ACT_CONFLICTS" \
  '9002-roadmap-b/0001-shared|9002-roadmap-b/0002-sibling|(b)' \
  "AC23 pair-predicate: naming a silent sibling is a conflict"
guard_contains "$ACT_CONFLICTS" \
  '9012-silent|9020-shares-silent|(b)' \
  "AC23 pair-predicate: shared work/ item target is a class (b) conflict"
if printf '%s\n' "$ACT_CONFLICTS" | grep -qF '9001-roadmap-a/0004-shipped'; then
  bad "AC23 pair-predicate: shipped item appears as a conflict counterpart"
else
  ok "AC23 pair-predicate: shipped item is excluded as a counterpart"
fi
if printf '%s\n' "$ACT_CONFLICTS" | grep -qF '9001-roadmap-a/0002-sibling|9002-roadmap-b/0002-sibling'; then
  bad "AC23 pair-predicate: cross-roadmap equal token was treated as a shared target"
else
  ok "AC23 pair-predicate: cross-roadmap equal token is not a shared target"
fi

# Edge (spec): an empty compared set — no unshipped item declares anything, and
# the all-shipped case — yields no findings and does not error. Exercised
# directly against the analyzer with a synthetic event stream so the fixture
# stays focused on the conflict-bearing cases.
guard_saved_events="$GUARD_EVENTS"
GUARD_EVENTS="E|9001-roadmap-a/0001-shared|0
E|9019-none|0"
guard_empty_nodecl="$(fixture_conflicts)"
GUARD_EVENTS="E|9001-roadmap-a/0001-shared|1
E|9019-none|1
T|9001-roadmap-a/0001-shared|resolved|surface|docs/artifact-conventions.md|docs/artifact-conventions.md
T|9019-none|resolved|surface|docs/artifact-conventions.md|docs/artifact-conventions.md"
guard_empty_shipped="$(fixture_conflicts)"
GUARD_EVENTS="$guard_saved_events"
if [ -z "$guard_empty_nodecl" ]; then
  ok "AC23 pair-predicate: an empty compared set with no declarations yields no findings"
else
  bad "AC23 pair-predicate: an empty compared set with no declarations produced a finding"
  guard_show_diff "(empty)" "$guard_empty_nodecl"
fi
if [ -z "$guard_empty_shipped" ]; then
  ok "AC23 pair-predicate: an all-shipped compared set yields no findings"
else
  bad "AC23 pair-predicate: an all-shipped compared set produced a finding"
  guard_show_diff "(empty)" "$guard_empty_shipped"
fi

# --- AC23 reporting-vocabulary (AC8) ----------------------------------------

GUARD_AUTH="$(awk '
  /^## Declared-conflict check[ \t]*$/ { f = 1; print; next }
  f && /^## / { exit }
  f { print }
' "$WF")"

guard_contains "$GUARD_AUTH" 'TEXTUAL-CONFLICT' \
  "AC23 reporting-vocabulary: authority names TEXTUAL-CONFLICT"
guard_contains "$GUARD_AUTH" 'DANGLING-DEP' \
  "AC23 reporting-vocabulary: authority names DANGLING-DEP"
guard_contains "$GUARD_AUTH" 'DRIFT-FACT' \
  "AC23 reporting-vocabulary: authority names DRIFT-FACT"
guard_contains "$GUARD_AUTH" '(a)' \
  "AC23 reporting-vocabulary: authority states class (a)"
guard_contains "$GUARD_AUTH" '(b)' \
  "AC23 reporting-vocabulary: authority states class (b)"
guard_contains "$GUARD_AUTH" '(d)' \
  "AC23 reporting-vocabulary: authority states class (d)"
guard_contains "$GUARD_AUTH" \
  '- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>' \
  "AC23 reporting-vocabulary: authority states the shipped finding-line grammar"
guard_absent "$GUARD_AUTH" '(e)' \
  "AC23 reporting-vocabulary: authority introduces no (e) class"
guard_absent "$GUARD_AUTH" 'DECLARED-' \
  "AC23 reporting-vocabulary: authority introduces no DECLARED- code"
guard_absent "$GUARD_AUTH" 'PLAN-' \
  "AC23 reporting-vocabulary: authority introduces no PLAN- code"
guard_absent "$GUARD_AUTH" 'CONFLICT-' \
  "AC23 reporting-vocabulary: authority introduces no CONFLICT- code"

guard_need() {  # $1 file, $2 literal, $3 label
  if [ -f "$1" ] && grep -qF -- "$2" "$1"; then ok "$3"; else bad "$3 (missing '$2' in $1)"; fi
}

guard_need "$SKILL_DIR/merge-conflict/SKILL.md" \
  '- [<CODE>] (<class>) <offender path or canonical reference(s)> — <specific detail>' \
  "AC23 reporting-vocabulary: skill states the shipped finding-line grammar"
guard_need "$SKILL_DIR/merge-conflict/SKILL.md" \
  'planning-time' \
  "AC23 reporting-vocabulary: skill carries the planning-time vocabulary block"
if [ -f "$SKILL_DIR/merge-conflict/SKILL.md" ] &&
   ! grep -qE '\(e\)|DECLARED-|PLAN-|CONFLICT-' "$SKILL_DIR/merge-conflict/SKILL.md"; then
  ok "AC23 reporting-vocabulary: skill introduces no new class or code prefix"
else
  bad "AC23 reporting-vocabulary: skill introduces a new class or code prefix"
fi

for guard_surface in \
  "$AGENT_DIR/status.md" \
  "$CMD_DIR/status.md" \
  "$CMD_DIR/conflicts.md" \
  "$CMD_DIR/build.md"; do
  guard_need "$guard_surface" '## Declared-conflict check' \
    "AC23 reporting-vocabulary: $guard_surface references the declaration-check authority"
done
