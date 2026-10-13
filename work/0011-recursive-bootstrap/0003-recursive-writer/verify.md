---
feature: 0011-recursive-bootstrap/0003-recursive-writer
phase: test
status: final
created: 2026-10-12
updated: 2026-10-12
parent: 0011-recursive-bootstrap
---

# Verification — Recursive decomposition writer

## Summary

This item is a **documentation/prompt-only** change: it makes the planning step
(`/plan`, `architect`) the recursive decomposition writer, demotes `/roadmap` to a
thin deprecated alias, and single-sources the writer contract in `docs/workflow.md`.
The production change set is exactly five files:

- `docs/workflow.md`
- `.opencode/agent/architect.md`
- `.opencode/command/plan.md`
- `.opencode/agent/roadmap.md`
- `.opencode/command/roadmap.md`

Per the spec's explicit non-goals ("Committed fixtures, agreement areas, or
mutation coverage pinning the writer — a successor roadmap (Roadmap 5)") and the
design's Test strategy ("**no new test file is added**"), no committed test file
was added. The deliverable is prompt/doc text, so the content criteria are
verified by inspection against cited `file:line` locations plus the existing
committed suite staying green. This is a deliberate, spec-sanctioned scope
decision, not an omitted test.

No open challenge exists: `work/0011-recursive-bootstrap/0003-recursive-writer/challenges.md`
is absent.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 489 passed, 0 failed, 0 skipped` |
| `FRAMEWORK_TEST_AREAS='40-inventory,96-signature-sweep,20-lifecycle,80-cycle-fixture,85-conflict-guards' bash tests/run.sh` | PASS | `TOTAL: 253 passed, 0 failed, 0 skipped` — the AC10 pin set |
| `FRAMEWORK_TEST_AREAS='10-readiness,80-cycle-fixture,85-conflict-guards,87-backtrack-guards,96-signature-sweep,20-lifecycle,30-permissions' bash tests/run.sh` | PASS | `TOTAL: 338 passed, 0 failed, 0 skipped` — the T1–T7 verify set |
| `git diff --name-only -- docs/ .opencode/ README.md AGENTS.md template/ tests/` | PASS | Exactly the five files above; no README/AGENTS/template/test change |
| `git ls-files --others --exclude-standard .opencode/` | PASS | Empty — no new agent/command/skill file |
| `git diff --name-only -- work/0011-recursive-bootstrap/0001-recursive-model work/0011-recursive-bootstrap/0002-recursive-schema` | PASS | Empty — no shipped `0001`/`0002` artifact re-opened |
| `grep -n "concrete writer's command/agent wiring" docs/ .opencode/` | PASS | No match (exit 1) — the `0003`-deferral sentence is gone |

Content checks were run as line-aware `grep -E` assertions over the five files
(70 assertions). Six initial non-matches were each traced to a pattern straddling
a Markdown line break and re-confirmed present with a line-aware grep; no
substantive failure remained. Key confirmations:

- `docs/workflow.md:68-97` — planning step is the recursive writer at any depth;
  manifest path + `feature:`/`phase: roadmap`; `.gitkeep` reservation;
  per-immediate-parent `MMMM` allocation (by reference); no child phase artifact;
  autonomous; single-feature-no-manifest / decomposing-always-manifest / optional
  hybrid; handoff publishes then routes to ready children.
- `.opencode/agent/architect.md:30-46,100-153,174-189,239-247` — two planning
  paths, decomposition rules, by-reference manifest quality bar, decomposed
  handoff.
- `docs/workflow.md:329-400` — revision generalized to any depth; four operations;
  final-state validation; `stale: roadmap`; shipped-child refusal; no-op rule.
- `docs/workflow.md:439-489` — `/plan` two-path Entry/Process/Exit/Artifact/Next;
  decomposition needs no node `spec.md`; publish-then-route handoff.
- `docs/workflow.md:580-611` — plan definition and the `spec.md`+`design.md`
  **or** `roadmap.md` precondition.
- `docs/workflow.md:188-192,1306-1311` — planning step named as author, `/roadmap`
  as the deprecated alias.
- `.opencode/command/plan.md:2`, `.opencode/command/roadmap.md:2` — exact `Usage:`
  strings preserved.
- `.opencode/agent/roadmap.md:20-52,97-145,192-206` and
  `.opencode/command/roadmap.md:8-55` — thin deprecated alias, create top-level,
  revise any depth, sole-writer reconciled, no competing grammar.

## Acceptance coverage

| Criterion | Test(s) / evidence | Result |
| --------- | ------------------ | ------ |
| AC1 — planning step authors the node's manifest at any depth | inspection `docs/workflow.md:66-97`, `.opencode/agent/architect.md:30-46,123-130`; content check "recursive writer for a decomposition at **any**", "manifest `work/<item-ref>/roadmap.md`", old deferral absent | PASS |
| AC2 — child `.gitkeep` reservation, per-immediate-parent `MMMM`, appended `Canonical reference` | inspection `docs/workflow.md:75-81`, `.opencode/agent/architect.md:126-130,151-153`; content checks `.gitkeep`, "per the immediate parent", "Sequence allocation" | PASS |
| AC3 — six-column `Children`, acyclic `Depends on`, resolving `Canonical reference`, well-formed `conflicts-with` | inspection `docs/workflow.md:375-377,468-478`, `.opencode/agent/architect.md:135-140,180-184`; existing `80-cycle-fixture.sh`, `85-conflict-guards.sh` green | PASS |
| AC4 — no child phase artifact written | inspection `docs/workflow.md:83-84`, `.opencode/agent/architect.md:130,203-208`, `.opencode/agent/roadmap.md:37-38,45,119-120`; content checks | PASS |
| AC5 — always manifest; optional hybrid; single feature → `design.md`/`tasks.md` and no manifest | inspection `docs/workflow.md:86-90,441-482`, `.opencode/agent/architect.md:34-40,141-143`; content checks "hybrid", "never forced on a pure container", "and no manifest" | PASS |
| AC6 — revision at any depth: four ops, final-state validation, `stale: roadmap`, shipped refusal, no-op | inspection `docs/workflow.md:329-400`, `.opencode/agent/architect.md:131-134`, `.opencode/agent/roadmap.md:123-145`; existing `87-backtrack-guards.sh` green | PASS |
| AC7 — autonomous; no pre-write approval gate | inspection `docs/workflow.md:84-86,339-341`, `.opencode/agent/architect.md:60-63`, `.opencode/agent/roadmap.md:70-71,135-140`, `.opencode/command/roadmap.md:52-55` | PASS |
| AC8 — handoff publishes then routes to ready children; node plan state publishable | inspection `docs/workflow.md:92-97,483-485,580-611`, `.opencode/agent/architect.md:146-148,239-247`, `.opencode/agent/roadmap.md:198,204` | PASS |
| AC9 — `/roadmap` thin deprecated alias; create top-level; revise any depth; not retired; usage preserved | inspection `.opencode/command/roadmap.md:2,8-19,36-50`, `.opencode/agent/roadmap.md:20-52,192-206`, `docs/workflow.md:70-73,188-192,1306-1311`; existing `96-signature-sweep.sh` green; both files present | PASS |
| AC10 — configured suite green; no new command/agent/skill; no inventory count change; core contracts unchanged | `bash tests/run.sh` → 489/0; `40-inventory.sh`, `96-signature-sweep.sh`, `20-lifecycle.sh`, `80-cycle-fixture.sh`, `85-conflict-guards.sh` green; `git ls-files --others .opencode/` empty; `git diff --name-only` = five files | PASS |
| AC11 — contract stated once in the authority; surfaces defer; sole-writer reconciled | inspection `docs/workflow.md:66-97,329-342`; `.opencode/agent/architect.md:42-45`, `.opencode/agent/roadmap.md:30-33,178-179`, `.opencode/command/roadmap.md:8-11`; "roadmap agent is the sole writer" no longer appears | PASS |
| AC12 — one-segment items and existing two-level roadmaps valid; invocations keep working; no `0001`/`0002` re-open | `git diff --name-only` = five files; no diff under `0001`/`0002`; `10-readiness.sh`, `87-backtrack-guards.sh`, `96-signature-sweep.sh` green; exact `Usage:` strings unchanged | PASS |
| AC13 — decomposition path reachable without node `spec.md` and writes none; single feature still requires `spec.md` | inspection `docs/workflow.md:444-450,592-596`, `.opencode/agent/architect.md:76-78`, `.opencode/command/plan.md:31-36,63-66`; content checks | PASS |

### Edge cases

| Edge case | Coverage | Result |
| --------- | -------- | ------ |
| Pure container | `docs/workflow.md:86-90,444-450` (no `spec.md` required, manifest-only plan); AC5/AC13 | PASS |
| Hybrid node | `docs/workflow.md:88-90,465-467,479-482`; AC5 | PASS |
| Single feature, not an initiative | `docs/workflow.md:86-88,449-456`; AC5/AC13 | PASS |
| `.gitkeep`-only reserved child decomposable later | `docs/workflow.md:400-404` ("a `.gitkeep`-reserved child or a pure container"); any-depth wording | PASS |
| Deep chain | "any depth" throughout; AC1 | PASS |
| Repeated local-id text at different levels | identity = full canonical path, shipped by `0002` (`docs/artifact-conventions.md` → "Work item references"); writer composes by reference | PASS (by reference) |
| Existing two-level roadmap unchanged | AC12; `git diff` shows no reference/grammar change; `10-readiness` green | PASS |
| Shipped node refused | `docs/workflow.md:397-400`; AC6 | PASS |
| No-op revision | `docs/workflow.md:341-342`; AC6 | PASS |
| Intended dependency cycle | `docs/workflow.md:379-381`; `80-cycle-fixture.sh` green | PASS |
| Withdrawal that would dangle a dependency | `docs/workflow.md:381-384` | PASS |
| Malformed `conflicts-with` cell | `docs/workflow.md:375-377`, `.opencode/agent/architect.md:139-140`; `85-conflict-guards.sh` green | PASS |
| Malformed reference | shipped reference grammar (`0002`, `docs/artifact-conventions.md`); writer references it | PASS (by reference) |
| Parallel nodes | writer produces only its own node's manifest + child reservations; `docs/workflow.md:83-84`; nobody else's artifacts written | PASS |

### Declared-conflict hygiene (not an AC)

`work/0011-recursive-bootstrap/0003-recursive-writer/design.md:7` declares
`conflicts-with: "docs/workflow.md, .opencode/agent/roadmap.md, .opencode/command/roadmap.md"`,
byte-equal to the parent `Children` row cell at
`work/0011-recursive-bootstrap/roadmap.md:105`. The child's declared set is the
union of `own` and `cell`, so the read-only check reports no `DRIFT-FACT`.

## Gaps and residual risk

- **Prompt behavior, not executable code.** The writer is a documented contract in
  prompts/docs; it cannot be executed offline, so verification is textual
  inspection plus the existing suite. Whether a live `architect` agent follows the
  prompt is not machine-verifiable here.
- **No committed guard pins the new writer text.** By explicit spec non-goal, the
  committed fixtures/agreement areas that would pin it are deferred to a successor
  roadmap (Roadmap 5). A future regression in this text is therefore not caught by
  `tests/run.sh`; only the shipped inventories/signatures/contracts it must not
  disturb are pinned today. This is an accepted, spec-sanctioned residual risk, not
  a coverage gap I can close within this item's scope.
- **Visual pass skipped.** The item has no user-facing UI surface; a browser pass
  is not applicable.
- **Out-of-scope surfaces.** `README.md`, the `workflow-lifecycle` skill, and the
  roadmap-deprecation/migration surfaces are explicitly deferred (Roadmaps 2 and
  4); they may still describe the pre-recursive writer and are not verified here.

## Verdict

All 13 acceptance criteria and all listed edge cases are covered (by inspection of
the cited `file:line` evidence, the existing committed suite staying green, and the
git-level invariants). No defect of any class was found; no test was weakened,
skipped, or deleted. No spec or design fault surfaced.
