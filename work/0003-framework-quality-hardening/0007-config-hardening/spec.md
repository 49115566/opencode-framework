---
feature: 0003-framework-quality-hardening/0007-config-hardening
phase: spec
status: final
created: 2026-10-05
updated: 2026-10-05
notes: "Decisions recorded: default agent changes to the least-privilege entry `product`; no per-agent model overrides (the shipped default is vision-capable and the strongest option); the always-loaded instruction set stays the same three files and gains documented rationale; the Playwright MCP dependency is pinned (exact version chosen in design). Premise correction: the roadmap's 'visual QA degrades on a text-only default' is disproven — `deepseek/deepseek-flash` has vision capabilities."
parent: 0003-framework-quality-hardening
---

# Default config safety and reproducibility

## Problem

The framework's shipped configuration undercuts the safety and reproducibility
story the rest of the framework tells, and its always-loaded instruction set is
undocumented as a choice:

- **The default agent is the most privileged one.** A fresh session opens as
  `builder`, the only agent with unrestricted source edit and broad bash access.
  A framework whose identity is "hard guardrails" hands every adopter a
  maximum-privilege default before they have asked for anything, so an
  accidental first prompt can rewrite source. This affects both **adopters**,
  who copy the configuration into arbitrary repositories, and **maintainers**,
  who cannot point to a deliberate default.
- **The MCP dependency floats.** The Playwright MCP is fetched from the
  `@latest` tag, so two clones or two runs at different times can receive
  different code. This breaks reproducibility and trusts an unpinned upstream
  supply chain. Maintainers cannot state what tooling a given revision resolves
  to.
- **The always-loaded instruction set looks accidental.** Three files are loaded
  into every request with no stated reason or cost, so the per-request token
  price is invisible and the set has no rationale to protect it from drift.
- **Model capability is misstated.** The roadmap assumed the shipped default
  (`deepseek/deepseek-flash`) is text-only and that `/visual` therefore degrades.
  That is false: the default is DeepSeek's strongest model and has vision
  capabilities. The stale premise would push maintainers toward unnecessary
  per-agent model overrides and erode trust in `/visual`.

## Goals

- The shipped default agent is a least-privilege lifecycle entry, so an
  accidental first prompt cannot modify source and the default reflects the
  framework's discipline rather than maximum privilege.
- The shipped Playwright MCP dependency resolves to one exact version, so any
  clone of a revision gets identical tooling and the upstream supply chain is
  not followed implicitly.
- The always-loaded instruction set is a documented, deliberate choice: each
  entry's purpose and the per-request cost of loading it are stated, and the set
  stays consistent with what adoption actually copies.
- Model documentation states the shipped default's real capability (vision-
  capable, strongest shipped option) and that `/visual` and `/reviewer` need no
  per-agent model overrides, removing the text-only-degradation premise.
- The changed configuration parses and resolves cleanly after restart, without
  pointing at a disabled agent.

## Non-goals

- Changing any agent's permission allowlists or the read-only/enforcement
  wording — owned by `0003-readonly-permissions`.
- Deciding whether `README.md` becomes an always-loaded instruction, or
  restructuring how instructions load — owned by `0004-doctor-scope`.
- Building or extending the committed test harness or CI — owned by
  `0006-committed-tests-ci`.
- Adding `LICENSE`, `CONTRIBUTING`, `CHANGELOG`, or a version manifest — owned
  by `0008-adoption-packaging`.
- Sweeping command usage strings, the `AGENTS.md` lifecycle table, the `ask`
  description, or the project profile — owned by `0009-surface-consistency`.
- Changing the `model`/`small_model` values, or adding per-agent `model:`
  overrides (the default is already the strongest, vision-capable option).
- Changing the set of disabled built-in agents or the baseline permission block.

## Users and stories

- **As an** adopter, **I want** the copied configuration to open in a
  least-privilege agent, **so that** a mistaken first prompt cannot rewrite my
  source before I have deliberately chosen a more powerful agent.
- **As a** maintainer, **I want** the Playwright MCP dependency pinned to an
  exact version, **so that** a clone of a given revision reproduces the same
  tooling and a silently changed upstream tag cannot alter my setup.
- **As a** maintainer, **I want** the always-loaded instruction set documented
  with its purpose and cost, **so that** its per-request price is a decision
  rather than an accident and the set matches what adoption copies.
- **As a** maintainer, **I want** the shipped model's capability stated
  accurately, **so that** I do not add unnecessary per-agent overrides or
  distrust `/visual` on a false text-only premise.

## Acceptance criteria

1. **AC1** — Given the shipped configuration, when it is parsed with the
   framework's config debug command, then the default agent is `product`, and
   `product` is an enabled `primary` agent whose edit permission is limited to
   work artifacts.
2. **AC2** — Given the repository documentation, when a reader looks up the
   default agent, then every mention agrees with the configured value and no
   file still states that `builder` is the default.
3. **AC3** — Given the Playwright MCP entry in the shipped configuration, when
   its command is inspected, then it names one exact published version and
   contains no floating tag or range (`latest`, `*`, `^`, `~`), and the same
   exact version appears in the configuration documentation.
4. **AC4** — Given the always-loaded instruction list, when it is inspected,
   then it contains exactly the three contract files `AGENTS.md`,
   `docs/workflow.md`, and `docs/artifact-conventions.md`, and every listed path
   is one the adoption quickstart copies into a target repository.
5. **AC5** — Given the configuration documentation, when a maintainer reads
   about the always-loaded instruction set, then each entry's purpose and the
   per-request cost of loading all entries are stated.
6. **AC6** — Given the shipped default model, when the model documentation is
   read, then it states that the model has vision capabilities and is the
   strongest shipped option, and that `/visual` and `/reviewer` require no
   per-agent model overrides; no file claims visual QA degrades because the
   default is text-only.
7. **AC7** — Given the agent definitions, when their model settings are
   inspected, then no agent declares its own `model` override and all agents
   inherit the global default.
8. **AC8** — Given the changed configuration, when the framework is restarted
   and the config is validated, then it parses without error and the default
   agent resolves without referencing a disabled agent.

## Edge cases

- **Merged rather than overwritten config.** An adopter may merge the shipped
  configuration into an existing one; an explicit `default_agent` they already
  set is preserved. The documented rationale must make the intended default
  clear so a merge is a conscious choice.
- **Pinned version later yanked or superseded.** The pin is a deliberate,
  reviewable change; documentation must make bumping the pin the sanctioned way
  to move versions rather than restoring a floating tag.
- **Partial instruction copy.** An adopter who copies only some always-loaded
  files gets a missing-path load; the set must stay limited to files the
  quickstart guarantees, and AC4 enforces that.
- **Default agent disabled or renamed by a user.** Validation (AC8) must surface
  the broken default rather than leaving a silent misconfiguration.
- **`small_model` interaction.** It remains unchanged and equal to the global
  model; no criterion depends on it.
- **No vision model available to an adopter.** `--headless`/`--isolated`
  browser QA still runs structurally; this is the `visual` agent's existing
  documented fallback and is unaffected by this change.

## Open questions

- [x] Which agent is the default? — resolved: `product`, the least-privilege
      lifecycle entry (user decision, 2026-10-05).
- [x] Should `visual`/`reviewer` receive model overrides? — resolved: no; the
      shipped default is vision-capable and the strongest option (user
      clarification, 2026-10-05).
- [x] Keep, trim, or annotate the always-loaded instruction set? — resolved:
      keep the three files and document why (user decision, 2026-10-05).
- [ ] Exact Playwright MCP version to pin — owner: architect, needed by:
      design. Deferred; any published version satisfying AC3 is acceptable to
      the requirements.

## Dependencies and constraints

- Roadmap parent: `0003-framework-quality-hardening`; this child's `Depends on`
  is `—`, so it is ready and blocks nothing.
- `0001-state-model` (shipped) established that `work/` artifacts are committed;
  that decision does not alter any configuration value here.
- Boundary constraints: `0003-readonly-permissions` owns permission allowlists;
  `0004-doctor-scope` owns the README-as-instruction decision and instruction
  loading structure; `0006-committed-tests-ci` owns the test harness that may
  later assert these config facts; `0009-surface-consistency` owns the
  remaining surface sweep. This item must not duplicate their work.
- opencode loads configuration once at startup, so AC8 requires a restart before
  validation.
- The pinned MCP version must be published and installable through the same
  package runner the configuration already uses.
- The chosen default agent must remain enabled (not among the disabled built-in
  agents) and must stay a least-privilege primary agent.
- **Verified context:** `deepseek/deepseek-flash` is DeepSeek's strongest model
  and has vision capabilities (user clarification, 2026-10-05), correcting the
  roadmap's text-only-premise evidence for this child.
