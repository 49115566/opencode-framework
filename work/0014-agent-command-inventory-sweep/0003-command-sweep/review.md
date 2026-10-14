---
feature: 0014-agent-command-inventory-sweep/0003-command-sweep
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Review — Command-surface recursive sweep

## Verdict

**approve** — every acceptance criterion is met by the evidence in the working
tree, the change set is exactly the eight command prompts plus this item's
artifacts, and no finding of any severity survives scrutiny.

## Base and diff

The item is a nested child whose plan was published and merged; `/build` does not
commit, so the work under review is the uncommitted working tree plus the
untracked `verify.md`.

Commands run:

- `git merge-base HEAD origin/main` → `54817dded46920531c384347511882108c445bdb`
- `git rev-parse HEAD origin/main` → both `54817dded46920531c384347511882108c445bdb`
  (base == HEAD == `origin/main`; the plan artifacts `spec.md`/`design.md`/`tasks.md`
  were committed by plan merge `164503c` / `54817dd`)
- `git diff` and `git diff --name-only` → the eight command prompts and
  `.../0003-command-sweep/tasks.md` (checkbox flips only)
- `git status --porcelain` → 8 modified commands, `tasks.md` modified, `verify.md`
  untracked (nothing else)

Because base == HEAD, the full source diff is the working-tree diff, reviewed in
full. `challenges.md` does not exist, so there was no challenge to adjudicate.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 — `status.md` detects a decomposing node by `manifest.md`, legacy `roadmap.md` labelled | **met** | `status.md:15-16` = "by the presence of `manifest.md` (or the legacy `roadmap.md` alias)"; the old "presence of `roadmap.md`" wording is gone |
| AC2 — container phase is `manifest`, never `roadmap` | **met** | `status.md:20` = "derives the container phase `manifest`"; grep of the eight commands shows no `roadmap` phase token |
| AC3 — `stale: roadmap` presented with `stale: manifest`, both → `spec`, alias labelled | **met** | `status.md:28` = "`stale: manifest` token — or its retained legacy alias `stale: roadmap` — to `spec`"; mirrors the shipped `status` agent wording (`agent/status.md:122`) |
| AC4 — `spec.md` allocation states canonical recursive form; "for a roadmap child" gone | **met** | `spec.md:23-25` = "for a nested child, use the supplied canonical reference (`NNNN-slug/MMMM-slug`, nesting to arbitrary depth per `docs/artifact-conventions.md` → \"Work item references\")"; repo-wide grep for "for a roadmap child" returns nothing |
| AC5 — `ship.md` reconcile re-checks the manifest's dependency graph; old phrase gone | **met** | `ship.md:40-41` = "re-check the manifest's dependency graph"; grep for "roadmap dependency graph" returns nothing |
| AC6 — seven item-ref sentences byte-identical, canonical form, cite authority, no "roadmap child" | **met** | The same identical four-line block is added in `spec.md:13-16`, `plan.md:26-29`, `build.md:12-15`, `test.md:11-14`, `review.md:11-14`, `ship.md:21-24`, `visual.md:12-15`; each states "`NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at any depth", cites "Work item references", resolves to `work/<item-ref>/` |
| AC7 — `plan.md` retains a clearly-labelled legacy `roadmap.md` alias | **met** | `plan.md:33` = "(or the legacy `roadmap.md` artifact alias)" — untouched by the diff; it is the only `roadmap` token in the file |
| AC8 — every remaining `roadmap` token is a labelled deprecated alias; no regression | **met** | Exactly three `roadmap` tokens across the eight commands: `plan.md:33`, `status.md:16`, `status.md:28` — all labelled legacy aliases. `ship.md`'s pre-existing `manifest.md` plan-publication/recall wording is absent from the diff |
| AC9 — `agent:` and `Usage:` byte-identical; prose-only | **met** | Every diff hunk lies after line 4 (the frontmatter block); no `description:`/`agent:` line appears in `git diff` |
| AC10 — change set is exactly the eight commands + item artifacts; excluded commands identical; no docs/README/AGENTS/template/tests/agent changes | **met** | `git diff --name-only` = the eight commands + `tasks.md` (plus untracked `verify.md`); `conflicts`/`fix`/`bootstrap`/`doctor` are absent from the diff (byte-identical) |
| AC11 — `bash tests/run.sh` exits 0, `96-signature-sweep` green, inventory 13/12/11 | **met** (on the tester's recorded run; not re-executed by the reviewer) | `verify.md` records `503 passed, 0 failed, 0 skipped`, exit 0. I verified by inspection that no committed check depends on the swept wording and that all pinned literals survive: `status.md:37` "Dependencies and readiness", `:46` "a child in a cycle is never `ready`", `:53` `CYCLIC-DEP`, `:54` "Report them without failing", `:68` "## Declared-conflict check", `:70` `TEXTUAL-CONFLICT`; every `Usage:` string is untouched |
| AC12 — statements cite the authority by name; no new phase/code/grammar; sentence matches the paired agents | **met** | `status.md:21` cites "Derived state"; `spec.md:15,25` cite "Work item references"; the canonical sentence's content equals the shipped agent sentence (`product.md:55`, `architect.md:86`, `builder.md:69`, `tester.md:97`, `reviewer.md:62`, `shipper.md:93`); no new `phase` value, finding code, or grammar introduced |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Not reviewed

- **Independent test execution.** The environment's bash allowlist permits only a
  small read-only command set, so I could not re-run `bash tests/run.sh` myself.
  AC11 rests on the tester's recorded run in `verify.md` plus my inspection of the
  pinning checks (`10-readiness.sh`, `25-review-severity-bar.sh`,
  `80-cycle-fixture.sh`, `85-conflict-guards.sh`, `96-signature-sweep.sh`), none of
  which asserts the swept wording — so the prose change cannot break them.
- **Out-of-scope surfaces.** `docs/**`, the agents, the skills, the README, and
  the excluded commands (`conflicts`, `fix`, `bootstrap`, `doctor`) are owned by
  sibling items; their correctness was not assessed here. Confirmed only that the
  three excluded clean commands are byte-identical.
- **No `visual.md`** — this is prompt/doc-only work with no user-facing UI, so the
  optional visual pass does not apply.

## Notes

- The wording "retained legacy alias" (rather than "deprecated legacy alias")
  satisfies AC3/AC8's "clearly-labelled legacy alias" and, importantly, matches the
  already-shipped `status` agent verbatim, which is this item's stated goal (a
  command must not diverge from its paired agent). No change recommended.
- Scope was checked adversarially: `conflicts.md`, `fix.md`, `bootstrap.md`, and
  `doctor.md` carry no `roadmap` token and no item-ref boilerplate, so the spec's
  8-command scope is complete and correct rather than an omission.
