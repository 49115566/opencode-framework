#!/usr/bin/env bash
#
# AC27 — recursive readiness, derived-state, and /status render guard.
#
# The recursive readiness algorithm, the derived-state precedence at a node, and
# the /status report shape are prompt behaviour in the framework; there is no
# committed checker. This area pins that behaviour to a committed fixture tree at
# depth >= 3, the same way tests/checks/80-cycle-fixture.sh pins the prompt-only
# cycle rule and tests/checks/87-backtrack-guards.sh pins the reverse-edge and
# overlay semantics.
#
# It references the neighbouring agreement areas by name and restates none of
# their authority: tests/checks/10-readiness.sh owns the readiness single-source
# phrases, tests/checks/20-lifecycle.sh owns the flat derived-state transitions,
# tests/checks/80-cycle-fixture.sh owns the decomposing-node cycle rule, and
# tests/checks/87-backtrack-guards.sh owns the flat reverse-edge and overlay
# vocabulary.
#
# It is fixture-scoped test code, not a production checker: it implements no
# command, is invoked by no framework command, and never reads live work/**. The
# fixture tree lives under tests/fixtures/recursive-status/items/, which shadows
# the live artifact root. The suite is read-only and fresh-clone-clean.
#
# Reads only tests/fixtures/** and live surfaces; sourced by tests/run.sh, so it
# must not call exit. Prints ok/FAIL lines labelled AC27 plus a sub-area, so a
# mutation self-check (tests/mutation.sh) can name the guard it trips:
# recursive-readiness, nested-readiness, dependency-satisfaction,
# decomposing-target, cycle-readiness, derived-phase, overlay-precedence,
# decomposing-summary, status-render, no-stored-readiness, determinism.
# Structural assertions (fixture-existence, read-only-contract, no-duplication)
# are labelled with the area but carry no mutation.
#
# Bash 3.2 compatible: no associative arrays, no mapfile, no empty-array
# expansion under `set -u`.

echo "== AC27 recursive readiness, derived-state, and /status guard =="

RS_ROOT="tests/fixtures/recursive-status"
RS_ITEMS="$RS_ROOT/items"

# --- helpers ---------------------------------------------------------------

rs_show_diff() {
  printf '    expected:\n%s\n    actual:\n%s\n' "$1" "$2"
}

# Resolve a decomposing node's manifest: its modern `manifest.md` spelling when
# present, else the recognized deprecated alias spelling, else nothing. Lets the
# analyzers read either spelling without hardcoding a migrated fixture path.
rs_manifest() {  # $1 = node directory; prints the manifest path, or nothing
  local d="$1" base
  for base in manifest roadmap; do
    if [ -f "$d/$base.md" ]; then printf '%s\n' "$d/$base.md"; return 0; fi
  done
  return 1
}

# Frontmatter field $2 of file $1; empty when the field is absent or blank.
rs_fm_value() {  # $1 file, $2 field name
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

# Normalized Children table rows parsed by header name (not position):
# `<localid>|<depends-on>|<conflicts-with>|<canonical-ref>`.
rs_children_rows() {  # $1 manifest file
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
rs_header() {  # $1 manifest file
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

# 0 when the node's challenges.md holds a `Challenge n` with no matching
# `Response n`/`Withdrawal n` (an open challenge); non-zero otherwise.
rs_has_open_challenge() {  # $1 = node directory
  local f="$1/challenges.md"
  [ -f "$f" ] || return 1
  awk '
    /^## Challenge [0-9]+/  { n=$0; sub(/^## Challenge /,"",n);  sub(/[^0-9].*$/,"",n); ch[n]=1; next }
    /^## Response [0-9]+/   { n=$0; sub(/^## Response /,"",n);   sub(/[^0-9].*$/,"",n); rs[n]=1; next }
    /^## Withdrawal [0-9]+/ { n=$0; sub(/^## Withdrawal /,"",n); sub(/[^0-9].*$/,"",n); wd[n]=1; next }
    END { for (n in ch) if (!(n in rs) && !(n in wd)) { print "open"; break } }
  ' "$f" | grep -q .
}

# --- fixture existence and read-only contract ------------------------------

if [ -d "$RS_ITEMS" ]; then
  ok "AC27 fixture-existence: recursive-status fixture tree exists at $RS_ITEMS"
else
  bad "AC27 fixture-existence: recursive-status fixture tree missing at $RS_ITEMS"
fi

for rs_fixture in \
  "$RS_ITEMS/9200-tree/manifest.md" \
  "$RS_ITEMS/9200-tree/0001-hybrid/manifest.md" \
  "$RS_ITEMS/9200-tree/0001-hybrid/0001-empty-leaf/.gitkeep" \
  "$RS_ITEMS/9201-decoy/manifest.md"; do
  if [ -f "$rs_fixture" ]; then
    ok "AC27 fixture-existence: $rs_fixture exists"
  else
    bad "AC27 fixture-existence: $rs_fixture missing"
  fi
done

if [ -d "$RS_ROOT" ] && ! grep -rq 'work/' "$RS_ROOT" 2>/dev/null; then
  ok "AC27 read-only-contract: fixture references no live work/ path"
else
  bad "AC27 read-only-contract: fixture references a live work/ path"
fi

if [ ! -d "$RS_ROOT/work" ]; then
  ok "AC27 read-only-contract: fixture tree contains no nested work/ directory"
else
  bad "AC27 read-only-contract: fixture tree contains a nested work/ directory"
fi

# Fixture self-containment: no absolute filesystem path and no `../` escape. The
# command tokens (`/build`, `/plan`, ...) are not absolute paths, so the absolute
# pattern matches only a known top-level directory.
if grep -rqE '\.\./|(^|[^A-Za-z0-9._/-])/(home|tmp|Users|etc|var|root|opt|mnt)/' "$RS_ROOT" 2>/dev/null; then
  bad "AC27 read-only-contract: fixture references an absolute or escaping path"
else
  ok "AC27 read-only-contract: fixture references no absolute or escaping path"
fi

# --- no-duplication --------------------------------------------------------
# This area extends the neighbouring agreement areas; it must reference them by
# name and must not re-assert the exact literals those areas already own. The
# forbidden needles are assembled at run time from separate fragments so this
# assertion's own source does not contain them contiguously and cannot match
# itself. References are checked against the file header only.

rs_checks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
rs_self="$rs_checks_dir/89-recursive-status-guards.sh"
rs_head="$(sed -n '1,40p' "$rs_self" 2>/dev/null)"

for rs_area in 10-readiness 20-lifecycle 80-cycle-fixture 87-backtrack-guards; do
  if printf '%s\n' "$rs_head" | grep -qF -- "$rs_area"; then
    ok "AC27 no-duplication: references tests/checks/$rs_area.sh by name"
  else
    bad "AC27 no-duplication: does not reference tests/checks/$rs_area.sh by name"
  fi
done

rs_no_dup() {  # $1 forbidden literal, $2 owning area
  if grep -qF -- "$1" "$rs_self" 2>/dev/null; then
    bad "AC27 no-duplication: re-asserts a literal owned by tests/checks/$2.sh"
  else
    ok "AC27 no-duplication: does not re-assert a literal owned by tests/checks/$2.sh"
  fi
}

rs_own_a='satisfied(dep_local_id)'
rs_no_dup "${rs_own_a}:" 10-readiness

rs_own_b1='presence is the sole'
rs_own_b2='shipped signal'
rs_no_dup "$rs_own_b1 $rs_own_b2" 10-readiness

rs_own_c1='`spec.md`'
rs_own_c2='missing'
rs_no_dup "$rs_own_c1 $rs_own_c2" 20-lifecycle

rs_own_d1='No spec.md'
rs_own_d2='?'
rs_no_dup "$rs_own_d1$rs_own_d2" 20-lifecycle

rs_own_e1='A child in a cycle is never '
rs_own_e2='`ready`'
rs_no_dup "$rs_own_e1$rs_own_e2" 80-cycle-fixture

rs_own_f1='informational and '
rs_own_f2='never fatal'
rs_no_dup "$rs_own_f1$rs_own_f2" 80-cycle-fixture

rs_own_g1='forces no finding '
rs_own_g2='record or'
rs_no_dup "$rs_own_g1$rs_own_g2" 87-backtrack-guards

rs_own_h1='carrying a `reopened:` marker '
rs_own_h2='does not satisfy a'
rs_no_dup "$rs_own_h1$rs_own_h2" 87-backtrack-guards

# --- analyzers -------------------------------------------------------------
# Each emits newline-delimited, `|`-separated output; the expected blocks below
# are the reviewed contract.

# Sibling satisfaction: `1` when the child's ship record is present and carries
# no recall marker, or - when no ship record exists - its review verdict is
# `approve`; else `0`. A recalled ship record is not satisfied.
rs_satisfied() {  # $1 = child directory; prints 1 satisfied, 0 otherwise
  local d="$1"
  if [ -f "$d/ship.md" ]; then
    if [ -n "$(rs_fm_value "$d/ship.md" reopened)" ]; then printf '0\n'; else printf '1\n'; fi
    return 0
  fi
  if [ -f "$d/review.md" ] && grep -qF -- 'approve' "$d/review.md"; then
    printf '1\n'
  else
    printf '0\n'
  fi
}

# Local ids left after Kahn's reduction of the Children dependency graph: the
# members of a dependency cycle. The same proof shape as the cycle guards.
rs_cycle_members() {  # $1 manifest file
  awk '
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
      if (removed < total) { for (k in nodes) if (indeg[k] > 0) print k }
    }
  ' "$1" | LC_ALL=C sort
}

# <node-ref>/<localid>|<ready|blocked: ids> for each Children row. `Depends on`
# resolves against the declaring node's own rows only (sibling-only); a target
# that is itself a decomposing node is satisfied by its own signal only; a cycle
# member is never ready.
rs_ready_blocked() {  # $1 = node dir, $2 = node canonical ref
  local dir="$1" ref="$2" mf rows cyc
  mf="$(rs_manifest "$dir")" || return 0
  rows="$(rs_children_rows "$mf")"
  cyc="$(rs_cycle_members "$mf")"
  printf '%s\n' "$rows" | while IFS='|' read -r id dep cf cref; do
    [ -n "$id" ] || continue
    local blocked="" d sat
    for d in $(printf '%s' "$dep" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'); do
      [ -n "$d" ] || continue
      [ "$d" = "—" ] && continue
      if printf '%s\n' "$cyc" | grep -qxF -- "$d"; then
        sat=0
      else
        sat="$(rs_satisfied "$dir/$d")"
      fi
      if [ "$sat" != "1" ]; then
        if [ -n "$blocked" ]; then blocked="$blocked, "; fi
        blocked="$blocked$d"
      fi
    done
    if [ -n "$blocked" ]; then
      printf '%s/%s|blocked: %s\n' "$ref" "$id" "$blocked"
    else
      printf '%s/%s|ready\n' "$ref" "$id"
    fi
  done
}

rs_contains() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then ok "$3"; else bad "$3 (missing '$2')"; fi
}

RS_READY_TREE="$(rs_ready_blocked "$RS_ITEMS/9200-tree" 9200-tree | LC_ALL=C sort)"
RS_READY_HYBRID="$(rs_ready_blocked "$RS_ITEMS/9200-tree/0001-hybrid" 9200-tree/0001-hybrid | LC_ALL=C sort)"
RS_READY_DECOY="$(rs_ready_blocked "$RS_ITEMS/9201-decoy" 9201-decoy | LC_ALL=C sort)"
RS_READY_ALL="$(printf '%s\n%s\n%s\n' "$RS_READY_TREE" "$RS_READY_HYBRID" "$RS_READY_DECOY" | LC_ALL=C sort)"

# --- recursive-readiness (AC2, AC6, AC13) ----------------------------------

RS_READINESS="$(cat <<'EOF'
9200-tree/0001-hybrid/0001-empty-leaf|ready
9200-tree/0001-hybrid/0002-approved-leaf|ready
9200-tree/0001-hybrid/0003-cyclic-a|blocked: 0004-cyclic-b
9200-tree/0001-hybrid/0004-cyclic-b|blocked: 0003-cyclic-a
9200-tree/0001-hybrid|ready
9200-tree/0002-shipped|ready
9200-tree/0003-approved|ready
9200-tree/0004-rejected|ready
9200-tree/0005-noreview|ready
9200-tree/0006-precedence|ready
9200-tree/0007-recalled|ready
9200-tree/0008-dependent|blocked: 0004-rejected, 0005-noreview, 0007-recalled
9200-tree/0009-decomposing-approved|ready
9200-tree/0010-depends-decomposing|ready
9200-tree/0011-decomposing-unsat|ready
9200-tree/0012-depends-unsat-dec|blocked: 0011-decomposing-unsat
9200-tree/0013-stale-hybrid|ready
9200-tree/0014-challenged-node|ready
9200-tree/0015-stale-and-challenged|ready
9201-decoy/0002-shipped|ready
EOF
)"

if [ "$RS_READY_ALL" = "$RS_READINESS" ]; then
  ok "AC27 recursive-readiness: per-child readiness matches the expected block"
else
  bad "AC27 recursive-readiness: per-child readiness diverged from the expected block"
  rs_show_diff "$RS_READINESS" "$RS_READY_ALL"
fi

# --- nested-readiness (AC2) ------------------------------------------------

RS_READY_HYBRID_EXP="$(cat <<'EOF'
9200-tree/0001-hybrid/0001-empty-leaf|ready
9200-tree/0001-hybrid/0002-approved-leaf|ready
9200-tree/0001-hybrid/0003-cyclic-a|blocked: 0004-cyclic-b
9200-tree/0001-hybrid/0004-cyclic-b|blocked: 0003-cyclic-a
EOF
)"

if [ "$RS_READY_HYBRID" = "$RS_READY_HYBRID_EXP" ]; then
  ok "AC27 nested-readiness: depth-3 readiness matches the expected block"
else
  bad "AC27 nested-readiness: depth-3 readiness diverged from the expected block"
  rs_show_diff "$RS_READY_HYBRID_EXP" "$RS_READY_HYBRID"
fi

# The tree is genuinely three levels deep: a depth-3 node directory exists.
if [ -d "$RS_ITEMS/9200-tree/0001-hybrid/0001-empty-leaf" ]; then
  ok "AC27 nested-readiness: the fixture tree is at least three levels deep"
else
  bad "AC27 nested-readiness: the fixture tree is shallower than three levels"
fi

# --- dependency-satisfaction (AC3, AC4, AC5) -------------------------------

rs_contains "$RS_READY_ALL" \
  '9200-tree/0008-dependent|blocked: 0004-rejected, 0005-noreview, 0007-recalled' \
  "AC27 dependency-satisfaction: the satisfied/unsatisfied/recalled cases match"
rs_contains "$RS_READY_ALL" '9200-tree/0002-shipped|ready' \
  "AC27 dependency-satisfaction: a non-recalled shipped dependency is satisfied"
rs_contains "$RS_READY_ALL" '9200-tree/0003-approved|ready' \
  "AC27 dependency-satisfaction: an approved, unshipped dependency is satisfied"
rs_contains "$RS_READY_ALL" '9200-tree/0004-rejected|ready' \
  "AC27 dependency-satisfaction: a changes-requested dependency is itself ready"
rs_contains "$RS_READY_ALL" '9200-tree/0006-precedence|ready' \
  "AC27 dependency-satisfaction: ship presence takes precedence over request-changes"

if printf '%s\n' "$RS_READY_ALL" | grep -qF -- '9200-tree/0008-dependent|blocked: 0002-shipped'; then
  bad "AC27 dependency-satisfaction: a satisfied dependency was reported blocked"
else
  ok "AC27 dependency-satisfaction: a satisfied dependency is not named as blocking"
fi

# --- decomposing-target (AC6) ----------------------------------------------

rs_contains "$RS_READY_ALL" '9200-tree/0010-depends-decomposing|ready' \
  "AC27 decomposing-target: a dependent of an approved decomposing node is ready"
rs_contains "$RS_READY_ALL" '9200-tree/0012-depends-unsat-dec|blocked: 0011-decomposing-unsat' \
  "AC27 decomposing-target: a dependent of an unsatisfied decomposing node is blocked"
rs_contains "$RS_READY_ALL" '9201-decoy/0002-shipped|ready' \
  "AC27 decomposing-target: the same-local-id decoy row is independently ready"

# Sibling-only resolution: the dependent names only its own node's recalled row,
# never the decoy's same-local-id recalled row.
if printf '%s\n' "$RS_READY_ALL" | grep -qE '9200-tree/0008-dependent\|blocked: .*0002-shipped'; then
  bad "AC27 decomposing-target: a bare local id resolved across roots"
else
  ok "AC27 decomposing-target: a bare local id resolves against its own rows only"
fi

# --- cycle-readiness (AC7) -------------------------------------------------

rs_contains "$RS_READY_HYBRID" '9200-tree/0001-hybrid/0003-cyclic-a|blocked: 0004-cyclic-b' \
  "AC27 cycle-readiness: cycle member A is blocked by its cycle peer"
rs_contains "$RS_READY_HYBRID" '9200-tree/0001-hybrid/0004-cyclic-b|blocked: 0003-cyclic-a' \
  "AC27 cycle-readiness: cycle member B is blocked by its cycle peer"

if printf '%s\n' "$RS_READY_HYBRID" | grep -qE '9200-tree/0001-hybrid/000[34]-cyclic-[ab]\|ready'; then
  bad "AC27 cycle-readiness: a cycle member was reported ready"
else
  ok "AC27 cycle-readiness: no cycle member is reported ready"
fi

# --- derived-phase (AC9, AC10, AC11, AC13) ---------------------------------

# Derived label for a fixture node, applying the authority's precedence: the
# earliest stale marker, then a reopened ship record, then a plain ship record,
# then the unshipped open-challenge overlay, then a manifest with no own phase
# artifacts, then the artifact-presence/verdict rows. A `.gitkeep`-only node
# derives `not started`.
rs_derive() {  # $1 = node dir, $2 = canonical ref
  local d="$1" ref="$2" art token phase
  for art in spec.md design.md tasks.md verify.md review.md; do
    [ -f "$d/$art" ] || continue
    token="$(rs_fm_value "$d/$art" stale)"
    if [ -n "$token" ]; then
      case "$token" in manifest|roadmap) token=spec ;; esac
      printf '%s (backtracked)\n' "$token"
      return 0
    fi
  done
  if [ -f "$d/ship.md" ]; then
    phase="$(rs_fm_value "$d/ship.md" reopened)"
    if [ -n "$phase" ]; then printf '%s (reopened)\n' "$phase"; return 0; fi
    printf 'shipped\n'; return 0
  fi
  if rs_has_open_challenge "$d"; then printf 'challenged (blocked)\n'; return 0; fi
  if rs_manifest "$d" >/dev/null 2>&1; then
    local own=0
    for art in spec.md design.md tasks.md verify.md review.md; do
      [ -f "$d/$art" ] && own=1
    done
    if [ "$own" -eq 0 ]; then printf 'manifest\n'; return 0; fi
  fi
  [ -f "$d/spec.md" ] || { printf 'not started\n'; return 0; }
  [ -f "$d/design.md" ] || { printf 'spec\n'; return 0; }
  [ -f "$d/tasks.md" ] || { printf 'design\n'; return 0; }
  if grep -q '^- \[ \]' "$d/tasks.md" 2>/dev/null; then printf 'build\n'; return 0; fi
  [ -f "$d/verify.md" ] || { printf 'test\n'; return 0; }
  if [ ! -f "$d/review.md" ]; then printf 'review\n'; return 0; fi
  if grep -qF -- 'request-changes' "$d/review.md"; then printf 'build (rework)\n'; return 0; fi
  printf 'ship\n'
}

# Walk every fixture node recursively, emitting `<ref>|<label>`.
rs_walk_derived() {  # $1 = dir, $2 = canonical ref
  local d="$1" ref="$2" child cname
  printf '%s|%s\n' "$ref" "$(rs_derive "$d" "$ref")"
  rs_manifest "$d" >/dev/null 2>&1 || return 0
  for child in "$d"/*/; do
    [ -d "$child" ] || continue
    cname="${child%/}"; cname="${cname##*/}"
    case "$cname" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    rs_walk_derived "$child" "$ref/$cname"
  done
}

fixture_derived() {
  local d ref
  for d in "$RS_ITEMS"/*/; do
    [ -d "$d" ] || continue
    ref="${d%/}"; ref="${ref##*/}"
    case "$ref" in [0-9][0-9][0-9][0-9]-*) : ;; *) continue ;; esac
    rs_walk_derived "$d" "$ref"
  done | LC_ALL=C sort
}

RS_DERIVED="$(fixture_derived)"
RS_EXP_DERIVED="$(cat <<'EOF'
9200-tree/0001-hybrid/0001-empty-leaf|not started
9200-tree/0001-hybrid/0002-approved-leaf|ship
9200-tree/0001-hybrid/0003-cyclic-a|not started
9200-tree/0001-hybrid/0004-cyclic-b|not started
9200-tree/0001-hybrid|design
9200-tree/0002-shipped|shipped
9200-tree/0003-approved|ship
9200-tree/0004-rejected|build (rework)
9200-tree/0005-noreview|review
9200-tree/0006-precedence|shipped
9200-tree/0007-recalled|build (reopened)
9200-tree/0008-dependent|spec
9200-tree/0009-decomposing-approved/0001-leaf|not started
9200-tree/0009-decomposing-approved|ship
9200-tree/0010-depends-decomposing|spec
9200-tree/0011-decomposing-unsat/0001-shipped-child|shipped
9200-tree/0011-decomposing-unsat|manifest
9200-tree/0012-depends-unsat-dec|spec
9200-tree/0013-stale-hybrid|design (backtracked)
9200-tree/0014-challenged-node|challenged (blocked)
9200-tree/0015-stale-and-challenged|spec (backtracked)
9200-tree|manifest
9201-decoy/0002-shipped|build (reopened)
9201-decoy|manifest
EOF
)"

if [ "$RS_DERIVED" = "$RS_EXP_DERIVED" ]; then
  ok "AC27 derived-phase: every fixture node's derived label matches the expected block"
else
  bad "AC27 derived-phase: a node's derived label diverged from the expected block"
  rs_show_diff "$RS_EXP_DERIVED" "$RS_DERIVED"
fi

# A hybrid node derives its own phase before the container `manifest`; a pure
# container derives `manifest`; a `.gitkeep`-only node derives `not started`.
rs_contains "$RS_DERIVED" '9200-tree/0001-hybrid|design' \
  "AC27 derived-phase: a hybrid derives its own phase before the container manifest"
rs_contains "$RS_DERIVED" '9200-tree/0009-decomposing-approved|ship' \
  "AC27 derived-phase: a hybrid with a full phase set derives its own phase"
rs_contains "$RS_DERIVED" '9200-tree|manifest' \
  "AC27 derived-phase: a pure container derives manifest"
rs_contains "$RS_DERIVED" '9200-tree/0011-decomposing-unsat|manifest' \
  "AC27 derived-phase: a nested pure container derives manifest"
rs_contains "$RS_DERIVED" '9200-tree/0001-hybrid/0001-empty-leaf|not started' \
  "AC27 derived-phase: a .gitkeep-only node derives not started"

# --- overlay-precedence (AC11) ---------------------------------------------

# The structural stale/reopened markers outrank the challenged overlay and the
# forward rows; the unshipped open-challenge overlay is evaluated before the
# artifact-presence rows.
rs_contains "$RS_DERIVED" '9200-tree/0013-stale-hybrid|design (backtracked)' \
  "AC27 overlay-precedence: the earliest stale marker derives the backtracked phase"
rs_contains "$RS_DERIVED" '9200-tree/0007-recalled|build (reopened)' \
  "AC27 overlay-precedence: a reopened ship record derives the reopened phase"
rs_contains "$RS_DERIVED" '9200-tree/0014-challenged-node|challenged (blocked)' \
  "AC27 overlay-precedence: an unshipped open challenge derives the challenged overlay"
rs_contains "$RS_DERIVED" '9200-tree/0015-stale-and-challenged|spec (backtracked)' \
  "AC27 overlay-precedence: a stale marker outranks an open challenge"
rs_contains "$RS_DERIVED" '9201-decoy/0002-shipped|build (reopened)' \
  "AC27 overlay-precedence: a recalled ship record derives the reopened phase at a decoy"

if printf '%s\n' "$RS_DERIVED" | grep -qE '9200-tree/0015-stale-and-challenged\|challenged'; then
  bad "AC27 overlay-precedence: the challenged overlay outranked a stale marker"
else
  ok "AC27 overlay-precedence: the structural marker precedes the challenged overlay"
fi

# --- decomposing-summary (AC2, AC13) ---------------------------------------

# `<node-ref>|<ready>/<total> ready · phases: <phase> <n>, ...` over the node's
# immediate Children rows, the phase token being rs_derive's label.
rs_summary() {  # $1 = node dir, $2 = node ref
  local dir="$1" ref="$2" mf rows rb id dep cf cref total ready labels tally
  mf="$(rs_manifest "$dir")" || return 0
  rows="$(rs_children_rows "$mf")"
  rb="$(rs_ready_blocked "$dir" "$ref")"
  total="$(printf '%s\n' "$rows" | grep -c .)"
  ready="$(printf '%s\n' "$rb" | grep -c '|ready$')"
  labels=""
  while IFS='|' read -r id dep cf cref; do
    [ -n "$id" ] || continue
    labels="$labels$(rs_derive "$dir/$id" "$ref/$id")
"
  done <<EOF
$rows
EOF
  tally="$(printf '%s\n' "$labels" | sed '/^$/d' | LC_ALL=C sort | uniq -c | awk '
    { c = $1; $1 = ""; sub(/^ /, ""); label = $0
      out = (NR > 1) ? out ", " label " " c : label " " c }
    END { print out }')"
  printf '%s|%s/%s ready · phases: %s\n' "$ref" "$ready" "$total" "$tally"
}

RS_SUMMARY="$({ rs_summary "$RS_ITEMS/9200-tree" 9200-tree
rs_summary "$RS_ITEMS/9200-tree/0001-hybrid" 9200-tree/0001-hybrid
rs_summary "$RS_ITEMS/9201-decoy" 9201-decoy; } | LC_ALL=C sort)"

RS_EXP_SUMMARY="$(cat <<'EOF'
9200-tree/0001-hybrid|2/4 ready · phases: not started 3, ship 1
9200-tree|13/15 ready · phases: build (reopened) 1, build (rework) 1, challenged (blocked) 1, design 1, design (backtracked) 1, manifest 1, review 1, ship 2, shipped 2, spec 3, spec (backtracked) 1
9201-decoy|1/1 ready · phases: build (reopened) 1
EOF
)"

if [ "$RS_SUMMARY" = "$RS_EXP_SUMMARY" ]; then
  ok "AC27 decomposing-summary: each node's ready/total and phase tally match the expected block"
else
  bad "AC27 decomposing-summary: a node's summary line diverged from the expected block"
  rs_show_diff "$RS_EXP_SUMMARY" "$RS_SUMMARY"
fi

# --- determinism (AC8) -----------------------------------------------------

# Deriving readiness, phase, and summary twice yields identical output; nothing
# is cached or stored between runs.
rs_snapshot() {
  fixture_derived
  rs_ready_blocked "$RS_ITEMS/9200-tree" 9200-tree | LC_ALL=C sort
  rs_ready_blocked "$RS_ITEMS/9200-tree/0001-hybrid" 9200-tree/0001-hybrid | LC_ALL=C sort
  rs_ready_blocked "$RS_ITEMS/9201-decoy" 9201-decoy | LC_ALL=C sort
  rs_summary "$RS_ITEMS/9200-tree" 9200-tree
  rs_summary "$RS_ITEMS/9200-tree/0001-hybrid" 9200-tree/0001-hybrid
  rs_summary "$RS_ITEMS/9201-decoy" 9201-decoy
}

RS_SNAP1="$(rs_snapshot)"
RS_SNAP2="$(rs_snapshot)"
if [ "$RS_SNAP1" = "$RS_SNAP2" ]; then
  ok "AC27 determinism: two derivations over unchanged files are identical"
else
  bad "AC27 determinism: two derivations over unchanged files diverged"
fi

# --- no-stored-readiness (AC8) ---------------------------------------------

# Readiness is derived live: every fixture manifest keeps the canonical
# six-column Children header and stores no readiness value.
RS_HEADER_EXP='Local id|Title|Scope|Depends on|conflicts-with|Canonical reference'
RS_MANIFESTS="$(find "$RS_ITEMS" -type f \( -name manifest.md -o -name roadmap.md \) | LC_ALL=C sort)"
RS_MANIFEST_COUNT="$(printf '%s\n' "$RS_MANIFESTS" | grep -c .)"
RS_BAD_HEADERS=""
while IFS= read -r rs_mf; do
  [ -n "$rs_mf" ] || continue
  rs_hdr="$(rs_header "$rs_mf")"
  if [ "$rs_hdr" != "$RS_HEADER_EXP" ]; then
    RS_BAD_HEADERS="$RS_BAD_HEADERS$rs_mf ($rs_hdr)
"
  fi
done <<EOF
$RS_MANIFESTS
EOF

if [ "$RS_MANIFEST_COUNT" -gt 0 ] && [ -z "$RS_BAD_HEADERS" ]; then
  ok "AC27 no-stored-readiness: every fixture manifest keeps the canonical six-column header"
else
  bad "AC27 no-stored-readiness: a fixture manifest stores a non-canonical header"
  [ -n "$RS_BAD_HEADERS" ] && printf '    %s\n' "$RS_BAD_HEADERS"
fi

# --- status-render (AC12) --------------------------------------------------

# The /status render contract is pinned to its prompt authority by name: the
# tree is indented to arbitrary depth, each node shows its derived phase and its
# readiness, and each decomposing node shows `<ready>/<total> ready` plus a
# `<phase> <n>, ...` tally. The literal is read-only; nothing is edited.
for rs_pair in \
  "$WF::indented to arbitrary depth" \
  "$AGENT_DIR/status.md::indented beneath it to arbitrary depth" \
  "$CMD_DIR/status.md::indented beneath it to arbitrary depth"; do
  rs_file="${rs_pair%%::*}"
  rs_lit="${rs_pair#*::}"
  if flat "$rs_file" | grep -qF -- "$rs_lit"; then
    ok "AC27 status-render: $rs_file states the tree is indented to arbitrary depth"
  else
    bad "AC27 status-render: $rs_file does not state the tree is indented to arbitrary depth"
  fi
done

for rs_surface in "$WF" "$AGENT_DIR/status.md" "$CMD_DIR/status.md"; do
  need "$rs_surface" 'its derived phase and' \
    "AC27 status-render: $rs_surface states each node shows its derived phase"
  for rs_pin in 'blocked: <local ids>' '<ready>/<total> ready' '<phase> <n>, ...'; do
    need "$rs_surface" "$rs_pin" "AC27 status-render: $rs_surface states '$rs_pin'"
  done
done
