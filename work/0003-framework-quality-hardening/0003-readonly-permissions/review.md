---
feature: 0003-framework-quality-hardening/0003-readonly-permissions
phase: review
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Review — Read-only agent permissions and enforcement claims

## Verdict

**approve** — all 11 acceptance criteria are met, the change is scoped exactly
to the nine declared files, and no Blocker or Major defect was found; one
cross-item test conflict is real and must be consciously accepted or fixed at
ship (Minor M1).

## Review basis

- Base ref: `ff5a2fa` (`git merge-base HEAD main` and
  `git merge-base HEAD origin/main` both resolve to it; `git rev-parse HEAD`
  equals it). All changes are **uncommitted**: `git diff HEAD`.
- Commands used: `git status`, `git rev-parse HEAD`, `git log --oneline -8`,
  `git merge-base HEAD main`, `git merge-base HEAD origin/main`,
  `git diff --name-only HEAD`, `git diff HEAD`, plus `rg`/`read` over the
  changed files and their neighbours.
- Diff scope: exactly nine tracked files modified
  (`README.md`, `docs/customization.md`, and six read-only agents + `tester`),
  plus five new untracked work-item files. No source, config, lifecycle doc,
  or global-permission file is touched.
- I could not execute `opencode` or any shell suite in this read-only review
  environment (bash is restricted to git/ls/cat/rg/find), so AC10 rests on the
  real `/doctor` run recorded in `verify.md`; that is stated under AC10 and
  "Not reviewed".

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] Cross-item regression guard is now red** —
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh:178-180`
  vs `.opencode/agent/doctor.md:183-187`.
  The shipped state-model suite asserts
  `git diff --quiet HEAD -- .opencode/agent/doctor.md .opencode/command/doctor.md`,
  a whole-file freeze that **no** legitimate doctor change can satisfy. This item
  is required by its own spec to edit `.opencode/agent/doctor.md` (AC1, AC3,
  AC4), so that assertion fails: `verify.md` reports 98/4 → 98/5. The design's
  "Affected areas"/"Risks" did not identify this conflict, and the task list had
  no task to reconcile it. This is a defect in the sibling's over-broad guard,
  not in this item's production change — the state-model suite was already
  failing 4/98 at `ff5a2fa`, so this does not turn a green suite red.
  **Fix (recommended):** narrow the state-model assertion to the ignore-policy
  semantics it was meant to protect (already asserted at
  `verify-tests.sh:182-189`), or record the accepted delta with user sign-off in
  this item's `verify.md` notes. Because the remedy edits another item's test,
  the user owns the call; it should be settled before `/ship`.

### Nits

- **[N1] `git branch*` remains a prefix-match escape hatch** —
  `.opencode/agent/status.md:12`. It also matches `git branch -D`/`-m`. The
  spec's resolved open question explicitly chose to keep the read-only git
  entries and accepted the prefix-match class (`tree -o`, `--output=`), and a
  branch ref is not a file, so this is not an AC2 violation — noted only.
- **[N2] Broad-bash list excludes `shipper`** — `README.md:197-203`,
  `docs/customization.md:136-141`. `shipper`'s `git`/`gh` allowlist is itself
  write-capable, but it is intentionally scoped rather than "broad", so its
  omission from the four-agent list matches AC8. No action.

## Acceptance criteria coverage

| # | Criterion | Verdict | Evidence |
| - | --------- | ------- | -------- |
| AC1 | Six agents grant neither `find*` nor `rg*`; leading rule still `"*": deny` | **met** | Diff removes both lines from all six; `git diff` + `product.md:10-16`, `architect.md:10-16`, `roadmap.md:10-16`, `status.md:7-14`, `reviewer.md:10-19`, `doctor.md:8-15` show `"*": deny` first. |
| AC2 | Every remaining allowed entry is read-only inspection | **met** | Remaining keys are `ls`/`cat`/`tree` + read-only git (`log`, `diff`, `show`, `status`, `branch`, `merge-base`, `rev-parse`, `blame`, `check-ignore`); no writer/executor remains. Accepted prefix residuals (`tree -o`, `--output=`, `git branch*`) are documented. |
| AC3 | Prompts do not route removed commands through bash; direct to search tools | **met** | `rg '\brg\b|\bfind\b'` over the six finds only prose (`product.md:63`, `architect.md:25`, `reviewer.md:25`); no command-shaped `rg`/`find`. Guard bullet names `Read, Grep, and Glob`. |
| AC4 | Explicit no-write bash prohibition; framed as guard, not sandbox | **met** | Identical guard bullet appended in all six (`product.md:107`, `architect.md:100`, `roadmap.md:132`, `status.md:169`, `reviewer.md:97`, `doctor.md:183`): "best-effort guard, not a sandbox … Never use bash to create, write, move, or delete a file". |
| AC5 | README drops "cannot touch source"; scopes claim to file tools | **met** | `README.md:23-27`; `rg 'cannot touch source'` returns nothing. |
| AC6 | README bash cells no longer "read-only allowlist"; best-effort + caveat pointer | **met** | `README.md:169-182` six `read-only, best-effort †` cells; footnote `:184-188` links `docs/customization.md`; `rg 'read-only allowlist' README.md` returns nothing. |
| AC7 | README scopes enforcement to file tools; bash prefix-based, not sandbox | **met** | `README.md:190-195` ("File-tool permissions are enforced … create, write, and patch") and `:197-203` (best-effort, command prefix, redirection, output flags). |
| AC8 | Customization names all broad-bash agents, scout residual, no sandbox, not `ask` | **met** | `docs/customization.md:133-141` names `bootstrap`, `scout`, `tester`, `visual`; "deliberate, accepted residual"; "not a sandbox for `bash`"; no `ask`. |
| AC9 | Tester edit allowlist covers five layouts in both path forms | **met** | `.opencode/agent/tester.md:15-24`: ten patterns for `e2e/`, `spec/`, `integration/`, `cypress/`, `playwright/`. |
| AC10 | Permission diagnostic runs clean (no drift finding) | **met (per evidence; not independently re-run)** | `verify.md:48` records `opencode run --agent doctor` → `No findings — repository is consistent.` I manually compared the README table cells against the six + `tester` blocks and found no drift, but could not invoke opencode here. |
| AC11 | No lifecycle phase, artifact format, routing, or global default changed | **met** | `git diff --name-only HEAD` lists only the nine expected files; `opencode.json`, `docs/workflow.md`, `docs/artifact-conventions.md`, `AGENTS.md` are absent. |

All 11 criteria: met.

## Test quality

- The new `verify-tests.sh` (110 assertions) is independent, read-only against
  the repo, and anchored to observable state: it parses frontmatter bash/edit
  blocks, compares each agent's allowlist against a pinned set, rejects any
  writer/executor via a denylist regex, checks the guard wording verbatim, and
  asserts the catch-all precedes the first allow. `verify.md` records 10
  mutation runs, each caught by its targeted guard. This is stronger evidence
  than the design's minimum.
- Cross-checked the added suite's assertions by reading the target files; the
  pinned allowlists in `expected_bash` (`verify-tests.sh:73-84`) exactly match
  the on-disk blocks, and `CANON_GUARD` (`:86`) matches all six bullets.
- One suite-level fragility, not a defect: AC11's expected-changed list is
  HEAD-relative and assumes the work artifacts stay untracked; once `/ship`
  commits them and the tree is clean the comparison is empty and still passes.

## Security, scope, and other checks

- **Security:** No secrets, credentials, or `.env` content in the diff. The
  change narrows capability (removes `rg --pre` and `find -delete`/`-exec`) and
  makes the documentation truthful; it introduces no runtime or dependency.
- **Error handling / edge cases:** Not applicable (prompt/config/docs only). The
  spec's edge cases are addressed: no bash `rg`/`find` instructions remain
  (AC3), the catch-all stays leading (AC1), and the documented residuals
  (`tree -o`, `--output=`) are covered by the guard plus AC7/AC8 text.
- **Convention fit:** Frontmatter permission maps, `<rules>` bullets, table
  style, and footnote convention match the repository. The README guardrail
  anchor `docs/customization.md#permissions` resolves to the existing
  `## Permissions` heading (`docs/customization.md:94`).
- **Scope:** Exactly the nine files named in `design.md` → "Affected areas"; no
  scope creep. The only incidental change is table-column whitespace in
  `README.md`, which is cosmetic.
- **Performance:** No hot paths; no runtime.
- **Backward compatibility:** Only the intended behavioral change (read-only
  agents lose bash `rg`/`find`), and the Grep/Glob/Read tools cover inspection.
  No user-facing UI, so skipping `/visual` is correct.

## Not reviewed

- I could not execute `opencode` or the shell suites here; the AC10 `/doctor`
  result and the mutation evidence are taken from `verify.md` as reported.
- The state-model suite's four pre-existing failures at `ff5a2fa` (unrelated to
  this item) and the sibling items' contents are out of this item's scope beyond
  the conflict recorded as M1.
- No `visual.md` exists and none is expected (non-UI work).

Done: `work/0003-framework-quality-hardening/0003-readonly-permissions/review.md` — verdict: approve.
Checks: ACs met 11/11; blockers 0; majors 0; minors 1.
Next: `/ship 0003-framework-quality-hardening/0003-readonly-permissions` (settle Minor M1 at ship).
Blockers: none.
