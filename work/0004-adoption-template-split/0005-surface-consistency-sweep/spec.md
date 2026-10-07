---
feature: 0004-adoption-template-split/0005-surface-consistency-sweep
phase: spec
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Amended 2026-10-07 after review M1: the canonical `/status` row now reads `/status [item-ref]`, matching `.opencode/command/status.md`, so AC1's 'no command states a divergent signature' holds."
---

# Command signature and prompt-surface sweep

## Problem

The framework's slash-command signatures and usage strings disagree across the
surfaces that document them. `AGENTS.md` advertises `/plan <feature>` where the
command takes an item-ref, `/build [task-id]` where it takes an item-ref or a
task-id, and bare `/test`, `/review`, and `/ship` where each takes an optional
item-ref; its supporting-commands list still carries the stale
`/visual [url|slug]` and `/fix <bug>` spellings. `docs/workflow.md`'s phase
headings repeat the same stale forms and its routing bullet says
`/visual [url or slug]`. The `README.md` Commands table, lifecycle mermaid, and
quickstart example use yet other spellings (`/visual [url]`, `/build [task]`).
The `workflow-lifecycle` skill's routing block is a fourth variant. And the
`ask` agent's frontmatter description — `Ultra-Basic Read-Only Agent.` — breaks
the `<Role> agent. <capability>. [Read-only.]` convention every other agent
follows.

Two audiences are affected. **Framework maintainers** cannot rely on any single
signature being correct, so reviewers and agents pass commands the wrong
arguments. **Adopters** are worse off: the adoption split made
`template/AGENTS.md` the adopter-pristine copy the quickstart installs, and it
duplicates the root `AGENTS.md`'s stale lifecycle table, so every adopted
repository receives contradictory usage. Nothing in the committed suite detects
the drift — `tests/checks/20-lifecycle.sh` explicitly excludes argument
signatures — so the inconsistency has persisted and will recur.

## Goals

- One canonical signature per command, derived from the command's own usage
  string and repaired where the command's usage string is itself incomplete, and
  stated identically on every in-scope lifecycle surface.
- Both the framework's maintainer-bootstrapped `AGENTS.md` and the
  adopter-pristine `template/AGENTS.md` carry the canonical signatures, so the
  maintainer and adopter copies no longer diverge.
- The `ask` agent's frontmatter description conforms to the agent-description
  convention.
- A committed check fails, and names the offending surface and command, when any
  in-scope signature diverges — so the drift cannot return silently.
- The existing committed suite, including the adoption split guard and the
  inventory, packaging, lifecycle, and instruction agreements, stays green.

## Non-goals

- Changing any command's behavior, arguments, phases, routing, lifecycle, or
  artifact format. This sweep changes wording only.
- Editing surfaces outside the enumerated set — in particular
  `docs/customization.md`, `docs/artifact-conventions.md`, agent handoff
  examples (e.g. "Next: `/build <item-ref>`"), the `README.md` Agents/Skills
  tables, and any command or agent file other than the `/spec` and `/ship` usage
  strings and the `ask.md` description.
- Adding a `CHANGELOG.md` or `VERSION` entry; releases are cut manually by a
  maintainer (`CONTRIBUTING.md`).
- Reopening the withdrawn `0003-framework-quality-hardening/0009-surface-consistency`
  or any shipped sibling child of this roadmap.
- Updating the stale test-internal comment at `tests/checks/20-lifecycle.sh:12`
  that attributes item-ref usage strings to the withdrawn `0009`; it is not a
  user-facing surface and its repair is optional.
- Introducing a runtime dependency, install step, build step, or network access.

## Canonical signatures

Derived from each command's `.opencode/command/*.md` frontmatter, with `/spec`
repaired to name its item-ref form and `/ship` repaired to name its fix-landing
form (both confirmed by their command bodies). This is the single source of
truth every in-scope surface must state.

| Command | Canonical signature |
| ------- | ------------------- |
| `/spec` | `/spec <feature or problem description \| item-ref>` |
| `/plan` | `/plan <item-ref>` |
| `/build` | `/build [item-ref or task-id]` |
| `/test` | `/test [item-ref]` |
| `/review` | `/review [item-ref]` |
| `/ship` | `/ship [item-ref]` |
| `/visual` | `/visual [url or item-ref]` |
| `/fix` | `/fix <bug description>` |
| `/roadmap` | `/roadmap <initiative>` |
| `/status` | `/status [item-ref]` |
| `/doctor`, `/bootstrap` | no argument |

The `/ship` command's own `Usage:` string also documents its fix-landing mode as
`/ship fix [short description]`; the lifecycle surfaces show the phase form
`/ship [item-ref]`. No other command has an alternate argument form.

## Users and stories

- **As a** framework maintainer, **I want** every documented command signature
  to match the command's actual arguments, **so that** I, reviewers, and other
  agents invoke the lifecycle with the right arguments and trust the docs.
- **As an** adopting engineer, **I want** the `AGENTS.md` the quickstart installs
  to carry the same correct signatures as the framework's own copy, **so that** I
  am not told to run commands differently from the people who built the
  framework.
- **As a** framework maintainer, **I want** a committed check that fails when a
  signature drifts, **so that** the next documentation change cannot silently
  reintroduce an inconsistency.
- **As a** framework agent reading another agent's prompt list, **I want** every
  agent description to follow the same shape, **so that** I can identify an
  agent's role and read-only status at a glance.

## Acceptance criteria

1. **AC1** — Given the framework's slash commands, when each command's own usage
   string is inspected, then it states the canonical signature from the table
   above (with `/spec` naming its item-ref form and `/ship` naming its
   fix-landing form), and no command states a divergent signature.

2. **AC2** — Given the framework's maintainer-bootstrapped `AGENTS.md`, when its
   lifecycle table and supporting-commands rendering are inspected, then every
   command signature equals the canonical signature, and none of the stale forms
   `/plan <feature>`, `/build [task-id]`, bare `/test`, `/review`, or `/ship`,
   `/fix <bug>`, or `/visual [url|slug]` remains.

3. **AC3** — Given the adopter-pristine `template/AGENTS.md`, when its lifecycle
   table and supporting-commands rendering are inspected, then they state the
   same canonical signatures as AC2, and the file's `## Project profile` section
   still holds its unfilled placeholders.

4. **AC4** — Given `docs/workflow.md`, when the six phase headings and the
   `/visual` routing bullet are inspected, then each states the canonical
   signature (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` headings;
   `/visual [url or item-ref]`), and the stale `/plan <feature>`,
   `/build [task-id]`, bare `/test`/`/review`/`/ship`, and
   `/visual [url or slug]` forms are gone.

5. **AC5** — Given `README.md`, when its Commands table, lifecycle mermaid, and
   quickstart example are inspected, then every command signature shown is
   canonical, the mermaid labels render the canonical signatures (accounting for
   its HTML-escaped `<`/`>`), and the stale `/build [task]`,
   `/visual [url]`, and `/fix <bug>` forms are gone.

6. **AC6** — Given the `workflow-lifecycle` skill, when its routing block and
   rules are inspected, then every command signature shown is canonical, and no
   stale form remains.

7. **AC7** — Given the `ask` agent prompt, when its frontmatter description is
   inspected, then it reads
   `Q&A agent. Answers whatever the user has on their mind with plain, thorough
   explanations. Read-only.` — a `<Role> agent. <capability>. Read-only.` shape
   consistent with the other agents — and not `Ultra-Basic Read-Only Agent.`.

8. **AC8** — Given the committed suite, when `bash tests/run.sh` runs, then it
   executes a check that, for every in-scope surface and command, fails and names
   the offending file and command when a stated signature diverges from the
   canonical signature, and `tests/README.md` documents that check's area and
   stable suite token.

9. **AC9** — Given the whole change, when `bash tests/run.sh` runs, then it exits
   `0`; in particular the adoption split guard still passes (the
   `template/AGENTS.md` placeholder profile is intact and the README quickstart
   copy set is unchanged) and the inventory, packaging, lifecycle, and
   instruction agreements are unbroken.

## Edge cases

- **HTML-escaped signatures in mermaid.** `README.md` renders `<`/`>` as
  `&lt;`/`&gt;` inside mermaid labels. The canonical signature comparison must
  account for the encoding (decode before comparing, or match the encoded form),
  or AC5 fails on a label that is correct when rendered.
- **Invocations are not signatures.** Surfaces legitimately show concrete
  invocations such as `/plan 0001-add-dark-mode`, `/build T2`, or
  `/spec add dark mode`. These must not be treated as signatures or fail the
  guard.
- **The `/ship` alternate form.** Phase surfaces show `/ship [item-ref]` while
  the command's usage string also names fix mode. The guard must accept the phase
  form as canonical and still require fix mode in the command usage.
- **Free-form `/spec` argument.** The `/spec` argument may be a multi-word
  problem description or an item-ref; the canonical signature must express both
  and the guard must not mistake the words of a description for signatures.
- **Missing surface or command.** If an in-scope surface omits a signature
  entirely, the guard must fail naming that surface rather than pass vacuously.
- **Adopter copy profile.** Editing `template/AGENTS.md` must not touch its
  `## Project profile`, or the adoption split guard's placeholder assertion
  fails.
- **README table parseability.** Editing signature cells must keep the Commands
  table parseable: `tests/checks/40-inventory.sh` reads each row's first cell for
  the command name, which the signature's leading `/name` preserves.
- **First guard of its kind.** No committed check currently asserts signature
  agreement; the new check must be self-contained and run on a minimal
  environment (bash + git only), like the rest of the suite.
- **Future command changes.** Adding or renaming a command later will fail the
  new guard by design; the canonical table and the guard are updated together.
- **Concurrency.** Not applicable: the change is static documentation and prompt
  text.

## Open questions

- [x] What is the canonical signature source, and are command files editable?
      **Resolved (user, 2026-10-07):** the command `Usage:` strings are canonical;
      repair `/spec` to include its item-ref form and `/ship` to include its
      fix-landing form, then propagate.
- [x] Is the adopter-pristine `template/AGENTS.md` in scope? **Resolved (user,
      2026-10-07):** yes — both root and template copies are updated.
- [x] Does this item add a committed regression guard? **Resolved (user,
      2026-10-07):** yes, a new committed check plus its `tests/README.md`
      documentation.
- [x] What replaces the `ask.md` description? **Resolved (user, 2026-10-07):** the
      wording in AC7.
- [ ] Exact guard mechanics — signature extraction from mixed contexts, mermaid
      entity decoding, and the new suite token number — owner: architect, needed
      by: design. Non-blocking.
- [ ] Whether to also refresh the stale `tests/checks/20-lifecycle.sh:12`
      comment naming the withdrawn `0009` — owner: user, needed by: design.
      _Assumption:_ no; recorded as a non-goal unless the user says otherwise.

## Dependencies and constraints

- **Parent roadmap child.** Canonical reference
  `0004-adoption-template-split/0005-surface-consistency-sweep`; `parent:
  0004-adoption-template-split`.
- **Readiness satisfied.** The roadmap's `Depends on` cell names
  `0001-adopter-template-split`, `0002-bootstrap-quickstart-rework`, and
  `0004-doctor-template-alignment`; all three contain a `ship.md`, so every
  dependency is satisfied and the child is ready. No cycle.
- **In-scope surfaces.** Root `AGENTS.md`; `template/AGENTS.md`;
  `docs/workflow.md` (six phase headings and the `/visual` routing bullet);
  `README.md` (Commands table, lifecycle mermaid, quickstart example);
  `.opencode/skill/workflow-lifecycle/SKILL.md` (routing block and rules);
  `.opencode/command/spec.md` and `.opencode/command/ship.md` usage strings;
  `.opencode/agent/ask.md` description; and the new committed check plus
  `tests/README.md`.
- **Sequenced last by the roadmap.** This child edits `AGENTS.md`, `README.md`,
  and `docs/workflow.md` after the split and doctor-alignment children settled
  them, so it consumes the split layout rather than re-deciding it. In
  particular, `template/AGENTS.md` is the adopter source and must stay
  placeholder-profiled for its Project profile.
- **Existing suite is the acceptance harness.** `bash tests/run.sh` must stay
  green; the split guard (`tests/checks/95-split-guard.sh`), inventory
  (`40-inventory.sh`), packaging (`90-packaging.sh`), lifecycle
  (`20-lifecycle.sh`), and instruction (`50-instructions.sh`) agreements must all
  continue to pass. `20-lifecycle.sh` deliberately ignores argument signatures,
  so the new guard is additive and does not fork that agreement.
- **No new dependency.** The change is prompt/config/doc/test only, with no
  runtime, build, install, or network requirement.
- **Recon basis.** The divergences and stale spellings cited above were
  re-verified against the current files on 2026-10-07; the roadmap's original
  line numbers had shifted after the split and doctor-alignment children landed,
  so this spec relies on the strings, not the cited line numbers.
