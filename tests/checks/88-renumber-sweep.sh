#!/usr/bin/env bash
#
# AC26 — renumber-sweep reference completeness.
#
# "Renumbering after a parallel merge" has two surfaces: the authority
# (docs/artifact-conventions.md -> "### Renumbering after a parallel merge",
# step 4) and its operational mirror (.opencode/skill/merge-conflict/SKILL.md,
# the class (c) renumber step 3). Both enumerate the references a renumber must
# rewrite. The recursive `conflicts-with` grammar (docs/workflow.md -> "Declared
# conflicts (`conflicts-with`)") lets a declaration target the renumbered item's
# local id or canonical reference at arbitrary depth, so a renumber sweep that
# skips the declaration references leaves the read-only declared-conflict check
# reporting `DANGLING-DEP` (or `DRIFT-FACT`). The sweep and the recursive grammar
# were generalized by different work items and each disclaimed the other's
# surface, so this area pins both lists to the exhaustive set: the existing
# directory / `feature:` / `Children` / `parent:` / `ship.md` / prose bullets
# plus (a) every `Depends on` cell naming the old local id and (b) every
# `conflicts-with` target naming the old local id or old canonical reference —
# the manifest `Children` cell and the `design.md` frontmatter value — and the
# skill's closing "no reference to the old canonical reference remains"
# assertion mirrored into the authority.
#
# It adds no production checker and no new conflict class or code; it is a
# live-surface agreement check like 95-split-guard and 96-signature-sweep, and
# reads only committed surfaces (never work/**); sourced by tests/run.sh, so it
# must not call exit. Prints ok/FAIL lines labelled AC26 with the sub-area
# `renumber-sweep` so a mutation self-check can name the guard it trips.

echo "== AC26 renumber-sweep reference completeness =="

RN_CONV="docs/artifact-conventions.md"
RN_SKILL="$SKILL_DIR/merge-conflict/SKILL.md"

# Authority block: the body of the "Renumbering after a parallel merge"
# subsection, up to the next heading at the same or a higher level.
rn_authority_block() {
  awk '
    /^### Renumbering after a parallel merge[ \t]*$/ { on = 1; next }
    on && /^#{2,3} / { exit }
    on { print }
  ' "$1"
}

# Skill block: the class (c) step 3 "rewrite every reference" bullet list,
# through the closing "Assert that ..." sentence.
rn_skill_block() {
  awk '
    /rewrite every reference/ { on = 1 }
    on && /Assert that/ { print; exit }
    on { print }
  ' "$1"
}

# rn_has <surface label> <file> <block extractor> <literal> <what it is>
rn_has() {
  local label="$1" file="$2" extractor="$3" literal="$4" what="$5" block
  if [ ! -f "$file" ]; then
    bad "AC26 renumber-sweep: $label is missing; cannot verify its rewrite list"
    return
  fi
  block="$("$extractor" "$file")"
  if [ -z "$block" ]; then
    bad "AC26 renumber-sweep: $label renumber block is not readable"
    return
  fi
  if printf '%s\n' "$block" | grep -qF -- "$literal"; then
    ok "AC26 renumber-sweep: $label names $what"
  else
    bad "AC26 renumber-sweep: $label does not name $what (missing '$literal')"
  fi
}

# The two declaration-reference bullets the sweep must carry, plus the closing
# assertion; both surfaces word them identically so the lists stay identical by
# reference (see docs/artifact-conventions.md -> "Renumbering after a parallel
# merge" and .opencode/skill/merge-conflict/SKILL.md -> step 3).
RN_DEPENDS='every `Depends on` cell that names the old local id'
RN_CONFLICTS='every `conflicts-with` target that names the old local id or old'
RN_CONFLICTS_DESIGN='`design.md` frontmatter `conflicts-with` value'
RN_ASSERT='no reference to the old canonical reference remains'

rn_has authority "$RN_CONV" rn_authority_block "$RN_DEPENDS" \
  'the Depends on bullet (old local id)'
rn_has authority "$RN_CONV" rn_authority_block "$RN_CONFLICTS" \
  'the conflicts-with bullet (old local id or canonical reference)'
rn_has authority "$RN_CONV" rn_authority_block "$RN_CONFLICTS_DESIGN" \
  'the design.md conflicts-with value'
rn_has authority "$RN_CONV" rn_authority_block "$RN_ASSERT" \
  'the closing no-stale-reference assertion'

rn_has skill "$RN_SKILL" rn_skill_block "$RN_DEPENDS" \
  'the Depends on bullet (old local id)'
rn_has skill "$RN_SKILL" rn_skill_block "$RN_CONFLICTS" \
  'the conflicts-with bullet (old local id or canonical reference)'
rn_has skill "$RN_SKILL" rn_skill_block "$RN_CONFLICTS_DESIGN" \
  'the design.md conflicts-with value'
rn_has skill "$RN_SKILL" rn_skill_block "$RN_ASSERT" \
  'the closing no-stale-reference assertion'
