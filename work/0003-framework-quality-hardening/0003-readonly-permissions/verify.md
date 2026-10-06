---
feature: 0003-framework-quality-hardening/0003-readonly-permissions
phase: test
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Independent verification of the uncommitted working tree (base ff5a2fa). Added the item suite work/0003-framework-quality-hardening/0003-readonly-permissions/verify-tests.sh (110 assertions) covering AC1-AC9 and AC11 statically; AC10 verified by a real /doctor run. All 11 ACs and all 8 spec edge cases pass. One cross-item test conflict reported: the shipped 0001-state-model suite freezes .opencode/agent/doctor.md at HEAD, so this item's intended doctor change turns its 4 pre-existing failures into 5; the actual state-model AC6 (ignore policy) still passes. No production file changed by this pass."
---

# Verification — Read-only agent permissions and enforcement claims

## Summary

All eleven acceptance criteria and all eight spec edge cases are verified
against the current working tree (base `ff5a2fa`, nine modified files, all
uncommitted). The change is prompt/config/documentation text only; there is no
runtime code.

This pass changed **no production file**. It added one focused, independent
suite, `work/0003-framework-quality-hardening/0003-readonly-permissions/verify-tests.sh`
(110 assertions, 110/0), which is now this item's executable evidence and
complements the repository's existing suites. AC10 was verified by a real,
read-only `/doctor` run rather than a static proxy.

### Test command determination

There is no test runner in this repository. `AGENTS.md` → "Project profile" is an
unfilled template; the only `package.json` is `.opencode/package.json`
(`@opencode-ai/plugin` dependency, no `scripts.test`); there is no
`pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod`, or `.github/`. Confirmed by
inspection against the `project-discovery` skill. Matching the shipped items
(`work/0001-framework-consistency-hardening`, `work/0002-agentic-roadmaps`,
`work/0003-.../0001-state-model`, `.../0002-readiness-ship-state`), framework
verification is read-only shell assertions plus real agent invocation. The
per-item suite is `bash work/0003-framework-quality-hardening/0003-readonly-permissions/verify-tests.sh`.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash work/0003-framework-quality-hardening/0003-readonly-permissions/verify-tests.sh` | PASS | `TOTAL: 110 passed, 0 failed` (new suite) |
| `bash work/0002-agentic-roadmaps/verify-tests.sh` | PASS | `TOTAL: 179 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh` | PASS | `TOTAL: 69 passed, 0 failed` |
| `bash work/0001-framework-consistency-hardening/verify-tests.sh` | PASS | `TOTAL: 51 passed, 0 failed` |
| `bash work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` | FAIL (5; 4 pre-existing, 1 cross-item) | `TOTAL: 98 passed, 5 failed`; see residual risk |
| `git clone -q . /tmp/opencode/head-clone2 && git checkout -q ff5a2fa && bash <clone>/work/0003-.../0001-state-model/verify-tests.sh <clone>` | FAIL (4) | reproduces the 4 pre-existing failures on unmodified `HEAD`; proves they predate this item |
| `opencode run --agent doctor "run the framework consistency diagnostic"` | PASS | `No findings — repository is consistent.`; counts agents 14, commands 12, skills 10 |
| `opencode debug agent <six>` (via `jq`) | PASS | resolved `permission.bash` for all six contains no `rg*`/`find*` and keeps a `deny *` rule |
| `git diff --name-only` | PASS | exactly the nine expected files; no `opencode.json`, `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md` |
| 10 mutation runs on throwaway `/tmp/opencode` copies | PASS (all caught) | every targeted guard failed as designed; see mutation table |

### Resolved-permission evidence (stronger than reading frontmatter)

`opencode debug agent <agent>` resolves the effective rules. For each of the six,
the `bash` entries are `ask git push*`, `ask git reset --hard*`, `ask git clean*`,
`ask git branch -D*`, `ask rm -rf*`, `ask sudo*` (global), then the agent's
`deny *`, then only the pinned allow entries. No `rg*`/`find*` appears for any of
the six. `tester` resolves `bash` `allow *` (broad, as intended).

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — six agents grant neither `find*` nor `rg*`; catch-all still `"*": deny` | item AC1 (18 assertions: no `rg*/find*`, leading rule, explicit deny) + `opencode debug agent` resolved blocks | PASS |
| AC2 — every remaining entry reads repository state only | item AC2 (exact pinned allowlist **and** a write/execute denylist scan, per agent) + resolved blocks | PASS |
| AC3 — prompts don't route removed commands through bash; use file-search tools | item AC3 (`no bash \`rg\`/\`find\``, `Use the Read, Grep, and Glob tools`) + manual scan for command-shaped `rg`/`find` | PASS |
| AC4 — explicit no-write prohibition; guard framed as not-a-sandbox | item AC4 (canonical guard verbatim across all six; `Never use bash to create, write, move, or delete a file`; `not a sandbox`) | PASS |
| AC5 — README drops "cannot touch source"; scopes the claim to file tools | item AC5 | PASS |
| AC6 — README cells no longer "read-only allowlist"; best-effort + customization pointer | item AC6 (6 cells, per-row, footnote, link) | PASS |
| AC7 — README scopes enforcement to file tools; bash prefix-based, not a sandbox | item AC7 | PASS |
| AC8 — customization names `bootstrap`/`scout`/`tester`/`visual`, the scout residual, no sandbox; not `ask` | item AC8 (scoped to the caveat paragraph) | PASS |
| AC9 — tester edit allowlist covers `e2e/`,`spec/`,`integration/`,`cypress/`,`playwright/` both forms | item AC9 (10 patterns) | PASS |
| AC10 — permission diagnostic clean after the change | real `opencode run --agent doctor` → `No findings — repository is consistent.` | PASS |
| AC11 — no lifecycle/artifact/routing/global-default change | item AC11 + `git diff --name-only` (nine expected files only) | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| A prompt still tells its agent to run a removed command | item AC3 (bash `rg`/`find` scan + search-tool direction); manual scan found none | PASS |
| `tree -o` / git `--output=` remain write-capable | item EDGE (`tree -o file`, `output=file` in README; `output-to-file` in customization); covered by AC4 prohibition, not a rule | PASS |
| Catch-all ordering (deny must precede allows) | item AC1 (leading rule) + item EDGE (deny line < first allow line, per agent) | PASS |
| README table and agent blocks drift apart | real `/doctor` clean (PERMISSION-TABLE-MISMATCH / PERMISSION-WORK-PATTERN absent) + item AC6 | PASS |
| `tester` broad bash must not be documented as sandboxed | item AC6 footnote (`not a sandbox`), AC8 (`tester` in broad-bash list), EDGE README (`Agents with broad bash … tester`) | PASS |
| `ask` must not be listed as broad-bash | item AC8 (scoped caveat contains no `` `ask` ``) | PASS |
| Empty/degenerate test layouts behave unchanged | the added globs are static exact-name patterns and only ever match; no runtime path. Not directly exercisable without a consuming project — see residual risk | MANUAL |

## Mutation evidence

Each run copied the working tree to `/tmp/opencode/mut`, applied one mutation,
and ran the item suite with the copy as `ROOT`. Baseline on an untouched copy:
**110/0**. Production tree untouched.

| Mutation | Targeted guard | Observed |
| -------- | -------------- | -------- |
| Re-add `"rg*": allow` to `product` | AC1/AC2 | 3 failed (`AC1 product still grants rg*/find*`; `AC2 … drifted`; `AC2 … write/execute`) |
| Move `"*": deny` after the allows in `product` | AC1 ordering / EDGE | 2 failed |
| Add `"rm*": allow` to `status` | AC2 denylist | 2 failed |
| Delete the guard bullet from `architect` | AC3/AC4 | 4 failed |
| Remove `not a sandbox` from `product` | AC4 canonical | 2 failed |
| Re-add `cannot touch source` to README | AC5 | 2 failed |
| Change one README cell to `read-only allowlist` | AC6 | 3 failed |
| Replace `deliberate, accepted` in customization | AC8 | 1 failed |
| Delete `"playwright/**": allow` from `tester` | AC9 | 1 failed |
| Append a comment to `docs/workflow.md` | AC11 | 2 failed |

No mutation produced a false negative: each mutation was caught by the guard it
targets, and none passed while the targeted guard was violated.

## Gaps and residual risk

- **Cross-item test conflict (reported, not hidden).** This item changes
  `.opencode/agent/doctor.md` (required by AC1/AC3/AC4). The shipped
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh` AC6
  asserts `git diff --quiet HEAD -- .opencode/agent/doctor.md .opencode/command/doctor.md`
  — a whole-file freeze that no legitimate change to doctor can satisfy. Its
  result goes from **98/4 on clean `HEAD` `ff5a2fa`** to **98/5 in this working
  tree**; the fifth failure is exactly `AC6 doctor agent/command changed vs HEAD`.
  This item does **not** violate state-model's real AC6 ("the audit reports no
  **ignore-policy** finding"): the read-only `/doctor` run is clean, and the
  state-model suite's other AC6 assertions (`doctor` still requires
  `.playwright-mcp/` and `scratch/`, keeps `IGNORE-MISSING`, and the
  `git check-ignore` inputs agree) all pass. Recommendation for `/review`:
  either accept the delta as an over-broad proxy, or narrow that assertion to the
  ignore-policy content it was meant to guard. I did **not** edit the shipped
  item's evidence without approval.
- **`git branch*` prefix.** `status` retains `"git branch*": allow` (per the
  spec's resolved open question: keep the read-only git entries). By prefix match
  it also admits `git branch -D`/`-m`; a branch ref is not a file, and the entry
  predates this item, so it is not an AC2 violation. It is the same
  prefix-match class the spec accepts as residual (`tree -o`, `git --output=`).
- **Static exact-set snapshot.** AC2's pinned allowlists encode the security
  posture; a future intentional allowlist change must update both `design.md`
  and the item suite. AC1/AC3/AC4 are token/wording based and a sufficiently
  creative paraphrase could evade them (accepted, matching the design's own
  "token-based heuristics, not proofs" note).
- **Degenerate layouts.** The five new tester globs are static; that a project
  with no `e2e/` etc. is unaffected is self-evident from pattern matching and was
  not exercised against a consuming project (no such project exists in-repo).
- **No visual pass.** The change touches no user-facing UI; `docs/customization.md`
  is developer documentation. `/visual` is correctly skipped.
- **Pre-existing, unrelated.** The 4 state-model failures (AC1 artifacts now
  committed; `.gitkeep` tracked) reproduce on clean `HEAD` and are out of scope.

## Self-check

- No production file was modified by this pass: `git status --porcelain` lists
  the same nine tracked modified files as before this pass; the only additions
  are `verify-tests.sh` and this `verify.md`.
- No test was weakened, skipped, or deleted. The item suite is new (110
  assertions, all passing); the four other shipped suites are unmodified and
  three of them pass. The one suite that fails is a separate item's over-broad
  guard, fully reproduced and reported above.
