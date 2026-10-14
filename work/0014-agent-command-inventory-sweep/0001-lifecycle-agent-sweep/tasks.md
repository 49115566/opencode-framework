---
feature: 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Tasks — Lifecycle-agent recursive sweep

Ordered, dependency-aware. One task ≈ one focused commit. The canonical sentence
used by T1–T4 is the exact one-line string fixed in `design.md` → "Resolution of
the spec's deferred open question"; insert it verbatim, unwrapped, with no
internal newline.

- [ ] **T1** — Sweep `product.md`: replace the `<inputs>` item 5 boilerplate with
      the canonical sentence; in `<process>` step 6 change "nested roadmap child"
      to "nested child" and the parent `work/<NNNN-slug>/roadmap.md` to
      `work/<NNNN-slug>/manifest.md` (citing "`manifest.md` — the manifest of a
      decomposing node") while preserving the readiness check and
      explicit-override sentence; in step 7 change "for a roadmap child" to "for
      a nested child"; in the `<rules>` parent-node rule change "parent roadmap"
      → "parent's manifest", `/roadmap revise <parent-ref>` → `/plan
      <parent-ref>`, target phase `roadmap` → `manifest`, affected
      `work/<parent-ref>/roadmap.md` → `work/<parent-ref>/manifest.md`,
      "Revising a roadmap" → "Revising a decomposition", and "only the roadmap
      owner writes it" → "only the planning step (its owner) writes it". [AC1]
      [AC2] [AC4] [AC6] [AC9]
      Verify: `grep -n roadmap .opencode/agent/product.md` prints nothing;
      `grep -n 'manifest.md\|Revising a decomposition\|/plan <parent-ref>' .opencode/agent/product.md`
      shows the new wording and the canonical sentence appears on one line after
      "The item reference in `$ARGUMENTS`:".

- [ ] **T2** — Sweep `shipper.md`: replace the `<inputs>` bullet 1 boilerplate
      with the canonical sentence, making it free-standing and starting "read
      `work/<item-ref>/spec.md`, `tasks.md`, `verify.md`, and `review.md`." as a
      new sentence; in the work-item precondition change "a `work/` sequence
      collision or a roadmap graph fault" to "… or a manifest dependency-graph
      fault" citing `docs/workflow.md` → "Dependencies and readiness"; in the
      work-item `<process>` step 2 change "re-check every roadmap graph" to
      "re-check every manifest's dependency graph" (semantics unchanged); in the
      `<rules>` renumber bullet change "the roadmap `Children`" to "the manifest
      `Children`". Leave the plan-publication and recall `manifest.md` wording
      untouched. [AC3] [AC4] [AC6] [AC9] [depends: T1]
      Verify: `grep -n roadmap .opencode/agent/shipper.md` prints nothing;
      `grep -n 'dependency graph\|manifest `Children`' .opencode/agent/shipper.md`
      shows the new terms, and `grep -n 'manifest.md' .opencode/agent/shipper.md`
      still shows the plan/recall wording.

- [ ] **T3** — Sweep `architect.md` and `builder.md`: replace each prompt's
      item-ref boilerplate (architect item 5, builder item 4) with the canonical
      sentence; keep `architect.md`'s existing labelled legacy alias
      "`… (or the legacy `roadmap.md` artifact alias)`" verbatim. Touch nothing
      else. [AC4] [AC6] [AC9] [depends: T1]
      Verify: `grep -n roadmap .opencode/agent/builder.md` prints nothing;
      `grep -c roadmap .opencode/agent/architect.md` prints `1` and
      `grep -n 'legacy `roadmap.md`' .opencode/agent/architect.md` shows it
      labelled `legacy`; the canonical sentence appears once in each file.

- [ ] **T4** — Sweep `tester.md` and `reviewer.md`: replace each prompt's
      item-ref boilerplate with the canonical sentence, and add a final
      `<inputs>` item addressing a decomposing node — its `manifest.md`, its
      nested children by canonical reference, and a hybrid node's own
      deliverable — citing `docs/artifact-conventions.md` → "Work item
      references", mirroring `builder.md`'s existing decomposing/hybrid input.
      [AC4] [AC5] [AC6] [AC9] [depends: T1]
      Verify: `grep -n roadmap .opencode/agent/tester.md .opencode/agent/reviewer.md`
      prints nothing; `grep -n 'manifest.md' .opencode/agent/tester.md .opencode/agent/reviewer.md`
      shows the decomposing/hybrid coverage and the canonical sentence.

- [ ] **T5** — Cross-prompt conformance check (no file edits beyond what the
      check reveals): extract the canonical sentence from each of the six inputs
      and confirm the six are byte-identical and free of "roadmap child"; confirm
      the token `roadmap` occurs exactly once across the six files, in
      `architect.md`, labelled `legacy`; confirm no frontmatter
      (`description`/`mode`/`permission`) or `<handoff>` block changed.
      [AC1] [AC2] [AC3] [AC4] [AC5] [AC6] [AC7] [AC9] [depends: T2, T3, T4]
      Verify: `grep -rn 'roadmap child' .opencode/agent/{product,architect,builder,tester,reviewer,shipper}.md`
      prints nothing; `grep -rno roadmap .opencode/agent/{product,architect,builder,tester,reviewer,shipper}.md`
      prints exactly one hit (the labelled legacy alias); the extracted canonical
      sentence compares byte-for-byte identical across the six; `git diff -- .opencode/agent/`
      shows no change to any `description`/`mode`/`permission` line or `<handoff>`
      block.

- [ ] **T6** — Run the committed suite and confirm the inventory is unchanged.
      [AC8] [depends: T5]
      Verify: `bash tests/run.sh` exits `0`; `grep` the `README.md` Layout counts
      and Agents/Commands/Skills tables show 13 / 12 / 11.
