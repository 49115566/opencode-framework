---
feature: 0002-agentic-roadmaps
phase: review
status: final
created: 2026-10-04
updated: 2026-10-04
---

# Review — Agentic multi-feature roadmaps

## Verdict

**approve** — the implementation satisfies all 15 acceptance criteria, the one
Major from the previous review (M1, `/visual` writing to `work/<slug>/…`) is
fixed across the agent, command, and skill, the four accompanying minors are
addressed, and the remaining items are low-severity consistency nits that do not
block merge.

## Scope and commands

Base ref: `4c81477c9d255c83477b6cb383c29c06ef6ac081` (`HEAD`, `origin/main`,
`main`). Every change is uncommitted working-tree state, so
`git diff <base>...HEAD` is empty and the real diff is the working tree plus the
two new untracked files.

Commands used:

- `git merge-base HEAD origin/main` → `4c81477c9d255c83477b6cb383c29c06ef6ac081`
- `git status --porcelain` → 26 modified tracked files + 2 untracked
  (`.opencode/agent/roadmap.md`, `.opencode/command/roadmap.md`)
- `git diff` and `git diff --stat` → 26 files, 523 insertions / 135 deletions
- `git diff -- docs/artifact-conventions.md docs/customization.md docs/workflow.md`
- `ls .opencode/agent/ .opencode/command/ .opencode/skill/` → 14 agents, 12
  commands, 10 skills
- `rg` sweeps over `.opencode/`, `docs/`, `README.md`, `AGENTS.md`
- Read of the recorded behavioral logs under `scratch/tester2-*.log` and
  `scratch/tester2-verify-tests.out`, and of the two new artifacts

This is a prompt/config-only work item; there is no runtime code, so the
security/performance surface reduces to permission blocks, secret handling, and
read-only guarantees.

## Findings

### Blockers

None.

### Major

None. The prior review's M1 is resolved: `.opencode/agent/visual.md:43,91,93,116,135`
and `.opencode/skill/browser-verification/SKILL.md:66,93` now use
`work/<item-ref>/`, and `.opencode/command/visual.md:24-27` already did. The
`<slug>` token is gone from every phase agent, command, and the skill.

### Minor

- **[m1] The readiness "detected PR" branch is not executable by `status`** —
  `.opencode/agent/status.md:107`, `docs/workflow.md:91`. `satisfied()` now
  counts "a PR is detected for the child" as shipped, but the status agent's
  `bash` allowlist (`.opencode/agent/status.md:6-17`) has no `gh` and cannot
  query a PR; a child shipped without the optional `ship.md` will still be
  reported `blocked`, contradicting AC6's "or has been shipped." This is the
  reworked m2 from the prior review, and the fix is documentation-only. It is
  Minor because `ship.md` covers the normal path and the branch is best-effort by
  design, but the clause currently overpromises.
  Recommendation: either add `gh pr view*` / `gh pr list*` to the status bash
  allowlist, or state explicitly in `docs/workflow.md` that `ship.md` is the sole
  machine-readable ship signal and treat the PR clause as informational.
- **[m2] The shared frontmatter example now shows `parent: ""`** —
  `docs/artifact-conventions.md:20`. The field is correctly marked optional and
  the rule at `:29-30` says standalone items omit it, but a shared template that
  every artifact is told to "begin with" invites product/scribe agents to emit an
  empty `parent` on standalone items, a cosmetic change AC11 otherwise protects.
  Recommendation: show `parent:` only in the nested-child paragraph, not in the
  universal example block.
- **[m3] Scope extends past `design.md`'s "Affected areas"** —
  `.opencode/agent/scribe.md:43`, `docs/customization.md:112-113`,
  `.opencode/skill/conventional-commits/SKILL.md`,
  `.opencode/skill/pr-workflow/SKILL.md`,
  `.opencode/skill/browser-verification/SKILL.md`. `design.md` lists scribe,
  `docs/customization.md`, and those three skills as unchanged / unlisted; each
  is a one-token `work/<slug>` → `work/<item-ref>` consistency edit (scribe) or a
  direct consequence of the prior review's m1/m4. No unrelated refactor, but the
  design's affected-areas list is now stale.
  Recommendation: note the extra files in the design or the build record; no code
  change required.

### Nits

- **[n1] `AGENTS.md:50` still advertises `/visual [url|slug]`** while the
  command now takes `[url or item-ref]` (`.opencode/command/visual.md:2`). Sweep
  the last stale `slug` spelling in the supporting-commands list.
- **[n2] README Command table drift** — `README.md:145` shows `/visual [url]`
  (not item-ref), and `README.md:146` drops the space before the closing pipe
  (`| `/review [item-ref]`|`), breaking the column alignment the neighboring rows
  keep. Cosmetic; `/doctor` normalizes whitespace.
- **[n3] `verify.md` AC8 row overstates coverage** — `verify.md:72` marks AC8 an
  unqualified PASS while Gap #2 (`verify.md:135-140`) discloses that only `/spec`
  was behaviorally exercised on a nested child; plan/build/test/review/ship/visual
  were verified statically. The prose is honest; the table should say
  "PASS (static + /spec behavioral)".

## Acceptance criteria walk

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 | met | `.opencode/command/roadmap.md:25-27` (autonomous, no gate); `.opencode/agent/roadmap.md:91-99` (allocate next `NNNN`, write artifact + `.gitkeep`); behavioral `scratch/tester2-roadmap-multi.log` created `work/0004-user-accounts/roadmap.md` with no approval step. |
| AC2 | met | Template `docs/artifact-conventions.md:76-131` (Initiative, Assumptions, Children with all five columns, Sequencing, Open issues); agent quality bar `.opencode/agent/roadmap.md:104-120`; produced artifact read in `tester2-roadmap-multi.log`. |
| AC3 | met | `.opencode/agent/roadmap.md:96-99` writes only `.gitkeep`; quality bar `:115-117` forbids phase artifacts; behavioral `find work/0004-user-accounts -mindepth 2 -type f -not -name '.gitkeep'` empty (`verify.md:58`). |
| AC4 | met | `docs/workflow.md:74-85` (existing local id, no self, acyclic, cycles to Open issues); `.opencode/agent/roadmap.md:79-84`; `docs/artifact-conventions.md:133-137`; probe acyclic + `CYCLIC-DEP` (`scratch/tester2-status-probe.log:47,67`). |
| AC5 | met | Readiness algorithm `docs/workflow.md:87-100` and `.opencode/agent/status.md:98-122`; behavioral probe reports `ready`/`blocked` and names blockers (`tester2-status-probe.log:35-53`). |
| AC6 | met | `docs/workflow.md:101-104`, `.opencode/agent/status.md:107-120`; probe: approve-unshipped and shipped ready, `request-changes`/no-review blocked, no-dep ready (`tester2-status-probe.log:42-48,70-72`). Minor m1 caveat on the PR branch. |
| AC7 | met | `.opencode/agent/status.md:145-163` output shape; `.opencode/command/status.md:17-22`; probe `7/13 ready · phases: rework 1, …` (`tester2-status-probe.log:53`), roadmap row separate from child rows. |
| AC8 | met (residual risk) | Grammar `docs/artifact-conventions.md:37-62`; rule present in all 7 phase agents and 7 commands (suite is `tester2-verify-tests.out:55-73,155-170`); behavioral `/spec` nesting in `tester2-spec-override.log`; M1 fixed. Six phases remain statically verified only (`verify.md:135-140`). |
| AC9 | met | `.opencode/agent/product.md:70-76`, `docs/workflow.md:121-128`; refusal and named blocker in `tester2-spec-blocked.log`; explicit override wrote nested `spec.md` with the blocker in `notes` (`tester2-spec-override.log`); no file deleted. |
| AC10 | met | `.opencode/agent/status.md:4-17` (`edit: deny`, read-only bash), `docs/workflow.md:85,242-247`; `git status --porcelain` byte-identical before/after all runs (`verify.md:57`); no state file. |
| AC11 | met | `parent` optional `docs/artifact-conventions.md:29-30,67`; spec template unchanged (suite `tester2-verify-tests.out:102`); permission-regression check `:188-189`; flat items derived normally in `tester2-status-all.log`. Minor m2 caveat. |
| AC12 | met | `.opencode/agent/roadmap.md:31-36,123-132`; `.opencode/command/roadmap.md:25-27`; no write-capable bash token (suite `:178-187`); behavioral `git diff --stat` unchanged (`verify.md:57`). |
| AC13 | met | Disk 14/12/10 match `README.md:201-203`; `roadmap` in README Agents (`:160`) and AGENTS (`:52-53`); `/doctor` clean (`scratch/tester2-doctor.log` per `verify.md:56`). |
| AC14 | met | `.opencode/agent/roadmap.md:64-74,87-90`; behavioral single-feature recommends `/spec` and creates nothing (`tester2-roadmap-single.log`), multi-feature records an unresolved item under Open issues (`tester2-roadmap-multi.log`). |
| AC15 | met | Four codes defined `.opencode/agent/status.md:126-134` and `docs/workflow.md:112-115`; probe emits all four and completes (`tester2-status-probe.log:64-67`); agent never repairs (suite `:186`). |

Met 15/15; no criterion is partial or not met.

## Other review axes

- **Correctness** — the readiness algorithm and integrity findings were
  exercised against a tester-built fixture independent of the builder's, and the
  reported results match the documented decision list. Derived state is ordered
  correctly (`roadmap.md` before `spec.md`, `docs/workflow.md:232`).
- **Security / secrets** — no secrets, credentials, or `.env` content in the
  diff. The new agent adds no runtime dependency and no write-capable bash pattern
  (default-deny, `work/**` + `**/work/**` edit only). Read-only agents keep
  `edit: deny`.
- **Tests** — `verify-tests.sh` is a 169-assertion static presence suite, not a
  behavioral test; it is mutation-checked against seven seeded defects
  (`verify.md:114-120`) and I read the recorded `169 passed, 0 failed` output.
  It is necessary but not sufficient; the behavioral logs are the real evidence.
  I could not re-run it (the review sandbox denies arbitrary `bash`), so I read
  it and the recorded output rather than executing it.
- **Convention fit** — new agent and command mirror the `product`/`/spec` and
  `status`/`/status` shapes; the shared rules live in the always-loaded
  `docs/workflow.md` and `docs/artifact-conventions.md`.
- **Scope** — the diff touches the design's affected areas plus the three
  skill/scribe/customization files noted in m3; no unrelated refactors,
  reformatting, or dependency additions.
- **Performance** — not applicable; prompts and docs only.

## Not reviewed

- Independent re-execution of `verify-tests.sh` and the agent runs (blocked by
  the review sandbox's bash allowlist). I relied on the recorded logs under
  `scratch/`, which exist and are internally consistent with `verify.md`.
- The removed scratch fixtures (`work/0003-tester-probe/`,
  `work/0004-user-accounts/`), since they were cleaned up as designed; `work/`
  contains only `0001-framework-consistency-hardening` and this item.
