---
feature: 0001-framework-consistency-hardening
phase: review
status: final
created: 2026-10-02
updated: 2026-10-02
---

# Review — Framework consistency and permission hardening

## Verdict

**approve** — all 12 acceptance criteria are met and no Blocker or Major finding
survives scrutiny; the remaining findings are hardening and evidence-hygiene
concerns that do not affect the correctness of the shipped change.

## Base and scope

The work item was never committed (`spec.md:238`, "No commits"), so the reviewable
change is the uncommitted working tree, not a commit range.

Commands used to establish the base and produce the change set:

- `git rev-parse origin/main HEAD main` → `72d5ac5f31001d9f7bd54ed07b8d838d3d216652`
  for all three; `git merge-base HEAD origin/main` → the same commit. Base =
  `origin/main` = `HEAD` = `72d5ac5`.
- `git status --porcelain=v1 --untracked-files=all` → 13 modified files, 2
  untracked (`?? .opencode/agent/doctor.md`, `?? .opencode/command/doctor.md`).
- `git diff` — the 13-file working-tree diff.
- Read directly (untracked, excluded from `git diff`):
  `.opencode/agent/doctor.md`, `.opencode/command/doctor.md`.

Note: because the change is uncommitted, `git diff origin/main...HEAD` is empty;
that range would have reviewed nothing.

No `visual.md` exists and the change has no user-facing UI, so visual QA is N/A.

## Acceptance criteria

| AC | Result | Evidence |
| -- | ------ | -------- |
| AC1 — artifact-writers grant both work forms; create+update under `work/<slug>/` succeeds; diagnostic flags a missing form | **met** | All seven agents grant `"work/**": allow` and `"**/work/**": allow` (product.md:7-8, architect.md:7-8, tester.md:7-8, visual.md:7-8, reviewer.md:7-8, bootstrap.md:13-14, scribe.md:7-8). `doctor.md:94-98` implements `PERMISSION-WORK-PATTERN`. `verify.md:33,47` records `opencode debug agent product` resolving both rules and a behavioral create+update. Caveat: the product/scribe end-to-end write was not exercised (verify.md gap #4); the behavioral probe used the tester's equivalent shape. |
| AC2 — documented agent/command/skill inventories match disk | **met** | Independently recounted: 13 agents, 11 commands, 10 skills. All 13 agents appear in README Agents table (README.md:150-162) and AGENTS.md; all 11 commands appear in README Commands table (README.md:134-144) and AGENTS.md:48-50; all 10 skills in README.md:177-186. `docs/workflow.md` names only existing lifecycle agents/commands. `doctor.md:72-92` implements the inventory checks. |
| AC3 — `ask` documented with read-only profile | **met** | README.md:161 (`ask` / primary / none / none); AGENTS.md:53 (`ask` (read-only Q&A)); ask.md frontmatter denies edit (`"*": deny`) and bash. See n4 on the purpose/profile split. |
| AC4 — stated agent-prompt count equals disk | **met** | README.md:192-194 = 13/11/10; disk counts match exactly. |
| AC5 — README permission table matches enforcement; both work forms | **met** | Every artifact-writer row shows both forms (README.md:150-160); read-only rows show `none`. `doctor.md:100-106` implements `PERMISSION-TABLE-MISMATCH`; `verify.md:51` records a clean run plus a drift probe raising it. |
| AC6 — `edit` covers create/write/patch; both path forms documented | **met** | docs/customization.md:107-136 states create/write/patch, no separate `write`, both path forms, last-match-wins, `edit: deny`, and `opencode debug agent`. README.md:164-171 repeats the core fact and links to it. |
| AC7 — `.playwright-mcp/` and `scratch/` ignored without requiring the dirs | **met** | .gitignore:21-22 adds both directory patterns; no `.gitkeep` added. `verify.md:31-32` records `git check-ignore -v` and a create-then-`git status` probe. |
| AC8 — temp-file guidance points in-repo; no `/tmp` instruction | **met** | `rg` for `/tmp`, `mktemp`, `TMPDIR`, `/var/tmp`, `tempfile` over the repo (excluding `.git/`, `work/`) returns no matches. browser-verification/SKILL.md now writes `scratch/dev-server.log`; AGENTS.md:115-117 adds the scratch working agreement; README.md:202 documents `scratch/`. |
| AC9 — diagnostic reports seeded drift naming source and stale location | **met (manual)** | `doctor.md:137-155` defines the finding format; catalogue codes exist for all seeded classes. Manual runs recorded in verify.md. Evidence labeling is inconsistent — see m3. |
| AC10 — consistent repo yields a clean result | **met (manual)** | `doctor.md:128-135` fixes the exact clean string. `verify.md:34,56` records `No findings — repository is consistent.` with counts 13/11/10, including from a subdirectory. |
| AC11 — diagnostic is read-only | **met** | doctor.md:6 `edit: deny`; bash allowlist has no commit/push/add/mv/rm/mkdir/touch/tee/sed -i pattern. `verify.md:40` records an identical `git status` before/after. See m1 on `find*`. |
| AC12 — no lifecycle phase behavior change | **met** | Diff to docs/workflow.md:165-170 is a single added routing bullet; AGENTS.md changes are supporting lists + a working-agreement bullet; README changes are inventory/permission facts. No phase table, input, output, or exit criterion changed. |

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[m1] `/doctor`'s "read-only" bash allowlist still permits write-capable commands** — `.opencode/agent/doctor.md:16` (`"find*": allow`), and by extension `.opencode/agent/doctor.md:15` (`"rg*": allow`, where `rg --pre <cmd>` executes an arbitrary command). `design.md:198` justifies AC11 with "the absence of any write-capable bash pattern"; that claim is false for `find` (`-delete`, `-exec`) and `rg --pre`. The prompt forbids writes (doctor.md:40-42,177-179) and the observed run wrote nothing, so this is a defense-in-depth gap, not a demonstrated write.
  Recommendation: remove `find*` from the allowlist (the process at doctor.md:72-126 uses only `ls`, `cat`, `rg`, and read-only `git`), and either constrain `rg` or soften the design.md/README wording to "no expected write path, plus an explicit prompt prohibition" rather than "no write-capable pattern".

- **[m2] Bootstrap's relative config grants are undocumented scope expansion** — `.opencode/agent/bootstrap.md:7-12` adds relative `"AGENTS.md"`, `"opencode.json"`, and `".gitignore"` allows (in addition to the `work/**` pair). The fix is correct and plausibly required for `/bootstrap` to edit a relative `AGENTS.md`, and it is the same path-form class as the work fix, but it is not covered by AC1/AC5 (which scope the change to `work/`), is not in tasks.md T1–T10, and `design.md:248` explicitly states all 12 existing permission blocks are unchanged. A reader auditing the change cannot tell why bootstrap's block differs from the "unchanged" claim.
  Recommendation: add the bootstrap config-path correction to the spec/design/tasks trail (or split it to a follow-up) and correct design.md's "unchanged" statement. No behavior regression is introduced, so this is not merge-blocking.

- **[m3] AC9's manual evidence is internally inconsistent** — `verify.md:35-37` (Commands run) says probe A detected `AGENT-UNDOCUMENTED` + `AGENT-PHANTOM` and probe B detected `AGENT-UNDOCUMENTED`, `COUNT-MISMATCH`, `PERMISSION-WORK-PATTERN`, `PERMISSION-TABLE-MISMATCH`, while `verify.md:66-68` (Edge cases) attributes the `_drift-probe.md` `AGENT-UNDOCUMENTED` to probe B and `AGENT-PHANTOM` to probe A. No T10 step seeds the permission-drift codes attributed to probe B. Because LLM runs cannot be re-executed by a CI runner and these records are the sole proof for AC9, the labels should be trustworthy.
  Recommendation: re-run T10 and record, per probe, the exact seeded input and the exact finding codes emitted; add the permission-drift probe to tasks.md T10 and reconcile the two tables.

### Nits

- **[n1] "nine checks" vs 12 finding codes** — `design.md:77` says "nine deterministic checks" and `doctor.md:169` says "All nine checks ran", while the catalogue emits 12 distinct codes. `doctor.md:66-126` is internally coherent (9 numbered process steps covering 12 codes); only the design wording is loose. Align the phrasing.
- **[n2] Unconditional per-block `ok` lines in the test suite** — `verify-tests.sh:50,55,59` print an `ok` summary for a block even if a `bad` line was already printed within it. The process exit code is still correct, but the output reads as if the block passed. Cosmetic.
- **[n3] Shell suite matches commands/skills in prose, not table rows** — `verify-tests.sh:52-53,57` uses `grep -qF "/$c" README.md` / `\`$s\`` anywhere in README, so a command or skill mentioned only in prose would satisfy AC2. The `doctor` agent (doctor.md:78-86) is the semantic authority and uses table rows; tightening the shell pre-check to row matches (as the agent check at verify-tests.sh:47 already does) would make the two agree.
- **[n4] AC3's "one-line purpose" is only on one surface** — AGENTS.md:53 gives `ask` a purpose but no permission profile; README.md:161 gives the permission profile but the Agents table has no purpose column. The criterion is satisfied only by reading both surfaces together. Consider adding a short purpose to the README row (or a purpose column) so a single surface is self-contained.

## Not reviewed

- The runtime behavior of the LLM-driven `/doctor` agent (AC9–AC11). This pass
  is read-only and did not launch opencode; it relies on the runs recorded in
  `verify.md`, whose labeling issue is captured in m3. The static prompt,
  permission block, and command wiring were reviewed in full.
- Visual QA — N/A; the change has no user-facing surface and no `visual.md`.
- `opencode`'s exact path-pattern/last-match-wins semantics — taken as stated by
  the spec (`spec.md:224-228`) and design; not independently reproducible here.
