---
feature: 0006-parallel-plan-conflicts/0004-conflict-guards
phase: review
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
---

# Review — Committed guards for the declared-conflict model and check

## Verdict

**approve** — the change is test-only, faithfully pins the shipped declaration
model and reporting vocabulary with fixture-based guards, and I found no Blocker
or Major; the two low-severity findings below are polish, not merge blockers.

## Base and diff

Commands used to establish the range:

- `git merge-base HEAD origin/main` → `4224f2049006872435f0b6b2c0f57782b73d2e1a`
- `git rev-parse HEAD origin/main` → HEAD = `4224f20…`, origin/main = `eec5adb…`
  (HEAD is an ancestor of origin/main, so the plan-record commit is already on
  the default branch; the committed range `origin/main...HEAD` is empty)
- `git status` / `git status --porcelain` — the implementation is **uncommitted**:
  5 modified tracked files plus 3 untracked paths
- `git diff HEAD` — the tracked diff
- Untracked files enumerated with Glob (the sandbox denies `find`): the new
  check, the new fixture tree, and the tester's `verify.md`.

Because the item's implementation is uncommitted on top of the plan record
(`4224f20`), the reviewable change is `git diff HEAD` plus the untracked new
files. **I did not re-execute `bash tests/run.sh` or `bash tests/mutation.sh`** —
the review sandbox's bash policy denies arbitrary command execution. Findings
below are from static analysis of the full diff and from the tester's recorded
evidence in `verify.md`; where approval depends on a runtime result I say so.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — cyclic fixture on the 6-column layout, cycle still proven, `Depends on` still at the same field | **met** | `tests/fixtures/cyclic-roadmap/roadmap.md:26-29` header + `—` cells; `tests/checks/80-cycle-fixture.sh:31` exact-header literal updated; the Kahn parser is untouched at `:50` (`id = a[2]; dep = a[5]`), which remains correct for the 6-column row shape (split yields `a[5]=Depends on`, `a[6]=conflicts-with`). |
| AC2 — every cell `—` or a well-formed list; malformed/unresolved fails and names the area | **met** | `85:412-447` expected resolution/unresolved blocks; `85:147-156` structural malformation; `85:466-485` exact comparison. Each malformed class has a fixture (`9015`, `9016`, `9017`, `9018`). |
| AC3 — two unshipped plans sharing a target is a genuine conflict | **met** | `85:456` expects `9001-roadmap-a/0001-shared|9010-surface-shared|(a)`; `9010-surface-shared/design.md:7` and the roadmap cell share `docs/artifact-conventions.md`. |
| AC4 — one-sided naming of a silent item is a conflict | **met** | `85:458-460`; `9011-names-silent/design.md:7` and `9020-shares-silent/design.md:7` name `9012-silent`, which has no `design.md`. |
| AC5 — sibling / canonical item / file+dir surface / `—` / absent / malformed / self / dup / empty / non-existent each resolve as expected | **met** | `85:412-462` enumerate all outcomes; `85:487-503` prove sibling-first vs the top-level `0001-shared` decoy and that `—`/absent yield no target. |
| AC6 — union of own + parent cell; both-present unequal is drift; one-sided is not | **met** | `85:449-452` expects exactly `9001-roadmap-a/0003-drift`; `85:227-234` implements the rule; `85:492-497` proves the union includes both surfaces; `9001-roadmap-a/0001-shared` (one-sided) is absent from the drift block. |
| AC7 — shipped item excluded as counterpart but still resolves as a target | **met** | `85:424` `9013-names-shipped` resolves to `9001-roadmap-a/0004-shipped`; `85:529-533` assert the shipped child is absent from the conflict set; `0004-shipped/ship.md` is the sole shipped signal. |
| AC8 — shipped grammar, codes, `(a)`–`(d)` classes for the four situations, no new class/code/policy | **met** | `85:569-597` assert the authority section (extracted by heading) contains `TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT`, `(a)`, `(b)`, `(d)`, and the grammar literal; `85:599-614` assert the skill grammar + planning-time block; `85:616-623` assert the four operative prompts reference the authority. Verified statically: `docs/workflow.md:430-556` is the section and contains the literal at `:512`; the skill literal is at `SKILL.md:99`. |
| AC9 — reads only committed fixtures + live surfaces, never live `work/**`; no committed executable checker | **met (residual noted)** | `85:373-377` read-only contract; the guard's resolution roots are `tests/fixtures/declared-conflicts/items/` and the repo copy root, never `work/`. "No executable checker added" is a diff-level property with no dedicated assertion — the tester calls this out (`verify.md:114`), consistent with AC9's wording. |
| AC10 — existing readiness/cycle/inventory stay green; no duplicate assertion | **met** | Static: `85` reads no readiness/cycle/inventory input; its cycle/positional assertion is scoped to the declaration fixture, while `80` keeps the cyclic fixture. Green suite is per `verify.md:37`. |
| AC11 — each new guard mutated, caught, named; escaped mutation fails | **met** | `tests/mutation.sh:296-335` add five `AC23` cases; `:72` stages the fixture; expectations require `FAIL  AC23 <sub-area>` (not an `ok` label). See Minor [M1] on mutation #4's precision. |
| AC12 — suite documents the area and token; existing list/tokens stay accurate | **met** | `tests/README.md:79` Checks row, `:112-134` `AC23` criterion mapping and manual-residual sentence; existing `AC18`–`AC22` rows/paragraphs untouched. |
| AC13 — fresh clone with no `work/` exits 0 with new assertions satisfied | **met (per tester)** | Verified by fixture-scoped reads from `tests/fixtures/**` + live surfaces; the tester ran an independent no-`work/` copy (`verify.md:39`). Static review finds no `work/` read. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] The "pair predicate" mutation does not isolate the pair predicate — it also breaks cell resolution.** `tests/mutation.sh:321-327` changes `9010-surface-shared`'s target from `docs/artifact-conventions.md` to `README.md` and expects `FAIL  AC23 pair-predicate`. Because that mutation changes the token's *resolved identity*, the exact resolution-block comparison at `tests/checks/85-conflict-guards.sh:466-471` also fails, so the run names `AC23 cell-resolution` in addition to `AC23 pair-predicate`. The mutation still satisfies AC11 (the required substring is present and the suite is non-zero), but the design and verify claim mutation #4 "keeps resolution valid and breaks only the pair predicate" (`design.md:185`, `verify.md`), which is inaccurate and means the pair-predicate guard is never exercised without a co-failing resolution assertion. Recommendation: either correct the design/verify wording, or add a scenario whose *resolution stays identical* while the conflict classification changes (e.g. two unshipped items that both resolve to the same surface but are expected to be classified `(b)` rather than `(a)`), so the pair-predicate assertion is shown to fail on its own.

### Nits

- **[N1] Misleading assertion label.** `tests/checks/85-conflict-guards.sh:526-528` labels the `9012-silent|9020-shares-silent|(b)` assertion "shared work/ item target"; it is a shared *canonical item reference*, not a `work/` surface path. Rename to "shared item target" for clarity.

- **[N2] Negative-control coverage is prefix-based.** `tests/checks/85-conflict-guards.sh:590-597` and `:609-614` reject only the literal prefixes `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-`. A new code without those prefixes (e.g. `OVERLAP-X`) would pass. This is an inherent limitation of a no-committed-checker vocabulary guard and is already recorded as residual in `verify.md`; worth a short comment in the guard so a future maintainer knows the negative controls are illustrative, not exhaustive.

## Tests

- The guard is itself test code; I read it for quality. The four analyzers
  (`85:304-352`) are exact-block compared against the reviewed contract, so the
  checks are not vacuous — an emptied fixture changes `ACT_*` away from `EXP_*`
  and fails. The empty-compared-set assertions (`85:540-565`) drive the analyzer
  with a synthetic event stream rather than a fixture, which is a reasonable way
  to cover the no-declaration/all-shipped paths without new files.
- Mutation staging is correct: `tests/mutation.sh:72` copies the new fixture into
  the scratch tree, and each new mutation is followed by `restore_file` +
  `assert_clean_absent`. `restore_file` copies from the working tree
  (`mutation.sh:112-115`), so it works for the new (currently untracked) fixture
  and will continue to work once committed.
- The exact-header assertion in `80` (`:31`) and the positional parser (`:50`)
  stay consistent with the fixture, so AC1 is genuinely guarded.
- I could not independently re-run the suite in this sandbox; the PASS counts in
  `verify.md` are the tester's evidence, and my static trace of the expected
  blocks against the fixture data agrees with them.

## Security and scope

- No secrets, credentials, network access, or new dependencies; the change is
  pure bash/awk over committed fixtures.
- No production surface (`docs/**`, `.opencode/**`, root docs/config,
  `template/**`) is touched — confirmed by `git status --porcelain` and by the
  diff. The only non-test change is the builder's `tasks.md` check-box update and
  the tester's `verify.md`, both expected.
- No scope creep observed: the cyclic-fixture header update is required by AC1,
  and the `mutation.sh` header-comment change (`:15`, adding `AC22`/`AC23`)
  corrects an existing stale list as part of AC11.

## Not reviewed

- The live model run of the check (`/conflicts`, `/status`, `/build`-gate) is not
  executable in CI by design; it is correctly documented as a manual residual in
  `tests/README.md:132-134` and `verify.md`.
- Whether `docs/workflow.md:437-438`'s phrase "no committed fixture or agreement
  area" is now literally stale after this child adds one. Editing that authority
  is a non-goal for this item (spec non-goal: production surfaces are frozen), and
  the sentence is scoped to the prompt-only check's execution, so it is not a
  finding against this diff — flagging it only as an observation for `0001`–`0003`
  owners.

Done: `work/0006-parallel-plan-conflicts/0004-conflict-guards/review.md` — verdict: approve.
Checks: ACs met 13/13; blockers 0; majors 0; minors 1; nits 2.
Next: `/ship 0006-parallel-plan-conflicts/0004-conflict-guards`.
Blockers: none.
