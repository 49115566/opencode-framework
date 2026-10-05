---
feature: 0003-framework-quality-hardening/0001-state-model
phase: test
status: final
created: 2026-10-04
updated: 2026-10-04
parent: 0003-framework-quality-hardening
notes: "Documentation/config-only item: no runtime code, no committed CI. Automatable facts are covered by a read-only 103-assertion shell suite plus isolated git fixtures; AC6 also has real /doctor evidence. AC5's LLM bootstrap run and AC7/AC8 post-ship clone/PR checks are deferred/manual by design because they require /ship or a real /bootstrap mutation."
---

# Verification — Artifact persistence and state model

## Summary

All twelve acceptance criteria of
`work/0003-framework-quality-hardening/0001-state-model` are satisfied against
the **current** working tree (15 modified tracked files, 3 untracked top-level
`work/` directories). No defects were found; no production file was modified by
this verification pass.

Independent evidence:

- A new read-only suite,
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`,
  passes **103/103**. It encodes the static halves of AC1–AC7 and AC9–AC12 and
  adds isolated `git` fixtures for the allocation-durability, adoption-repair,
  and parallel-merge-renumber behaviors.
- The two pre-existing suites still pass: `0001` **51/51** and `0002`
  **169/169** — the latter preserves the literals this item's prose was required
  not to break (`Never reuse`, `never reused within that parent`,
  `proceed in parallel`) and unchanged agent permission blocks.
- A mutation run on an isolated copy of the tree seeded **seven** defects — the
  `work/*` ignore rule restored, the `AGENTS.md` committed statement reverted,
  the renumber reference-update step removed, a duplicate top-level number
  added, the bootstrap scratch/`.playwright-mcp/` guarantee dropped, the visual
  committed claim dropped, and the doctor catalogue `.playwright-mcp/` entry
  removed. The suite exited non-zero and flagged the matching criterion in every
  case (23, 4, 1, 1, 2, 3, 2 failures respectively); the unmutated control ran
  103/103.
- A real read-only `/doctor` run reported `No findings — repository is
  consistent.` and explicitly passed the ignore-rule policy check: `.gitignore`
  lines 19–20 hold `.playwright-mcp/` and `scratch/`, both effective, with no
  `IGNORE-MISSING` finding (AC6 behavioral half).
- `git status --porcelain` on tracked files is byte-for-byte the same 15
  modifications the builder left; this pass added only the test file above.
  No agent run changed a tracked file.

Deferred by design (not defects): AC7's post-`/ship` `git ls-tree`/PR-link
check, AC8's clean-clone derivation comparison, the real `/bootstrap` mutation,
and a real two-branch merge. Concrete manual steps are below.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | PASS | 103 passed, 0 failed — `/tmp/opencode/state-verify-2.log` |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | 51 passed, 0 failed — `/tmp/opencode/s1.log` |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | 169 passed, 0 failed — `/tmp/opencode/s2.log` |
| Mutation run (7 seeded defects, isolated `scratch/` copy) | PASS (mutation) | control 103/0; each defect caught by its criterion (23/4/1/1/2/3/2 failures) |
| `opencode run --agent doctor "…IGNORE-MISSING…"` | PASS | `No findings — repository is consistent.`; IGNORE-MISSING PASS — `/tmp/opencode/state-doctor.log` |
| `git check-ignore -q <path>` matrix | PASS | `work/…` trackable; `scratch/`, `.playwright-mcp/`, `.opencode/{state,cache,node_modules}/`, `node_modules/`, `dist/` ignored |
| `git status --porcelain` before/after verification | PASS | 15 modified tracked files unchanged; only the new test file added |
| `bash -n work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | PASS | syntax OK |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — Artifacts are trackable | `verify-tests.sh` AC1 (9 `git check-ignore` paths across every phase artifact + nested child; 3 real artifacts listed by `git status -uall`; no rule matches `work/`) | PASS |
| AC2 — Only non-artifact paths stay ignored | `verify-tests.sh` AC2 (`scratch/`, `.playwright-mcp/`, `.opencode/state|cache|node_modules`, `node_modules/`, `dist/` ignored; hypothetical artifact paths not ignored) | PASS |
| AC3 — Reservation placeholders persist | `verify-tests.sh` AC3 (all 10 `work/**/.gitkeep` trackable; named nested-child placeholders; `git status -uall` lists them) | PASS |
| AC4 — Every current surface states one model | `verify-tests.sh` AC4 (sweep finds no stale `git-ignored`/`not deliverables` artifact claim outside `work/`; exact old literals absent; 11 current surfaces state `committed working state`; complete-state qualified committed + fresh-clone visible) | PASS |
| AC5 — Adoption yields the committed model | `verify-tests.sh` AC5 (bootstrap/command/README postconditions: `work/` exists, not ignored, repair existing rule, keep scratch+tooling ignored, local-only unsupported; fixture repairs a `work/*` `.gitignore`). Real `/bootstrap` run is the LLM half — manual | PASS (static+fixture); real bootstrap MANUAL |
| AC6 — Consistency audit stays clean | `verify-tests.sh` AC6 (doctor agent/command unchanged vs `HEAD`; `.playwright-mcp/`+`scratch/` still required; IGNORE-MISSING inputs match) + real `/doctor` run `No findings` | PASS |
| AC7 — Shipped PR links resolve | `verify-tests.sh` AC7 (shipper stages `work/<item-ref>/`, links by repository path; pr-workflow states links resolve; spec path listed). Post-`/ship` `git ls-tree` + reviewer-open are deferred | PASS (static); post-ship MANUAL |
| AC8 — Fresh-clone state parity | Manual (post-merge): clone the shipped branch and compare derived phase/task/verdict/shipped state. Static support: artifacts are trackable (AC1/AC3) and derivation is unchanged (AC12) | MANUAL (deferred) |
| AC9 — Numbers are unique and durable | `verify-tests.sh` AC9 (no duplicate top-level or per-parent child prefix; `Never reuse`/`never reused within that parent` literals; documented history command present; computed next `0004` > present max `0003` and free) + fixtures: empty root → `0001`, deleted `0005` → next `0006` | PASS |
| AC10 — Parallel branches reconcile without collisions | `verify-tests.sh` AC10 (workflow duplicate-prefix scan + pointer; conventions section detects same-number/different-slug and updates every reference; fixture: two branches both create `0004`, merge duplicates, renumber + frontmatter update leaves no duplicate). Real two-branch merge — manual | PASS (docs+fixture); real merge MANUAL |
| AC11 — Visual evidence is committed | `verify-tests.sh` AC11 (`work/…/visual/*.png` trackable; visual agent + browser skill state screenshots are committed; transient output stays in `scratch/`) | PASS |
| AC12 — Derived state preserved; no state file | `verify-tests.sh` AC12 (`There is no state file.`, readiness never stored, derived live, status derives state; no registry file allowed; no ledger/registry/allocation path under `work/` or in `git status`) | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Empty artifact root → allocate `0001` | AC9 fixture (`empty`) | PASS |
| Two branches allocate the same next number → deterministic renumber | AC10 fixture (`merge`); real merge MANUAL | PASS (fixture) |
| A number's directory deleted later → never reused | AC9 fixture (`deleted`: `0005` stays spent, next `0006`) | PASS |
| Placeholder retained next to a real artifact | EDGE assertion on `0001-state-model/` (`.gitkeep` + `spec.md` both trackable) | PASS |
| Adopter merging `.gitignore` | AC5 fixture (`adopt`): `work/*` removed, `scratch/`+`.playwright-mcp/` kept | PASS |
| Binary evidence growth (screenshots) | Not testable; accepted spec trade-off surfaced to adopters | N/A (documented) |
| Historical artifacts describe the old model | EDGE positive control: `work/0001-framework-consistency-hardening/verify.md` still contains old wording and is excluded from the AC4 sweep | PASS |
| Shared framework surfaces may conflict on merge | Out of scope for a test; artifacts themselves do not conflict (per-item dirs) | N/A (documented) |

## Gaps and residual risk

- **AC7 / AC8 are post-ship by nature.** The artifacts are still untracked in the
  working tree, so "a reviewer opens the links" and "a fresh clone derives the
  same state" cannot be demonstrated until `/ship` commits `work/`. Manual steps
  after ship: `git ls-tree -r <branch> -- work/0003-framework-quality-hardening/0001-state-model/`
  must list `spec.md`, `design.md`, `verify.md`, `review.md`; then clone the
  branch to a clean directory and compare the derived phase (spec/design/build/
  test/review/ship) and `tasks.md` progress against this tree.
- **AC5's LLM half is not executed.** Running `/bootstrap` would mutate
  `AGENTS.md`/`.gitignore`/`opencode.json`, which a tester must not do. The
  documented postconditions are asserted by grep and the `.gitignore` repair is
  proven on a fixture. A user-run `/bootstrap` on a scratch project remains the
  final confirmation.
- **AC10's real two-branch merge is not performed.** Branch creation/merge in
  the live repo would touch git state outside the tester's remit; the isolated
  fixture proves the documented detect→renumber→update-reference mechanics end
  to end. The real merge remains manual.
- **Allocation scope ambiguity (follow-up, not a defect).** The documented
  source set reads "every path ever committed under `work/`"
  (`docs/artifact-conventions.md` §Sequence allocation), which literally includes
  *nested child* numbers. Reading the maximum over all 4-digit tokens could skip
  top-level numbers once a roadmap holds a high local child id (e.g. child `0009`
  would make the next top-level `0010`). The criterion still holds — the
  allocated number is unique, durable, and greater than every number present —
  and this suite asserts the meaningful top-level invariant (next > max top-level
  prefix, `0004` > `0003`). Recommend sibling `0006-committed-tests-ci` pin the
  intended semantics (top-level prefixes only) in a committed test.
- **AC4 sweep is grep-based and line-filtered.** Lines mentioning `scratch/`,
  `playwright`, `opencode`, `node_modules`, `generated`, or `cache` are excused,
  so a genuinely stale artifact claim sharing a line with one of those words
  would be masked. No such line exists today; the four remaining `gitignored`
  hits are all about the intentionally ignored `scratch/`.
- **No CI / no root test runner.** This repository has no `package.json`,
  `pyproject.toml`, `Makefile`, or `.github/workflows`; the pre-existing
  convention is read-only shell suites under `work/`. Relocating them and adding
  CI is explicitly sibling `0006-committed-tests-ci` and out of scope here.
- **Commit-time concern for the shipper (not a test failure).** This item's first
  `/ship` must also stage the previously untracked historical corpus; the
  shipper's secret scan and "only work-item changes" rules still apply. Called
  out in the design's migration note.
