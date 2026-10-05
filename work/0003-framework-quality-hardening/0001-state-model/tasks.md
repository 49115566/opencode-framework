---
feature: 0003-framework-quality-hardening/0001-state-model
phase: tasks
status: final
created: 2026-10-04
updated: 2026-10-04
parent: 0003-framework-quality-hardening
---

# Tasks — Artifact persistence and state model

Ordered, dependency-aware. One task ≈ one focused commit. No task introduces a
new dependency or writes runtime code.

- [x] **T1** — Flip the ignore policy in `.gitignore`: remove the `work/*` rule
      and the `!work/.gitkeep` negation, replace the "working state" comment with
      the committed-state comment, and leave `.opencode/` generated state,
      `.playwright-mcp/`, `scratch/`, and the stack/editor blocks untouched.
      [AC1] [AC2] [AC3] [AC11]
      Verify: `git check-ignore -v work/example/spec.md` prints nothing and exits
      non-zero; `git check-ignore -q .playwright-mcp/x && git check-ignore -q
      scratch/y && echo ignored`; `git check-ignore -q
      work/0003-framework-quality-hardening/0002-readiness-ship-state/.gitkeep;
      test $? -ne 0 && echo reservation-trackable`; `git check-ignore -q
      work/example/visual/desktop.png; test $? -ne 0 && echo evidence-trackable`.

- [x] **T2** — State the committed model in the always-loaded contract and
      lifecycle docs: update `AGENTS.md:65`, `docs/workflow.md:13-14,55`, and
      `README.md:199-212`, and add the canonical persistence statement to
      `docs/artifact-conventions.md`. Remove every `git-ignored` /
      `not deliverables` artifact claim; qualify "complete state" as committed.
      [AC4] [AC12]
      Verify: `rg -n "git-ignored|gitignored|not deliverables" AGENTS.md
      docs/workflow.md docs/artifact-conventions.md README.md` returns no
      artifact-persistence claim (only `scratch/` wording may remain);
      `rg -n "committed" AGENTS.md docs/workflow.md
      docs/artifact-conventions.md README.md` shows the new statements.

- [x] **T3** — Make adoption yield the committed model: update
      `.opencode/agent/bootstrap.md` inputs, step 5, quality bar, and handoff so
      bootstrap ensures `work/` exists, removes any `work/` ignore rule, keeps
      `scratch/`/`.playwright-mcp/` ignored, and states that local-only is
      unsupported; align `.opencode/command/bootstrap.md`; add the quickstart
      note to `README.md:33-53`. [AC5] [depends: T1]
      Verify: `rg -n "does not ignore .work/" .opencode/agent/bootstrap.md
      README.md` matches; `rg -n "ignores .*work/|work/\\*" .opencode/agent/bootstrap.md`
      returns nothing. Fixture check: in a temp repo containing `work/*` in
      `.gitignore`, apply the documented correction, then `git check-ignore
      work/x` fails and `git check-ignore scratch/y` passes.

- [x] **T4** — Make numbering durable and define parallel-merge reconciliation:
      replace `## Sequence allocation` in `docs/artifact-conventions.md` with the
      committed-tree-plus-history contract (preserving the literals `Never reuse`
      and `never reused within that parent`); add the duplicate-detection and
      renumber procedure to `docs/workflow.md` "Multiple work items" (preserving
      `proceed in parallel`); update allocation steps `product.md:77` and
      `roadmap.md:91-99`. Do not add a ledger file. [AC9] [AC10] [depends: T2]
      Verify: `rg -n "Never reuse|never reused within that parent|proceed in
      parallel" docs/artifact-conventions.md docs/workflow.md`; `rg -n
      "git log --all --name-only" docs/artifact-conventions.md`; run `ls work/`
      and `git log --all --name-only --pretty=format: -- work/`, confirm the
      documented rule yields a number greater than every prefix present; `bash
      work/0002-agentic-roadmaps/verify-tests.sh` exits 0.

- [x] **T5** — Make the PR handoff and visual evidence committed: in
      `shipper.md` add that `work/<item-ref>/` artifacts are staged and committed
      with the item (leave the permission block and `ship.md` fate untouched); in
      `pr-workflow/SKILL.md` note the linked paths resolve because `work/` is
      committed; in `visual.md` and `browser-verification/SKILL.md` note
      screenshots under `work/` are committed while `scratch/` stays ignored.
      [AC7] [AC11] [depends: T1]
      Verify: `rg -n "commit.*work/<item-ref>|artifacts.*commit"
      .opencode/agent/shipper.md`; `rg -n "committed"
      .opencode/skill/pr-workflow/SKILL.md .opencode/skill/browser-verification/SKILL.md
      .opencode/agent/visual.md`; `git check-ignore -q
      work/example/visual/desktop.png; test $? -ne 0 && echo trackable`.

- [x] **T6** — Complete the persistence-surface sweep and confirm audit
      compatibility: add the committed qualifier to
      `.opencode/skill/workflow-lifecycle/SKILL.md:17-24` and
      `.opencode/agent/status.md:36-45`; confirm `doctor.md` and
      `command/doctor.md` still require only `.playwright-mcp/` and `scratch/`
      and were **not** given a new catalogue; confirm no state/ledger file was
      introduced. [AC4] [AC6] [AC12] [depends: T1] [depends: T2]
      Verify: `rg -n "git-ignored|not deliverables" .opencode docs README.md
      AGENTS.md` returns no artifact claim; `rg -n "\.playwright-mcp/.*scratch/|scratch/.*\.playwright-mcp/|IGNORE-MISSING"
      .opencode/agent/doctor.md .opencode/command/doctor.md` shows the unchanged
      policy; `git check-ignore -q .playwright-mcp/x && git check-ignore -q
      scratch/y`; `ls work/` shows no allocation/state/ledger file; `bash
      work/0001-framework-consistency-hardening/verify-tests.sh` exits 0.

- [x] **T7** — Confirm the migration surface and fresh-tree derivability:
      enumerate the previously ignored corpus that now enters version control
      (all of `0001-*`, `0002-*`, `0003-*`, including nested child `.gitkeep`
      files and visual evidence paths) and re-run both existing static suites.
      Do not modify the suites. [AC1] [AC3] [AC8] [AC12] [depends: T1] [depends: T2] [depends: T3] [depends: T4] [depends: T5] [depends: T6]
      Verify: `git status --porcelain --untracked-files=all work/` lists the
      corpus and every nested `.gitkeep`; `bash
      work/0001-framework-consistency-hardening/verify-tests.sh && bash
      work/0002-agentic-roadmaps/verify-tests.sh` both exit 0 and report zero
      failures.
      Note: enumeration confirmed — 27 untracked `work/` entries now visible
      (all of `0001-*`, `0002-*`, `0003-*`); 9 nested child `.gitkeep` files
      under `0003-framework-quality-hardening` are trackable; no visual evidence
      paths exist in the current corpus. `work/.gitkeep` is already tracked and
      no state/ledger file was introduced. AC8's clean-clone comparison is
      fully confirmed only after this item is shipped; the tester/reviewer owns
      the post-merge clone check.
