---
feature: 0003-framework-quality-hardening/0003-readonly-permissions
phase: spec
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Nested roadmap child; no dependencies (Depends on: —), so it is ready. Re-verified the roadmap's cited findings against current files before specifying; all still hold. User made the scoping decisions recorded under Open questions."
---

# Read-only agent permissions and enforcement claims

## Problem

The framework labels six agents — `product`, `architect`, `roadmap`, `status`,
`reviewer`, and `doctor` — as "read-only", and the top-level README states that
"Reviewers and product agents cannot touch source" and presents their bash access
as a "read-only allowlist". Neither claim is fully true. Each of the six grants
bash tokens that can write or execute: `find` supports `-delete` and `-exec`, and
`rg` supports `--pre` to run an arbitrary program (`product.md:15-17`,
`architect.md:15-17`, `roadmap.md:15-17`, `status.md:14-16`, `reviewer.md:19-21`,
`doctor.md:14-17`). Worse, opencode matches bash rules by command prefix, so no
allowlist can prevent shell redirection (`cmd > file`) or output flags — a fact
the customization guide already documents (`docs/customization.md:133-136`) but
the README contradicts. This was reported as a Minor in the shipped
framework-consistency review (`work/0001-framework-consistency-hardening/review.md:67`,
finding m1) and remains unfixed.

Two audiences are affected. **Framework maintainers** cannot trust the product's
own security language and have no regression guard tying the claimed and actual
permissions together. **Adopters** copy this permission model into arbitrary
repositories, so the over-claim is propagated into every adoption. Separately,
`tester`'s file-tool allowlist omits common test layouts (`e2e/`, `spec/`,
`integration/`), so a tester working in those layouts must fall back to the same
broad bash it is meant to avoid (`tester.md:9-34`).

## Goals

- The six read-only agents no longer carry bash commands whose canonical use
  modifies the filesystem or executes an arbitrary program.
- Every documented claim about read-only agents matches what opencode actually
  enforces: a file-tool guarantee, with bash restrictions described honestly as
  best-effort rather than a sandbox.
- Users can tell, from the README and customization guide, exactly which agents
  can modify files through the shell and which cannot.
- `tester`'s file-tool allowlist covers the common test layouts `e2e/`, `spec/`,
  `integration/`, `cypress/`, and `playwright/`.

## Non-goals

- **Not a bash sandbox.** Shell redirection and output-to-file flags remain
  possible and are documented, not blocked; opencode's prefix rules cannot
  express that restriction. The goal is truthful claims, not a jail.
- **Not hardening the broad-bash agents.** `scout`, `tester`, `visual`, and
  `bootstrap` keep their broad bash; `scout` in particular is documented as an
  accepted residual.
- **Not changing `ask`.** It already denies `edit` and `bash`; it serves only as
  context for the broad-bash documentation.
- **Not changing `edit` permissions of any read-only agent** (other than adding
  test paths for `tester`), and not changing `shipper`, `builder`, or `scribe`.
- **Not the artifact state model** (committed vs local-only `work/`), owned by
  sibling `0001-state-model`.
- **Not the surface-consistency sweep** — the `/visual` spelling and the
  `AGENTS.md` lifecycle-table `item-ref` cleanup belong to sibling
  `0009-surface-consistency`.
- **Not a committed test harness or CI workflow**, owned by sibling
  `0006-committed-tests-ci`; this item's verification uses the repository's
  existing static assertions and diagnostics.
- **Not changing lifecycle phases, artifact formats, routing, or the global
  permission defaults.**

## Users and stories

- **As a** framework maintainer, **I want** the "read-only" label and its
  supporting tables to be accurate, **so that** I can trust the framework's
  security claims and defend them in review.
- **As an** adopter, **I want** to know exactly which agents can write files and
  by what mechanism, **so that** I can reason about risk before copying the
  framework into a repository that contains secrets or production code.
- **As a** framework maintainer adding tests, **I want** the tester agent's
  file-tool allowlist to cover `e2e/`, `spec/`, and `integration/` layouts, **so
  that** it can add tests there without resorting to broad shell access.

## Acceptance criteria

1. **AC1** — Given the six read-only agents (`product`, `architect`, `roadmap`,
   `status`, `reviewer`, `doctor`), when each agent's bash allowlist is
   inspected, then it grants neither `find*` nor `rg*`, and its leading catch-all
   rule is still `"*": deny`.

2. **AC2** — Given any of the six read-only agents, when its bash allowlist is
   inspected, then every remaining allowed entry is a command whose canonical use
   only reads repository state (for example listing, displaying, and read-only
   git subcommands), and no entry is a command whose primary purpose is to
   create, modify, move, delete, or change permissions on files or to execute an
   arbitrary program.

3. **AC3** — Given the six read-only agents no longer grant the removed search
   commands, when each agent's prompt body is read, then it does not instruct the
   agent to run those commands through bash and instead directs it to the
   file-search tools, so the prompt is executable under the agent's own
   permissions.

4. **AC4** — Given each of the six read-only agents, when its prompt body is
   read, then it contains an explicit prohibition against using bash to write,
   move, create, or delete files, and frames the allowlist as a guard rather than
   a sandbox.

5. **AC5** — Given the top-level README's guardrail prose, when it is read, then
   it no longer states that the read-only agents "cannot touch source"; it states
   that they cannot create, modify, or delete source through the file tools.

6. **AC6** — Given the top-level README's agent reference table, when the "Can
   run bash" cells for the six read-only agents are read, then they no longer
   present "read-only allowlist" as an enforced guarantee; they describe the
   restriction as best-effort and point to the customization guide for the
   caveat.

7. **AC7** — Given the top-level README paragraph claiming permissions are
   "enforced by opencode", when it is read, then it scopes enforcement to the
   file-tool permissions (create, write, patch, edit) and states that bash
   restrictions are command-prefix based and do not constitute a sandbox.

8. **AC8** — Given the customization guide's permission-caveat section, when it
   is read, then it names every agent with broad bash access (`bootstrap`,
   `scout`, `tester`, `visual`) as able to modify files through the shell, names
   `scout`'s broad access as a deliberate, accepted residual, and states that no
   bash allowlist sandboxes the filesystem.

9. **AC9** — Given the `tester` agent's file-tool allowlist, when it is
   inspected, then it permits editing test files under `e2e/`, `spec/`,
   `integration/`, `cypress/`, and `playwright/`, in both relative and
   repository-absolute path forms, in addition to the layouts already permitted.

10. **AC10** — Given the repository after this change, when the framework's
    permission diagnostics run, then documented capabilities and on-disk
    allowlists agree with no drift finding.

11. **AC11** — Given the repository after this change, when the lifecycle
    documentation and global configuration are inspected, then no lifecycle
    phase, artifact format, routing rule, or global permission default has
    changed.

## Edge cases

- **A prompt still tells its agent to run a removed command.** If an agent's
  process references `rg` or `find` after the allowlist drops them, the prompt
  becomes non-executable under its own permissions; AC3 requires those references
  to be replaced with the file-search tools.
- **`tree -o <file>` and git `--output=<file>`** remain write-capable while their
  commands stay allowed. They are accepted residual risk covered by AC4's prompt
  prohibition and AC7/AC8's documentation, not blocked by a rule.
- **Catch-all ordering.** Because opencode evaluates permission rules
  last-match-wins, removing a token must not accidentally reorder the catch-all
  `"*": deny` behind an allow; AC1 checks it remains the leading rule.
- **The README table and the agent blocks can drift apart.** `/doctor` compares
  them (`doctor.md:100-106`); if the table's wording changes shape, the
  comparison must be re-verified so a clean run still reports no findings
  (AC10).
- **`tester` already has broad bash.** Broadening its file-tool allowlist is an
  intent/consistency improvement, not a security boundary; the documentation
  must not imply the tester is sandboxed.
- **`ask` is already fully denied.** Any broad-bash documentation must not
  accidentally list `ask` as a broad-bash agent.
- **Empty/degenerate layouts.** A project with no test directory still behaves
  unchanged; the new test-path patterns simply never match.

## Open questions

- [x] Which agents are in scope, and how are `scout` and `ask` handled?
      **Resolved (user):** the six read-only agents; `scout` keeps broad bash and
      is documented as an accepted residual; `ask` is unchanged (already denies
      `edit` and `bash`).
- [x] Which bash tokens should the six read-only agents drop? **Resolved
      (user):** remove `find*` and `rg*`; keep `ls*`, `cat*`, `tree*`, and the
      read-only git entries.
- [x] How far should `tester`'s file-tool allowlist be broadened? **Resolved
      (user):** add `e2e/`, `spec/`, `integration/`, plus the common runner
      directories `cypress/` and `playwright/`, in both path forms.
- [ ] Should `tree -o` and git `--output` get dedicated blocking rules? —
      owner: user, needed by: design. **Deferred:** opencode's prefix rules
      cannot express argument-level restrictions; covered by the prompt
      prohibition (AC4) and the corrected documentation (AC7, AC8).

## Dependencies and constraints

- No item dependencies: the parent `roadmap.md` lists this child as
  `Depends on: —`, so it is ready.
- The change is prompt/config/documentation only; it touches no runtime code and
  introduces no dependency.
- `docs/customization.md:133-136` already states that the permission blocks are
  not a bash sandbox; the README must be brought into agreement with it, not the
  reverse.
- The `/doctor` agent's `PERMISSION-TABLE-MISMATCH` and `PERMISSION-WORK-PATTERN`
  checks (`doctor.md:94-106`) compare the README table against on-disk blocks;
  both sides are edited here, so the pair must remain mutually consistent.
- `/doctor` itself is one of the six hardened agents; removing `rg`/`find` from
  its allowlist requires its process description to use the search tools
  (AC3).
- Sibling `0002-readiness-ship-state` already shipped and did not modify these
  permission blocks; this item does not reopen it.
- **Assumption:** because the artifact under change is the framework's own
  prompts, tables, and guides, acceptance criteria name those surfaces so they
  are testable; they specify required content, not implementation choices.
- **Assumption:** opencode bash rules match command prefixes and cannot prevent
  shell redirection or output-to-file flags; the spec therefore targets truthful
  claims plus removal of inherently write/execute commands rather than an
  unattainable sandbox.
