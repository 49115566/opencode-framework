---
feature: 0004-adoption-template-split/0004-doctor-template-alignment
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
---

# Review — Doctor alignment with the adoption template split

## Verdict

**approve** — the diff extends the existing `/doctor` catalogue in place (same
nine checks, same codes), declares `template/AGENTS.md` a documentation and
required surface, adds `template/` to the temp-path scan, and closes the README
Agents-table maintainer-only residual without touching any compared cell; all
eleven acceptance criteria are met and no Blocker or Major survives scrutiny.

## Scope of the diff

The changes are **uncommitted working-tree changes** on `main`. Commands used:

- `git rev-parse HEAD` → `5c715a0a3a34c24db8a485725e745885dab9ca79`
- `git merge-base HEAD origin/main` → `5c715a0a3a34c24db8a485725e745885dab9ca79`
  (base = HEAD; branch is up to date with `origin/main`)
- `git status --porcelain` → `M .opencode/agent/doctor.md`,
  `M .opencode/command/doctor.md`, `M README.md`, plus untracked
  `work/0004-adoption-template-split/0004-doctor-template-alignment/*.md`
- `git diff` (the three tracked files; artifacts read directly)
- `git diff -- README.md`, `git diff --no-index opencode.json template/opencode.json`,
  `git diff --no-index .gitignore template/.gitignore`

Files changed: `.opencode/agent/doctor.md` (+), `.opencode/command/doctor.md`,
`README.md`. No test, config, or `opencode.json` change. The four artifacts
(`spec.md`, `design.md`, `tasks.md`, `verify.md`) are untracked, as expected for
the builder phase.

## Acceptance criteria

| AC | Verdict | Evidence |
| -- | ------- | -------- |
| AC1 — declared surfaces include `template/AGENTS.md` beside root `AGENTS.md` and `README.md` | **met** | `.opencode/agent/doctor.md:55-61` names `AGENTS.md` and `template/AGENTS.md` together in `<inputs>` item 3; `README.md` remains item 2 (`:53-54`). |
| AC2 — temp-path check scans the template directory and reports file+line | **met** | `<inputs>` item 6 adds `template/` (`.opencode/agent/doctor.md:65-66`); check 8 scans `README.md`, `AGENTS.md`, `template/`, `docs/`, and the `.opencode/` dirs (`:120-124`); command mirrors it (`.opencode/command/doctor.md:39-41`). `verify.md:32,48` records a scratch-clone `/tmp` injection producing `TEMP-PATH-OUTSIDE-WORKSPACE … template/AGENTS.md:139`. |
| AC3 — `template/AGENTS.md` is a required surface; absent/unreadable = exactly one finding, no cascade, unrelated checks run | **met** | `<completeness_rule>` adds it as a third required surface and states the per-surface skip (`:173-182`); `SURFACE-MISSING` example added (`:161`); command guard names it and gives the example (`.opencode/command/doctor.md:13-20`). `verify.md:33,49` records exactly one finding from a renamed template, no per-item cascade, temp-path check still fired. |
| AC4 — supporting-list divergence is reported, naming surface and item | **met** | Checks 1 and 2 now require each on-disk agent/command by name in the lifecycle table or supporting lists of **both** `AGENTS.md` files, and drop the phantom bound to those surfaces (`.opencode/agent/doctor.md:75-87`). `verify.md:34,50` records `AGENT-UNDOCUMENTED … <-> template/AGENTS.md supporting-agents list: not named.` |
| AC5 — counts agree with disk; no `COUNT-MISMATCH` from the `template/` Layout entry | **met** | Check 4 is untouched (`:94-98`). The `template/` Layout lines (`README.md:277-280`) carry none of the unit phrases `role prompts` / `slash commands` / `knowledge skills` that the matcher keys on. On-disk counts are 14 agents / 12 commands / 10 skills (`ls .opencode/{agent,command,skill}`); `verify.md:30` records a clean run reporting 14/12/10. |
| AC6 — expected pristine state is not reported as drift | **met** | Explicit scope clause in `<inputs>` item 3 (`:58-61`: placeholder profile expected; `template/opencode.json`/`.gitignore` not compared) and in `<completeness_rule>` (`:173-176`). `git diff --no-index opencode.json template/opencode.json` and `… .gitignore` both return empty (byte-identical, confirmed independently). |
| AC7 — README Agents-table `doctor` entry labeled maintainer-only, compared cells unchanged | **met** | Note added below the table (`README.md:226-227`). `git diff -- README.md` shows only these three added lines; the `doctor` row's `Can edit`/`Can run bash` cells are byte-identical. |
| AC8 — every documented `/doctor` / `doctor` surface carries the marker | **met** | README Commands row `README.md:204`; README Agents note `:226`; root `AGENTS.md` supporting-commands and supporting-agents lists; `docs/workflow.md:302`; `.opencode/agent/doctor.md:2`; `.opencode/command/doctor.md:2`; `template/AGENTS.md:50,54-55`. None omits it. |
| AC9 — `/doctor` writes nothing; read-only guarantee unchanged | **met** | The diff touches no frontmatter permission block; `.opencode/agent/doctor.md:5-16` is unchanged. The added prose reiterates read-only. `verify.md:35,55` records identical `git status --porcelain` before/after a run. |
| AC10 — agent and command agree, audience unchanged, catalogue preserved | **met** | Both name `template/AGENTS.md`, `template/`, the same code set, and keep "the nine checks" (`.opencode/command/doctor.md:21`, agent checks 1-9). The `framework-maintainer only` description is unchanged in both. No check added or removed. |
| AC11 — `bash tests/run.sh` exits 0 | **met** (see limitation) | `verify.md:29,57` records `182 passed, 0 failed, 0 skipped`, exit 0. Static trace supports it: no test reads the doctor prompt or command (grep of `tests/` for `doctor` → no matches), and the only live-parsed surface changed is `README.md`, whose Agents section gains a non-`|` paragraph that `30-permissions.sh:104-118` and `40-inventory.sh:48-57` skip by design. Could not be re-run in this sandbox (see "Not reviewed"). |

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] The completeness clause's "checks apply to it" list is imprecise about which checks target which surface** — `.opencode/agent/doctor.md:173-176`
  It reads "only the inventory, count, permission, ignore-rule, skill, and
  temp-path checks apply to it" where "it" is `template/AGENTS.md`. Three of
  those checks (permission, ignore-rule, skill) do not target an `AGENTS.md`
  surface at all — the ignore-rule check targets root `.gitignore`, the
  permission check compares agent frontmatter to the README table, and the skill
  check reads the README Skills table. The sentence can be read as instructing
  the model to run an ignore-rule check against the template, which the `<inputs>`
  clause at `:60-61` explicitly forbids by declaring `template/.gitignore` "not
  compared". It is a latent clarity risk in an LLM-driven detector, not an
  observed false positive (`verify.md` records a clean run), hence Minor.
  Recommendation: reword to state that the template is subject to the normal
  inventory/count/permission/ignore/skill/temp checks only to the extent they
  target shared surfaces, and that its placeholder Project profile and
  byte-identical `template/opencode.json`/`.gitignore` are exempt — e.g.
  "only the inventory, count, permission, ignore-rule, skill, and temp-path
  checks run against the template directory; its placeholder profile is
  expected, and `template/opencode.json`/`.gitignore` are not compared."

### Nits

- **[n1] Agent and command describe the temp-path scan at different granularity** — `.opencode/command/doctor.md:40-41` vs `.opencode/agent/doctor.md:120-124`
  The command says `.opencode/**`; the agent enumerates `.opencode/agent/`,
  `.opencode/command/`, `.opencode/skill/`. Today these are equivalent, but if a
  new `.opencode/` subdirectory is ever added the two descriptions would silently
  disagree, which is what AC10 asks them not to do. Recommendation: use the same
  literal list in both, or write `.opencode/{agent,command,skill}/` in the
  command.

## Not reviewed

- **`bash tests/run.sh` was not independently re-run.** This review sandbox's
  bash allowlist denies `bash`, `sh`, and any non-`git`/`ls`/`cat` command, so I
  could not reproduce the 182-pass run. I verified statically that no committed
  check reads `.opencode/agent/doctor.md` or `.opencode/command/doctor.md` (grep
  of `tests/` for `doctor` returns no matches), that the `README.md` change adds
  only a non-table paragraph in the `## Agents` section, and that the layout/count
  and packaging checks key on phrases the note does not contain. AC11 is marked
  met on that analysis plus the tester's recorded result.
- **The adopter template's own `/doctor` and `doctor` references** are
  deliberately left as-is per spec non-goals; they already carry the marker and
  were not modified.
- **Committed split guards for the new prompt coverage** are out of scope by spec
  (child `0003-split-guard-tests`); the absence is a spec-sanctioned residual, not
  a defect. The tester records it at `verify.md:76-82` and suggests a future
  guard.
- **`/visual`** does not apply: no user-facing surface (prompt/doc + one README
  paragraph).

## Residual risk

- The diagnostic is a prompt executed by a model; the new coverage is not
  deterministically guarded by the committed suite. The behavioural edges
  (AC2/AC3/AC4) were exercised only in a discarded scratch clone. This matches
  the spec's explicit `0003` boundary.
- The temp-path scan is directory-level over `template/`, so any future
  non-document file placed there is scanned; the tester notes this at
  `verify.md:87-91`. Consistent with the declared scan and not a defect.
