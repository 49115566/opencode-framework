---
feature: 0014-agent-command-inventory-sweep/0003-command-sweep
phase: tasks
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Tasks — Command-surface recursive sweep

Ordered, dependency-aware. The exact target wording and the pinned literals are
fixed in `design.md` → "Interfaces and data model"; no task requires a further
design decision. One task ≈ one focused commit. Edits are prose-only: no
frontmatter, `description:`/`Usage:` line, or `agent:` value changes.

- [ ] **T1** — Replace the retired three-line item-ref boilerplate with the
      canonical command sentence in **all seven** commands — `spec.md`,
      `plan.md`, `build.md`, `test.md`, `review.md`, `ship.md`, `visual.md` — using
      the exact four-line block in `design.md` → "The canonical command sentence",
      identical in every file. In `plan.md`, leave line 32's labelled legacy
      `(or the legacy `roadmap.md` artifact alias)` text untouched. Change no other
      line. [AC6, AC7, AC9, AC12]
      Verify: `for f in spec plan build test review ship visual; do grep -A3 -F
      'A work-item reference (`item-ref`) is' .opencode/command/$f.md; done`
      shows the identical four lines for all seven;
      `grep -rnF 'for a roadmap child' .opencode/command/` returns nothing;
      `grep -nF '(or the legacy `roadmap.md` artifact alias)' .opencode/command/plan.md`
      matches.

- [ ] **T2** — Sweep `command/spec.md`'s nested-child allocation step (lines
      22–24) to the canonical recursive reference form fixed in `design.md` →
      "`spec.md` nested-child allocation step": "for a roadmap child, use the
      supplied `NNNN-slug/MMMM-slug` reference" becomes "for a nested child, use
      the supplied canonical reference (`NNNN-slug/MMMM-slug`, nesting to arbitrary
      depth per `docs/artifact-conventions.md` → "Work item references")". Change
      no other line. [AC4] [depends: T1]
      Verify: `grep -nF 'for a nested child, use the supplied' .opencode/command/spec.md`
      and `grep -nF 'docs/artifact-conventions.md` → "Work item references"' .opencode/command/spec.md`
      both match; `grep -nF 'for a roadmap child' .opencode/command/spec.md`
      returns nothing.

- [ ] **T3** — Sweep `command/status.md`'s decomposing-node detection and
      container phase (lines 15–20) per `design.md` → "`status.md`
      decomposing-node detection and container phase": detect by `manifest.md`
      (with `roadmap.md` named as the legacy alias) and derive the container phase
      `manifest`. Do not touch lines 34–46 (the Children-table/readiness block)
      or lines 52–53 (the finding codes). [AC1, AC2]
      Verify: `grep -nF 'by the presence of `manifest.md` (or the legacy' .opencode/command/status.md`
      matches; `grep -nF 'container phase' .opencode/command/status.md` shows
      `manifest` and no `roadmap`; `grep -nF 'presence of `roadmap.md`' .opencode/command/status.md`
      returns nothing.

- [ ] **T4** — Pair the legacy stale token in `command/status.md` line 28 per
      `design.md` → "`status.md` legacy stale-token pairing": replace
      `Map a `stale: roadmap` token to `spec`` with a sentence mapping both
      `stale: manifest` and its retained legacy alias `stale: roadmap` to `spec`,
      introducing no second mapping and no new derived label. [AC3] [depends: T3]
      Verify: `grep -nF 'stale: manifest' .opencode/command/status.md` and
      `grep -nF 'stale: roadmap' .opencode/command/status.md` both match on the
      same sentence and both read as mapping to `spec`.

- [ ] **T5** — Sweep `command/ship.md`'s reconcile re-check (lines 39–40) per
      `design.md` → "`ship.md` reconcile re-check":
      `re-check the roadmap dependency graph` becomes
      `re-check the manifest's dependency graph`; leave the surrounding reconcile
      and "Renumbering after a parallel merge" semantics unchanged. [AC5]
      [depends: T1]
      Verify: `grep -nF "re-check the manifest's" .opencode/command/ship.md`
      matches; `grep -nF 'roadmap' .opencode/command/ship.md` returns nothing.

- [ ] **T6** — Audit the completed sweep for scope, legacy-alias discipline, and
      no-restatement. Confirm `conflicts.md`, `fix.md`, `bootstrap.md`, and
      `doctor.md` are byte-identical; every remaining `roadmap` token in the eight
      swept commands is a clearly-labelled legacy alias (only `plan.md` line 32 and
      the two `status.md` alias mentions); and the change set is exactly the eight
      commands plus this item's `design.md`/`tasks.md`. [AC7, AC8, AC10, AC12]
      [depends: T1, T2, T3, T4, T5]
      Verify: `git diff --name-only` lists exactly `.opencode/command/spec.md`,
      `.opencode/command/plan.md`, `.opencode/command/build.md`,
      `.opencode/command/test.md`, `.opencode/command/review.md`,
      `.opencode/command/ship.md`, `.opencode/command/status.md`,
      `.opencode/command/visual.md`,
      `work/0014-agent-command-inventory-sweep/0003-command-sweep/design.md`, and
      `.../tasks.md`; `git diff -- .opencode/command/conflicts.md
      .opencode/command/fix.md .opencode/command/bootstrap.md
      .opencode/command/doctor.md` is empty; `grep -rn roadmap
      .opencode/command/{spec,plan,build,test,review,ship,status,visual}.md`
      yields only the labelled `plan.md:32` alias and the two labelled
      `status.md` alias mentions.

- [ ] **T7** — Verify the protected lines and the committed suite. Confirm
      `git diff` changes lie outside every command's frontmatter (including
      `description:`/`Usage:` and `agent:`), then run the repository's configured
      test command. [AC9, AC11] [depends: T6]
      Verify: `git diff -- .opencode/command/` shows no change within any `---`
      frontmatter block; `bash tests/run.sh` exits 0 with no `FAIL` line and the
      `96-signature-sweep` checks stay green; the pinned literals survive —
      `grep -F 'a child in a cycle is never `ready`' .opencode/command/status.md`,
      `grep -F 'CYCLIC-DEP' .opencode/command/status.md`,
      `grep -F 'Report them without failing' .opencode/command/status.md`,
      `grep -F 'Dependencies and readiness' .opencode/command/status.md`, and
      `grep -F '## Declared-conflict check' .opencode/command/status.md` all match;
      and the documented inventory remains 13 agents / 12 commands / 11 skills.
