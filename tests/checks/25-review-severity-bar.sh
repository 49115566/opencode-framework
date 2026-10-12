#!/usr/bin/env bash
#
# AC25 — review severity-bar agreement.
#
# A surviving finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`)
# must yield `request-changes`; `approve` requires that no finding of any
# severity survives. The bar is duplicated across six committed surfaces — the
# reviewer agent, the `/review` command, the `code-review` skill, the workflow
# authority's Review phase and challenge-adjudication sections, the review
# artifact conventions, and the `workflow-lifecycle` skill. This check asserts
# that all six state the bar and that none still carries the old Blocker/Major
# only rule or presents a `Minor`/`Nit` as non-blocking or optionally declinable.
#
# It is a live-surface agreement check (the analogue of `50-instructions.sh` and
# `96-signature-sweep.sh`): it reads six committed surfaces, is sourced by
# `tests/run.sh`, and never reads live `work/**`. The suite token `AC25` maps to
# `0009-minor-nit-resolution`; its mapping to the item's acceptance criteria is in
# `tests/README.md`. Each assertion is labelled `AC25 <sub-area>` so a mutation
# names the guard it trips.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Bash 3.2 compatible: no associative arrays, no mapfile.

echo "== AC25 review severity-bar agreement =="

# --- the six surfaces that state the review gate ----------------------------
# lib.sh names the agent/command/skill directories and the two docs; the two
# skill paths are derived from SKILL_DIR.
sevbar_reviewer="$AGENT_DIR/reviewer.md"
sevbar_review_cmd="$CMD_DIR/review.md"
sevbar_review_skill="$SKILL_DIR/code-review/SKILL.md"
sevbar_lifecycle_skill="$SKILL_DIR/workflow-lifecycle/SKILL.md"
sevbar_wf="$WF"
sevbar_conv="$CONV"

# A missing surface is a labelled bad (never a skip): the bar cannot be verified
# against a surface that does not exist.
for sevbar_f in "$sevbar_reviewer" "$sevbar_review_cmd" "$sevbar_review_skill" \
                "$sevbar_wf" "$sevbar_conv" "$sevbar_lifecycle_skill"; do
  if [ -f "$sevbar_f" ]; then
    ok "AC25 all-severity-bar surface $sevbar_f exists"
  else
    bad "AC25 all-severity-bar surface $sevbar_f is missing; cannot verify the bar"
  fi
done

# Flattened-text matcher: the bar phrases span wrapped lines, so a surface is
# flattened (lib.sh `flat`: newlines to spaces, runs squeezed) before a
# fixed-string match. The label is `AC25 <sub-area> <label>`.
sevbar_flat_need() {  # $1 sub-area, $2 file, $3 flattened literal, $4 label
  if [ ! -f "$2" ]; then
    bad "AC25 $1 $4 (surface $2 is missing)"
    return
  fi
  if flat "$2" | grep -qF -- "$3"; then
    ok "AC25 $1 $4"
  else
    bad "AC25 $1 $4 (missing '$3' in $2)"
  fi
}

# --- AC25 all-severity-bar: each surface states the bar ---------------------
sevbar_flat_need all-severity-bar "$sevbar_reviewer" \
  'Set the verdict: `request-changes` if any finding of any severity' \
  'reviewer.md verdict: any surviving severity -> request-changes'
sevbar_flat_need all-severity-bar "$sevbar_reviewer" \
  'Recompute the verdict: `approve` if and only if no finding of any severity' \
  'reviewer.md sustained-challenge recompute: approve iff no severity remains'
sevbar_flat_need all-severity-bar "$sevbar_reviewer" \
  'A finding adjusted to `Minor` or `Nit` still blocks; only an overturn removes it.' \
  'reviewer.md adjusted Minor/Nit still blocks'
# AC7 edge case: the question escape hatch records genuine uncertainty and is
# never a way to decline a classifiable Minor/Nit; a classifiable finding must be
# recorded and blocks.
sevbar_flat_need all-severity-bar "$sevbar_reviewer" \
  'never a classified `Minor` or `Nit` you are declining to raise' \
  'reviewer.md question escape is not a decline path'
sevbar_flat_need all-severity-bar "$sevbar_reviewer" \
  'A finding you can classify as any severity must be recorded as a finding' \
  'reviewer.md classifiable finding cannot be dodged as a question'
sevbar_flat_need all-severity-bar "$sevbar_review_cmd" \
  'recompute the verdict (`approve` if and only if no finding of any severity remains)' \
  'review.md recommendation: approve iff no severity remains'
# The command's closing gate line uses the same noun as the reviewer agent: under
# the all-severity bar the prohibition applies to a finding of any severity, so
# "do not invent findings" (never the narrower "blockers") keeps the two prompts
# from drifting apart.
sevbar_flat_need all-severity-bar "$sevbar_review_cmd" \
  'do not invent findings' \
  'review.md command gate: do not invent findings'
sevbar_flat_need all-severity-bar "$sevbar_review_skill" \
  '`request-changes` if any finding of any severity' \
  'code-review skill verdict: any surviving severity -> request-changes'
sevbar_flat_need all-severity-bar "$sevbar_review_skill" \
  '`approve` if and only if no finding of any severity survives' \
  'code-review skill verdict: approve iff no severity survives'
sevbar_flat_need all-severity-bar "$sevbar_review_skill" \
  'recomputes the verdict: `approve` if and only if no finding of any severity remains' \
  'code-review skill disputed-findings recompute: approve iff no severity remains'
sevbar_flat_need all-severity-bar "$sevbar_wf" \
  'A finding of any severity — `Blocker`, `Major`, `Minor`, or `Nit` — that survives scrutiny yields `request-changes`' \
  'workflow Review Exit: any surviving severity -> request-changes'
sevbar_flat_need all-severity-bar "$sevbar_wf" \
  'if and only if no finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`) remains' \
  'workflow challenge recompute: approve iff no severity remains'
sevbar_flat_need all-severity-bar "$sevbar_lifecycle_skill" \
  'produced by a surviving finding of any severity (`Blocker`, `Major`, `Minor`, or `Nit`)' \
  'workflow-lifecycle skill build (rework): any severity'
sevbar_flat_need all-severity-bar "$sevbar_lifecycle_skill" \
  '(rework findings)' \
  'workflow-lifecycle skill routes request-changes to rework findings'

# --- AC25 contract-preserved: the vocabulary is unchanged -------------------
# The four severity labels and both verdicts still appear on both definition
# surfaces, and the Minor/Nit definitions say the finding blocks rather than
# being non-blocking or declinable.
for sevbar_f in "$sevbar_review_skill" "$sevbar_conv"; do
  for sevbar_t in Blocker Major Minor Nit request-changes approve; do
    if [ -f "$sevbar_f" ] && grep -qF -- "$sevbar_t" "$sevbar_f"; then
      ok "AC25 contract-preserved $sevbar_f still names $sevbar_t"
    else
      bad "AC25 contract-preserved $sevbar_f no longer names $sevbar_t"
    fi
  done
  sevbar_flat_need contract-preserved "$sevbar_f" \
    '**Minor** — worth fixing; blocks the item' \
    "$sevbar_f Minor definition blocks the item"
  sevbar_flat_need contract-preserved "$sevbar_f" \
    '**Nit** — style or preference; blocks the item' \
    "$sevbar_f Nit definition blocks the item"
done

# Negative control: across all six surfaces, the old Blocker/Major-only phrasing,
# the non-blocking/declinable Minor/Nit language, and any new disposition token
# must be absent. One assertion per token, naming the offending surface when found.
for sevbar_t in 'Blocker or Major' 'not merge-blocking' 'the author may decline' 'waived' 'declined'; do
  sevbar_hit=""
  for sevbar_f in "$sevbar_reviewer" "$sevbar_review_cmd" "$sevbar_review_skill" \
                  "$sevbar_wf" "$sevbar_conv" "$sevbar_lifecycle_skill"; do
    if [ -f "$sevbar_f" ] && grep -qF -- "$sevbar_t" "$sevbar_f"; then
      sevbar_hit="$sevbar_hit $sevbar_f"
    fi
  done
  if [ -z "$sevbar_hit" ]; then
    ok "AC25 contract-preserved no surface carries '$sevbar_t'"
  else
    bad "AC25 contract-preserved old/new text '$sevbar_t' present in:$sevbar_hit"
  fi
done
