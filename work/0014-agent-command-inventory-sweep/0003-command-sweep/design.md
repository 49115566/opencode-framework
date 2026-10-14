---
feature: 0014-agent-command-inventory-sweep/0003-command-sweep
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
conflicts-with: "—"
---

# Design — Command-surface recursive sweep

## Summary

Apply the parent manifest's fixed sweep vocabulary to eight command prompts under
`.opencode/command/` by editing prose only. Seven of them (`spec`, `plan`,
`build`, `test`, `review`, `ship`, `visual`) carry the retired two-level item-ref
boilerplate; each is replaced with one byte-identical canonical sentence that
mirrors the already-swept agent prompts. `status.md` is the substantive surface:
it is taught to detect a decomposing node by `manifest.md` (with the deprecated
`roadmap.md` spelling clearly labelled as the legacy alias), to derive the
container phase `manifest`, and to pair `stale: roadmap` with `stale: manifest`.
`spec.md` and `ship.md` each get one additional substantive correction. No
command's frontmatter, `Usage:` signature, `agent:` value, phase behavior, or
pinned-suite literal changes, and no source, test, `docs/**`, README, agent,
skill, or other command file is touched.

## Approach

This is a **prose-only vocabulary correction**, not a behavior change: there is no
runtime code, and the "implementation" is the wording of eight Markdown prompts.
The single source of truth is the shipped recursive authority the prompts must
reference rather than restate (`docs/workflow.md` → "The recursive lifecycle
model", "Where decomposition is authored and recorded", "Revising a
decomposition", "Dependencies and readiness", "Derived state", "Status
reporting"; `docs/artifact-conventions.md` → "Work item references" and the
`manifest.md` template). The design therefore fixes the exact target wording per
edit so no builder judgment remains.

The parent manifest fixes the shared mapping (its "Shared sweep vocabulary"): the
item-ref boilerplate → the canonical recursive form; container/target phase
`roadmap` → `manifest`; `work/<parent-ref>/roadmap.md` →
`work/<parent-ref>/manifest.md`; "roadmap graph" → the manifest's dependency
graph. A bare `roadmap` used as if current is swept; a **deliberately labelled
legacy-alias mention** of `roadmap.md` or `stale: roadmap` is sanctioned and
retained (spec AC7, AC8, Edge cases). This item consumes the wording already
settled by the shipped siblings `0001-lifecycle-agent-sweep` and
`0002-supporting-agent-sweep`, so no command diverges from its paired agent.

### Edits, by file

| File | Current | Target | AC |
| ---- | ------- | ------ | -- |
| `spec.md` | item-ref boilerplate (lines 13–15) | the canonical command sentence (below) | AC6, AC9, AC12 |
| `spec.md` | nested-child allocation step (lines 22–24) | canonical recursive reference form (below) | AC4 |
| `plan.md` | item-ref boilerplate (lines 26–28) | the canonical command sentence | AC6, AC9, AC12 |
| `plan.md` | line 32 `(or the legacy `roadmap.md` artifact alias)` | **retained unchanged** — the labelled legacy alias | AC7 |
| `build.md` | item-ref boilerplate (lines 12–14) | the canonical command sentence | AC6, AC9, AC12 |
| `test.md` | item-ref boilerplate (lines 11–13) | the canonical command sentence | AC6, AC9, AC12 |
| `review.md` | item-ref boilerplate (lines 11–13) | the canonical command sentence | AC6, AC9, AC12 |
| `ship.md` | item-ref boilerplate (lines 21–23) | the canonical command sentence | AC6, AC9, AC12 |
| `ship.md` | line 39 `re-check the roadmap dependency graph` | `re-check the manifest's dependency graph` | AC5 |
| `status.md` | decomposing-node detection + container phase (lines 15–20) | detect by `manifest.md` (+ labelled legacy `roadmap.md` alias); container phase `manifest` | AC1, AC2 |
| `status.md` | line 28 `Map a `stale: roadmap` token to `spec`` | pair `stale: manifest` and its labelled legacy alias `stale: roadmap` | AC3 |
| `visual.md` | item-ref boilerplate (lines 12–14) | the canonical command sentence | AC6, AC9, AC12 |

**Untouched:** `conflicts.md`, `fix.md`, `bootstrap.md`, and `doctor.md` carry no
retired vocabulary or item-ref boilerplate and are left byte-identical (AC10;
`doctor.md` is owned by `0005-inventory-and-doctor-sweep`). Every command's
frontmatter and `description:`/`Usage:` line is preserved (AC9).

## Alternatives considered

- **Option A — targeted per-occurrence prose edits, canonical sentence fixed once
  (chosen).** Pros: matches the spec's enumerated surfaces exactly; each edit is
  independently verifiable; the prompts keep citing the authority by name instead
  of restating it, so drift cannot silently return. Cons: several small edits
  across eight files. This is the only option that satisfies AC9's "prose only"
  and the non-goal "not restating or redefining the recursive authority".
- **Option B — rewrite each command's recursive section to restate the authority's
  reference grammar, derived-state table, and readiness algorithm inline.**
  Rejected: the spec's Non-goals forbid restating the model, and an inline
  restatement creates a second source of truth that can drift — the exact failure
  this sweep exists to remove. It would also risk the pinned authority literals.
- **Option C — extract the item-ref boilerplate into a shared include/partial so
  the seven commands share one string.** Rejected: opencode prompts have no
  include mechanism, introducing one is out of scope, and the parent manifest
  already fixes the wording so a literal single sentence across the seven files
  achieves the identical guarantee without a new abstraction.
- **Option D — edit only the substantive `status`/`spec`/`ship` corrections and
  leave the seven boilerplate copies for a later pass.** Rejected: AC6 requires the
  seven sentences to be byte-identical now, and the parent manifest scopes this
  child to the whole command family; deferring the boilerplate would leave the
  command/agent divergence the item exists to close.

## Interfaces and data model

There is no runtime interface and no data model to migrate: all eight surfaces are
static prose, and no schema, artifact, or config changes. The changeless
"interface" is the **exact target wording**, fixed here so no builder judgment
remains and so AC6's cross-command identity is checkable.

### The canonical command sentence (AC6)

Replaces, **byte-identically in all seven** of `spec.md`, `plan.md`, `build.md`,
`test.md`, `review.md`, `ship.md`, and `visual.md`, the retired three-line block

```
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
```

with the recursive form — content matching the canonical sentence the swept
lifecycle agents carry:

```
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item, or a
  nested `NNNN-slug/MMMM-slug` at any depth; a canonical reference per
  `docs/artifact-conventions.md` → "Work item references", resolving to the
  directory `work/<item-ref>/`.
```

The four lines and their wrapping are identical in every file, so the extracted
sentence is byte-identical across the seven (AC6). The sentence cites
`docs/artifact-conventions.md` → "Work item references", states the recursive form
(nested to arbitrary depth), resolves to `work/<item-ref>/`, and drops the
wording "roadmap child".

### `spec.md` nested-child allocation step (AC4)

The `<process>`-style bullet currently reads:

```
- Then write `work/<item-ref>/spec.md` using the `spec-writing` skill and the
  template in `docs/artifact-conventions.md`. For a standalone item, allocate the
  next `NNNN` and a kebab-case slug; for a roadmap child, use the supplied
  `NNNN-slug/MMMM-slug` reference.
```

Its second sentence becomes, in full:

```
  next `NNNN` and a kebab-case slug; for a nested child, use the supplied
  canonical reference (`NNNN-slug/MMMM-slug`, nesting to arbitrary depth per
  `docs/artifact-conventions.md` → "Work item references").
```

### `ship.md` reconcile re-check (AC5)

Line 39–40's `re-check the roadmap\n  dependency graph` becomes
`re-check the manifest's\n  dependency graph`; the surrounding reconcile and
"Renumbering after a parallel merge" semantics are unchanged.

### `status.md` decomposing-node detection and container phase (AC1, AC2)

Lines 15–20 currently read:

```
- Detect a **decomposing node** by the presence of `roadmap.md` — at any depth,
  a pure container or a hybrid that also carries its own artifacts; treat
  everything else as a single-feature item. Decide this before deriving any
  phase. A decomposing node derives its phase from its own phase artifacts
  first; only a manifest with no own phase artifacts derives the container phase
  `roadmap`.
```

and become:

```
- Detect a **decomposing node** by the presence of `manifest.md` (or the legacy
  `roadmap.md` alias) — at any depth, a pure container or a hybrid that also
  carries its own artifacts; treat everything else as a single-feature item.
  Decide this before deriving any phase. A decomposing node derives its phase
  from its own phase artifacts first; only a manifest with no own phase artifacts
  derives the container phase `manifest`.
```

The primary spelling is `manifest.md`; `roadmap.md` is named as the **legacy
alias**; the container phase is `manifest` and never `roadmap`.

### `status.md` legacy stale-token pairing (AC3)

Line 28's `Map a\n  `stale: roadmap` token to `spec`` becomes:

```
  `stale: manifest` token — or its retained legacy alias `stale: roadmap` — to
  `spec`
```

Both tokens map to `spec`; `stale: roadmap` is labelled the deprecated legacy
alias; no second mapping or derived label is introduced.

### Pinned literals that must survive (AC11)

The committed suite reads the live prompts (never `work/**`) and pins exact
command literals the sweep must not disturb:

- `tests/checks/80-cycle-fixture.sh` requires `command/status.md` to carry
  `a child in a cycle is never `ready``, `CYCLIC-DEP`, and
  `Report them without failing`.
- `tests/checks/10-readiness.sh` requires `command/status.md` to carry
  `Dependencies and readiness`.
- `tests/checks/85-conflict-guards.sh` requires `command/status.md` (and
  `conflicts.md`, `build.md`) to carry `## Declared-conflict check` /
  `TEXTUAL-CONFLICT` vocabulary.

All of these live on different lines from the two `status.md` edits above, so the
risk is a careless reflow near a pinned block, not the intended change.
`tests/checks/96-signature-sweep.sh` pins each command's `Usage:` signature
(lines 269–299) and its `description:` line; the sweep touches neither.

## Affected areas

- `.opencode/command/spec.md` — boilerplate (13–15) and allocation step (22–24).
- `.opencode/command/plan.md` — boilerplate (26–28) only; line 32 retained.
- `.opencode/command/build.md` — boilerplate (12–14) only.
- `.opencode/command/test.md` — boilerplate (11–13) only.
- `.opencode/command/review.md` — boilerplate (11–13) only.
- `.opencode/command/ship.md` — boilerplate (21–23) and reconcile re-check (39–40).
- `.opencode/command/status.md` — detection/phase (15–20) and stale token (28).
- `.opencode/command/visual.md` — boilerplate (12–14) only.
- `work/0014-agent-command-inventory-sweep/0003-command-sweep/design.md` and
  `tasks.md` — this item's own artifacts (AC10).

Read-only references (not edited): `docs/workflow.md`,
`docs/artifact-conventions.md`, the paired swept agent prompts under
`.opencode/agent/`, and the pinning checks
`tests/checks/{10-readiness,80-cycle-fixture,85-conflict-guards,96-signature-sweep}.sh`.

## Risks and mitigations

- **Dropping the retained `plan.md` legacy alias.** An over-eager boilerplate
  pass could remove or un-label line 32. *Likelihood:* low / *Impact:* medium
  (fails AC7 and the "no migration" edge case). *Mitigation:* T1 edits only the
  boilerplate block and T6 greps `plan.md` for the labelled `roadmap.md` alias.
- **Breaking a pinned `status.md` literal.** Rewording near lines 45 or 52 could
  drop a suite-pinned phrase. *Likelihood:* medium / *Impact:* high (red suite
  blocks merge). *Mitigation:* the edits are confined to lines 15–20 and 28; T7
  runs `bash tests/run.sh` and greps the four pinned literals directly.
- **Canonical sentence divergence across the seven commands.** Hand-editing each
  copy could introduce whitespace drift. *Likelihood:* medium / *Impact:* medium
  (fails AC6). *Mitigation:* T1 inserts the identical four-line block and its
  `Verify:` extracts and diffs the block across all seven files.
- **Frontmatter or `Usage:`/`agent:` drift.** An incidental reflow could change a
  protected line. *Likelihood:* low / *Impact:* high (fails AC9 and
  `96-signature-sweep.sh`). *Mitigation:* T7 inspects `git diff` and confirms
  changes fall outside every frontmatter block.
- **Scope creep into a sibling's surface.** The temptation to also fix the same
  boilerplate in agents/skills, or to sweep `doctor.md`, is real. *Likelihood:*
  medium / *Impact:* high (collides with `0001`/`0004`/`0005`). *Mitigation:* the
  changeset allowlist is exactly the eight commands; T6 runs
  `git diff --name-only` and fails if any other path appears.
- **Definition drift — a command becomes a second authority.** Paraphrasing the
  model rather than citing it would re-create drift. *Likelihood:* low / *Impact:*
  medium. *Mitigation:* every edit cites the authority by name and restates no
  algorithm; T6 audits the remaining `roadmap` tokens (AC8, AC12).

## Test strategy

No new committed test is added: the spec's Non-goals forbid new fixtures/guards
(Roadmap 5) and AC10 forbids touching `tests/`. Verification is static inspection
of the live prompts plus the existing committed suite.

| Acceptance criterion | Verification level | Where |
| -------------------- | ------------------ | ----- |
| AC1 | static | T3 greps `status.md` for `manifest.md` detection and the labelled alias |
| AC2 | static | T3 greps container phase `manifest` and the absence of a `roadmap` container phase |
| AC3 | static | T4 greps the paired `stale: manifest`/`stale: roadmap` → `spec` rendering |
| AC4 | static | T2 greps the canonical reference clause and the absence of "for a roadmap child" |
| AC5 | static | T5 greps `manifest's dependency graph` and the absence of "roadmap dependency graph" |
| AC6 | static | T1 extracts the four-line block from all seven commands and confirms byte-identity |
| AC7 | static | T1/T6 grep `plan.md` for the retained labelled `roadmap.md` alias |
| AC8 | static | T6 audits every remaining `roadmap` token in the eight commands |
| AC9 | diff inspection | T7 checks frontmatter and `Usage:` lines are unchanged in `git diff` |
| AC10 | diff inspection | T6 checks `git diff --name-only` is exactly the eight commands plus `design.md`/`tasks.md` |
| AC11 | integration | T7 runs `bash tests/run.sh`, greps the pinned literals, and confirms 13/12/11 |
| AC12 | static | T1/T3/T4 review citations; T6 confirms no new phase value, finding code, or grammar |

No criterion is manual-only; every one is a grep, a diff inspection, or the
committed suite.
