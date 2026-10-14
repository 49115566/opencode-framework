#!/usr/bin/env bash
#
# AC27 — recursive model, canonical-reference, and per-level-allocation guard.
#
# The recursive lifecycle model (the standard cycle applies uniformly at every
# node, any node may decompose to arbitrary depth, fine-grained tasks.md entries
# are not nodes, per-level child reservation, and immediate-parent sequence
# allocation) and the canonical-reference grammar are prompt behaviour in the
# framework; there is no committed production checker. This area pins that
# behaviour to a committed, reviewable fixture tree, the same way
# tests/checks/80-cycle-fixture.sh pins the prompt-only CYCLIC-DEP rule and
# tests/checks/85-conflict-guards.sh pins the declared-conflict model.
#
# It is fixture-scoped test code, not a production checker: it implements no
# command and is invoked by no framework command. Its fixture root,
# tests/fixtures/recursive-structure/items/, is a self-contained tree that
# shadows no live path; the guard reads only that fixture root and the live
# authority docs, and never reads live work/**. The suite is read-only and
# fresh-clone-clean.
#
# The residual — that a live prompt run derives the same shape — is not
# executable in CI and is documented in tests/README.md and verify.md.
#
# Sourced by tests/run.sh, so it must not call exit. Prints ok/FAIL lines
# labelled AC27 plus a sub-area, so a mutation self-check can name the guard it
# trips: fixture-depth, hybrid-node, reservation-marker, allocation-scoping,
# reference-depth, duplicate-derivation, duplicate-position, contract-pins,
# read-only-contract.

echo "== AC27 recursive structure, reference, and allocation guard =="

# The fixture root and its fixture-local "work root". Every item reference is
# resolved inside $RS_ITEMS; the guard never touches the live work/ tree.
RS_ROOT="tests/fixtures/recursive-structure"
RS_ITEMS="$RS_ROOT/items"

# --- helpers ---------------------------------------------------------------

# An item directory name is a four-digit prefix, a dash, then a kebab slug.
rs_is_item_dir() {  # 0 when $1 is an item directory basename
  case "$1" in
    [0-9][0-9][0-9][0-9]-[a-z0-9]*) return 0 ;;
    *) return 1 ;;
  esac
}

# Resolve a decomposing node's manifest through the same manifest-then-alias
# lookup the sibling guards use: the modern `manifest.md` spelling when present,
# else the recognized deprecated alias `roadmap.md`, else nothing.
rs_manifest() {  # $1 = node directory; prints the manifest path, or nothing
  local d="$1" base
  for base in manifest roadmap; do
    if [ -f "$d/$base.md" ]; then printf '%s\n' "$d/$base.md"; return 0; fi
  done
  return 1
}

# A node's immediate child item directories, as references relative to
# $RS_ITEMS. Empty for a node that holds no manifest (it does not decompose).
rs_children() {  # $1 = node directory; one child ref per line on stdout
  local d="$1" c
  [ -d "$d" ] || return 0
  rs_manifest "$d" >/dev/null 2>&1 || return 0
  for c in "$d"/*/; do
    [ -d "$c" ] || continue
    c="${c%/}"
    rs_is_item_dir "${c##*/}" || continue
    printf '%s\n' "${c#"$RS_ITEMS"/}"
  done
}

# The maximum item-directory depth under $RS_ITEMS: 1 for a top-level item,
# 4 for a four-level (`<NNNN>/<MMMM>/<MMMM>/<MMMM>/`) branch. A directory chain
# counts only when every segment is an item directory name. Prints 0 when the
# fixture root is absent.
rs_max_depth() {
  if [ ! -d "$RS_ITEMS" ]; then printf '0\n'; return 0; fi
  find "$RS_ITEMS" -type d 2>/dev/null | awk -v root="$RS_ITEMS" '
    {
      rel = $0
      sub("^" root "/", "", rel)
      if (rel == $0 || rel == "") next
      n = split(rel, seg, "/")
      ok = 1
      for (i = 1; i <= n; i++)
        if (seg[i] !~ /^[0-9][0-9][0-9][0-9]-[a-z0-9-]+$/) { ok = 0; break }
      if (ok && n > max) max = n
    }
    END { print (max == "" ? 0 : max) }
  '
}

# 0 when $1 contains an immediate item child directory.
rs_has_item_child() {  # $1 = directory
  local c
  for c in "$1"/*/; do
    [ -d "$c" ] || continue
    c="${c%/}"
    rs_is_item_dir "${c##*/}" && return 0
  done
  return 1
}

# Emit one allocation record per top-level item (``P|<ref>``) and per immediate
# child of a decomposing node (``C|<parent-ref>|<child-ref>|<local-id>``); the
# awk analyzer below derives the duplicate pairs from it. Identity is the full
# canonical reference, so equal local-id text under different parents is never
# collapsed into a collision.
rs_alloc_events() {
  local node child
  for node in "$RS_ITEMS"/*/; do
    [ -d "$node" ] || continue
    node="${node%/}"
    rs_is_item_dir "${node##*/}" || continue
    printf 'P|%s\n' "${node##*/}"
  done
  while IFS= read -r node; do
    [ -d "$node" ] || continue
    rs_is_item_dir "${node##*/}" || continue
    while IFS= read -r child; do
      [ -n "$child" ] || continue
      printf 'C|%s|%s|%s\n' "${node#"$RS_ITEMS"/}" "$child" "${child##*/}"
    done < <(rs_children "$node")
  done < <(find "$RS_ITEMS" -type d 2>/dev/null | LC_ALL=C sort)
}

# Derive the allocation finding set, sorted under LC_ALL=C. A top-level pair with
# an equal four-digit NNNN is ``DUPLICATE-PREFIX``; a same-parent pair of
# immediate children with an equal four-digit MMMM is ``DUPLICATE-CHILD``. The
# two kinds are produced by separate loops, so neither can be emitted at the
# other's tree position. At depth >= 3 the DUPLICATE-CHILD line also names the
# shared parent and shared local prefix, so a collision is unambiguous at depth.
rs_dup_findings() {
  rs_alloc_events | awk -F'|' '
    $1 == "P" { top[++nt] = $2; next }
    $1 == "C" { nc++; par[nc] = $2; ref[nc] = $3; loc[nc] = $4; next }
    END {
      for (i = 1; i <= nt; i++)
        for (j = i + 1; j <= nt; j++)
          if (substr(top[i], 1, 4) == substr(top[j], 1, 4)) {
            a = top[i]; b = top[j]
            if (a > b) { t = a; a = b; b = t }
            print "DUPLICATE-PREFIX|" a "|" b
          }
      for (i = 1; i <= nc; i++)
        for (j = i + 1; j <= nc; j++) {
          if (par[i] != par[j]) continue
          if (substr(loc[i], 1, 4) != substr(loc[j], 1, 4)) continue
          a = ref[i]; b = ref[j]
          if (a > b) { t = a; a = b; b = t }
          if (gsub("/", "/", a) >= 2)
            print "DUPLICATE-CHILD|" a "|" b "|" par[i] "|" substr(loc[i], 1, 4)
          else
            print "DUPLICATE-CHILD|" a "|" b
        }
    }
  ' | LC_ALL=C sort
}

rs_show_diff() {
  printf '    expected:\n%s\n    actual:\n%s\n' "$1" "$2"
}

rs_block_contains() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then ok "$3"; else bad "$3 (missing '$2')"; fi
}

rs_block_absent() {  # $1 haystack, $2 literal, $3 label
  if printf '%s\n' "$1" | grep -qF -- "$2"; then bad "$3 (found '$2')"; else ok "$3"; fi
}

# --- AC1 fixture-depth ------------------------------------------------------
# The fixture root must exist and its deepest branch must reach four item
# levels. A missing or shallow root is a hard failure, never a skip.

if [ ! -d "$RS_ITEMS" ]; then
  bad "AC27 fixture-depth: committed fixture root missing at $RS_ITEMS (must fail, not skip)"
else
  ok "AC27 fixture-depth: committed fixture root exists at $RS_ITEMS"
  RS_DEPTH="$(rs_max_depth)"
  if [ "$RS_DEPTH" -ge 4 ]; then
    ok "AC27 fixture-depth: tree reaches $RS_DEPTH item levels (>= 4)"
  else
    bad "AC27 fixture-depth: deepest branch is $RS_DEPTH item levels (< 4)"
  fi
fi

# --- AC2 hybrid-node --------------------------------------------------------
# At least one node both decomposes (holds a manifest) and carries one of its
# own phase artifacts, pinning that a node may carry an artifact and a child set
# at the same time.

RS_HYBRID=""
if [ -d "$RS_ITEMS" ]; then
  while IFS= read -r rs_d; do
    [ -d "$rs_d" ] || continue
    rs_is_item_dir "${rs_d##*/}" || continue
    rs_manifest "$rs_d" >/dev/null 2>&1 || continue
    for rs_a in spec design tasks verify review ship; do
      if [ -f "$rs_d/$rs_a.md" ]; then
        RS_HYBRID="${rs_d#"$RS_ITEMS"/}"
        break
      fi
    done
    if [ -n "$RS_HYBRID" ]; then break; fi
  done < <(find "$RS_ITEMS" -type d 2>/dev/null | LC_ALL=C sort)
fi
if [ -n "$RS_HYBRID" ]; then
  ok "AC27 hybrid-node: $RS_HYBRID both decomposes and carries its own phase artifact"
else
  bad "AC27 hybrid-node: no node both decomposes and carries its own phase artifact"
fi

# --- AC3 reservation-marker -------------------------------------------------
# Every child directory, at every level, holds a `.gitkeep`, and at least one
# leaf child holds only that marker and no phase artifacts.

RS_RESERV_MISSING=""
RS_MARKER_ONLY=""
if [ -d "$RS_ITEMS" ]; then
  while IFS= read -r rs_node; do
    [ -d "$rs_node" ] || continue
    rs_is_item_dir "${rs_node##*/}" || continue
    rs_manifest "$rs_node" >/dev/null 2>&1 || continue
    while IFS= read -r rs_child; do
      [ -n "$rs_child" ] || continue
      if [ ! -f "$RS_ITEMS/$rs_child/.gitkeep" ]; then
        RS_RESERV_MISSING="$RS_RESERV_MISSING $rs_child"
        continue
      fi
      if ! rs_has_item_child "$RS_ITEMS/$rs_child"; then
        rs_own=0
        for rs_a in manifest spec design tasks verify review ship; do
          if [ -f "$RS_ITEMS/$rs_child/$rs_a.md" ]; then rs_own=1; fi
        done
        if [ "$rs_own" -eq 0 ] && [ -z "$RS_MARKER_ONLY" ]; then
          RS_MARKER_ONLY="$rs_child"
        fi
      fi
    done < <(rs_children "$rs_node")
  done < <(find "$RS_ITEMS" -type d 2>/dev/null | LC_ALL=C sort)
fi

if [ -z "$RS_RESERV_MISSING" ]; then
  ok "AC27 reservation-marker: every child directory at every level carries .gitkeep"
else
  bad "AC27 reservation-marker: child directories lack .gitkeep:${RS_RESERV_MISSING}"
fi
if [ -n "$RS_MARKER_ONLY" ]; then
  ok "AC27 reservation-marker: marker-only leaf exists ($RS_MARKER_ONLY)"
else
  bad "AC27 reservation-marker: no marker-only leaf (a child with only .gitkeep) exists"
fi

# --- AC4 allocation-scoping -------------------------------------------------
# Two distinct parents each independently begin their local numbering at 0001,
# and a depth-3 grandchild is allocated under its immediate parent.

RS_ALLOC_PARENTS=0
if [ -d "$RS_ITEMS" ]; then
  while IFS= read -r rs_node; do
    [ -d "$rs_node" ] || continue
    rs_is_item_dir "${rs_node##*/}" || continue
    rs_manifest "$rs_node" >/dev/null 2>&1 || continue
    rs_started=0
    while IFS= read -r rs_child; do
      [ -n "$rs_child" ] || continue
      case "${rs_child##*/}" in
        0001-*) rs_started=1 ;;
      esac
    done < <(rs_children "$rs_node")
    if [ "$rs_started" -eq 1 ]; then
      RS_ALLOC_PARENTS=$((RS_ALLOC_PARENTS + 1))
    fi
  done < <(find "$RS_ITEMS" -type d 2>/dev/null | LC_ALL=C sort)
fi
if [ "$RS_ALLOC_PARENTS" -ge 2 ]; then
  ok "AC27 allocation-scoping: $RS_ALLOC_PARENTS distinct parents each begin their local numbering at 0001"
else
  bad "AC27 allocation-scoping: fewer than two parents begin their local numbering at 0001 (got $RS_ALLOC_PARENTS)"
fi

if rs_children "$RS_ITEMS/9001-tree/0001-branch" | grep -qxF '9001-tree/0001-branch/0001-leaf'; then
  ok "AC27 allocation-scoping: a grandchild is allocated under its immediate parent (9001-tree/0001-branch/0001-leaf)"
else
  bad "AC27 allocation-scoping: grandchild 9001-tree/0001-branch/0001-leaf is not listed under its immediate parent"
fi

# The grandchild's local number is scoped to its immediate parent, not derived
# from the top-level 9001 sequence: its manifest names its immediate parent.
RS_GC="$RS_ITEMS/9001-tree/0001-branch/0001-leaf"
if [ -f "$RS_GC/manifest.md" ]; then
  RS_GC_PARENT="$(fm "$RS_GC/manifest.md" | awk '
    /^parent:/ { v = $0; sub(/^parent:[ \t]*/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }
  ')"
  if [ "$RS_GC_PARENT" = "9001-tree/0001-branch" ]; then
    ok "AC27 allocation-scoping: grandchild's local id is scoped to its immediate parent"
  else
    bad "AC27 allocation-scoping: grandchild's parent is '$RS_GC_PARENT', not its immediate parent 9001-tree/0001-branch"
  fi
else
  bad "AC27 allocation-scoping: grandchild manifest missing at $RS_GC/manifest.md"
fi

# --- AC5 reference-depth ----------------------------------------------------
# A depth-four reference resolves to its directory, and the documented grammar
# is pinned as the arbitrary-depth nesting form.

RS_DEEP_REF="9001-tree/0001-branch/0001-leaf/0001-deep"
if [ -d "$RS_ITEMS/$RS_DEEP_REF" ]; then
  ok "AC27 reference-depth: depth-four reference $RS_DEEP_REF resolves to its directory"
else
  bad "AC27 reference-depth: depth-four reference $RS_DEEP_REF does not resolve"
fi

if printf '%s\n' "$RS_DEEP_REF" | grep -qE '^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$'; then
  ok "AC27 reference-depth: depth-four reference matches the arbitrary-depth grammar"
else
  bad "AC27 reference-depth: depth-four reference does not match ^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$"
fi
need "$CONV" '^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$' \
  "AC27 reference-depth: $CONV pins the arbitrary-depth reference grammar"

# --- AC6/AC7 duplicate-derivation -------------------------------------------
# Derive the allocation findings for the fixture's duplicate samples and compare
# the derived set to the committed expected block. A top-level collision is a
# DUPLICATE-PREFIX; a same-parent collision at depth >= 3 is a DUPLICATE-CHILD
# that also names the shared parent and shared local prefix.

RS_DUP_ALL="$(rs_dup_findings)"
RS_DUP_PREFIX="$(printf '%s\n' "$RS_DUP_ALL" | grep '^DUPLICATE-PREFIX|' || true)"
RS_DUP_CHILD="$(printf '%s\n' "$RS_DUP_ALL" | grep '^DUPLICATE-CHILD|' || true)"

RS_EXPECTED_DUP="$(cat <<'EOF'
DUPLICATE-CHILD|9001-tree/0001-branch/0001-leaf/0009-dup-x|9001-tree/0001-branch/0001-leaf/0009-dup-y|9001-tree/0001-branch/0001-leaf|0009
DUPLICATE-PREFIX|9010-dup-a|9010-dup-b
EOF
)"

if [ "$RS_DUP_ALL" = "$RS_EXPECTED_DUP" ]; then
  ok "AC27 duplicate-derivation: derived allocation findings match the expected block"
else
  bad "AC27 duplicate-derivation: derived allocation findings diverged from the expected block"
  rs_show_diff "$RS_EXPECTED_DUP" "$RS_DUP_ALL"
fi

if [ "$(printf '%s\n' "$RS_DUP_PREFIX" | grep -c .)" -eq 1 ] &&
   printf '%s\n' "$RS_DUP_PREFIX" | grep -qxF 'DUPLICATE-PREFIX|9010-dup-a|9010-dup-b'; then
  ok "AC27 duplicate-derivation: exactly one DUPLICATE-PREFIX names both top-level offenders"
else
  bad "AC27 duplicate-derivation: expected exactly one DUPLICATE-PREFIX for the 9010 pair"
fi

if [ "$(printf '%s\n' "$RS_DUP_CHILD" | grep -c .)" -eq 1 ] &&
   printf '%s\n' "$RS_DUP_CHILD" | grep -qxF 'DUPLICATE-CHILD|9001-tree/0001-branch/0001-leaf/0009-dup-x|9001-tree/0001-branch/0001-leaf/0009-dup-y|9001-tree/0001-branch/0001-leaf|0009'; then
  ok "AC27 duplicate-derivation: exactly one DUPLICATE-CHILD names both depth-4 offenders plus the shared parent and local prefix"
else
  bad "AC27 duplicate-derivation: expected exactly one depth-4 DUPLICATE-CHILD with shared parent and local prefix"
fi

# --- AC8 duplicate-position -------------------------------------------------
# The negative clamp: a top-level collision is never reported at the deeper
# position, a deeper collision is never reported at the top-level position, and
# equal local-id text under different parents is never a collision.

rs_block_absent "$RS_DUP_CHILD" '9010-dup' \
  "AC27 duplicate-position: the top-level 9010 collision is not reported as DUPLICATE-CHILD"
rs_block_absent "$RS_DUP_PREFIX" '0009-dup' \
  "AC27 duplicate-position: the depth-4 0009 collision is not reported as DUPLICATE-PREFIX"
rs_block_absent "$RS_DUP_CHILD" '9001-tree/0001-branch|9002-tree/0001-branch' \
  "AC27 duplicate-position: '0001-branch' under 9001-tree and 9002-tree is not a same-parent duplicate"
rs_block_absent "$RS_DUP_CHILD" '9002-tree/0001-branch|9001-tree/0001-branch' \
  "AC27 duplicate-position: '0001-branch' under 9002-tree and 9001-tree is not a same-parent duplicate"
rs_block_absent "$RS_DUP_CHILD" '9001-tree/0001-branch/0001-leaf|9002-tree/0001-branch/0001-leaf' \
  "AC27 duplicate-position: '0001-leaf' under the two branches is not a same-parent duplicate"
rs_block_absent "$RS_DUP_CHILD" '9002-tree/0001-branch/0001-leaf|9001-tree/0001-branch/0001-leaf' \
  "AC27 duplicate-position: '0001-leaf' under the two branches (reverse order) is not a same-parent duplicate"

# --- AC9/AC10/AC11/AC12 contract-pins ---------------------------------------
# Pin the shipped recursive-model, canonical-reference, per-level-allocation, and
# "prompt behavior only — no committed executable checker" prose in the live
# authority, so a dropped or weakened statement is caught and named. Statements
# that wrap across source lines are matched against a whitespace-flattened copy
# (the same flat() technique the sibling guards use).

RS_CONV_FLAT="$(tr '\n' ' ' < "$CONV" | tr -s ' ')"

# AC9 — the standard cycle applies uniformly at every node, decomposition imposes
# no maximum recursion depth, and nesting continues to arbitrary depth.
need "$WF" 'applies uniformly at every node' \
  "AC27 contract-pins: $WF states the cycle applies uniformly at every node"
need "$WF" 'no maximum recursion depth' \
  "AC27 contract-pins: $WF states decomposition imposes no maximum recursion depth"
need "$WF" 'nesting continues to arbitrary depth' \
  "AC27 contract-pins: $WF states nesting continues to arbitrary depth"

# AC10 — fine-grained tasks.md entries are not nodes, pinned in the authority and
# asserted against the fixture: no tasks.md entry, and no task-like directory,
# creates an item directory.
need "$WF" 'are **not** nodes' \
  "AC27 contract-pins: $WF states fine-grained task entries are not nodes"
RS_TASK_BAD=""
if [ -f "$RS_ITEMS/9001-tree/tasks.md" ]; then
  while IFS= read -r rs_t; do
    [ -n "$rs_t" ] || continue
    if [ -n "$(find "$RS_ITEMS" -type d -name "$rs_t" 2>/dev/null)" ]; then
      RS_TASK_BAD="$RS_TASK_BAD $rs_t"
    fi
  done < <(grep -oE '\*\*T[0-9]+\*\*' "$RS_ITEMS/9001-tree/tasks.md" | tr -d '*')
fi
RS_TASKLIKE="$(find "$RS_ITEMS" -type d -name 'T[0-9]*' 2>/dev/null)"
if [ -z "$RS_TASK_BAD" ] && [ -z "$RS_TASKLIKE" ]; then
  ok "AC27 contract-pins: no fixture task entry names an item directory (task entries are not nodes)"
else
  bad "AC27 contract-pins: a fixture task entry names a directory (named:${RS_TASK_BAD:-none}; task-like dirs:${RS_TASKLIKE:-none})"
fi

# AC11 — every child directory is reserved at every level, per-level allocation
# is scoped to the immediate parent, and a local number is never reused.
rs_block_contains "$RS_CONV_FLAT" \
  'each child directory is reserved with a `.gitkeep` at that level' \
  "AC27 contract-pins: $CONV states each child directory is reserved at every level"
need "$CONV" 'greatest 4-digit prefix ever committed under that parent and add one' \
  "AC27 contract-pins: $CONV states immediate-parent allocation starts from the greatest committed prefix"
rs_block_contains "$RS_CONV_FLAT" 'scoped to its **immediate** parent' \
  "AC27 contract-pins: $CONV states allocation is scoped to the immediate parent"
need "$CONV" 'never reused within that parent' \
  "AC27 contract-pins: $CONV states a local number is never reused within that parent"

# AC12 — the merge-integrity guard and the declared-conflict check are each
# "prompt behavior only" with no committed executable checker. Both sentences
# wrap across source lines, so each is matched against a flattened copy of its
# own authority section rather than the whole file.
RS_MIG_AUTH="$(awk '
  /^### Merge-integrity guard[ \t]*$/ { f = 1; print; next }
  f && /^### / { exit }
  f { print }
' "$WF")"
RS_DCC_AUTH="$(awk '
  /^## Declared-conflict check[ \t]*$/ { f = 1; print; next }
  f && /^## / { exit }
  f { print }
' "$WF")"
RS_MIG_FLAT="$(printf '%s\n' "$RS_MIG_AUTH" | tr '\n' ' ' | tr -s ' ')"
RS_DCC_FLAT="$(printf '%s\n' "$RS_DCC_AUTH" | tr '\n' ' ' | tr -s ' ')"

rs_block_contains "$RS_MIG_FLAT" 'prompt behavior only' \
  "AC27 contract-pins: $WF merge-integrity guard is prompt behavior only"
rs_block_contains "$RS_MIG_FLAT" 'no committed checker, script, helper, or executable tool' \
  "AC27 contract-pins: $WF merge-integrity guard has no committed checker"
rs_block_contains "$RS_DCC_FLAT" 'prompt behavior only' \
  "AC27 contract-pins: $WF declared-conflict check is prompt behavior only"
rs_block_contains "$RS_DCC_FLAT" 'no committed checker, script, helper, or executable tool' \
  "AC27 contract-pins: $WF declared-conflict check has no committed checker"

# --- AC13 read-only-contract -------------------------------------------------
# The guard reads only its committed fixture root and the live authority docs; it
# never reads live work/**, references no live work path, and contains no
# absolute or escaping path. It is fixture-scoped test code invoked by no
# framework command, so it adds no committed production checker.

if [ -d "$RS_ROOT" ] && ! grep -rq 'work/' "$RS_ROOT" 2>/dev/null; then
  ok "AC27 read-only-contract: the fixture references no live work/ path"
else
  bad "AC27 read-only-contract: the fixture references a live work/ path"
fi

# Fixture self-containment: no `..` escape token and no absolute filesystem path
# token. The absolute pattern matches only a known top-level directory, so the
# framework command tokens (`/build`, `/plan`, ...) are not mistaken for absolute
# paths (the same clamp the sibling guards use).
if grep -rqE '\.\.|(^|[^A-Za-z0-9._/-])/(home|tmp|Users|etc|var|root|opt|mnt)/' "$RS_ROOT" 2>/dev/null; then
  bad "AC27 read-only-contract: the fixture references an absolute or escaping path"
else
  ok "AC27 read-only-contract: the fixture references no absolute or escaping path"
fi

# The guard is invoked by no framework command and adds no committed production
# checker: it lives under tests/checks/ (sourced by tests/run.sh), and no
# production surface (a command, agent, skill, doc, or top-level README/AGENTS)
# names it. A test-doc registration (tests/README.md) is not a production surface.
RS_GUARD_PATH="${BASH_SOURCE[0]}"
case "$RS_GUARD_PATH" in
  */tests/checks/*)
    ok "AC27 read-only-contract: the guard lives under tests/checks/ (fixture-scoped test code)" ;;
  *)
    bad "AC27 read-only-contract: the guard does not live under tests/checks/ ($RS_GUARD_PATH)" ;;
esac

RS_GUARD_STEM="$(basename "${BASH_SOURCE[0]%.sh}")"
RS_PROD_HITS=""
for rs_prod in .opencode docs README.md AGENTS.md; do
  [ -e "$rs_prod" ] || continue
  if grep -rq -- "$RS_GUARD_STEM" "$rs_prod" 2>/dev/null; then
    RS_PROD_HITS="$RS_PROD_HITS $rs_prod"
  fi
done
if [ -z "$RS_PROD_HITS" ]; then
  ok "AC27 read-only-contract: no production surface names the guard (invoked by no framework command)"
else
  bad "AC27 read-only-contract: a production surface names the guard:${RS_PROD_HITS}"
fi
