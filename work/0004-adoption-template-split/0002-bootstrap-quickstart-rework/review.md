---
feature: 0004-adoption-template-split/0002-bootstrap-quickstart-rework
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
---

# Review — Bootstrap and quickstart rework

## Verdict

**approve** — all nine acceptance criteria are met, the change is tightly scoped
to the six surfaces the design names, and no Blocker or Major finding survives
scrutiny; the findings that remain are wording and process-quality items that do
not affect the split contract.

## Base and scope

The work is uncommitted on `main`, level with `origin/main`. There is no feature
branch, so the base is `HEAD`.

Commands used (exact):

- `git merge-base HEAD origin/main` → `28da4d0974020e51f17d05d54765e4de58857c5c`
- `git log --oneline -20` → tip `28da4d0 Merge pull request #13 …0001-adopter-template-split`
- `git status` → 6 modified tracked files, 4 untracked artifacts under
  `work/0004-adoption-template-split/0002-bootstrap-quickstart-rework/`
- `git diff --stat` → `.opencode/agent/bootstrap.md`, `.opencode/command/bootstrap.md`,
  `CONTRIBUTING.md`, `README.md`, `docs/customization.md`, `tests/README.md`
  (86 insertions, 30 deletions)
- `git diff` (full; read in the phase run)
- Grep sweeps for `FRAMEWORK/(AGENTS|opencode|\.gitignore)`, `quickstart cop(y|ies)`,
  `root \`AGENTS.md\``, and `template/` across live surfaces
- Direct reads of `template/{AGENTS.md,opencode.json,.gitignore}`, `opencode.json`,
  root `AGENTS.md`, `docs/customization.md`, `tests/README.md`, `tests/run.sh`,
  `tests/lib.sh`, `tests/mutation.sh`, and
  `tests/checks/{10,20,30,40,50,90}-*.sh`

**Verification limitation.** My sandbox allowlist denies non-git `bash`, so I
could not independently re-run `bash tests/run.sh` or `bash tests/mutation.sh`. I
traced every changed surface to the assertions that read it and found no path by
which the change flips a check; AC7/AC8 therefore rest on the tester's recorded
evidence plus this static trace.

**Not in the diff.** The untracked item artifacts (`spec.md`, `design.md`,
`tasks.md`, `verify.md`) are the phase documents, not code; they were read but are
not part of the reviewed change. `template/**`, root `AGENTS.md`, `opencode.json`,
and `.gitignore` are unchanged, as the design requires.

## Acceptance criteria

| # | Criterion | Status | Evidence |
| - | --------- | ------ | -------- |
| AC1 | Quickstart copies each of the three from `template/`, none from root | **met** | `README.md:49-51` are three `cp "$FRAMEWORK/template/<file>" ./<file>` commands; grep of every live surface finds no `cp …"$FRAMEWORK/AGENTS.md"`-style command (`git grep`). |
| AC2 | Documented quickstart in an empty project yields placeholder `AGENTS.md`, pristine `opencode.json`/`.gitignore`, no `template/` | **met** | `template/AGENTS.md:13-24` holds the placeholder profile; `template/opencode.json`/`template/.gitignore` are byte-identical to root (grep of `README.md:50-51` sources them from `template/`); the quickstart creates no `template/` dir. Tester reproduced this in `/tmp/opencode/qscheck-ac2` (`verify.md:34-49`). |
| AC3 | Resolved bootstrap edit permissions deny `template/`, allow adopter root files | **met** | `.opencode/agent/bootstrap.md:15-16` append `"template/**": deny` and `"**/template/**": deny` after every allow; `docs/customization.md:163-165` documents last-match-wins; tester's `opencode debug agent bootstrap` inspection shows the two denies last (`verify.md:19,52-58`). |
| AC4 | Bootstrap agent and command state adopter-copy ownership and never-modify | **met** | Agent: `bootstrap.md:55-59,96-114,129-131,142-145`; command: `command/bootstrap.md:11-16,23-29`. |
| AC5 | All four copy-set surfaces name `template/` sources, framework copies, shared-verbatim | **met** | `README.md:60-70`; `docs/customization.md:30-39,64-69`; `tests/README.md:8-16`; `CONTRIBUTING.md:129-136`. |
| AC6 | No copy-set surface claims an adopter receives a root copy | **met** | Each surface explicitly marks the root copies maintainer-bootstrapped/never copied; no root-source `cp` remains in any live surface. |
| AC7 | `bash tests/run.sh` exits 0 | **met** | Tester recorded `TOTAL: 182 passed, 0 failed, 0 skipped` (`verify.md:17`). Statically traced: AC19 claim/cp regexes and AC10 path extraction are not tripped by the new prose; AC8 derives the same `config+work` class. |
| AC8 | `bash tests/mutation.sh` reports zero failed mutations | **met** | Tester recorded `MUTATION TOTAL: 25 checked passed, 0 failed`, including `mutation AC19 caught and named` (`verify.md:18`). The mutation's target literal `` `docs/*.md`) `` is still the tail of the `.opencode/`-bearing parenthetical at `tests/README.md:13-14`. |
| AC9 | Merge advisory retained; no migration/deletion step added | **met** | `README.md:97-98` retains "merge rather than overwrite"; the quickstart's `rm -f` set is unchanged from `HEAD` (no new `rm`/`mv`/migration). |

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] Bootstrap command says "the adopter's own copies" in the framework-repo context** — `.opencode/command/bootstrap.md:12-14` (and, less sharply, `.opencode/agent/bootstrap.md:55-58`).
  In an adopted repository the root `AGENTS.md`/`opencode.json`/`.gitignore` were
  received from `template/`, so "the adopter's own copies" is true; in the
  framework repository itself the root copies are the maintainers'
  bootstrapped originals, not copies received from `template/`. The spec lists
  this exact context-mismatch edge case and requires the wording to be truthful
  in both contexts. The agent body already uses the neutral phrasing
  ("this repository's own root copies"), so the command is the outlier.
  Recommendation: s/"the adopter's own copies"/"this repository's own root
  copies"/ in `command/bootstrap.md:12-14` (the following sentence about
  `template/` already carries the framework-repo meaning and stays truthful for
  adopters, who simply have no `template/`).

- **[m2] T6 is checked while its own `Verify:` is recorded as failing** — `tasks.md:59-68`.
  The task's stated verification includes an `awk` assertion that
  `tasks.md:8`'s notes call out as over-matching, and the box is ticked with
  "Verify failing; human checked." The underlying criterion is genuinely met by
  a stronger method (`opencode debug agent bootstrap` ordering), so this is not
  an unmet AC — but a checked task whose declared `Verify:` does not pass
  weakens the build/test evidence chain the lifecycle relies on.
  Recommendation: child `0003-split-guard-tests` should replace the
  over-matching `awk` with the ordered-permission assertion it can commit; until
  then, record in `tasks.md` that the `awk` check is superseded by the resolved
  `permission.edit` inspection rather than left as a bare "Verify failing".

### Nits

- **[n1] Ambiguous "this change" antecedent** — `CONTRIBUTING.md:138`.
  "Because this change adds no files to the copied set…" now follows the
  inserted split paragraph, so "this change" reads as the split rather than the
  earlier packaging change it originally referred to. The statement remains true
  of both, so this is only a clarity nit.
  Recommendation: say "Because neither change adds files to the copied set…" or
  reword to "Because the copy-set membership is unchanged…".

- **[n2] `template/AGENTS.md` named inside a file copied verbatim to adopters** —
  `docs/customization.md:66-67`. Adopters receive `docs/customization.md` but no
  `template/` directory, so the path is framework-repository organisation, not
  an adopter location. The section already frames it that way and the tester
  flagged the risk (`verify.md:136-140`); noted only for the child-0005 sweep to
  keep an eye on.
  Recommendation: optionally add "(in the framework repository)" after the
  `template/AGENTS.md` reference.

## Test quality and residual risk

- The spec's non-goals ("Adding committed split-guard tests — child `0003`") and
  dependency ("`tests/checks/**` … must not be changed here") mean the correct
  choice was **not** to commit new checks. AC1–AC6/AC9 rest on reproducible
  ad-hoc commands pasted into `verify.md:27-88` and a `/tmp` script that is not
  committed; a reviewer or CI cannot re-run them directly. This is an accepted,
  spec-ordered gap, and child `0003` is the named owner to promote them.
- AC3 depends on opencode's last-match-wins permission evaluation. The denies
  are ordered strictly last and the resolved inspection confirms the order; a
  first-match-wins change would silently re-allow `template/`. This residual is
  disclosed (`verify.md:129-135`) and is exactly what `0003`'s committed guard
  should pin.
- The `edit` guard is not a shell sandbox: `bootstrap` has unrestricted `bash`
  (`docs/customization.md:200-208`), so a maintainer could still alter
  `template/` through redirection. Pre-existing, documented, and out of scope.

## Not reviewed

- Runtime/browser behavior (no UI; no `visual.md` expected).
- `template/**`, root `AGENTS.md`, `opencode.json`, `.gitignore`, `tests/checks/**`,
  `tests/run.sh`, `tests/lib.sh`, and `tests/mutation.sh` — outside the diff.
- Historic verification suites under `work/0003-…/` (including
  `0004-doctor-scope/verify-tests.sh`) that still reference `$FRAMEWORK/AGENTS.md`;
  these are committed historical records, not live surfaces, and must not be
  edited.
