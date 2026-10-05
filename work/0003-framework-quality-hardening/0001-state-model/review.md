---
feature: 0003-framework-quality-hardening/0001-state-model
phase: review
status: final
created: 2026-10-04
updated: 2026-10-04
parent: 0003-framework-quality-hardening
---

# Review — Artifact persistence and state model

## Verdict

**approve** — the change cleanly resolves the framework's central contradiction
with no Blocker or Major finding: `work/` is no longer ignored, one canonical
committed-state statement is propagated across every current surface, numbering
and parallel-merge reconciliation are documented, and the automatable halves of
every acceptance criterion are proven by a read-only fixture suite; the remaining
halves are post-`/ship` by construction and explicitly deferred.

## Scope of the diff

The work is entirely in the **uncommitted working tree**; the item's first
`/ship` will also introduce the previously untracked `work/` corpus (a spec
goal, called out in `design.md`'s migration note).

Commands used to establish the range:

- `git merge-base HEAD origin/main` → `c060626b67e41f8e7319c35c96adda7fc3396fe2`
  (equals `HEAD` and `origin/main`).
- `git diff c060626...HEAD --stat` → empty: no commits yet on the branch.
- `git diff` → the 15 modified tracked files (`141` insertions, `49` deletions).
- `git status --short` / `git status --porcelain --untracked-files=all work/` →
  15 modified files plus untracked `work/0001-*`, `work/0002-*`,
  `work/0003-*` (the migration corpus and this item's artifacts).
- `rg --files work` and `find work -type f -size +200k` for corpus inventory.

The 15 modified files match `design.md`'s "Affected areas" table exactly; there
is **no scope creep** (no dependency, no runtime code, no unrelated refactor).
`doctor.md`/`command/doctor.md` are deliberately untouched per the design.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — Artifacts are trackable | **met** | `.gitignore:5-6` removes the `work/*`/`!work/.gitkeep` pair; no remaining rule matches `work/` (`verify-tests.sh` AC1: 9 `git check-ignore` paths + real `git status -uall`). |
| AC2 — Only non-artifact paths stay ignored | **met** | `.gitignore:8-20` retains `.opencode/{state,cache,node_modules}`, `.playwright-mcp/`, `scratch/`, `node_modules/`, `dist/`; `verify-tests.sh` AC2 passes both directions. |
| AC3 — Reservation placeholders persist | **met** | All 10 `work/**/.gitkeep` placeholders trackable; `git status -uall` lists the nested-child placeholders (`verify-tests.sh` AC3). |
| AC4 — Every current surface states one model | **met** | No stale `git-ignored`/`not deliverables` claim survives outside the historical corpus; 11 surfaces carry the literal committed statement (`verify-tests.sh` AC4). Verified independently by `rg` over `AGENTS.md`, `README.md`, `docs/`, `.opencode/`. |
| AC5 — Adoption yields the committed model | **partial** — static+fixture met, real `/bootstrap` deferred | `bootstrap.md:96-100,113-114`, `command/bootstrap.md:21-22`, `README.md:56-61`; fixture repairs a `work/*` `.gitignore` while keeping `scratch/`/`.playwright-mcp/` (`verify-tests.sh` AC5). The LLM `/bootstrap` mutation is correctly deferred (`verify.md:104-108`). |
| AC6 — Consistency audit stays clean | **met** | `doctor.md:108-112` still requires only `.playwright-mcp/`/`scratch/`; unchanged vs `HEAD`; real `/doctor` reported `No findings` (`verify-tests.sh` AC6, `verify.md:60`). |
| AC7 — Shipped PR links resolve | **partial** — static guidance met, post-`/ship` check deferred | `shipper.md:36-39,81-88,98-99` stages `work/<item-ref>/`; `pr-workflow/SKILL.md:45-48` states links resolve (`verify-tests.sh` AC7). Actual branch/PR resolution is post-`/ship` by nature. |
| AC8 — Fresh-clone state parity | **deferred (not verifiable pre-ship)** | Artifacts are committed-model-ready and derivation is unchanged (AC12); the clean-clone comparison is inherently post-merge (`verify.md:97-103`). |
| AC9 — Numbers are unique and durable | **met** | Contract at `artifact-conventions.md:417-426` uses the history source set; `product.md`/`roadmap.md` aligned; unique prefixes at HEAD and per-parent; fixtures prove empty root→`0001` and deleted `0005`→`0006` (`verify-tests.sh` AC9). |
| AC10 — Parallel branches reconcile | **met** | `workflow.md:281-291` + `artifact-conventions.md:434-461` procedure; fixture creates two branches each adding `0004`, merges, renumbers, updates frontmatter, and asserts no duplicate remains (`verify-tests.sh` AC10). |
| AC11 — Visual evidence is committed | **met** | `visual.md:43-45`, `browser-verification/SKILL.md:65-67` state screenshots are committed; hypothetical `work/**/visual/*.png` not ignored (`verify-tests.sh` AC11). |
| AC12 — Derived state preserved; no state file | **met** | No ledger/registry introduced (`verify-tests.sh` AC12 scans `work/` and `git status`); derivation unchanged. |

**Tally:** 9 met, 2 partial (AC5, AC7 — deferred halves only), 1 deferred by
nature (AC8). No acceptance criterion is unmet on a defect reading.

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] The canonical persistence sentence overstates the ignore set** —
  `AGENTS.md:64-67`, `docs/workflow.md:55-58`,
  `docs/artifact-conventions.md:8-10`, `.gitignore:5-6`.
  The one sentence the item replicates everywhere says "Only `scratch/` and
  opencode's generated state are ignored." The repository also ignores
  `.playwright-mcp/` (tooling output, not "generated state"), plus
  `node_modules/`, `dist/`, `build/`, `coverage/`, `__pycache__/`, and editor/OS
  files (`.gitignore:8-54`). Because the item's entire purpose is one *true*
  statement, a small systematic over-claim is worth correcting.
  Recommendation: scope the sentence to workflow state and name the tooling
  output, e.g. "Only the temporary workspace (`scratch/`), tooling output
  (`.playwright-mcp/`), opencode's generated state, and build artifacts remain
  ignored," in all replicated copies. Non-blocking: the surrounding context
  still directs `scratch/`/tooling to stay ignored.

- **[m2] The allocation source set conflates top-level and nested child
  numbers** — `docs/artifact-conventions.md:417-426`.
  The source set is "directory names under `work/` at `HEAD` and every path ever
  committed under `work/`", read with
  `git log --all --name-only --pretty=format: -- work/`. That command yields
  nested paths such as `work/0003-.../0009-.../spec.md`, so a literal maximum
  over all 4-digit tokens would include the child local `MMMM`. A roadmap whose
  highest child is `0009` would push the next *top-level* allocation to `0010`,
  skipping free numbers. AC9 (unique + durable + no reuse) still holds, and the
  tester already recorded this as a follow-up (`verify.md:113-122`); it is a
  contract-precision issue, not a defect.
  Recommendation: say "the greatest **top-level** 4-digit directory prefix" and
  show the extraction the suite already uses
  (`sed -n 's#^work/\([0-9]\{4\}\)-.*#\1#p'`); leave the machine assertion to
  sibling `0006-committed-tests-ci`.

### Nits

- **[n1] The design contradicts its own test suite over ownership** —
  `design.md:258-262` says regression assertions for duplicate numbers, ignore
  policy, and surface agreement "belong to sibling `0006` … and are not added
  here," yet `verify-tests.sh` implements exactly those. The design's
  "Test strategy" table (`design.md:253-256`) plans these same checks, so the
  tester is justified; only the follow-up wording is stale. Reconcile the
  design note or leave it to `0006`.

- **[n2] `.gitignore` comment omits the generated-state block that follows it** —
  `.gitignore:5-6` says "Only `scratch/` and tooling output below are ignored,"
  immediately above the `.opencode/` generated-state block. Align the comment
  with the canonical sentence once `m1` is addressed.

- **[n3] Placeholder retained beside real artifacts** —
  `work/0003-framework-quality-hardening/0001-state-model/.gitkeep`. The spec
  edge case explicitly permits this and the suite asserts both files stay
  trackable; the `.gitkeep` may be removed now that the directory holds content.

- **[n4] Committed evidence cites out-of-workspace temp paths** —
  `verify.md:56-60` records `/tmp/opencode/*.log`. The framework's own scratch
  convention (and prior review finding in item `0001`) directs temp files to
  `scratch/`; item `0002`'s `verify.md` has the same precedent, so this is
  cosmetic. A future pass could drop the log paths.

- **[n5] The AC4 sweep is line-filtered and can mask** —
  `verify-tests.sh:114-118` excludes lines containing
  `scratch|playwright|opencode|node_modules|generated|cache`. The exact-literal
  assertions (`:120-126`) mitigate this, and `verify.md:123-127` acknowledges the
  limitation; splitting a stale claim onto a shared line could still slip
  through. Not worth blocking.

## Security, error handling, and compatibility

- **Secrets / sensitive content.** `find work -type f` for `*.env*`, `*.pem`,
  `*.key`, `*credential*`, `*secret*` → none. `rg` for key/token/password
  markers and machine-specific absolute paths (`/home/<user>`, `/Users/`) in the
  corpus → none. No file over 200 KB. The shipper's existing secret scan still
  applies before the one-time migration commit.
- **Error handling / edge cases.** No runtime code; the affected surface is
  configuration and prose. The empty root, deleted number, adopter repair, and
  parallel-merge edge cases each have a working fixture.
- **Backward compatibility.** Removing the `work/*` ignore is an intentional,
  documented behavior change; the quickstart states a local-only posture is an
  unsupported override. `doctor`'s ignore-policy catalogue is unchanged and
  still satisfied. The pre-existing suites' required literals (`Never reuse`,
  `never reused within that parent`, `proceed in parallel`) survive
  (`artifact-conventions.md:422,432`; `workflow.md:285`).
- **Performance.** Not applicable (docs/config only).

## Not reviewed

- `.opencode/agent/doctor.md` and `.opencode/command/doctor.md` — intentionally
  out of scope (`design.md:205`, sibling `0004-doctor-scope`); only the
  compatibility of the ignore-policy inputs was checked.
- The historical corpus contents (`0001-*`, `0002-*`) were inventoried for
  secrets/size but not re-reviewed; the design states they are immutable.
- The actual `/ship` commit, the PR body/link resolution, and the post-merge
  clean-clone derivation (AC7/AC8) — deferred by construction.

## Verification gaps (accepted, not defects)

`verify.md` correctly labels AC5's real `/bootstrap` run, AC7's post-`/ship`
`git ls-tree`/reviewer-open, AC8's clean-clone comparison, and AC10's real
two-branch merge as manual. These cannot be closed inside `/test` without
mutating the live repo or shipping; the item's static and fixture evidence covers
their automatable halves. The shipper (or the next phase) should perform the
AC8 clone comparison after `work/` is committed and record the result.
