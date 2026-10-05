---
feature: 0001-framework-consistency-hardening
phase: spec
status: final
created: 2026-10-02
updated: 2026-10-02
notes: "Scoped from a 19-item idea list; large initiatives deferred to backlog (see Non-goals). The work/ permission defect was reproduced and repaired mid-phase; docs and regression coverage remain."
---

# Framework consistency and permission hardening

## Problem

opencode-framework is a prompt-and-config product: its correctness depends on
the documentation accurately describing the agents, commands, skills, and
permissions that actually exist, and on those permissions actually working.
There is no repeatable way to detect when they diverge, and divergence has
already happened:

- **The artifact-write permission pattern was wrong and is neither documented
  nor protected.** Agents declared only
  `edit: { "*": deny, "**/work/**": allow }`, which does not match the path
  opencode evaluates, so writes under `work/` fell through to the catch-all
  deny. Reproduced on 2026-10-02: the `product` agent and the `scribe` subagent
  were both denied when creating
  `work/0001-framework-consistency-hardening/spec.md` and `work/.probe`.
  Commit `72d5ac5` had switched from `work/**` to `**/work/**` for absolute
  paths; neither form alone covers every tool path form. The repair — adding
  `work/**` alongside `**/work/**` on all seven artifact-writing agents — landed
  during this spec. Nothing documents that both forms are required, and nothing
  detects if one is dropped, so the fix can silently regress.
- The manually added `ask` agent exists (`.opencode/agent/ask.md`) but appears
  nowhere in `README.md`, `AGENTS.md`, or `docs/workflow.md`, and
  `README.md:182` still claims 11 agent prompts when there are 12. A reachable
  primary agent is invisible to anyone reading the docs.
- `README.md:149-159` documents each agent's file access with only `work/**`,
  while every artifact-writing agent must declare both `work/**` and
  `**/work/**` to cover relative and absolute path forms. The docs never explain
  why both are needed, nor that opencode's `edit` permission covers
  create/write/patch, so the product looks like it is missing a `write` grant
  when it is not.
- Playwright MCP output (`.playwright-mcp/`) and any in-repo scratch space are
  not ignored, so tooling artifacts can be committed by accident.
- The only temporary-file guidance writes to `/tmp` outside the workspace
  (`browser-verification/SKILL.md:46`), which triggers opencode
  `external_directory` approval prompts on every use and adds friction.

Who is affected: framework maintainers, who cannot trust the docs, and
adopters, who receive the same stale inventory and undocumented permission
pattern. Left alone, each new agent, command, or skill can silently reintroduce
this class of drift, and a future permission edit can silently break every
phase's ability to write artifacts.

## Goals

- Artifact-writing agents can create and update files under `work/<slug>/`,
  and the permission pattern that enables this (both path forms) is documented
  and checked so it cannot silently regress.
- The documented inventories of agents, commands, and skills match what is on
  disk exactly: nothing reachable is undocumented, and nothing documented is
  missing.
- The `ask` agent is documented with an accurate purpose and permission profile.
- The documented permission model matches the agents' actual frontmatter, and
  states plainly that opencode's `edit` permission covers create, write, and
  patch, and that both a relative and an absolute `work/` allow are required.
- Non-source tooling output (Playwright MCP output and in-repo scratch space) is
  ignored by version control.
- The framework's temporary-file convention uses an in-repo, gitignored location
  instead of `/tmp`, so no external-directory approval is required.
- A repeatable, read-only diagnostic detects this class of drift (inventory,
  counts, permission mismatches, ignore entries) and reports it before release.
- Existing lifecycle behavior is preserved: no phase gains, loses, or changes
  inputs, outputs, exit criteria, or command behavior.

## Non-goals

- Changing the lifecycle, phases, artifacts, or routing beyond correcting
  factual statements.
- New capabilities: ADR support, build orchestration, full-workflow
  orchestration, parallel-agent development, generated documentation from
  `work/<slug>`, greenfield-repo behavior, a detailed user guide,
  failure-recovery/edge-case handling for the development system, preventive
  risk management, public packaging/installer, dogfooding separation, or
  language capabilities beyond TypeScript/Python.
- Adopting any third-party plugin (for example opencode-shell-hang-guard). This
  is an external dependency with supply-chain and version-pinning risk and is
  deferred to its own work item.
- Broad prompt-engineering rewrites of agent behavior. Only facts that are
  demonstrably wrong are corrected.
- Redesigning the bash-versus-edit security boundary. Tester, visual, scout, and
  bootstrap can modify source through broad `bash` access even though their
  `edit` permission is restricted. This is a known limitation that the docs must
  describe honestly; fixing it is out of scope.
- Auto-fixing drift. The diagnostic reports; it does not modify files.

### Deferred backlog (recorded, not scheduled)

These are acknowledged as valuable and are deliberately not rejected, only
deferred. Priority order is a recommendation for future work-item sequencing.

1. Failure recovery and preventive risk management for the development process.
2. Detailed per-phase user guide (what to do and what not to do).
3. ADR capability.
4. Greenfield-repository behavior.
5. Public packaging and simplified installation.
6. Dogfooding separation and non-TS/Python task capabilities.
7. Parallel-agent development, build orchestration, and full-workflow
   orchestration.
8. Broader determinism and prompt-engineering improvements.
9. Evaluate opencode-shell-hang-guard as an optional integration.

## Users and stories

- **As a** framework maintainer, **I want** the artifact-write permission to be
  correct, documented, and regression-checked, **so that** the lifecycle keeps
  running and a future edit cannot silently break it.
- **As a** framework maintainer, **I want** the documented agent, command, and
  skill inventories to match the repository, **so that** I can trust the docs
  and stop rediscovering drift by hand.
- **As a** framework maintainer, **I want** a single read-only diagnostic that
  reports doc/config drift, **so that** I catch it before shipping instead of
  after.
- **As an** adopter, **I want** the permission documentation and temp-file
  conventions to be accurate and friction-free, **so that** each phase works
  without surprise denials, approval prompts, or accidental commits of tooling
  output.

## Acceptance criteria

1. **AC1** — Given an artifact-writing agent, when its permission block is
   inspected, then it grants both `work/**` and `**/work/**`, and a create plus
   update of a file under `work/<slug>/` succeeds without falling through to a
   deny. The diagnostic reports a regression if either form is missing.
2. **AC2** — Given the repository after this change, when the documented agent,
   command, and skill inventories are compared against `.opencode/agent/`,
   `.opencode/command/`, and `.opencode/skill/`, then every existing item is
   documented in the places that list it (README, AGENTS.md, `docs/workflow.md`)
   and no documented item is absent from disk. *(Clarified: lifecycle phase lists
   in `docs/workflow.md` need only cover lifecycle agents; non-lifecycle agents
   such as `ask` must be documented in README and AGENTS.md.)*
3. **AC3** — Given the `ask` agent exists, when a reader consults the README
   agent list and the AGENTS.md supporting-agents list, then `ask` appears with
   an accurate one-line purpose and its permission profile (primary mode,
   read-only: no file edits and no bash).
4. **AC4** — Given README states a count of agent prompts, when that number is
   compared with the file count on disk, then the stated count equals the actual
   count.
5. **AC5** — Given any agent's declared permission block, when the
   corresponding README permission-table row is read, then the documented
   capability matches what opencode enforces, including that every
   artifact-writing agent is granted access under `work/` via both the relative
   and the absolute path patterns. No row is stale.
6. **AC6** — Given a reader wants to know whether an agent can create a new
   file, when they read the permission/customization documentation, then it
   states that opencode's `edit` permission covers create, write, and patch;
   that no separate `write` grant is required; and that a relative-path and an
   absolute-path allow (`work/**` and `**/work/**`) are both needed to cover
   every tool path form.
7. **AC7** — Given Playwright MCP output and scratch space may be created in the
   repository, when version-control status is checked after they exist, then
   `.playwright-mcp/` and `scratch/` contents are ignored and do not appear as
   untracked files. The ignore rules must not require either directory to exist.
8. **AC8** — Given a maintainer or agent needs a temporary file or a background
   process log, when they follow the framework's documented guidance, then the
   guidance directs them to the in-repo scratch location rather than `/tmp`, and
   no documentation or prompt instructs writing a temporary file outside the
   workspace.
9. **AC9** — Given the repository contains drift (at least: an agent missing
   from the docs, a count mismatch, and a permission-table mismatch), when the
   read-only diagnostic is invoked, then it reports each drift as a finding that
   names both the source of truth and the stale statement/location.
10. **AC10** — Given the repository is internally consistent, when the read-only
    diagnostic is invoked, then it reports no findings and clearly indicates a
    clean result.
11. **AC11** — Given the diagnostic is invoked, when it completes, then it has
    modified no files and performed no write operations; it is safe to run at
    any time, including while other work is in progress.
12. **AC12** — Given the pre-existing lifecycle documentation, when the factual
    corrections are applied, then no phase's inputs, outputs, exit criteria, or
    command behavior changes; only inventory, count, permission, and temp-file
    facts are corrected.

## Edge cases

- **Empty repository state**: `work/` contains no items. The diagnostic must
  succeed and report a clean result rather than erroring on the empty directory.
- **Newly added item, undocumented**: an agent, command, or skill is added
  without updating the docs. The diagnostic must flag it, naming the on-disk item
  and the doc that should list it.
- **Documented but deleted**: a doc lists an item that no longer exists on disk.
  The diagnostic must flag the phantom entry.
- **Consistent addition**: an item added and documented together produces no
  finding.
- **Skill metadata mismatch**: a skill directory exists whose frontmatter `name`
  does not match its folder name (a documented rule). The diagnostic flags it or
  explicitly reports it as unchecked; it must not silently pass.
- **Ignore rules without the directories**: `.playwright-mcp/` and `scratch/` do
  not exist yet; the ignore rules must still be valid and create no
  tracked-directory side effects.
- **Wrong working directory**: the diagnostic is invoked from a subdirectory
  rather than the repo root. It must resolve paths relative to the repository,
  not the process working directory.
- **Formatting noise**: whitespace, line endings, or table-column alignment
  differences must not produce false-positive drift findings.
- **Intentional omissions**: the diagnostic must not flag the deliberately
  deferred features or the intentionally command-less `ask` agent as missing.
- **Concurrent activity**: running the diagnostic while another agent edits
  files must not corrupt state, since it is read-only.

## Open questions

- [x] Exact allowed pattern per agent — resolved: grant both `work/**` and
  `**/work/**`; all seven artifact-writing agents were updated during this spec
  (the `**/work/**`-only allow did not match). The diagnostic must assert both
  forms remain present, and the defect and its rationale still need documenting.
- [x] `scribe`/test/visual `work/` access — resolved: this was a real defect,
  not a non-issue; all artifact-writing agents now carry both path patterns.
- [x] Third-party plugin adoption — resolved: deferred to its own work item.
- [ ] Backlog prioritization (see Deferred backlog) — owner: user, needed by:
  future `/spec` calls. Not blocking this work item.

## Dependencies and constraints

- **opencode version**: targets opencode 1.18+ as stated in README. The
  `edit`/`write` relationship and path-pattern semantics were confirmed
  empirically this cycle: the shipped `**/work/**`-only allow did not match, and
  adding `work/**` repaired it. Re-confirm with `opencode debug agent` when the
  opencode version changes.
- **Prompt-only product**: the diagnostic must not add an installed runtime
  dependency; it may use opencode's built-in tools and the repository's own
  files. (User decision, 2026-10-02.)
- **Duplicated documentation**: agent/command/skill inventories and permission
  facts are restated across `README.md`, `AGENTS.md`, `docs/workflow.md`, and
  `docs/customization.md`. Corrections must keep all copies consistent, and the
  diagnostic should check the duplicated inventories.
- **Artifact ownership**: this phase writes only `work/0001-.../spec.md`. No
  another phase's artifact may be edited.
- **No commits**: per `AGENTS.md`, no commit, push, or PR occurs during this
  work item.
- **Backward compatibility**: adopters copy framework files; corrected docs and
  ignore rules require no migration. Existing `work/` directories are unaffected.
- **Known limitation (documented, not fixed)**: tester, visual, scout, and
  bootstrap hold broad `bash` access, so `edit` restrictions do not fully
  sandbox them. The docs must state this rather than claim full enforcement.

## Assumptions

- The `ask` agent is intentionally retained and should be documented, not
  removed.
- `scratch/` (in-repo, gitignored) is the desired name and location for
  temporary files and background logs.
- `.playwright-mcp/` is the correct ignore path for Playwright MCP output.
- The diagnostic is implemented within opencode's prompt-only model rather than
  as a standalone script.
