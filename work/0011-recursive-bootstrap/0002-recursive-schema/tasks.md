---
feature: 0011-recursive-bootstrap/0002-recursive-schema
phase: tasks
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Tasks — Recursive work-item schema, references, and sequence allocation

Ordered, dependency-aware. One task ≈ one focused commit. This item is
documentation-only; no test file is added (committed guards are deferred to a
successor roadmap per the spec's non-goals). `Verify:` commands that run the
suite use the project's configured test command, `bash tests/run.sh`, optionally
area-scoped via `FRAMEWORK_TEST_AREAS`. Do not touch any literal listed in the
design's "Must-not-restate / must-not-touch" lists.

- [ ] **T1** — In `docs/artifact-conventions.md`, generalize the canonical
      reference to a recursive path. Rewrite `## Work item references` so
      `item-ref ::= NNNN-slug ( "/" MMMM-slug )*` with regex
      `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`; state that the first
      segment is the top-level `NNNN`, each further `MMMM` segment is local to
      its immediate parent, a reference resolves to `work/<item-ref>/` by
      following its segments, the one-segment standalone form is unchanged, and
      the two-segment form is a special case rather than a maximum depth. Also
      generalize the top-of-file layout sentence (lines 3–4) to
      `work/<item-ref>/` and the `feature:` frontmatter comment/rule so it names
      the full canonical reference for any depth. Leave `stale: ""`,
      `reopened: ""`, and the `spec | design | build | test | review` literal
      untouched. [AC1] [AC2]
      Verify: `grep -n 'item-ref' docs/artifact-conventions.md` shows the
      recursive grammar and its `*`-repeated segment; the one-segment form and
      the "special case" wording are present; the two-level-only regex
      `(...)?$` is gone; `FRAMEWORK_TEST_AREAS='87-backtrack-guards,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [ ] **T2** — In `docs/artifact-conventions.md`, generalize the frontmatter
      `parent:` field. Update the template comment (line 24), the `parent` rule
      (lines 35–36), and the "Nested children's artifacts…" paragraph
      (lines 96–98): a nested child's `parent:` names the **immediate** parent's
      canonical reference — one segment (`NNNN-slug`) at depth two and the
      parent's full multi-segment reference at depth three or deeper — the full
      ancestor chain is derivable from the directory path, and a standalone item
      omits `parent` as before. Do not alter the `stale:`/`reopened:` comment
      lines. [AC4] [depends: T1]
      Verify: `grep -n 'parent' docs/artifact-conventions.md` shows the
      "immediate parent's canonical reference" wording and the depth-two vs
      depth-≥3 distinction; `FRAMEWORK_TEST_AREAS='87-backtrack-guards' bash tests/run.sh`
      exits 0.

- [ ] **T3** — In `docs/artifact-conventions.md`, generalize `## Sequence
      allocation` (lines 630–647): keep the top-level `NNNN` rule unchanged and
      state that every further level allocates its children's local `MMMM`
      scoped to the **immediate** parent (the greatest 4-digit prefix ever
      committed under `work/<parent-ref>/` plus one, never reused within that
      parent), applying the same contract at every level, independent of the
      top-level sequence and of other nodes. Leave `### Renumbering after a
      parallel merge` unchanged. [AC3] [depends: T1]
      Verify: the section states per-level allocation at every depth and names
      the immediate parent as the scope; `FRAMEWORK_TEST_AREAS='96-signature-sweep' bash tests/run.sh`
      exits 0.

- [ ] **T4** — In `docs/artifact-conventions.md`, recast the `### roadmap.md`
      template section (lines 107–179) as the **manifest** of a decomposing
      node. Rewrite the intro to state that a decomposing node records its
      children in its manifest, that the manifest is the generic
      child-enumeration source for any decomposing node at any depth, and that
      its shipped concrete spelling is `roadmap.md` with `phase: roadmap` at
      every depth — no new file name, `phase` value, or artifact-presence row.
      Add the `.gitkeep` reservation rule (`work/<parent-ref>/<MMMM-slug>/.gitkeep`
      at every level). Generalize the `Local id` and `Canonical reference`
      bullets for any depth. **Preserve unchanged** the fenced template block,
      its six-column header line
      (`| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |`),
      the `Depends on` bullet, and the withdrawal/revision bullets. On the
      `conflicts-with` bullet, keep the shipped grammar reference and append one
      sentence deferring `conflicts-with` targets at arbitrary depth to the
      successor roadmap that owns "`conflicts-with` at every level". [AC5] [AC6]
      [AC7] [AC8] [depends: T1]
      Verify: `grep -nF '| Local id | Title | Scope | Depends on | conflicts-with | Canonical reference |' docs/artifact-conventions.md`
      still finds the six-column header; the manifest/generic/at-every-depth
      wording, the `.gitkeep` rule, and the deferral sentence are present;
      `FRAMEWORK_TEST_AREAS='80-cycle-fixture,85-conflict-guards,87-backtrack-guards' bash tests/run.sh`
      exits 0.

- [ ] **T5** — In `docs/workflow.md`, make the two **minimal** restatements
      consistent with the schema, touching `## The work item directory` only.
      (a) Generalize the canonical-reference bullet (lines 135–138) from the
      two-level maximum to the recursive path and point to
      `docs/artifact-conventions.md` → "Work item references". (b) Add one
      sentence after the directory-layout block (lines 113–129) noting the
      layout repeats at every level — any node may hold a manifest and child
      directories, so nesting continues to arbitrary depth. Do not add a
      `### <digit>. ` heading and do not edit any other section (leave
      `## Roadmaps`, the readiness/conflict/backtrack/derived-state authorities,
      and the phase headings byte-for-byte). [AC2] [AC11] [depends: T1, T4]
      Verify: the canonical-reference bullet names the recursive path and defers
      to `docs/artifact-conventions.md`; the layout note is present;
      `FRAMEWORK_TEST_AREAS='10-readiness,20-lifecycle,80-cycle-fixture,85-conflict-guards,87-backtrack-guards,96-signature-sweep' bash tests/run.sh`
      exits 0.

- [ ] **T6** — Confirm the whole repository is green and scoped. Run the full
      committed suite, confirm no new agent/command/skill file exists, no
      documented inventory count changed, and the change set is only the two
      documentation files. [AC9] [AC10] [AC11] [depends: T1, T2, T3, T4, T5]
      Verify: `bash tests/run.sh` exits 0 with `TOTAL: <p> passed, 0 failed`;
      `40-inventory.sh` reports the documented counts equal to disk;
      `git diff --name-only` lists only `docs/artifact-conventions.md` and
      `docs/workflow.md`; `ls .opencode/agent .opencode/command .opencode/skill`
      shows no added file.
