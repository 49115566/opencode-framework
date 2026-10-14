---
feature: 0014-agent-command-inventory-sweep/0004-skill-sweep
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
conflicts-with: "—"
---

# Design — Skill-surface recursive sweep

## Summary

Make three skill prompts (`merge-conflict`, `workflow-lifecycle`,
`conventional-commits`) describe the recursive model the authority already
documents, by in-place prose edits that rename the remaining bare `roadmap`
terms to manifest terms and fix one substantive instruction: the merge-conflict
graph re-check must cover **every decomposing node's manifest at any depth**
instead of only `roadmap.md`. Every canonical finding code, class, grammar, and
routing surface is preserved byte-for-byte; the diff is text-only and confined to
the three named `SKILL.md` files.

## Approach

Three independent, surgical edits, each referencing the shipped authority rather
than restating it:

1. **`merge-conflict/SKILL.md` — vocabulary + substantive bug.** Rename the
   pre-flight heading "Roadmap graph faults" and the bare `roadmap` terms in the
   pre-flight finding-vocabulary table, the planning-time `DRIFT-FACT` bullet, and
   the reconcile prose to manifest terms. Fix the graph re-check at `:349` from
   "In every `roadmap.md`" to every decomposing node's manifest — its
   `manifest.md` **or** the clearly-labelled legacy `roadmap.md` alias — at any
   depth, so a node using the current spelling is no longer silently skipped. Keep
   the sanctioned legacy-alias mention at `:81` and every finding code/class and
   the finding-line grammar unchanged, so the merge-integrity guard's vocabulary
   stays identical to `docs/workflow.md`.
2. **`workflow-lifecycle/SKILL.md` — depth.** Generalize the decomposing-node
   definition (`:22-28`) so a node and its descendants nest to arbitrary depth and
   a child may itself decompose, while retaining the clearly-labelled legacy
   `roadmap.md` alias and the `stale: roadmap` equivalent (`:23`, `:91`). The
   `## Which command now?` routing block is left byte-identical for
   `tests/checks/96-signature-sweep.sh`.
3. **`conventional-commits/SKILL.md` — illustrative example.** Replace the retired
   `0002-agentic-roadmaps/0001-roadmap-model` illustration (table row, examples,
   and the superseded `-` form) with the neutral `0002-billing/0001-invoice-model`
   used consistently by the authority's own examples (`docs/workflow.md:146`,
   `docs/artifact-conventions.md:98`), preserving the flatten round-trip and the
   non-injectivity argument.

The retired-to-current vocabulary mapping (fixed by the parent manifest) is
applied: "roadmap graph"/"roadmap `Children`" → the manifest's dependency graph /
the `Children` table; a bare `roadmap child` → a decomposing child. A
clearly-labelled legacy `roadmap.md` / `stale: roadmap` alias is retained.

## Alternatives considered

- **Full rewrite of the three skills to restate the recursive authority.** Pros:
  one consistent voice. Cons: directly contradicts the spec's non-goal that the
  authority is referenced, never restated; restating a shipped contract in three
  more places re-creates the drift this sweep removes; and it would churn already
  correct text and risk disturbing the fixture-pinned routing block. **Rejected.**
- **Fix only the substantive `:349` instruction; leave the vocabulary.** Pros:
  smallest diff. Cons: AC1–AC4, AC7, AC10, and the goal of teaching one model
  consistently are unmet; adopters would still be taught retired terms.
  **Rejected.**
- **Delete all legacy `roadmap.md` / `stale: roadmap` mentions.** Pros: no
  `roadmap` substring survives. Cons: directly contradicts the recorded user
  decision (retain clearly-labelled alias) and the spec's non-goal; removes the
  backward-compatibility documentation the authority deliberately preserves.
  **Rejected.**

## Interfaces and data model

No code, schema, or API changes: the deliverables are text edits to three
Markdown prompts. The exact string transitions are:

| File | Location | From | To |
| ---- | -------- | ---- | -- |
| `merge-conflict/SKILL.md` | `:80` heading | `**Roadmap graph faults.**` | `**Manifest graph faults.**` (resolving each `Depends on` in the node's own `Children` table against its manifest) |
| `merge-conflict/SKILL.md` | `:81` | legacy `roadmap.md` alias clause | **retained** (clearly labelled) |
| `merge-conflict/SKILL.md` | `:121` `DANGLING-DEP` | "a roadmap `Depends on`" | "a manifest `Depends on`" |
| `merge-conflict/SKILL.md` | `:124` `CYCLIC-DEP` | "a cycle in a roadmap dependency graph" | "a cycle in a manifest dependency graph" |
| `merge-conflict/SKILL.md` | `:141` planning-time `DRIFT-FACT` | "a roadmap child's own `design.md` declaration" | "a decomposing child's own `design.md` declaration" |
| `merge-conflict/SKILL.md` | `:221` | "re-checks the roadmap dependency graph" | "re-checks the manifest dependency graph" |
| `merge-conflict/SKILL.md` | `:258` class (b) | "roadmap `Children` / `Depends on` tables" | "manifest `Children` / `Depends on` tables" |
| `merge-conflict/SKILL.md` | `:333` | "**Roadmap `Children` rows**" | "**Manifest `Children` rows**" |
| `merge-conflict/SKILL.md` | `:349` graph re-check | "In every `roadmap.md`, each `Depends on` ..." | every decomposing node's manifest (`manifest.md`, or the clearly-labelled legacy `roadmap.md` alias) at any depth |
| `workflow-lifecycle/SKILL.md` | `:22-28` | two-level `NNNN-slug` + `<MMMM-slug>` shape | arbitrary-depth nesting; a child may itself decompose; legacy alias retained |
| `workflow-lifecycle/SKILL.md` | `:32-56` routing block | — | **unchanged** (fixture-pinned) |
| `conventional-commits/SKILL.md` | `:80,84-85,89` | `0002-agentic-roadmaps/0001-roadmap-model` (+ flat / superseded forms) | `0002-billing/0001-invoice-model` (+ `0002-billing+0001-invoice-model`, `0002-billing-0001-invoice-model`) |

**Backward compatibility:** none affected. The legacy `roadmap.md` /
`stale: roadmap` alias handling is retained and clearly labelled (AC8, AC11); no
skill is renamed, added, or retired, and no frontmatter `name`/`description`
changes, so the inventory stays 11 skills.

## Affected areas

- `.opencode/skill/merge-conflict/SKILL.md` — pre-flight heading and
  finding-vocabulary rows, planning-time `DRIFT-FACT` bullet, reconcile-procedure
  prose, and the graph re-check instruction.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — the decomposing-node
  definition paragraph only.
- `.opencode/skill/conventional-commits/SKILL.md` — the `flatten(ref)`
  illustrative table row, examples, and superseded-form note.
- No other file changes. `.opencode/agent/status.md` is the shared-vocabulary
  counterpart (`merge-conflict/SKILL.md:116` says the `status` agent repeats the
  vocabulary) but is owned by the sibling `0002-supporting-agent-sweep` and is
  **not** edited here; the swept wording stays phrased to the authority so the
  sibling can align it without divergence.

## Risks and mitigations

- **A committed fixture pin breaks.** Several live checks pin literals in these
  files: `tests/checks/85-conflict-guards.sh:626-633` (the finding-line grammar,
  the word `planning-time`, and the absence of any `(e)`/`DECLARED-`/`PLAN-`/
  `CONFLICT-` prefix), `tests/checks/88-renumber-sweep.sh:77-97` (the step-3
  rewrite-reference bullets), `tests/checks/20-lifecycle.sh` and
  `tests/checks/25-review-severity-bar.sh` and `tests/checks/10-readiness.sh`
  (workflow-lifecycle routing and derived-state phrasing), and
  `tests/checks/96-signature-sweep.sh` (the routing fenced block). Likelihood:
  medium / impact: high. Mitigation: edit only the enumerated lines; keep every
  pinned literal verbatim; run `bash tests/run.sh` after each edit and fix
  immediately.
- **The graph re-check re-introduces the skip bug or drops the alias.**
  Likelihood: medium / impact: high. Mitigation: the new phrasing explicitly
  names both the `manifest.md` spelling and the clearly-labelled legacy
  `roadmap.md` alias **and** "at any depth"; verify no bare "In every
  `roadmap.md`" remains by grep.
- **The depth prose disturbs the routing block extraction.** `96-signature-sweep`
  extracts routes from the fenced block after `## Which command now?`; the
  pre-flight decomposition is edited, so the block must stay identical.
  Likelihood: low / impact: high. Mitigation: touch only the paragraph above the
  heading; confirm `git diff` shows no change inside the fenced block; run the
  `96-signature-sweep` area.
- **The replacement example collides with a real item or breaks the round-trip
  illustration.** Likelihood: low / impact: medium. Mitigation: `0002-billing` is
  the authority's own illustrative slug and no `work/0002-billing/` exists; the
  flatten and superseded `-` forms stay internally consistent with the same
  example; verify the round-trip and the no-directory check.
- **A residual bare `roadmap` term is missed.** Likelihood: medium / impact:
  medium. Mitigation: a case-insensitive grep over the three files classifies
  every remaining hit as a clearly-labelled legacy-alias/equivalent mention or an
  in-scope term to fix (AC12).
- **Scope creep into neighbouring surfaces.** `CONTRIBUTING.md:77` also carries
  the retired illustration, and finding one tempts edits outside the spec.
  Likelihood: low / impact: high. Mitigation: AC14 restricts the change set to
  the three files; verify with `git diff --name-only`. `CONTRIBUTING.md` is
  recorded as an out-of-scope follow-up (see below).

## Test strategy

The suite is static/read-only and never reads `work/**`; the swept skill files
are read by the live-surface checks, so the change is verified by those checks
plus targeted greps.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1, AC2 | static: grep `merge-conflict/SKILL.md` for the new heading/row terms + `85-conflict-guards` |
| AC3 | static: grep for the reworded planning-time `DRIFT-FACT` bullet |
| AC4 | static: grep the three reconcile-procedure phrases |
| AC5 | static: grep — no bare "In every `roadmap.md`"; both spellings + "any depth" present |
| AC6 | static: `docs/workflow.md` census vs `merge-conflict/SKILL.md`; `85-conflict-guards`, `88-renumber-sweep` green |
| AC7 | static: grep "arbitrary depth" / "may itself decompose" |
| AC8 | static: grep the labelled legacy alias and `stale: roadmap` equivalent |
| AC9 | static + fixture: `96-signature-sweep` green; routing block unmodified in the diff |
| AC10 | static: grep no `roadmap` in the file; flatten/unflatten round-trip; `work/0002-billing/` absent |
| AC11, AC12 | static: case-insensitive `roadmap` census over the three files |
| AC13 | integration: `bash tests/run.sh` exits 0 |
| AC14 | diff: `git diff --name-only` reports only the three `SKILL.md` files (plus this item's `work/`) |

## Follow-ups (out of scope)

- `.opencode/agent/status.md` repeats the merge-conflict finding vocabulary
  (`merge-conflict/SKILL.md:116`) and is aligned by the sibling
  `0014-agent-command-inventory-sweep/0002-supporting-agent-sweep`, not here.
- `CONTRIBUTING.md:77` carries the same retired illustrative reference
  (`feat/0002-agentic-roadmaps+0001-roadmap-model`) outside this spec's file
  scope. This design does not edit it; the user may want to extend scope or
  route it to a later item.
