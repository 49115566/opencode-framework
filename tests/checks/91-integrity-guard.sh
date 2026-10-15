#!/usr/bin/env bash
#
# AC30 — recursive merge-integrity invariant evaluation.
#
# The merge-integrity guard (docs/workflow.md -> "Merge conflicts" ->
# "Merge-integrity guard", mirrored in .opencode/skill/merge-conflict/SKILL.md)
# is prompt behaviour: the framework commits no checker. This area pins its
# RECURSIVE shape to a committed fixture, the same way
# tests/checks/80-cycle-fixture.sh pins the prompt-only CYCLIC-DEP rule. It
# reimplements the invariant evaluation as a genuine recursive scan over
# tests/fixtures/recursive-integrity/items/ — the top level against the
# top-level items and every decomposing node against its own immediate children
# — so an evaluation that flattens to two levels misses the depth-three
# collision and fails per-node-eval.
#
# It is fixture-scoped test code, not a production checker: it implements no
# command, is invoked by no framework command, and never reads live work/**.
# Item references resolve inside the fixture root, which shadows the live work/
# root. The suite is read-only and fresh-clone-clean.
#
# It references the sibling agreement areas that own overlapping literals by
# name and re-asserts none of their literals: the recursive structure guard
# 0001-recursive-structure-guard (the DUPLICATE-PREFIX / DUPLICATE-CHILD
# derivation), tests/checks/10-readiness.sh, tests/checks/20-lifecycle.sh,
# tests/checks/80-cycle-fixture.sh (the CYCLIC-DEP diagnostic and the
# roadmap.md migration guard), tests/checks/85-conflict-guards.sh,
# tests/checks/87-backtrack-guards.sh, tests/checks/88-renumber-sweep.sh (the
# renumber prose rewrite lists), tests/checks/90-packaging.sh (the duplicated
# inventory/count fact), and tests/checks/96-signature-sweep.sh.
#
# Reads only tests/fixtures/** and live surfaces (never work/**); sourced by
# tests/run.sh, so it must not call exit. Prints ok/FAIL lines labelled AC30
# plus a sub-area, so the mutation self-check (tests/mutation.sh) can name the
# guard it trips: per-node-eval, structural-graph, spelling-drift, report-only,
# renumber-sweep, fixture-existence, read-only-contract, mutation-staging,
# no-duplication.

echo "== AC30 recursive merge-integrity invariant evaluation =="

FIG_ROOT="tests/fixtures/recursive-integrity"
FIG_ITEMS="$FIG_ROOT/items"
FIG_CANON_HEADER='| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |'

# --- helpers ---------------------------------------------------------------

# Resolve a decomposing node's manifest: its modern `manifest.md` spelling when
# present, else the recognized deprecated alias `roadmap.md`, else nothing. Lets
# the scan read either spelling without hardcoding a migrated fixture path.
fig_manifest() {  # $1 = node directory; prints the manifest path, or nothing
  local d="$1" base
  for base in manifest roadmap; do
    if [ -f "$d/$base.md" ]; then printf '%s\n' "$d/$base.md"; return 0; fi
  done
  return 1
}

# Declared `phase` value from the manifest frontmatter (empty when absent).
fig_phase_of() {
  awk '
    NR == 1 && $0 == "---" { f = 1; next }
    f && $0 == "---" { exit }
    f && /^phase:/ {
      v = $0
      sub(/^phase:[ \t]*/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$1"
}

# Parse a manifest Children table by header name (not fixed positions), so the
# six-column header parses. Emits "<local-id>|<depends-on>" per data row.
fig_children_rows() {
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
      idcell = ""; dep = ""
      if ("Local id" in col) idcell = a[col["Local id"]]
      if ("Depends on" in col) dep = a[col["Depends on"]]
      gsub(/^[ \t]+|[ \t]+$/, "", idcell)
      gsub(/^[ \t]+|[ \t]+$/, "", dep)
      if (idcell == "" || idcell ~ /^-+$/) next
      print idcell "|" dep
    }
  ' "$1"
}

# The node's `## Open issues` block, through the next section heading. The
# withdrawal record lives here; it names the retained child directory.
fig_open_issues() {
  awk '
    /^## Open issues[ \t]*$/ { on = 1; next }
    on && /^## / { exit }
    on { print }
  ' "$1"
}

# Trim each comma-separated token of a `Depends on` cell; one token per line.
fig_dep_tokens() {
  printf '%s' "$1" | awk -F',' '{
    for (i = 1; i <= NF; i++) {
      t = $i
      gsub(/^[ \t]+|[ \t]+$/, "", t)
      if (t != "") print t
    }
  }'
}

fig_has_line() {  # $1 = newline list, $2 = whole-line literal
  printf '%s\n' "$1" | grep -qxF -- "$2"
}

# --- finding accumulators ---------------------------------------------------
# Findings normalize to "CODE|<offender>[,<offender>]"; offenders are canonical
# refs relative to items/, sorted. Three category globals keep one mutation
# naming one sub-area.

FIG_DUP=""
FIG_GRAPH=""
FIG_DRIFT=""

fig_add_dup()   { FIG_DUP="$FIG_DUP
$1"; }
fig_add_graph() { FIG_GRAPH="$FIG_GRAPH
$1"; }
fig_add_drift() { FIG_DRIFT="$FIG_DRIFT
$1"; }

# Group same-parent prefixes and record a collision. $1 = code, $2 = newline
# list of full offender refs (all sharing one parent). The immediate child's
# 4-digit prefix is the last path segment's leading number.
fig_check_dups() {
  local code="$1" refs="$2" prefix member members cnt joined seg
  local prefixes
  prefixes="$(printf '%s\n' "$refs" \
    | awk 'NF { n = split($0, seg, "/"); s = seg[n]; sub(/-.*/, "", s); print s }' \
    | LC_ALL=C sort -u)"
  for prefix in $prefixes; do
    [ -n "$prefix" ] || continue
    members=""
    for member in $refs; do
      [ -n "$member" ] || continue
      seg="${member##*/}"
      seg="${seg%%-*}"
      if [ "$seg" = "$prefix" ]; then
        members="$members
$member"
      fi
    done
    cnt="$(printf '%s\n' "$members" | grep -c '[^[:space:]]')"
    if [ "$cnt" -ge 2 ]; then
      joined="$(printf '%s\n' "$members" | grep '[^[:space:]]' | LC_ALL=C sort -u \
        | awk 'NF { if (s != "") s = s ","; s = s $0 } END { print s }')"
      fig_add_dup "$code|$joined"
    fi
  done
}

# --- recursive invariant scan ----------------------------------------------
# Evaluate the invariant set for one node against its own immediate children,
# then recurse into every child that is itself a decomposing node. The top-level
# prefix grouping is done once by fig_scan_all.

fig_scan_node() {  # $1 = canonical ref relative to items/, $2 = node directory
  local ref="$1" dir="$2"
  local man base phase rows opensec
  local cdir localid
  local dirs="" rowids="" childrefs=""

  # A node holding both manifest spellings is drift; the modern spelling stays
  # authoritative and neither file is merged, normalized, or deleted.
  if [ -f "$dir/manifest.md" ] && [ -f "$dir/roadmap.md" ]; then
    fig_add_drift "DRIFT-FACT|$ref"
  fi

  man="$(fig_manifest "$dir")" || return 0
  base="${man##*/}"
  base="${base%.md}"
  phase="$(fig_phase_of "$man")"
  # A manifest's spelling and its declared `phase` value must agree
  # (manifest.md/manifest, roadmap.md/roadmap); a disagreement is drift.
  if [ "$base" = "manifest" ] && [ "$phase" != "manifest" ]; then
    fig_add_drift "DRIFT-FACT|$ref"
  elif [ "$base" = "roadmap" ] && [ "$phase" != "roadmap" ]; then
    fig_add_drift "DRIFT-FACT|$ref"
  fi

  rows="$(fig_children_rows "$man")"
  opensec="$(fig_open_issues "$man")"

  # Immediate child directories (NNNN-slug only).
  for cdir in "$dir"/*/; do
    [ -d "$cdir" ] || continue
    localid="${cdir%/}"
    localid="${localid##*/}"
    case "$localid" in
      [0-9][0-9][0-9][0-9]-*) : ;;
      *) continue ;;
    esac
    dirs="$dirs
$localid"
  done

  rowids="$(printf '%s\n' "$rows" | awk -F'|' 'NF { print $1 }')"

  # MISSING-CHILD: a Children row whose child directory is absent.
  local rid deprow dep d
  for rid in $rowids; do
    [ -n "$rid" ] || continue
    if ! fig_has_line "$dirs" "$rid"; then
      fig_add_graph "MISSING-CHILD|$ref/$rid"
    fi
  done

  # UNLISTED-CHILD: a child directory absent from the table, unless the node's
  # open issues name it as a deliberate withdrawal (report-only, never a fault).
  for localid in $dirs; do
    [ -n "$localid" ] || continue
    if fig_has_line "$rowids" "$localid"; then continue; fi
    if printf '%s\n' "$opensec" | grep -qF -- "$ref/$localid"; then continue; fi
    fig_add_graph "UNLISTED-CHILD|$ref/$localid"
  done

  # DANGLING-DEP: a `Depends on` local id resolving to no row and no directory.
  while IFS= read -r deprow; do
    [ -n "$deprow" ] || continue
    rid="${deprow%%|*}"
    dep="${deprow#*|}"
    [ -n "$dep" ] || continue
    for d in $(fig_dep_tokens "$dep"); do
      [ "$d" = "—" ] && continue
      if fig_has_line "$rowids" "$d"; then continue; fi
      fig_add_graph "DANGLING-DEP|$ref/$rid"
    done
  done <<EOF
$rows
EOF

  # DUPLICATE-CHILD: two immediate children of THIS node sharing a 4-digit
  # prefix, at whatever depth the node sits.
  for localid in $dirs; do
    [ -n "$localid" ] || continue
    childrefs="$childrefs
$ref/$localid"
  done
  fig_check_dups "DUPLICATE-CHILD" "$childrefs"

  # Recurse into every child that is itself a decomposing node.
  for localid in $dirs; do
    [ -n "$localid" ] || continue
    if fig_manifest "$dir/$localid" >/dev/null 2>&1; then
      fig_scan_node "$ref/$localid" "$dir/$localid"
    fi
  done
}

fig_scan_all() {
  local pd pname toprefs=""
  for pd in "$FIG_ITEMS"/*/; do
    [ -d "$pd" ] || continue
    pname="${pd%/}"
    pname="${pname##*/}"
    case "$pname" in
      [0-9][0-9][0-9][0-9]-*) : ;;
      *) continue ;;
    esac
    toprefs="$toprefs
$pname"
  done
  # DUPLICATE-PREFIX: two top-level items sharing a 4-digit prefix.
  fig_check_dups "DUPLICATE-PREFIX" "$toprefs"
  for pname in $toprefs; do
    [ -n "$pname" ] || continue
    fig_scan_node "$pname" "$FIG_ITEMS/$pname"
  done
}

fig_block() {  # normalize a category accumulator to a sorted, deduped block
  printf '%s\n' "$1" | grep -v '^$' | LC_ALL=C sort -u
}

# The three category blocks, one mutation per sub-area.
fixture_duplicates() { fig_block "$FIG_DUP"; }
fixture_graph()      { fig_block "$FIG_GRAPH"; }
fixture_drift()      { fig_block "$FIG_DRIFT"; }

fig_cmp() {  # $1 label, $2 expected, $3 actual
  if [ "$2" = "$3" ]; then
    ok "AC30 $1: matches the expected block"
  else
    bad "AC30 $1: diverged from the expected block"
    printf '    expected:\n%s\n    actual:\n%s\n' "$2" "$3"
  fi
}

# --- analyzers and expected outcome blocks ----------------------------------

fig_scan_all

ACT_DUP="$(fixture_duplicates)"
ACT_GRAPH="$(fixture_graph)"
ACT_DRIFT="$(fixture_drift)"

# The reviewed expectation over the committed fixture: exactly the planted
# duplicates, the structural graph faults (with the recorded withdrawal
# excluded), and the two drift nodes. A two-level-only scan misses the
# depth-three DUPLICATE-CHILD and diverges here.
EXP_DUP="$(cat <<'EOF'
DUPLICATE-CHILD|9211-deep/0001-mid/0001-alpha,9211-deep/0001-mid/0001-beta
DUPLICATE-PREFIX|9210-dup-a,9210-dup-b
EOF
)"

EXP_GRAPH="$(cat <<'EOF'
DANGLING-DEP|9202-graph-faults/0003-dangling
MISSING-CHILD|9202-graph-faults/0002-missing
UNLISTED-CHILD|9202-graph-faults/0005-unlisted
EOF
)"

EXP_DRIFT="$(cat <<'EOF'
DRIFT-FACT|9203-spelling-both
DRIFT-FACT|9204-phase-mismatch
EOF
)"

# --- AC30 per-node-eval (AC2) -----------------------------------------------

fig_cmp "per-node-eval" "$EXP_DUP" "$ACT_DUP"

# The collision is attributed to its OWN node, not flattened to the top level:
# both offenders carry the depth-three parent's canonical reference.
if printf '%s\n' "$ACT_DUP" \
  | grep -qF 'DUPLICATE-CHILD|9211-deep/0001-mid/0001-alpha,9211-deep/0001-mid/0001-beta'; then
  ok "AC30 per-node-eval: the depth-three collision is attributed to 9211-deep/0001-mid"
else
  bad "AC30 per-node-eval: the depth-three collision is not attributed to 9211-deep/0001-mid"
fi

# --- AC30 structural-graph (AC3) --------------------------------------------

fig_cmp "structural-graph" "$EXP_GRAPH" "$ACT_GRAPH"

# The recorded withdrawal is report-only: it yields no UNLISTED-CHILD fault, so
# a deliberate withdrawal is never counted as an accidental graph fault.
if printf '%s\n' "$ACT_GRAPH" | grep -qF 'UNLISTED-CHILD|9202-graph-faults/0004-withdrawn'; then
  bad "AC30 structural-graph: the recorded deliberate withdrawal was reported as UNLISTED-CHILD"
else
  ok "AC30 structural-graph: the recorded deliberate withdrawal yields no UNLISTED-CHILD fault"
fi

# --- AC30 spelling-drift (AC4) ----------------------------------------------

fig_cmp "spelling-drift" "$EXP_DRIFT" "$ACT_DRIFT"

# The modern `manifest.md` spelling is authoritative over the deprecated alias:
# the evaluation resolves a dual-spelling node's manifest to the modern spelling,
# never the alias, so the redundant `roadmap.md` is reported (above) and left
# untouched. A resolver that preferred the alias would be wrong and is caught
# here even though both files carry the same rows.
FIG_DRIFT_MAN="$(fig_manifest "$FIG_ITEMS/9203-spelling-both")"
if [ "$FIG_DRIFT_MAN" = "$FIG_ITEMS/9203-spelling-both/manifest.md" ]; then
  ok "AC30 spelling-drift: the modern manifest is authoritative over the deprecated alias"
else
  bad "AC30 spelling-drift: the modern manifest is not authoritative (resolved '${FIG_DRIFT_MAN:-none}')"
fi

# The dual-spelling node keeps both files: the inconsistency is reported, never
# merged, normalized, dropped, or auto-repaired, so neither spelling disappears.
if [ -f "$FIG_ITEMS/9203-spelling-both/manifest.md" ] \
   && [ -f "$FIG_ITEMS/9203-spelling-both/roadmap.md" ]; then
  ok "AC30 spelling-drift: both spellings are retained, never dropped or auto-repaired"
else
  bad "AC30 spelling-drift: a dual-spelling file was dropped or auto-repaired"
fi

# --- AC30 report-only (AC5, AC2) --------------------------------------------
# The merge-integrity guard commits no checker, so its report-only, non-fatal
# contract lives only on the authority docs/workflow.md -> "### Merge-integrity
# guard" and its operational mirror .opencode/skill/merge-conflict/SKILL.md.
# Both surfaces are pinned here, by path; no sibling agreement area owns these
# literals. The recursive authority phrases are pinned the same way: the
# invariant set is evaluated at every node, no node's check depends on another's
# (authority), and every node at every depth (skill).

FIG_WF='docs/workflow.md'
FIG_SKILL="$SKILL_DIR/merge-conflict/SKILL.md"

# Authority block: docs/workflow.md -> "### Merge-integrity guard", through the
# next heading at the same or a higher level.
fig_mi_block() {
  awk '
    /^### Merge-integrity guard[ \t]*$/ { on = 1; next }
    on && /^#{2,3} / { exit }
    on { print }
  ' "$1"
}

# Skill block: the reconcile procedure's post-merge integrity pass (step 6),
# through the next numbered step, carrying the report-only contract sentence.
fig_skill_post_block() {
  awk '
    /6\. \*\*Post-merge integrity pass/ { on = 1 }
    on && /^7\. / { exit }
    on { print }
  ' "$1"
}

# Collapse a prose block to one line so a contract phrase that wraps across the
# surface's line width still matches as one literal.
fig_flat() { tr '\n' ' ' | tr -s ' '; }

# fig_pin <label> <file> <block> <literal> <what>: assert the block carries the
# literal; a missing file or an unreadable block fails (never skips). The
# literal is matched with grep -F so a markdown-emphasis phrase matches exactly.
fig_pin() {
  local label="$1" file="$2" block="$3" literal="$4" what="$5"
  if [ ! -f "$file" ]; then
    bad "AC30 report-only: $label surface $file is missing; cannot pin $what"
    return
  fi
  if [ -z "$block" ]; then
    bad "AC30 report-only: $label block is not readable; cannot pin $what"
    return
  fi
  if printf '%s\n' "$block" | grep -qF -- "$literal"; then
    ok "AC30 report-only: $label pins $what"
  else
    bad "AC30 report-only: $label does not pin $what (missing '$literal')"
  fi
}

FIG_MI_BLOCK="$(fig_mi_block "$FIG_WF" | fig_flat)"
FIG_SKILL_POST="$(fig_skill_post_block "$FIG_SKILL" | fig_flat)"
FIG_SKILL_ALL="$(cat "$FIG_SKILL" 2>/dev/null | fig_flat)"

# Authority: the non-fatal / never-dropped / never-truncated / not-auto-repaired
# / modifies-no-file contract, and the clean-tree no-findings / no-error clause.
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**non-fatal**' \
  'the non-fatal finding contract'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**never silently dropped**' \
  'the never-silently-dropped contract'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**never truncated**' \
  'the never-truncated contract'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**not auto-repaired**' \
  'the not-auto-repaired contract'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**modifies no file**' \
  'the modifies-no-file contract'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" 'report **no findings**' \
  'the clean-tree reports-no-findings clause'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" '**does not error**' \
  'the clean-tree does-not-error clause'

# The recursive authority phrases: the invariant set is evaluated at every node
# and no node's check depends on another's (authority); the skill carries the
# every-node-at-every-depth phrasing.
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" \
  'The invariant set is evaluated at **every node** of the recursive tree' \
  'the invariant-set-at-every-node authority phrase'
fig_pin authority "$FIG_WF" "$FIG_MI_BLOCK" \
  "no node's check depends on another's" \
  'the node-independence authority phrase'
fig_pin skill "$FIG_SKILL" "$FIG_SKILL_ALL" 'every node at every depth' \
  'the every-node-at-every-depth recursive phrase'

# Skill: the operational mirror's report-only contract.
fig_pin skill "$FIG_SKILL" "$FIG_SKILL_POST" '**report-only**' \
  'the report-only pass contract'
fig_pin skill "$FIG_SKILL" "$FIG_SKILL_POST" 'the list is never truncated' \
  'the never-truncated pass contract'
fig_pin skill "$FIG_SKILL" "$FIG_SKILL_POST" '**modifies no file**' \
  'the modifies-no-file pass contract'
fig_pin skill "$FIG_SKILL" "$FIG_SKILL_POST" 'it never auto-repairs a violation' \
  'the never-auto-repairs pass contract'

# A clean tree reports no findings and does not error: re-scan the clean
# 9201-clean node in isolation into a scratch accumulator; the combined block
# must be empty. (The subshell keeps the real accumulators intact.)
FIG_CLEAN="$(
  FIG_DUP=""; FIG_GRAPH=""; FIG_DRIFT=""
  fig_scan_node "9201-clean" "$FIG_ITEMS/9201-clean"
  fig_block "$FIG_DUP"
  fig_block "$FIG_GRAPH"
  fig_block "$FIG_DRIFT"
)"
if [ -z "$FIG_CLEAN" ]; then
  ok "AC30 report-only: the clean 9201-clean node yields empty findings and does not error"
else
  bad "AC30 report-only: the clean 9201-clean node produced findings: $FIG_CLEAN"
fi

# --- AC30 renumber-sweep (AC7, AC8, AC9) ------------------------------------
# A completed whole-subtree renumber is pinned by the committed fixture
# 9220-renamed-parent/: the new directory exists, the new reference appears in
# every enumerated rewrite position, and the old local id / old canonical
# reference appear NOWHERE. The presence assertions keep the absence assertion
# from being vacuous on an empty tree. The rewrite positions are the ones the
# authority (docs/artifact-conventions.md -> "Renumbering after a parallel
# merge") and its operational mirror (.opencode/skill/merge-conflict/SKILL.md,
# class (c) step 3) enumerate; the intermediate-manifest position is the
# recursive specific tests/checks/88-renumber-sweep.sh does not own — it pins
# the declaration bullets and the closing assertion — so only that one is pinned
# on the surfaces here, referencing 88 by name and restating none of its
# literals. The old-reference constants live only in this check, never in the
# fixture, so the recursive literal scan is scoped to the fixture root and never
# matches this file.

FIG_RN_NODE="$FIG_ITEMS/9220-renamed-parent"
FIG_RN_OLD_LOCAL='0001-old'
FIG_RN_NEW_LOCAL='0002-new'
FIG_RN_OLD_REF='9220-renamed-parent/0001-old'
FIG_RN_NEW_REF='9220-renamed-parent/0002-new'

# fig_rn_file_has <what> <file> <literal>: the file must exist and carry the
# literal (fails, never skips, when the fixture file is absent).
fig_rn_file_has() {
  local what="$1" file="$2" literal="$3"
  if [ ! -f "$file" ]; then
    bad "AC30 renumber-sweep: $what — fixture file $file is missing"
    return
  fi
  if grep -qF -- "$literal" "$file"; then
    ok "AC30 renumber-sweep: $what"
  else
    bad "AC30 renumber-sweep: $what (missing '$literal' in $file)"
  fi
}

# Rewrite position: the directory name.
if [ -d "$FIG_RN_NODE/$FIG_RN_NEW_LOCAL" ]; then
  ok "AC30 renumber-sweep: the new directory $FIG_RN_NEW_LOCAL exists"
else
  bad "AC30 renumber-sweep: the new directory $FIG_RN_NEW_LOCAL is missing"
fi

# The owning manifest's `Children` row: `Local id` and `Canonical reference`.
fig_rn_file_has "the owning manifest's Local id cell names $FIG_RN_NEW_LOCAL" \
  "$FIG_RN_NODE/manifest.md" "| $FIG_RN_NEW_LOCAL |"
fig_rn_file_has "the owning manifest's Canonical reference cell names $FIG_RN_NEW_REF" \
  "$FIG_RN_NODE/manifest.md" "$FIG_RN_NEW_REF"
# Every descendant artifact's `feature:` value.
fig_rn_file_has "a descendant artifact's feature: value carries $FIG_RN_NEW_REF/0001-leaf" \
  "$FIG_RN_NODE/$FIG_RN_NEW_LOCAL/0001-leaf/spec.md" "feature: $FIG_RN_NEW_REF/0001-leaf"
# Every `parent:` value on the changed path.
fig_rn_file_has "a descendant artifact's parent: value carries $FIG_RN_NEW_REF" \
  "$FIG_RN_NODE/$FIG_RN_NEW_LOCAL/0001-leaf/spec.md" "parent: $FIG_RN_NEW_REF"
# Every intermediate manifest's `Children` `Canonical reference` cell.
fig_rn_file_has "the intermediate manifest's Canonical reference cell names $FIG_RN_NEW_REF/0001-leaf" \
  "$FIG_RN_NODE/$FIG_RN_NEW_LOCAL/manifest.md" "$FIG_RN_NEW_REF/0001-leaf"
# Every `Depends on` cell naming the new local id (its `conflicts-with` cell
# follows, so the trailing `| — |` anchors the `Depends on` cell).
fig_rn_file_has "the owning manifest's Depends on cell names $FIG_RN_NEW_LOCAL" \
  "$FIG_RN_NODE/manifest.md" "| $FIG_RN_NEW_LOCAL | — |"
# Every `conflicts-with` target naming the new local id.
fig_rn_file_has "the follower's conflicts-with declaration names $FIG_RN_NEW_LOCAL" \
  "$FIG_RN_NODE/0003-follower/design.md" "conflicts-with: \"$FIG_RN_NEW_LOCAL\""
# The recorded ship/handoff path (branch flattened with `+`, per the branch
# naming rule).
fig_rn_file_has "the recorded ship branch names $FIG_RN_NEW_LOCAL" \
  "$FIG_RN_NODE/0003-follower/ship.md" "+$FIG_RN_NEW_LOCAL"

# Old-reference absence: a recursive literal scan over the whole fixture root.
# A reintroduced old reference makes this fail and names the sub-area (AC8).
fig_rn_scan_absent() {  # $1 literal: print matching files, or nothing
  grep -rIlF -- "$1" "$FIG_ROOT" 2>/dev/null
}

FIG_RN_LEAK="$(fig_rn_scan_absent "$FIG_RN_OLD_REF")"
if [ -z "$FIG_RN_LEAK" ]; then
  ok "AC30 renumber-sweep: the old canonical reference $FIG_RN_OLD_REF appears nowhere under the fixture root"
else
  bad "AC30 renumber-sweep: the old canonical reference $FIG_RN_OLD_REF leaked into: $FIG_RN_LEAK"
fi

FIG_RN_LEAK="$(fig_rn_scan_absent "$FIG_RN_OLD_LOCAL")"
if [ -z "$FIG_RN_LEAK" ]; then
  ok "AC30 renumber-sweep: the old local id $FIG_RN_OLD_LOCAL appears nowhere under the fixture root"
else
  bad "AC30 renumber-sweep: the old local id $FIG_RN_OLD_LOCAL leaked into: $FIG_RN_LEAK"
fi

# The recursive surface pin 88 does not own: the intermediate manifest on the
# changed path. The extractors mirror 88's (referenced by name); the literal is
# 88's to restate, not this area's, so only the intermediate-manifest phrase is
# pinned here.
FIG_RN_CONV='docs/artifact-conventions.md'
FIG_RN_SKILL_PATH="$SKILL_DIR/merge-conflict/SKILL.md"

fig_rn_authority_block() {
  awk '
    /^### Renumbering after a parallel merge[ \t]*$/ { on = 1; next }
    on && /^#{2,3} / { exit }
    on { print }
  ' "$1"
}

fig_rn_skill_block() {
  awk '
    /rewrite every reference/ { on = 1 }
    on && /Assert that/ { print; exit }
    on { print }
  ' "$1"
}

FIG_RN_INTERMEDIATE="every intermediate manifest's** \`Children\` \`Canonical reference\` cell on the changed path"

fig_rn_pin() {  # $1 label, $2 file, $3 flattened block, $4 literal, $5 what
  local label="$1" file="$2" block="$3" literal="$4" what="$5"
  if [ ! -f "$file" ]; then
    bad "AC30 renumber-sweep: $label surface $file is missing; cannot pin $what"
    return
  fi
  if [ -z "$block" ]; then
    bad "AC30 renumber-sweep: $label block is not readable; cannot pin $what"
    return
  fi
  if printf '%s\n' "$block" | grep -qF -- "$literal"; then
    ok "AC30 renumber-sweep: $label names $what"
  else
    bad "AC30 renumber-sweep: $label does not name $what (missing '$literal')"
  fi
}

FIG_RN_AUTH_BLOCK="$(fig_rn_authority_block "$FIG_RN_CONV" | fig_flat)"
FIG_RN_SKILL_BLOCK="$(fig_rn_skill_block "$FIG_RN_SKILL_PATH" | fig_flat)"

fig_rn_pin authority "$FIG_RN_CONV" "$FIG_RN_AUTH_BLOCK" "$FIG_RN_INTERMEDIATE" \
  'the intermediate manifest on the changed path'
fig_rn_pin skill "$FIG_RN_SKILL_PATH" "$FIG_RN_SKILL_BLOCK" "$FIG_RN_INTERMEDIATE" \
  'the intermediate manifest on the changed path'

# --- AC30 fixture-existence (AC1) -------------------------------------------
# A required fixture file that is absent fails (never skips): a silently dropped
# fixture would leave a finding block vacuous while the area still reported green.

if [ -d "$FIG_ITEMS" ]; then
  ok "AC30 fixture-existence: recursive-integrity fixture tree exists at $FIG_ITEMS"
else
  bad "AC30 fixture-existence: recursive-integrity fixture tree missing at $FIG_ITEMS"
fi

for fig_required in \
  "$FIG_ITEMS/9201-clean/manifest.md" \
  "$FIG_ITEMS/9202-graph-faults/manifest.md" \
  "$FIG_ITEMS/9203-spelling-both/manifest.md" \
  "$FIG_ITEMS/9203-spelling-both/roadmap.md" \
  "$FIG_ITEMS/9204-phase-mismatch/manifest.md" \
  "$FIG_ITEMS/9210-dup-a/manifest.md" \
  "$FIG_ITEMS/9210-dup-b/manifest.md" \
  "$FIG_ITEMS/9211-deep/manifest.md" \
  "$FIG_ITEMS/9211-deep/0001-mid/manifest.md" \
  "$FIG_ITEMS/9220-renamed-parent/manifest.md" \
  "$FIG_ITEMS/9220-renamed-parent/0002-new/manifest.md" \
  "$FIG_ITEMS/9220-renamed-parent/0002-new/0001-leaf/spec.md" \
  "$FIG_ITEMS/9220-renamed-parent/0003-follower/design.md" \
  "$FIG_ITEMS/9220-renamed-parent/0003-follower/ship.md"; do
  if [ -f "$fig_required" ]; then
    ok "AC30 fixture-existence: $fig_required exists"
  else
    bad "AC30 fixture-existence: $fig_required missing"
  fi
done

# --- AC30 read-only-contract (AC1, AC12) ------------------------------------
# The fixture is test data, never live state: it references no live work/ path
# and carries no executable file. The area is sourced test code, not a committed
# executable checker, and no committed command, agent, or skill references it —
# the merge-integrity guard stays prompt behaviour with no committed checker.

if [ -d "$FIG_ROOT" ] && ! grep -rq 'work/' "$FIG_ROOT" 2>/dev/null; then
  ok "AC30 read-only-contract: fixture references no live work/ path"
else
  bad "AC30 read-only-contract: fixture references a live work/ path"
fi

fig_exec_files="$(find "$FIG_ROOT" -type f 2>/dev/null | while IFS= read -r fig_f; do
  [ -n "$fig_f" ] && [ -x "$fig_f" ] && printf '%s\n' "$fig_f"
done)"
if [ -z "$fig_exec_files" ]; then
  ok "AC30 read-only-contract: fixture tree contains no executable file"
else
  bad "AC30 read-only-contract: fixture tree contains an executable file: $(printf '%s ' $fig_exec_files)"
fi

FIG_CHECKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
FIG_SELF="$FIG_CHECKS_DIR/91-integrity-guard.sh"
if [ -f "$FIG_SELF" ] && [ ! -x "$FIG_SELF" ]; then
  ok "AC30 read-only-contract: the area adds no committed executable checker"
else
  bad "AC30 read-only-contract: the area adds a committed executable checker"
fi

if ! grep -rqF '91-integrity-guard' .opencode/ 2>/dev/null; then
  ok "AC30 read-only-contract: no committed command, agent, or skill references the area"
else
  bad "AC30 read-only-contract: a committed command, agent, or skill references the area"
fi

# --- AC30 mutation-staging (AC10) -------------------------------------------
# The opt-in whole-suite mutation self-check stages each fixture root into its
# scratch copy; the new root must be staged or its whole-suite runs fail once
# this area exists (tests/checks/91-integrity-guard.sh lives in the copy).
# The suite-documentation row and the per-rule mutation jobs remain
# 0005-guard-registration-sweep's responsibility.
#
# Resolve mutation.sh through this check's own directory, never through the
# process CWD: the mutation self-check runs the suite against a staged copy of
# the live surfaces, and tests/mutation.sh is deliberately not staged, so a
# CWD-relative path would fail the copy's whole-suite run.

FIG_MUTATION="$FIG_CHECKS_DIR/../mutation.sh"
if [ -f "$FIG_MUTATION" ] && grep -qF 'tests/fixtures/recursive-integrity' "$FIG_MUTATION"; then
  ok "AC30 mutation-staging: tests/mutation.sh stages tests/fixtures/recursive-integrity"
else
  bad "AC30 mutation-staging: tests/mutation.sh does not stage tests/fixtures/recursive-integrity"
fi

# --- AC30 no-duplication (AC6, AC11) ----------------------------------------
# This area extends the neighbouring agreement areas; it references them by name
# and re-asserts none of the literals those areas already own. The forbidden
# needles are assembled at run time from separate fragments so this assertion's
# own source does not contain them contiguously and cannot match itself. The
# name references are checked against the file header only, so the check is not
# satisfied by the assertion text below.

FIG_HEAD="$(sed -n '1,40p' "$FIG_SELF" 2>/dev/null)"

for fig_area in 10-readiness 20-lifecycle 80-cycle-fixture 85-conflict-guards \
  87-backtrack-guards 88-renumber-sweep 90-packaging 96-signature-sweep; do
  if printf '%s\n' "$FIG_HEAD" | grep -qF -- "$fig_area"; then
    ok "AC30 no-duplication: references tests/checks/$fig_area.sh by name"
  else
    bad "AC30 no-duplication: does not reference tests/checks/$fig_area.sh by name"
  fi
done

if printf '%s\n' "$FIG_HEAD" | grep -qF -- '0001-recursive-structure-guard'; then
  ok "AC30 no-duplication: references the structure guard 0001-recursive-structure-guard by name"
else
  bad "AC30 no-duplication: does not reference the structure guard 0001-recursive-structure-guard by name"
fi

fig_no_dup() {  # $1 forbidden literal, $2 owning area
  if grep -qF -- "$1" "$FIG_SELF" 2>/dev/null; then
    bad "AC30 no-duplication: re-asserts a literal owned by $2"
  else
    ok "AC30 no-duplication: does not re-assert a literal owned by $2"
  fi
}

# 10-readiness — the readiness derivation and shipped-signal literals.
fig_nd_a1='satisfied('
fig_nd_a2='dep_local_id)'
fig_no_dup "$fig_nd_a1$fig_nd_a2" 'tests/checks/10-readiness.sh'
fig_nd_b1='presence is the sole'
fig_nd_b2='shipped signal'
fig_no_dup "$fig_nd_b1 $fig_nd_b2" 'tests/checks/10-readiness.sh'

# 20-lifecycle — the derived-state table cells.
fig_nd_c1='No spec'
fig_nd_c2='.md?'
fig_no_dup "$fig_nd_c1$fig_nd_c2" 'tests/checks/20-lifecycle.sh'

# 80-cycle-fixture — the CYCLIC-DEP diagnostic and roadmap.md migration guard.
fig_nd_d1='unexpected roadmap.md'
fig_nd_d2='fixture set'
fig_no_dup "$fig_nd_d1 $fig_nd_d2" 'tests/checks/80-cycle-fixture.sh'

# 85-conflict-guards — the declared-conflict target grammar.
fig_nd_e1='SiblingOrItem'
fig_nd_e2='Ref'
fig_no_dup "$fig_nd_e1$fig_nd_e2" 'tests/checks/85-conflict-guards.sh'

# 87-backtrack-guards — the backtrack/reopen record literals.
fig_nd_i1='resolves: '
fig_nd_i2='Finding'
fig_no_dup "$fig_nd_i1$fig_nd_i2" 'tests/checks/87-backtrack-guards.sh'

# 88-renumber-sweep — the renumber prose rewrite lists.
fig_nd_f1='no reference to the old'
fig_nd_f2='canonical reference remains'
fig_no_dup "$fig_nd_f1 $fig_nd_f2" 'tests/checks/88-renumber-sweep.sh'

# 90-packaging — the duplicated inventory / count fact.
fig_nd_g1='README '
fig_nd_g2='Layout'
fig_no_dup "$fig_nd_g1$fig_nd_g2" 'tests/checks/90-packaging.sh'

# 96-signature-sweep — the command usage-string literals.
fig_nd_h1='/build [item-ref'
fig_nd_h2=' or task-id]'
fig_no_dup "$fig_nd_h1$fig_nd_h2" 'tests/checks/96-signature-sweep.sh'
