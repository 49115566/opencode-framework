---
feature: 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
conflicts-with: "—"
---

# Design — Lifecycle-agent recursive sweep

## Summary

Apply one fixed, canonical item-ref sentence to the `<inputs>` list of all six
lifecycle agent prompts, and make the minimal term replacement that removes the
retired two-level vocabulary from the two prompts that still teach it —
`product.md` (parent "roadmap" → parent **manifest**, `/roadmap revise` →
`/plan`, target phase `roadmap` → `manifest`) and `shipper.md` ("roadmap graph"
/ "roadmap `Children`" → manifest dependency graph / `Children` table) — while
adding decomposing/hybrid coverage to `tester.md` and `reviewer.md`. The change
is prose-only: frontmatter, permission blocks, handoff blocks, and phase behavior
are untouched (AC7), and no recursive statement introduces new vocabulary or
grammar (AC9).

## Resolution of the spec's deferred open question

The spec defers to design the *exact text* of the canonical item-ref sentence
(spec → "Open questions", third item). This design fixes it. **The canonical
sentence is, verbatim and on one unwrapped line:**

```
`NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at any depth; a canonical reference per `docs/artifact-conventions.md` → "Work item references", resolving to the directory `work/<item-ref>/`.
```

Rules for its use, which make AC4's "byte-identical" requirement mechanical:

- It is exactly that character sequence — one sentence, one unwrapped line,
  terminated by its own `.` — and nothing else. It is never re-wrapped, and no
  file inserts an internal newline into it.
- In the five lifecycle prompts whose inputs already read "The item reference in
  `$ARGUMENTS`: …" (`product`, `architect`, `builder`, `tester`, `reviewer`) the
  sentence follows that colon, replacing the current
  "`NNNN-slug` for a standalone item, or `NNNN-slug/MMMM-slug` for a roadmap
  child; resolve it to the directory `work/<item-ref>/`.".
- In `shipper.md`, whose input is a bullet ("a work-item reference
  (`item-ref`) — … — resolves to the directory …; read …"), the sentence is
  inserted verbatim and made free-standing, and the trailing "read
  `work/<item-ref>/spec.md`, `tasks.md`, `verify.md`, and `review.md`." becomes a
  new sentence beginning after the canonical sentence's `.`.
- It cites `docs/artifact-conventions.md` → "Work item references" by name, so
  the boilerplate is itself a recursive-model statement that satisfies AC9.

This resolves the open question; `0003-command-sweep` mirrors the same sentence,
so it is the single coordination point noted under "Risks".

## Approach

The recursive authority is already shipped (`docs/workflow.md` → "The recursive
lifecycle model", "Where decomposition is authored and recorded", "Revising a
decomposition", "Dependencies and readiness"; `docs/artifact-conventions.md` →
"Work item references", "`manifest.md` — the manifest of a decomposing node").
This sweep does not re-derive it: every edit either (a) replaces a retired term
with the shipped term the parent manifest's "Shared sweep vocabulary" fixed, or
(b) replaces the item-ref boilerplate with the fixed canonical sentence. No file
restates an authority algorithm; each cites the section by name.

Per-file edit map (exact current → target prose; line numbers are the pre-sweep
recon and are advisory):

**`product.md`** — the substantive one; 9 `roadmap` tokens, all retired:

1. `<inputs>` item 5 — replace the boilerplate with the canonical sentence (AC4).
2. `<process>` step 6 — `nested roadmap child` → `nested child`; its parent
   `work/<NNNN-slug>/roadmap.md` → `work/<NNNN-slug>/manifest.md`, citing
   `docs/artifact-conventions.md` → "`manifest.md` — the manifest of a
   decomposing node"; the readiness check and explicit-override behavior are
   preserved word-for-word (AC2).
3. `<process>` step 7 — `use the supplied `NNNN-slug/MMMM-slug` for a roadmap
   child` → `… for a nested child` (AC6).
4. `<rules>` parent-node rule — `parent roadmap` → `parent's manifest`;
   `/roadmap revise <parent-ref>` → `/plan <parent-ref>`; target phase
   `roadmap` → `manifest`; affected `work/<parent-ref>/roadmap.md` →
   `work/<parent-ref>/manifest.md`; "Revising a roadmap" → "Revising a
   decomposition"; "only the roadmap owner writes it" → "only the planning step
   (its owner) writes it" (AC1, AC9). `product.md` has **no** sanctioned legacy
   alias, so it ends with zero `roadmap` tokens.

**`shipper.md`** — 4 `roadmap` tokens:

1. `<inputs>` bullet 1 — canonical sentence (restructured as above) (AC4).
2. `<preconditions>` work-item bullet — "a `work/` sequence collision or a
   roadmap graph fault" → "… or a manifest dependency-graph fault", citing
   `docs/workflow.md` → "Dependencies and readiness" (AC3, AC9).
3. `<process>` work-item step 2 — "re-check every roadmap graph so each
   `Depends on` local id resolves and the stored graph is acyclic" → "re-check
   every manifest's dependency graph …"; semantics unchanged (AC3).
4. `<rules>` renumber bullet — "the roadmap `Children` `Local id` and `Canonical
   reference` cells" → "the manifest `Children` `Local id` and `Canonical
   reference` cells" (AC3). The plan-publication and recall modes that already
   name `manifest.md` are left untouched.

**`architect.md`** — 2 tokens: item 5 boilerplate → canonical sentence (AC4);
the existing labelled legacy alias at `<process>` step 3
(`… (or the legacy `roadmap.md` artifact alias)`) is **kept verbatim** — it is
the spec's single intentional AC6 exception.

**`builder.md`** — 1 token: item 4 boilerplate → canonical sentence (AC4). Its
existing decomposing/hybrid handling in item 1 is already correct and untouched.

**`tester.md`** — boilerplate → canonical sentence (AC4), plus a new final
`<inputs>` item addressing a decomposing node's `manifest.md`, its nested
children by canonical reference, and a hybrid node's own deliverable (AC5),
citing "Work item references".

**`reviewer.md`** — boilerplate → canonical sentence (AC4), plus the same style
of new final `<inputs>` item (AC5).

The sweep is exhaustive over the six files: after the edit, the token `roadmap`
appears exactly once in the six prompts — `architect.md`'s labelled legacy alias
(AC6).

## Alternatives considered

- **Wholesale regeneration of the six `<inputs>`/`<process>` sections from the
  authority** — rewrites each prompt in the wholly recursive vocabulary rather
  than patching the stale terms. Rejected: it inflates the diff, makes AC7's
  byte-identity of `description`/`mode`/`permission` and the handoff block hard
  to prove, risks silent behavior change in phase steps that are currently
  correct, and violates the spec's prose-only, minimal-change constraint
  (spec → Goals).
- **A shared recursive boilerplate block included by all six prompts** —
  introduce one canonical text artefact and reference it. Rejected: opencode
  agent prompts are single self-contained files with no include mechanism;
  adding one is a new surface and a new abstraction outside this child's scope
  (and outside the parent's "no new surfaces" assumption).
- **Chosen approach** — one fixed canonical sentence plus targeted term
  replacement. Pros: minimal, reviewable, provably prose-only, and the
  canonical sentence becomes the single artifact `0003` mirrors. Cons: the
  sentence's exact bytes must be replicated by hand in six files (mitigated by
  making it a single unwrapped line and by the cross-check task).

## Interfaces and data model

This is a prompt-and-documentation sweep; there is no runtime interface, schema,
or migration. The concrete contracts are:

- **Canonical item-ref sentence** — the fixed one-line string above; it is the
  only new shared text and the coordination point with `0003-command-sweep`.
- **Prose-only invariant** — for each of the six files, the YAML frontmatter
  (`description`, `mode`, `permission`), and the `<handoff> … </handoff>` block's
  commands and structure, are byte-identical pre- and post-sweep (AC7). The
  `<handoff>` *body prose* may change only if it contains a retired term; recon
  shows none of the six handoff blocks contains `roadmap`, so they are unchanged.
- **Declared recursive-model statements cite their authority** — the canonical
  sentence cites "Work item references"; `product.md` step 6 cites the manifest
  template and "Dependencies and readiness"; the `product.md` rule cites "Phase
  reversal (backtracking)" and "Revising a decomposition"; `shipper.md`'s
  dependency-graph mention cites "Dependencies and readiness"; no statement
  introduces a new `phase` value, finding code, or reference grammar (AC9).
- **No inventory change** — no agent is added, renamed, removed, or
  re-frontmattered, so the documented inventory remains 13 agents / 12 commands
  / 11 skills (AC8).

**Backward compatibility / migrations.** None required. The prompts are shared
verbatim with adopters from the single `.opencode/agent/` source; the sweep only
removes retired vocabulary that the shipped authority already superseded, and it
deliberately preserves the one labelled legacy `roadmap.md` alias for readers of
historical `work/` content. No committed `work/` item, fixture, or test is read
or rewritten.

## Affected areas

- `.opencode/agent/product.md` — boilerplate, step 6, step 7, parent-node rule.
- `.opencode/agent/shipper.md` — boilerplate, precondition, reconcile step,
  renumber rule.
- `.opencode/agent/architect.md` — boilerplate only (legacy alias preserved).
- `.opencode/agent/builder.md` — boilerplate only.
- `.opencode/agent/tester.md` — boilerplate + `manifest.md`/nested-child/hybrid
  input coverage.
- `.opencode/agent/reviewer.md` — boilerplate + `manifest.md`/nested-child/hybrid
  input coverage.

Read-only references (never edited): `docs/workflow.md`,
`docs/artifact-conventions.md`, `work/0014-agent-command-inventory-sweep/manifest.md`.

## Risks and mitigations

- **Canonical-sentence drift.** The six insertions must be byte-identical, and
  `0003-command-sweep` mirrors the same sentence — any divergence fails AC4 and
  re-opens `0003`. Likelihood: medium. Impact: high. Mitigation: fix the exact
  one-line string here, forbid internal line breaks, and have the cross-check
  task extract and compare the sentence from all six files.
- **Over- or under-sweeping the `roadmap` token.** Removing the sanctioned
  labelled legacy alias in `architect.md`, or leaving a bare/current `roadmap`
  in `product.md`/`shipper.md`, fails AC6. Likelihood: medium. Impact: medium.
  Mitigation: pin the alias in the architect task and verify via one consolidated
  `grep -rn roadmap` over the six files (exactly one hit, labelled `legacy`).
- **Prose-only invariant broken.** Editing frontmatter, mode, permissions, or the
  handoff block would fail AC7 and could trip `30-permissions.sh` /
  `60-default-agent.sh`. Likelihood: low. Impact: high. Mitigation: the
  cross-check task diffs exactly the frontmatter region and the handoff block,
  and the suite is run.
- **Regressing `shipper.md`'s already-correct `manifest.md` wording** in its
  plan-publication and recall modes. Likelihood: low. Impact: medium.
  Mitigation: the shipper task touches only the four named stale spots; the
  cross-check verifies the plan/recall wording is unchanged.
- **Suite / inventory drift.** A stray frontmatter edit or a new file would
  break the inventory or signature checks. Likelihood: low. Impact: medium.
  Mitigation: no new surfaces and no frontmatter change; run `bash tests/run.sh`
  and confirm 13/12/11.

## Test strategy

There is no committed fixture for an agent-prompt sweep — fixture-based
recursive guards are the parent's Roadmap 5 and are explicitly out of scope
(spec → Non-goals). Per the spec's "Dependencies and constraints", AC1–AC7 and
AC9 are verified by inspection of the swept prompts and AC8 by the suite. Each
criterion maps to one verification level below.

| Criterion | Verification level | Observation |
| --------- | ------------------ | ----------- |
| AC1 | inspection (grep `product.md`) | text names the parent `work/<parent-ref>/manifest.md`, target phase `manifest`, `/plan <parent-ref>`, "Revising a decomposition"; no `parent roadmap`, `/roadmap revise`, `roadmap` phase, or live `roadmap.md` path |
| AC2 | inspection (grep `product.md` step 6) | resolves the parent's `work/<NNNN-slug>/manifest.md`; readiness check and override sentence preserved |
| AC3 | inspection (grep `shipper.md`) | "manifest dependency-graph" and "manifest `Children`"; plan/recall `manifest.md` wording unchanged |
| AC4 | inspection (extract + byte-compare) | the canonical sentence is present exactly once in each of the six inputs and the six are byte-identical; no "roadmap child" |
| AC5 | inspection (grep `tester.md`, `reviewer.md`) | each names `manifest.md`, nested children by canonical reference, and a hybrid node |
| AC6 | inspection (consolidated grep) | exactly one `roadmap` token across the six files, and it is `architect.md`'s labelled legacy alias |
| AC7 | inspection (`git diff`) | frontmatter `description`/`mode`/`permission` and the `<handoff>` block unchanged in all six files |
| AC8 | suite (`bash tests/run.sh`) | exits `0`; documented inventory remains 13 agents / 12 commands / 11 skills |
| AC9 | inspection (grep authority names) | every recursive-model statement cites an authority section; no new `phase` value, finding code, or reference grammar |
