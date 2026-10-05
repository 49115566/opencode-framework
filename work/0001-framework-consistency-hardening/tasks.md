---
feature: 0001-framework-consistency-hardening
phase: tasks
status: final
created: 2026-10-02
updated: 2026-10-02
notes: "Prompt-and-config work item: no runtime code. T9 and T10 are verification tasks; no files are committed."
---

# Tasks — Framework consistency and permission hardening

Ordered, dependency-aware. One task ≈ one focused commit. There is no test
runner in this repo; `Verify:` steps are read-only shell assertions or explicit
manual checks.

- [x] **T1** — Ignore non-source tooling output. Add `.playwright-mcp/` and
      `scratch/` directory patterns to the root `.gitignore`, in a clearly
      labelled section (e.g. near the opencode local-state block). Do not add a
      `.gitkeep` for either. [AC7]
      Verify: `git check-ignore -v .playwright-mcp/trace.zip scratch/dev-server.log`
      prints a matching `.gitignore` line for both paths; after
      `mkdir -p scratch .playwright-mcp && touch scratch/dev-server.log .playwright-mcp/trace.zip`,
      `git status --porcelain` reports neither directory.

- [x] **T2** — Adopt the in-repo `scratch/` temp-file convention. Rewrite
      `.opencode/skill/browser-verification/SKILL.md:46` so the dev-server log
      goes to `scratch/dev-server.log` (not `/tmp`), and add a one-line note
      that `scratch/` is gitignored and created on demand. Add a matching
      working-agreement bullet to `AGENTS.md` directing temporary files and
      background process logs to `scratch/`, never `/tmp`. [AC8]
      Verify: `rg -n "/tmp" .opencode docs README.md AGENTS.md` returns no
      matches; `rg -n "scratch/dev-server.log" .opencode/skill/browser-verification/SKILL.md`
      matches; `rg -n "scratch/" AGENTS.md` matches.

- [x] **T3** — Document the permission model. Extend the "Permissions" section
      of `docs/customization.md` to state that opencode's `edit` permission
      covers **create, write, and patch** (no separate `write` key exists or is
      needed); that tool paths appear both relative (`work/<slug>/spec.md`) and
      absolute (`/repo/work/<slug>/spec.md`), so artifact-writing agents declare
      **both** `work/**` and `**/work/**`; that permission objects are
      last-match-wins; that read-only agents use `edit: deny`; and that
      `opencode debug agent <name>` shows the resolved result. [AC6]
      Verify: `rg -n "create|write|patch" docs/customization.md` shows the
      sentence; `rg -n '\*\*/work/\*\*' docs/customization.md` matches;
      `rg -n "debug agent" docs/customization.md` matches.

- [x] **T4** — Add the read-only diagnostic agent. Create
      `.opencode/agent/doctor.md` using the frontmatter and check catalogue in
      `design.md` §"Interfaces and data model": primary mode, `edit: deny`,
      read-only bash allowlist (`git rev-parse*`, `git status*`, `git diff*`,
      `git check-ignore*`, `ls*`, `cat*`, `rg*`, `find*`, `tree*`),
      `question: allow`, `temperature: 0`. The body resolves the repo root with
      `git rev-parse --show-toplevel`, runs the nine checks, emits findings in
      the `[CODE] source-of-truth <-> stale location: detail` format, prints
      `No findings — repository is consistent.` when clean, and states it never
      edits or runs a write command. [AC1] [AC9] [AC10] [AC11]
      Verify: restart opencode, then `opencode debug agent doctor` resolves with
      `edit: deny` and the read-only allowlist; inspect the prompt for all check
      codes and the both-path-forms rule; run the `doctor` agent directly (the
      `/doctor` command does not exist until T5 — select `doctor`, or
      `opencode run --agent doctor "run the consistency diagnostic"`) and confirm
      it reports the currently-known drift (at least `[COUNT-MISMATCH]` for the
      README agent count and `[AGENT-UNDOCUMENTED]` for `ask`), demonstrating
      detection.

- [x] **T5** — Add the `/doctor` command. Create `.opencode/command/doctor.md`
      with the frontmatter and body from `design.md`, mirroring the shape of
      `.opencode/command/status.md`: state that the run is read-only, checklist
      the diagnostic's checks, and end with the handoff block. [AC9] [AC11]
      [depends: T4]
      Verify: restart opencode, invoke `/doctor`, and confirm it executes the
      diagnostic and produces the finding output; `git status --porcelain`
      shows no new modifications caused by the run.

- [x] **T6** — Correct the README inventory and permission facts. Add `ask`
      (primary; `none` edit; `none` bash) and `doctor` (primary; `none`; read-only
      allowlist) rows to the Agents table; change every artifact-writer row's
      "Can edit" cell to `` `work/**` + `**/work/**` ``; add a short paragraph
      under the table stating `edit` covers create/write/patch and both path
      forms are required, linking to `docs/customization.md`; add the `/doctor`
      row to the Commands table; update the layout counts to `# 13 role prompts`
      and `# 11 slash commands`; add `scratch/` to the layout block. [AC2] [AC3]
      [AC4] [AC5] [AC6] [AC8] [depends: T4, T5]
      Verify: `rg -n "13 role prompts" README.md` and
      `rg -n "11 slash commands" README.md` match; `rg -n "\`ask\`|\`doctor\`|/doctor" README.md`
      matches; a shell loop confirms every `.opencode/agent/*.md` basename
      (minus `.md`) appears in `README.md` and every command basename appears in
      the Commands table; `rg -n '\*\*/work/\*\*' README.md` matches all seven
      artifact-writer rows.

- [x] **T7** — Correct the AGENTS.md inventory. Add `ask` (read-only Q&A) and
      `doctor` (read-only consistency diagnostic) to the supporting-agents list,
      and `/doctor` (read-only drift diagnostic) to the supporting-commands
      list. Do not alter the lifecycle phase table. [AC2] [AC3] [depends: T4, T5]
      Verify: `rg -n "\`ask\`|\`doctor\`|/doctor" AGENTS.md` matches;
      `git diff AGENTS.md` shows no changes to the phase/command/reads/writes
      table.

- [x] **T8** — Add the diagnostic to the workflow routing docs. Add a
      `/doctor` routing-heuristic bullet to `docs/workflow.md` describing a
      read-only consistency check of inventories, counts, permission blocks, and
      ignore rules that reports but never edits. Confirm no other factual
      corrections are needed there; change no phase input, output, exit
      criterion, or command behavior. [AC2] [AC12] [depends: T5]
      Verify: `rg -n "/doctor" docs/workflow.md` matches; `git diff docs/workflow.md`
      shows only the added bullet, with no edits to the phase tables or the
      derived-state table.

- [x] **T9** — Verify the repository is internally consistent. Restart opencode
      and run `/doctor`; expect exactly `No findings — repository is
      consistent.` Run the shell assertions for counts, inventories, ignore
      rules, both-path-form permissions, and the absence of `/tmp`. Confirm the
      run modified no files. [AC1] [AC2] [AC4] [AC5] [AC10] [AC11]
      [depends: T1, T2, T3, T4, T5, T6, T7, T8]
      Verify: `/doctor` prints the clean-result line and no `[` findings;
      `git check-ignore -v .playwright-mcp/x scratch/y` prints both rules;
      `rg -n "/tmp" .opencode docs README.md AGENTS.md` is empty;
      `git status --porcelain` shows no diagnostic-created files.

- [x] **T10** — Prove drift detection and the artifact-write path (manual).
      (a) Add a temporary unlisted agent file `.opencode/agent/_drift-probe.md`,
      restart opencode, run `/doctor`, and confirm it reports
      `[AGENT-UNDOCUMENTED]` and `[COUNT-MISMATCH]` naming the probe and the
      README count; delete the probe. (b) Temporarily move
      `.opencode/agent/ask.md` aside (e.g. `mv ... ask.md.bak`; `.bak` is not
      globbed), run `/doctor`, confirm `[AGENT-PHANTOM]` names the README/AGENTS
      entry, then move it back. (c) As the `product` agent or `scribe` subagent,
      create and then update `work/0001-framework-consistency-hardening/.perm-probe`,
      confirm both succeed with no permission denial, then delete it. (d) Review
      `git diff` of the docs to confirm AC12 (no lifecycle-semantic changes).
      [AC1] [AC9] [AC12] [depends: T9]
      Verify: each seeded drift produces its named finding code with a source
      and location; the create+update probe succeeds; `ls work/0001-framework-consistency-hardening/.perm-probe`
      fails afterward (probe removed); the docs diff contains no phase
      input/output/exit changes.

## Acceptance-criteria coverage

| AC | Tasks |
| --- | --- |
| AC1 | T4, T9, T10 |
| AC2 | T6, T7, T8, T9 |
| AC3 | T6, T7 |
| AC4 | T6, T9 |
| AC5 | T6, T9 |
| AC6 | T3, T6 |
| AC7 | T1, T4 |
| AC8 | T2, T4, T6 |
| AC9 | T4, T5, T9, T10 |
| AC10 | T4, T9 |
| AC11 | T4, T5, T9 |
| AC12 | T8, T10 |
