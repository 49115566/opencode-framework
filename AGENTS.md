# AGENTS.md — Development Workflow Contract

This repository uses a structured, phase-based agent workflow. This file is
loaded into **every** agent's context. Read it before acting; it defines how
work moves through the system and the rules that govern all agents.

> This file ships as a template. The `## Project profile` section below is
> filled in by `/bootstrap` (or by hand) when the framework is adopted into a
> real project. Until then, treat stack commands as "discover at runtime".

## Project profile

- **Purpose**: A portable, prompt-driven development workflow for opencode: agents, commands, and skills with committed lifecycle artifacts.
- **Primary language(s)**: none (opencode prompt/config files; the test harness is Bash)
- **Package manager**: none
- **Install**: none
- **Test**: `bash tests/run.sh`
- **Lint**: none
- **Typecheck**: none
- **Format**: none
- **Build**: none
- **Key directories**: `.opencode/`, `docs/`, `tests/`, `work/`

If a value is missing or looks wrong, do not guess — run the
`project-discovery` skill and confirm against the repository's real config.

## The lifecycle

Work flows through fixed phases. Each phase reads the previous phase's
artifact and writes its own. Phases are driven by slash commands, and each
command runs as the named agent.

| Phase       | Command            | Agent       | Reads                    | Writes                         |
| ----------- | ------------------ | ----------- | ------------------------ | ------------------------------ |
| Requirements| `/spec <feature or problem description \| item-ref>` | `product`   | repo, request            | `spec.md`                      |
| Design      | `/plan <item-ref>` | `architect` | `spec.md`                | `design.md`, `tasks.md`        |
| Build       | `/build [item-ref or task-id]` | `builder`   | `design.md`, `tasks.md`  | code, updated `tasks.md`       |
| Test        | `/test [item-ref]` | `tester`    | `spec.md`, `tasks.md`    | tests, `verify.md` †           |
| Review      | `/review [item-ref]` | `reviewer`  | diff, `spec.md`, `tasks.md` | `review.md`                 |
| Ship        | `/ship [item-ref]` | `shipper`   | `review.md`              | branch, commits, PR, `ship.md` |

† For work with a user-facing UI, an optional `/visual` pass drives a real
browser and writes `visual.md` plus screenshots. Review must consider it when
present. Non-UI projects skip it.

Supporting commands: `/fix <bug description>` (lightweight fix), `/status [item-ref]` (phase report),
`/roadmap <initiative>` (author a multi-feature roadmap), `/bootstrap` (adopt
into a project), `/visual [url or item-ref]` (browser QA), `/doctor` (read-only drift
diagnostic; framework-maintainer only).
Supporting agents: `scout` (recon), `scribe` (artifact editing), `bootstrap`
(provisioning), `status` (read-only reporting), `roadmap` (roadmap authoring),
`visual` (browser inspection), `ask` (read-only Q&A), `doctor` (read-only
consistency diagnostic; framework-maintainer only).

The authoritative description of each phase, its inputs, and its exit criteria
lives in `docs/workflow.md`. The exact artifact formats live in
`docs/artifact-conventions.md`.

## The artifact contract

All workflow artifacts live under `work/<NNNN-slug>/`, one directory per
feature (`NNNN` is the next zero-padded sequence number; `slug` is kebab-case).
Workflow artifacts under `work/` are **committed working state**:
version-controlled so a fresh clone, a teammate, and CI derive the same phase.
Only `scratch/` and opencode's generated state are ignored.

A **roadmap** is a parent work item at `work/<NNNN-slug>/` whose `roadmap.md`
enumerates child features; its children are nested at
`work/<NNNN-slug>/<MMMM-slug>/` and later run the ordinary lifecycle unchanged. A
work item is addressed by its **canonical reference** — `NNNN-slug`, or
`NNNN-slug/MMMM-slug` for a nested child — and phase commands accept either
form. A one-segment reference behaves exactly as before, so standalone items are
unchanged.

- Only the owning phase writes its artifact. Do not edit another phase's file.
- Every artifact starts with YAML frontmatter (`feature`, `phase`, `status`,
  `created`, `updated`). Preserve it when editing.
- Phase state is derived from which artifacts exist and their contents — there
  is no separate state file. Do not invent one.

```xml
<rules>
  <rule>Write only inside your phase's artifact file and, for code phases, the source files in scope.</rule>
  <rule>Never rewrite or "clean up" artifacts owned by another phase; leave a note instead.</rule>
  <rule>Use `scribe` when you need to produce or reformat a large artifact.</rule>
</rules>
```

## Handoff protocol

Every phase ends by telling the user, in one short block:

1. **Done** — the artifact(s) produced, by path.
2. **Checks** — commands run and their result (for code phases).
3. **Next** — the exact next command, e.g. `Next: /plan 0001-add-dark-mode`.
4. **Blockers** — anything that must be resolved first, or `none`.

Never start a downstream phase's work. If something is wrong upstream, stop
and report it rather than working around it.

## Guardrails

```xml
<guardrails>
  <rule priority="critical">Never commit, push, tag, or open a PR unless the user invoked `/ship` or explicitly asked. Only the `shipper` agent performs git write operations: for an approved work item on `/ship <item-ref>`, and for a verified fix on `/ship fix` when the user explicitly requests it. Every other agent never writes git.</rule>
  <rule priority="critical">Never commit secrets, credentials, tokens, or `.env` contents. If you find them, stop and report.</rule>
  <rule priority="critical">Never run destructive commands without confirmation: force-push, `reset --hard`, `clean -fd`, bulk deletes, dropping databases.</rule>
  <rule priority="high">After any code change, run the project's lint, typecheck, and tests for the touched scope, and fix what you broke.</rule>
  <rule priority="high">Follow existing code conventions, patterns, libraries, and structure. Read neighboring code before writing.</rule>
  <rule priority="high">Keep changes scoped to the task. Do not refactor unrelated code, reformat whole files, or add dependencies without stating why.</rule>
  <rule priority="high">Do not claim success you have not verified. "It should work" is not a result; run the command.</rule>
  <rule priority="medium">If requirements are ambiguous and the choice materially changes the outcome, ask before building. Batch questions.</rule>
  <rule priority="medium">Prefer the smallest change that satisfies the acceptance criteria.</rule>
</guardrails>
```

## Working agreements

- **Discovery before action.** Read the relevant files first. If tooling
  commands are unknown, use the `project-discovery` skill instead of guessing.
- **Right-size the process.** Typos and one-line fixes use `/fix`. Features and
  behavior changes use the full lifecycle. When unsure, ask.
- **Evidence over assertion.** Cite `file:line`, paste command output, link
  artifact paths.
- **Scratch space.** Write temporary files and background process logs to the
  in-repo, gitignored `scratch/` directory, created on demand. Never write a
  temporary file outside the workspace.
- **The user owns decisions.** Agents recommend; the user approves. Present
  options with trade-offs when a decision is non-obvious.

## Reference

- `docs/workflow.md` — lifecycle, phase entry/exit criteria, routing.
- `docs/artifact-conventions.md` — templates and frontmatter for every artifact.
- `docs/customization.md` — how to add or change agents, skills, and commands.
- `.opencode/skill/merge-conflict/SKILL.md` — the shipper's reconcile procedure; the normative contract is `docs/workflow.md` → `## Merge conflicts`.
