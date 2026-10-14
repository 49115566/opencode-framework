---
feature: 0014-agent-command-inventory-sweep/0002-supporting-agent-sweep
phase: design
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
conflicts-with: "—"
---

# Design — Supporting-agent recursive sweep

## Summary

Apply the parent manifest's fixed sweep vocabulary to exactly three supporting
agent prompts — `.opencode/agent/status.md` (the substantive surface),
`.opencode/agent/visual.md`, and `.opencode/agent/scribe.md` — by editing prose
only. `status.md` learns to detect a decomposing node and derive its container
phase from the **manifest** (`manifest.md`, with the deprecated `roadmap.md`
spelling clearly labelled as the legacy alias), to pair `stale: roadmap` with
`stale: manifest`, and to render its tree with `manifest` vocabulary; `visual.md`
and `scribe.md` state the canonical recursive reference form instead of the
retired two-level "roadmap child" boilerplate. No prompt's frontmatter, permission
block, handoff block, phase behavior, or pinned suite phrase changes, and no
source, test, `docs/**`, README, other-agent, command, or skill file is touched.

## Approach

This is a **prose-only vocabulary correction**, not a behavior change. There is
no runtime code: the "implementation" is the wording of three Markdown prompts,
and the single source of truth is the shipped recursive authority that the
prompts must reference rather than restate (`docs/workflow.md` → "The recursive
lifecycle model", "Where decomposition is authored and recorded", "Dependencies
and readiness", "Derived state", "Status reporting"; `docs/artifact-conventions.md`
→ "Work item references" and the `manifest.md` template). The design therefore
fixes the exact target wording per edit and pins a scope allowlist, so no builder
decision remains.

The parent manifest fixes the shared mapping (its "Shared sweep vocabulary"):
container/target phase `roadmap` → `manifest`; `work/<parent-ref>/roadmap.md` →
`work/<parent-ref>/manifest.md`; the item-ref boilerplate → the canonical
recursive form; "roadmap child" → "nested child". A bare `roadmap` used as if
current is swept; a **deliberately labelled legacy-alias mention** of `roadmap.md`
or `stale: roadmap` is sanctioned and retained (spec Edge cases "Legacy item still
reportable", AC3, AC12).

### Edits, by file

**`.opencode/agent/status.md`** — the only substantive file. Every `roadmap`
occurrence in the spec's line set (`status.md:48,53-54,58,90,104,120,128,244,265,
296-313,327,337,340`) is mapped:

| Lines | Current | Target | AC |
| ----- | ------- | ------ | -- |
| 48–51 | detect a decomposing node by `roadmap.md` | detect by `manifest.md`, with `roadmap.md` named as the recognized deprecated alias | AC1 |
| 53–55 | manifest (`roadmap.md`); container phase `roadmap` | manifest (`manifest.md`, or the legacy `roadmap.md` alias); container phase `manifest` | AC1, AC2 |
| 58 | readiness value written into `roadmap.md` | `manifest.md` | AC1 |
| 90–93 | the `roadmap.md` template | the `manifest.md` template (legacy `roadmap.md` alias labelled) | AC4 |
| 104–105 | decomposing node if `roadmap.md` exists | if `manifest.md` (or the legacy `roadmap.md` alias) exists | AC1 |
| 119–120 | Map a `stale: roadmap` token to `spec` | Map both `stale: manifest` and the retained legacy `stale: roadmap` to `spec` | AC3 |
| 128 | read its manifest (`roadmap.md`) | read its manifest (`manifest.md`, or the legacy `roadmap.md` alias) | AC1 |
| 244–246 | a roadmap child's own `design.md` declaration | a nested child's own `design.md` declaration | AC5 |
| 265–266 | only a manifest … derives `roadmap` | derives `manifest` | AC2 |
| 296–297 | example phase column `roadmap` | `manifest` (identifiers unchanged) | AC7 |
| 307–308 | `Roadmap <ref>:` summary lines, `phases: roadmap 1` | `Manifest <ref>:` and `phases: manifest 1` (identifiers unchanged) | AC7 |
| 327 | base phases list ends `roadmap` | ends `manifest` | AC6 |
| 337–339 | decomposing nodes (`roadmap.md` present) | (`manifest.md`, or the legacy `roadmap.md` alias present) | AC1 |
| 340 | readiness value into `roadmap.md` | `manifest.md` | AC1 |

**`.opencode/agent/visual.md`** — line 58–60, the item-ref input, only (AC8).
**`.opencode/agent/scribe.md`** — line 43, the target-path step, only (AC9).

**Untouched:** `.opencode/agent/scout.md`, `.opencode/agent/ask.md`,
`.opencode/agent/bootstrap.md` carry no work-item or `roadmap` vocabulary and are
not edited (AC10). The paired `/status` command, the `docs/**` authority, the
tests, README, and every other agent are out of scope (AC13; the command and
`docs/customization.md`/`doctor`/count are siblings `0003` and `0005`).

### The pinned phrases must survive

The committed suite reads the live prompts (never `work/**`) and pins exact
`status.md` literals that the sweep must not disturb (AC14):
`tests/checks/80-cycle-fixture.sh` requires `A child in a cycle is never
\`ready\``, `CYCLIC-DEP`, `informational and never fatal`, and (flattened)
`members of a cycle are never reported`; `tests/checks/10-readiness.sh` requires
`Dependencies and readiness`; `tests/checks/85-conflict-guards.sh` requires
`## Declared-conflict check`. All live in blocks the sweep leaves alone (the
`<readiness>`, `<findings>`, and `<rules>` sections). The sweep edits the
`<operating_principles>`, `<inputs>`, `<process>`, `<quality_bar>`, and
`<output_format>` sections around them, so the risk is a careless reflow near a
pinned block, not the intended edits.

## Alternatives considered

- **Option A — targeted per-occurrence prose edits in the three prompts
  (chosen).** Pros: matches the spec's enumerated line set exactly; each edit is
  independently verifiable; the prompts keep referencing the authority by name
  instead of restating it, so drift cannot return silently. Cons: several small
  edits in one file. This is the only option that satisfies AC11's "prose only"
  and the non-goal "not restating or redefining the recursive authority".
- **Option B — rewrite each prompt's recursive section wholesale to restate the
  authority's grammar, readiness algorithm, and derived-state table inline.**
  Rejected: the spec's Non-goals forbid restating or redefining the model, and a
  restatement would create a second source of truth that can drift — the exact
  failure this sweep exists to remove. It would also jeopardize AC14, because the
  authority's own wording is pinned in `docs/workflow.md`, not the prompts.
- **Option C — edit only `status.md` and defer `visual.md`/`scribe.md`.** Rejected:
  AC8 and AC9 require those two edits, and the parent manifest scopes the child to
  the whole supporting-agent family including the item-ref boilerplate.
- **Option D — extract the canonical-reference boilerplate into a shared
  include/partial so the three prompts (and the commands) share one string.**
  Rejected: opencode prompts have no include mechanism, introducing one is out of
  scope, and the parent manifest already fixes the wording so the sibling
  `0003-command-sweep` consumes it consistently without a shared file.

## Interfaces and data model

There is no runtime interface and no data model to migrate: all three surfaces are
static prose, and no schema, artifact, or config changes. The changeless
"interface" is the **exact target wording**, fixed here so `0003-command-sweep`
can consume it identically and so no builder judgment remains.

### Canonical recursive reference form (for `visual.md` and `scribe.md`)

Replaces the retired boilerplate `` `NNNN-slug` for a standalone item, or
`NNNN-slug/MMMM-slug` for a roadmap child `` with the recursive form — the item's
canonical reference — stated once and identically:

> `NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at any
> depth, per `docs/artifact-conventions.md` → "Work item references".

`visual.md` `<inputs>` item 5 becomes, in full:

> The item reference in `$ARGUMENTS` is the item's **canonical reference**:
> `NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at any
> depth, per `docs/artifact-conventions.md` → "Work item references"; resolve it
> to the directory `work/<item-ref>/`.

`scribe.md` `<process>` step 1 becomes, in full:

> Identify the target path (`work/<item-ref>/<file>`) and the artifact phase. The
> `item-ref` is the item's canonical reference — `NNNN-slug` for a standalone
> item, or a nested `NNNN-slug/MMMM-slug` at any depth, per
> `docs/artifact-conventions.md` → "Work item references".

### Legacy-alias label (for `status.md`)

Wherever the sweep retains a `roadmap.md` or `stale: roadmap` occurrence, it is
immediately qualified. The exact qualifier: `` `roadmap.md` is the recognized
deprecated alias `` (or "the legacy `roadmap.md` alias"), and for the stale token
"both `stale: manifest` and its retained legacy alias `stale: roadmap` map to
`spec`". This introduces no second mapping and no new derived label (spec Edge
case "Mixed stale tokens").

### Preserved blocks (AC11)

`status.md` frontmatter (lines 1–16, including the `permission` block) and
`<handoff>` block (lines 359–366); `visual.md` frontmatter (1–18) and `<handoff>`
(133–140); `scribe.md` frontmatter (1–10) and `<rules>` (50–56) are byte-for-byte
unchanged. `scribe.md` has no `<handoff>` block; none is added.

## Affected areas

- `.opencode/agent/status.md` — the sweep map above; all other sections untouched.
- `.opencode/agent/visual.md` — `<inputs>` item 5 (lines 58–60) only.
- `.opencode/agent/scribe.md` — `<process>` step 1 (line 43) only.
- `work/0014-agent-command-inventory-sweep/0002-supporting-agent-sweep/design.md`
  and `tasks.md` — this item's own artifacts (AC13).

Read-only references (not edited): `docs/workflow.md`,
`docs/artifact-conventions.md`, and the pinning checks
`tests/checks/{10-readiness,80-cycle-fixture,85-conflict-guards,96-signature-sweep}.sh`.

## Risks and mitigations

- **Over-sweep of illustrative identifiers.** The output example's reference
  identifiers (`0002-agentic-roadmaps`, `0001-roadmap-model`, and the
  `0002-agentic-roadmaps/0003-*` finding rows) must remain, or AC7's "illustrative
  reference identifiers may remain" and AC13's scope are violated. *Likelihood:*
  medium / *Impact:* low (a rogue `roadmap` token would fail the intent of AC12).
  *Mitigation:* the T5 task names the identifiers as retained; T8's audit greps
  every remaining `roadmap` and classifies it.
- **Dropping the legacy alias.** Replacing `roadmap.md`/`stale: roadmap` outright
  would break the "no migration path" edge case. *Likelihood:* low / *Impact:*
  medium. *Mitigation:* the map above retains and labels both; AC3/AC12 tasks
  assert the paired `stale: manifest`/`stale: roadmap` rendering.
- **Breaking a pinned suite phrase.** Rewording near the `<readiness>`/`<findings>`
  blocks could drop a literal the suite pins (AC14). *Likelihood:* medium /
  *Impact:* high (red suite blocks merge). *Mitigation:* the edits are confined to
  non-pinned sections; T9 runs `bash tests/run.sh` and greps the five pinned
  literals directly.
- **Frontmatter, permission, or handoff drift.** An incidental reflow could change
  a protected block (AC11). *Likelihood:* low / *Impact:* medium. *Mitigation:*
  T9 inspects `git diff` and confirms changes fall outside frontmatter,
  `permission`, and `<handoff>`.
- **Scope creep into a sibling's surface.** The temptation to fix the identical
  boilerplate in the lifecycle agents or commands is real. *Likelihood:* medium /
  *Impact:* high (collides with `0001`/`0003`). *Mitigation:* the changeset
  allowlist is exactly the three prompts; T8 runs `git diff --name-only` and fails
  if any other path appears.
- **Definition drift — the prompt becomes a second authority.** Paraphrasing the
  model rather than citing it would re-create drift. *Likelihood:* low / *Impact:*
  medium. *Mitigation:* every edit references the authority by name
  (`docs/artifact-conventions.md` → "Work item references"; `workflow.md` →
  "Derived state") and restates no algorithm.

## Test strategy

No new committed test is added: the spec's Non-goals forbid new fixtures/guards
(Roadmap 5), and AC13 forbids touching `tests/`. Verification is static
inspection of the live prompts plus the existing committed suite.

| Acceptance criterion | Verification level | Where |
| -------------------- | ------------------ | ----- |
| AC1 | static | T1 greps `status.md` for `manifest.md` detection and the labelled alias |
| AC2 | static | T1 greps container phase `manifest` and the absence of a `roadmap` container phase |
| AC3 | static | T2 greps the paired `stale: manifest`/`stale: roadmap` → `spec` rendering |
| AC4 | static | T3 greps the `manifest.md` template name and the labelled alias |
| AC5 | static | T4 greps "nested child's own `design.md` declaration" |
| AC6 | static | T5 greps the phase-vocabulary list for `manifest`, not `roadmap` |
| AC7 | static | T5 greps the example's phase column, tally, and `Manifest …` summary lines |
| AC8 | static | T6 greps `visual.md` for the recursive form and the absence of "for a roadmap child" |
| AC9 | static | T7 greps `scribe.md` for the canonical-reference clause beside the path |
| AC10 | static | T8 greps `scout.md`/`ask.md`/`bootstrap.md` for `roadmap` (expects none) |
| AC11 | diff inspection | T9 checks the protected blocks are unchanged in `git diff` |
| AC12 | static | T8 audits every remaining `roadmap` occurrence in the three prompts |
| AC13 | diff inspection | T8 checks `git diff --name-only` is exactly the three prompts plus `design.md`/`tasks.md` |
| AC14 | integration | T9 runs `bash tests/run.sh` and greps the five pinned literals |

No criterion is manual-only; every one is a grep, a diff inspection, or the
committed suite.
