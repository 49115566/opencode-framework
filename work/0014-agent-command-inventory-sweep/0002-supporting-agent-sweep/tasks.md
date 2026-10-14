---
feature: 0014-agent-command-inventory-sweep/0002-supporting-agent-sweep
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Tasks — Supporting-agent recursive sweep

Ordered, dependency-aware. The exact target wording, the legacy-alias label, and
the preserved blocks are fixed in `design.md` → "Approach" and "Interfaces and
data model"; no task requires a further design decision. One task ≈ one focused
commit. Edits are prose-only; no frontmatter, permission, or handoff block changes.

- [ ] **T1** — Sweep `.opencode/agent/status.md`'s decomposing-node detection to
      the manifest spelling. In `<operating_principles>`: line 48 becomes "A
      directory containing `manifest.md` is a **decomposing node** … (`roadmap.md`
      is the recognized deprecated alias…)"; lines 53–55 become the manifest
      `(`manifest.md`, or the legacy `roadmap.md` alias)` and container phase
      `manifest`; line 58's `roadmap.md` becomes `manifest.md`. In `<process>`:
      line 104 becomes "if `manifest.md` (or the legacy `roadmap.md` alias)
      exists"; line 128's manifest spelling becomes
      `(`manifest.md`, or the legacy `roadmap.md` alias)`. In `<quality_bar>`:
      line 265's derived phase `roadmap` becomes `manifest`. In `<rules>`: lines
      337 and 340 become `manifest.md` (or the labelled legacy alias). Change no
      other text. [AC1, AC2]
      Verify: `grep -nF 'containing `manifest.md`' .opencode/agent/status.md`,
      `grep -nF 'container phase `manifest`' .opencode/agent/status.md`, and
      `grep -nc 'deprecated alias' .opencode/agent/status.md` (≥1) all match; and
      every remaining `roadmap.md`/`roadmap` occurrence is immediately
      legacy-labelled except the illustrative identifiers confined to the output
      example.

- [ ] **T2** — Pair the legacy stale token in `.opencode/agent/status.md`
      `<process>` (lines 119–120): replace "Map a `stale: roadmap` token to
      `spec`." with a sentence mapping **both** `stale: manifest` and its retained
      legacy alias `stale: roadmap` to `spec`, introducing no second mapping and
      no new derived label. [AC3] [depends: T1]
      Verify: `grep -nF 'stale: manifest' .opencode/agent/status.md` and
      `grep -nF 'stale: roadmap' .opencode/agent/status.md` both match on/near
      the same sentence, and both read as mapping to `spec`.

- [ ] **T3** — Rename the cited template in `.opencode/agent/status.md`
      `<inputs>` (lines 90–93): "the `roadmap.md` template (the Children table
      contract)" becomes "the `manifest.md` template (the Children table
      contract; `roadmap.md` is the retained legacy alias)". [AC4] [depends: T1]
      Verify: `grep -nF 'the `manifest.md` template' .opencode/agent/status.md`
      matches and the `roadmap.md` template name no longer appears unlabelled.

- [ ] **T4** — Correct the `DRIFT-FACT` wording in `.opencode/agent/status.md`
      `<findings>` (lines 244–246): "a roadmap child's own `design.md`
      declaration" becomes "a nested child's own `design.md` declaration".
      [AC5] [depends: T1]
      Verify: `grep -nF "a nested child's own \`design.md\` declaration"
      .opencode/agent/status.md` matches and `grep -nF "roadmap child"
      .opencode/agent/status.md` returns nothing.

- [ ] **T5** — Sweep `.opencode/agent/status.md`'s phase vocabulary and rendered
      output example. In `<output_format>`: the example phase column entries on
      lines 296–297 become `manifest`; the summary lines 307–308 become
      `Manifest 0002-agentic-roadmaps: … phases: manifest 1, …` and
      `Manifest 0002-agentic-roadmaps/0001-roadmap-model: …`; the phase-vocabulary
      line 327 ends `… \`shipped\`, \`manifest\`;`. **Keep every illustrative
      reference identifier unchanged** (`0002-agentic-roadmaps`,
      `0001-roadmap-model`, `0002-agentic-roadmaps/0003-*`). [AC6, AC7]
      [depends: T1]
      Verify: `grep -nE '\| (manifest) +\| [0-9]+/[0-9]+ ready' .opencode/agent/status.md`
      matches the two example rows; `grep -nF 'Manifest 0002-agentic-roadmaps'
      .opencode/agent/status.md` matches; `grep -nF 'phases: manifest 1'
      .opencode/agent/status.md` matches; and the phase-vocabulary list contains
      `manifest` and not `roadmap`.

- [ ] **T6** — State the canonical recursive reference form in
      `.opencode/agent/visual.md` `<inputs>` item 5 (lines 58–60), replacing "or
      `NNNN-slug/MMMM-slug` for a roadmap child" with the form fixed in
      `design.md` → "Interfaces and data model" (a nested `NNNN-slug/MMMM-slug` at
      any depth, per `docs/artifact-conventions.md` → "Work item references").
      Change no other line. [AC8]
      Verify: `grep -nF 'at any depth, per `docs/artifact-conventions.md` →
      "Work item references"' .opencode/agent/visual.md` matches and
      `grep -nF 'for a roadmap child' .opencode/agent/visual.md` returns nothing.

- [ ] **T7** — Add the canonical-reference clause to `.opencode/agent/scribe.md`
      `<process>` step 1 (line 43), so the `work/<item-ref>/<file>` path is
      accompanied by the item's canonical reference (`NNNN-slug`, or nested
      `NNNN-slug/MMMM-slug` at any depth, per `docs/artifact-conventions.md` →
      "Work item references"). Change no other line. [AC9]
      Verify: `grep -nF 'canonical reference' .opencode/agent/scribe.md` matches
      within step 1 and the `docs/artifact-conventions.md` → "Work item
      references" citation appears.

- [ ] **T8** — Audit the completed sweep for scope and legacy-alias discipline.
      Confirm the three untouched prompts carry no `roadmap` vocabulary, that
      every remaining `roadmap` occurrence in the edited prompts is either
      legacy-labelled or an illustrative identifier inside the output example,
      and that the change set contains only the three prompts plus this item's
      `design.md`/`tasks.md`. [AC10, AC12, AC13]
      Verify: `grep -nF roadmap .opencode/agent/scout.md .opencode/agent/ask.md
      .opencode/agent/bootstrap.md` returns nothing;
      `grep -n roadmap .opencode/agent/status.md .opencode/agent/visual.md
      .opencode/agent/scribe.md` yields only labelled aliases or in-example
      identifiers; and `git diff --name-only` lists exactly
      `.opencode/agent/status.md`, `.opencode/agent/visual.md`,
      `.opencode/agent/scribe.md`,
      `work/0014-agent-command-inventory-sweep/0002-supporting-agent-sweep/design.md`,
      and `.../tasks.md`.

- [ ] **T9** — Verify the protected blocks and the committed suite. Confirm
      `git diff` changes lie outside each prompt's frontmatter (including the
      `permission` block) and `<handoff>` block, then run the repository's
      configured test command. [AC11, AC14] [depends: T8]
      Verify: `git diff -- .opencode/agent/status.md .opencode/agent/visual.md
      .opencode/agent/scribe.md` shows no change within any frontmatter,
      `permission:`, or `<handoff>` block; `bash tests/run.sh` exits 0 with no
      `FAIL` line; and the pinned literals survive —
      `grep -F 'A child in a cycle is never \`ready\`' .opencode/agent/status.md`,
      `grep -F 'CYCLIC-DEP' .opencode/agent/status.md`,
      `grep -F 'informational and never fatal' .opencode/agent/status.md`,
      `tr '\n' ' ' < .opencode/agent/status.md | grep -F 'members of a cycle are never reported'`,
      `grep -F 'Dependencies and readiness' .opencode/agent/status.md`, and
      `grep -F '## Declared-conflict check' .opencode/agent/status.md` all match.
