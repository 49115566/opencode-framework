---
feature: 0004-adoption-template-split/0001-adopter-template-split
phase: review
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0004-adoption-template-split
---

# Review — Adopter/maintainer template split

## Verdict

**approve** — all seven acceptance criteria are met, the committed changes are
correct and tightly scoped, and no Blocker or Major finding survives scrutiny;
the remaining findings are clarity nits that do not affect the contract.

## Base and scope

The work is uncommitted on `main`, which is level with `origin/main`; there is no
feature branch yet, so the base is simply `HEAD`.

Commands used (exact):

- `git merge-base HEAD origin/main` → `8c4102d83aba57a1d1b172498c4c5788a4793273`
- `git rev-parse HEAD` → `8c4102d83aba57a1d1b172498c4c5788a4793273`
- `git status --porcelain` → `M AGENTS.md`, `M README.md`,
  `M docs/customization.md`, `M tests/mutation.sh`, `?? template/`,
  `?? work/0004-adoption-template-split/`
- `git diff` (the four tracked modifications; shown above in the phase run)
- `git diff --no-index AGENTS.md template/AGENTS.md`,
  `git diff --no-index opencode.json template/opencode.json`,
  `git diff --no-index .gitignore template/.gitignore`
- direct reads of the untracked `template/{AGENTS.md,opencode.json,.gitignore}`
  and of the test harness (`tests/run.sh`, `tests/mutation.sh`,
  `tests/checks/{40,50,90}-*.sh`, `tests/README.md`).

The new `template/` tree and the `work/0004-…` artifacts are untracked, so they
appear only in `git status`, not in `git diff`; both were read directly.

**Verification limitation.** My sandbox allowlist denies non-git `bash`, so I
could not independently re-run `bash tests/run.sh` or `bash tests/mutation.sh`.
I instead reviewed the checks line by line against the diff and the tester's
recorded `verify.md` output. Every changed surface was statically traced to the
assertions that read it; I found no path by which the change flips a check. AC6
therefore rests on the tester's evidence plus this static trace, and is called
out below.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 — adopter-pristine source exists for each of `AGENTS.md`, `opencode.json`, `.gitignore` and holds no framework-bootstrapped value | **met** | `template/AGENTS.md`, `template/opencode.json`, `template/.gitignore` all exist. `git diff --no-index AGENTS.md template/AGENTS.md` shows the pristine file's profile is the placeholder block (`template/AGENTS.md:13-24`); the root has the filled profile. `git diff --no-index opencode.json template/opencode.json` and `… .gitignore` are empty (byte-identical). `opencode.json` currently contains only shipped framework defaults (`model`, disabled agents, baseline permissions, `mcp.playwright.enabled: false`), none of which `/bootstrap` writes, so the byte-identical edge case is satisfied. |
| AC2 — root profile holds verified values or explicit `none`, no placeholder text | **met** | `AGENTS.md:13-22` has all ten fields; `Test` = `bash tests/run.sh`, eight fields `none`, `Purpose`/`Key directories` filled. The placeholder comment and `_e.g._` text are removed (`git diff AGENTS.md`). |
| AC3 — pristine `AGENTS.md` still presents the placeholder profile | **met** | `template/AGENTS.md:13-24` carries the `<!-- /bootstrap … -->` comment and all ten `_e.g._`/sentence placeholders; it does not contain `bash tests/run.sh`. |
| AC4 — contract names both copies for all three files and states `docs/*.md` shared verbatim; no copied file ambiguous | **met** | `docs/customization.md:30-34` table maps `template/AGENTS.md` ↔ root `AGENTS.md`, `template/opencode.json` ↔ root `opencode.json`, `template/.gitignore` ↔ root `.gitignore`; lines 36-40 state the single-source/verbatim rule for `.opencode/{agent,command,skill}` and `docs/*.md` and that `docs/*.md` are never templated. |
| AC5 — no maintainer-bootstrapped value in the framework copy appears in the pristine source | **met** | `template/AGENTS.md` lacks the root `Purpose` sentence, `bash tests/run.sh`, and the `none (opencode …)` value; `opencode.json`/`.gitignore` are byte-identical with no bootstrapped value to leak. |
| AC6 — `bash tests/run.sh` passes; packaging/inventory/instruction agreements not regressed | **met** | Tester recorded `TOTAL: 182 passed, 0 failed, 0 skipped` and `MUTATION TOTAL: 25 checked passed, 0 failed`. Static trace: AC20's forward check reads `README.md:260-263` and finds the four new paths on disk; the reverse check finds the new non-hidden root entry `template` documented as `template/` (`README.md:260`); AC9's count regex ignores the new comment lines; AC10's `cust_instruction_paths` only scans the `## Always-loaded instructions` section, which the new section precedes; AC19's claim/cp regexes do not match the new prose. `tests/mutation.sh:66` stages `template/` so the mutation copy satisfies AC20. |
| AC7 — config parses and root `AGENTS.md` is the contract; pristine source not loaded | **met** | Tester recorded `opencode debug config` exiting 0 with `instructions = ["AGENTS.md","docs/workflow.md","docs/artifact-conventions.md"]` and no `template/` references; `opencode.json:6-10` still names root `AGENTS.md`. `template/opencode.json` is not in opencode's upward project-config walk, so it cannot become the framework's contract. (Not independent — see limitation.) |

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] Maintainer `AGENTS.md` still describes itself as an unfilled template** —
  `AGENTS.md:7-9`.
  The root copy's Project profile is now bootstrapped, but the always-loaded
  blockquote still reads "This file ships as a template… Until then, treat stack
  commands as 'discover at runtime'." Because `AGENTS.md:3-5` loads into every
  agent in this repository, the two statements now contradict each other and can
  prompt an agent to distrust a profile that is in fact filled. `AC2` is scoped to
  the profile fields and is met; this is a clarity defect, not an AC failure.
  The design chose to leave the blockquote to match `/bootstrap`'s "change
  nothing else" rule, which applies to an adopter's file — not to the maintainer
  copy.
  Recommendation: remove or reword lines 7-9 in the root `AGENTS.md` only (leave
  `template/AGENTS.md:7-9` untouched), or state explicitly that the profile has
  already been bootstrapped for this repository.

### Nits

- **[n1] `docs/customization.md:38` calls `.opencode/{agent,command,skill}`
  "shared verbatim", but the quickstart deletes the doctor files** —
  `docs/customization.md:38`, cf. `README.md:47-48,58-65`.
  The source is indeed a single, untemplated source, so the design intent is
  preserved, but "shared verbatim" overstates the adopter's final tree. Child
  `0002` owns the surrounding copy-set prose, so take or leave.
  Recommendation: soften to "has a single source" and let `0002` add the doctor
  exclusion.

- **[n2] Always-loaded cost table understates the token estimate** —
  `docs/customization.md:57-62`.
  Measured sizes (`ls -l`): `AGENTS.md` 7 594 B, `docs/workflow.md` 18 298 B,
  `docs/artifact-conventions.md` 13 190 B; total 39 082 B ≈ 9.8k tokens at 4 B/token,
  while the table shows `~9.6k`. The refreshed KB values are accurate; only the
  rounded token sums drift. Beyond T4's stated `AGENTS.md` row, the builder also
  refreshed the `workflow.md`/`artifact-conventions.md` rows — both were stale and
  the new values are correct, but those two files are unchanged by this item, so
  the edit is slightly out of the task's literal scope (disclosed in
  `verify.md`).
  Recommendation: state the total as `~9.8k` (or keep per-row rounding and note
  the total is the sum of rounded rows).

- **[n3] The contract section names `template/*` paths inside a file copied
  verbatim to adopters** — `docs/customization.md:21-40`.
  Adopters receive `docs/customization.md` but not `template/`, so they will read
  references to paths that do not exist in their repository. The text is framed
  as framework-repository organization and `0002` reconciles the surrounding
  copy-set prose, so this is expected; flagging only so it is not lost.
  Recommendation: no change required for this child; ensure `0002` marks the
  section maintainer/framework-scoped.

## Accepted residual risks (not findings)

- **Intermediate quickstart leak window.** `README.md:49` still copies root
  `AGENTS.md` (now bootstrapped) and root `opencode.json`/`.gitignore`. Running
  the documented quickstart before child `0002-bootstrap-quickstart-rework` would
  ship the maintainer profile. The spec explicitly accepts this ("Unprotected
  intermediate window"), scopes AC1/AC5 to the pristine source, and sequences
  `0002` immediately after; the design forbids a release/cutover between the two.
  This reviewer concurs that it is in-scope and correctly deferred, but it is a
  hard operational gate: **no release or quickstart cutover may occur before
  `0002` lands**, and `0003-split-guard-tests` must add the committed guards.
- **Pristine/maintainer drift for `opencode.json`/`.gitignore`.** Their pristine
  copies are byte-identical today only because the framework's copies carry no
  bootstrapped values (Playwright MCP still disabled). If the framework later
  enables it via `/bootstrap`, the pristine copies will silently diverge from
  what adopters should get until a snapshot is taken and `0003`'s guards cover
  it. Correctly deferred, already recorded in `verify.md`.
- **AC7 is asserted from the tester's `opencode debug config` capture**, not
  re-run here (see the limitation above). The static argument — opencode merges
  project config walking upward, and `instructions` names root-relative paths —
  is plausible and matches the design; if a maintainer wants stronger assurance,
  re-running `opencode debug config` on a machine with the CLI closes it.

## Scope, security, and conventions

- Scope is exactly the design's "Affected areas": three new `template/` files,
  `AGENTS.md` profile, `docs/customization.md`, `README.md` `## Layout`, and
  `tests/mutation.sh` staging. No other source, config, test, or dependency
  changed; `opencode.json`, `.gitignore`, `.opencode/**`, and `docs/workflow.md`
  are untouched. The single out-of-scope edit is the always-loaded table rows
  noted in `[n2]` (benign, disclosed).
- No secrets, credentials, debug output, or commented-out code. `template/` is
  intended to be committed and is trackable (`git status` shows it untracked, not
  ignored); the nested `template/.gitignore` only governs its own subtree and
  ignores nothing that matters here.
- Conventions fit: artifacts carry correct canonical `feature`/`parent`
  frontmatter; `README.md` `## Layout` uses the existing indented style; the
  `tests/mutation.sh` edit matches the surrounding `cp` idiom.
- No `visual.md` exists and none is required — this is a prompt/config/doc/test
  item with no user-facing surface. No UI findings to weigh.

## Not reviewed

- Child `0002`+ surfaces (quickstart commands, `/bootstrap`, `/doctor`, the
  signature sweep) — explicitly out of scope.
- The correctness of opencode's upward-only config discovery beyond the
  documented behavior and the tester's capture (see AC7 note).
- The mutation harness and full committed suite were not re-executed here due to
  the sandbox allowlist; their content was reviewed, not run.

Done: `work/0004-adoption-template-split/0001-adopter-template-split/review.md` — verdict: approve.
Checks: ACs met 7/7; blockers 0; majors 0; minors 1; nits 3.
Next: `/ship 0004-adoption-template-split/0001-adopter-template-split`.
Blockers: none — but do not release or run the quickstart as documented until `0002-bootstrap-quickstart-rework` lands and `0003-split-guard-tests` adds the committed guards.
