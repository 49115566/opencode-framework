---
feature: 0003-framework-quality-hardening/0004-doctor-scope
phase: design
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Maintainer-only scope per user decision. Exclusion implemented as a removal step in the README quickstart. No permission/config/lifecycle behavior changes."
---

# Design — Doctor audience and diagnostic accuracy

## Summary

Treat `/doctor` and the `doctor` agent as framework-maintainer-only tooling:
label them as such on every live surface, drop them from the adoption quickstart
so a fresh adopter never installs them, and correct the diagnostic prompt so its
sample findings no longer assert stale counts or `file:line` citations and its
completeness rule derives lifecycle classification from `docs/workflow.md`
instead of an inline agent snapshot. A missing documentation surface yields one
`SURFACE-MISSING` finding rather than a cascade. Permissions, `opencode.json`,
the check catalogue, and lifecycle behavior are deliberately untouched.

## Approach

Recon found exactly five live files mention `/doctor`: `README.md` (Commands row
`:159`, Agents row `:179`, quickstart `:40-47`), `AGENTS.md:50,54`,
`docs/workflow.md:274-276`, `.opencode/agent/doctor.md`, and
`.opencode/command/doctor.md`. `docs/customization.md` and every `SKILL.md` are
silent, so no broad sweep is needed. The change has three parts plus an explicit
non-change list, all backed by AC numbers from the spec.

### 1. Adoption exclusion (AC2, AC3)

The quickstart copies whole directories (`README.md:43`), so there is no
per-file copy list to extend. The smallest structural change is a removal step
immediately after the directory copy:

```bash
cp -r "$FRAMEWORK/.opencode/agent" "$FRAMEWORK/.opencode/command" "$FRAMEWORK/.opencode/skill" .opencode/
rm -f .opencode/agent/doctor.md .opencode/command/doctor.md
```

A short note below the block explains why (the diagnostic needs the framework
README's inventory tables, which the quickstart never copies), tells an
already-adopted repository to remove or ignore the two files, and warns that an
out-of-band `.opencode/` copy that retains them will make `/doctor` misreport
outside the framework repo (spec edge cases; AC3).

### 2. Maintainer-only labeling (AC1, AC3)

Append the scope marker where it cannot disturb the names the diagnostic matches
on. The diagnostic's inventory and permission-table checks key on the agent and
command names, so **name cells stay byte-identical** and labels go in adjacent
content:

- `README.md` Commands table: append `— framework-maintainer only` to the
  `/doctor` row's description cell (`:159`).
- `README.md` Agents table: append `(framework-maintainer only)` to the `doctor`
  row's "Can run bash" cell (`:179`), leaving the `doctor` name cell untouched.
- `AGENTS.md`: mark `/doctor` in the supporting-commands list (`:50`) and
  `doctor` in the supporting-agents list (`:54`).
- `docs/workflow.md`: add the scope to the `/doctor` routing bullet
  (`:274-276`).
- `description:` frontmatter of `.opencode/agent/doctor.md:2` and
  `.opencode/command/doctor.md:2`.

### 3. Prompt correctness (AC4, AC5, AC6)

**Symbolic examples (AC4).** In `.opencode/agent/doctor.md` `<finding_format>`
(`:137-155`):
- `:148` currently reads `[COUNT-MISMATCH] .opencode/agent/ (12 files) <->
  README.md:182 ("11 role prompts").` — both integers are stale (disk holds 14
  agents; `README.md:209` says "14 role prompts") and the citation is brittle.
  Replace with a symbolic form: `[COUNT-MISMATCH] .opencode/agent/ (count on
  disk) <-> README.md Layout comment ("role prompts"): counts differ.`
- `:152` cites `.opencode/skill/browser-verification/SKILL.md:46` as writing to
  the system temp directory, but that line actually directs output to the
  in-repo `scratch/dev-server.log` (`.opencode/skill/browser-verification/SKILL.md:46-48`)
  — the example is factually wrong. Replace with a symbolic form over a
  placeholder file and its scratch guidance, with no line number.
- Add a `[SURFACE-MISSING]` example matching the new guard in part 3b.

Examples at `:147` and `:149-151` carry no counts or line citations; leave them.
The hard-coded word "nine" (`agent:169`, `command:13`) is an accurate count of
the existing check steps and is out of AC4's scope (it is not agent/command/
skill count nor a `file:line`); it is intentionally left unchanged to avoid
expanding the catalogue.

**Completeness rule (AC5, AC6).** Replace `<completeness_rule>`
(`.opencode/agent/doctor.md:157-164`). The current block hard-codes the
non-lifecycle agent set `(ask, doctor, scout, scribe, status, bootstrap)` and
the `ask`-has-no-command special case — a snapshot that duplicates repository
state and can silently go stale. New semantics:

1. Enumerate the required documentation surfaces (`README.md` tables and Layout
   count comments; `AGENTS.md` lifecycle table and supporting lists). Before any
   inventory comparison, confirm each surface exists and is readable.
2. If a surface is absent, emit a single `[SURFACE-MISSING] <surface>` finding
   and skip the comparisons that depend on it — never one finding per item.
3. Derive classification from the repository: an agent is *lifecycle* exactly
   when it is named in a `docs/workflow.md` phase table. Only lifecycle agents
   must be consistent with those phase lists (a phase-table name must exist on
   disk); a non-lifecycle agent's absence from them is not a finding.
4. State that an agent need not have a command; a command-less agent is not a
   finding. This replaces the `ask`-specific exception without naming any agent.

Add the matching guard bullet and the `SURFACE-MISSING` example to
`.opencode/command/doctor.md` so the command and agent stay consistent.

### 4. Deliberate non-changes

- `opencode.json` `instructions` (`:6-10`) is unchanged: README stays out; the
  token tax is accepted (spec AC8, user decision).
- `doctor`'s `permission:` block is untouched (`edit: deny`, read-only bash
  allowlist). Write-capable allowlist tokens are `0003-readonly-permissions`'
  scope (spec boundary).
- The catalogue of checks and the output contract are unchanged apart from the
  one new completeness guard code.
- No lifecycle phase, artifact, command argument, or `docs/workflow.md` phase
  behavior changes (AC10).

## Alternatives considered

- **Chosen — removal step in the quickstart.** Pros: matches the existing
  directory-copy convention, one line, self-documenting next to the note; no new
  files. Cons: a manual, out-of-band copy can still retain the files — mitigated
  by the explicit warning.
- **Structural exclusion via a maintainer-only source tree** (move doctor out of
  `.opencode/agent|command/` and symlink/copy it in for framework development).
  Pros: exclusion is structural, so no adopter can copy it by accident. Cons:
  opencode only discovers `.opencode/agent/*.md` and `.opencode/command/*.md`,
  so the framework repo would need an install/symlink step to keep `/doctor`
  working for maintainers — new machinery, platform-dependent symlink behavior,
  and a second place to keep the prompt. Rejected: more moving parts for one
  file than the removal step.
- **Self-detecting doctor** (ship everywhere; detect a non-framework repo and
  report "not applicable"). Rejected by the spec's maintainer-only decision:
  branching the prompt cannot make the README inventory checks meaningful in a
  repo that has no framework README, and it keeps an ambiguous command in the
  adopted set.
- **Adopter-usable via AGENTS.md / shipping README to adopters.** Rejected as a
  spec non-goal; it means maintaining an inventory surface for adopters and
  paying the README token cost.

## Interfaces and data model

No runtime interfaces, schemas, or migrations: the product is prompt and
documentation files. The relevant contracts are:

- **Finding catalogue.** The existing codes are unchanged. One code is added,
  scoped to the completeness guard: `SURFACE-MISSING`, emitted at most once per
  missing/unreadable required surface, in the existing line shape
  `[SURFACE-MISSING] <surface>: absent or unreadable; dependent inventory checks
  skipped.`
- **Completeness rule contract.** Required surfaces are `README.md` (Agents,
  Commands, Skills tables; Layout count comments) and `AGENTS.md` (lifecycle
  table; supporting-commands and supporting-agents lists). Coverage: every
  on-disk agent and command appears in the README tables and by name in
  `AGENTS.md`; every on-disk skill appears in the README Skills table. Lifecycle
  classification is derived from `docs/workflow.md` phase tables, not from a
  hard-coded name list.
- **Documentation labeling contract.** The `doctor` / `/doctor` name tokens stay
  exact; scope text is appended only to descriptions and non-name cells so the
  diagnostic's own checks (and `README.md:181-188`'s permission explanation)
  remain valid.
- **Backward compatibility.** Adopters on the previous version keep working;
  the change adds documentation and removes nothing from their disk. The
  inventory counts in the framework repo remain 14 agents / 12 commands / 10
  skills, so `/doctor` stays clean.

## Affected areas

- `README.md` — quickstart copy block + maintainer-only note (`:40-47`),
  Commands row (`:159`), Agents row (`:179`). Layout counts (`:209-211`) are not
  changed.
- `AGENTS.md` — supporting-commands and supporting-agents lists (`:48-55`). The
  lifecycle table is not changed.
- `docs/workflow.md` — `/doctor` routing bullet (`:274-276`).
- `.opencode/agent/doctor.md` — `description` (`:2`), `<finding_format>`
  (`:137-155`), `<completeness_rule>` (`:157-164`).
- `.opencode/command/doctor.md` — `description` (`:2`), surface-existence guard
  in the check list (`:13-26`).
- `opencode.json`, `docs/customization.md`, all `SKILL.md` files, and the
  `doctor` permission block — **not changed** (verified by recon and by T5).

## Risks and mitigations

- **Labeling breaks the diagnostic's own matching (AC1 vs AC11).** Likelihood:
  low. Impact: medium (self-inflicted drift). Mitigation: never alter the name
  cells; put scope text only in descriptions/non-name cells; T5 runs `/doctor`
  and requires the clean result.
- **Adopter keeps the doctor files via a manual copy and sees false findings.**
  Likelihood: medium. Impact: medium. Mitigation: the quickstart note and the
  `/doctor` routing/docs labels state the maintainer-only scope and warn that it
  misreports outside the framework repo (AC3).
- **Completeness rewrite regresses the clean run (AC5/AC6 vs AC7/AC11).**
  Likelihood: low. Impact: medium. Mitigation: the rewrite keeps the existing
  README+AGENTS coverage and only replaces the inline enumeration with a derived
  classification; T5 re-runs the diagnostic; the rule forbids per-item cascades.
- **`SURFACE-MISSING` exists in the agent but not the command (or vice versa).**
  Likelihood: low. Impact: low. Mitigation: T4 edits both in one task and its
  verify greps both files for the code.
- **Overlap with `0009-surface-consistency`.** Likelihood: medium. Impact: low.
  Mitigation: `0004` lands first (the roadmap makes `0009` depend on it); keep
  edits localized and minimal so `0009` rebases onto a settled surface. No
  `item-ref` usage-string or project-profile edits here.

## Test strategy

Prompt/docs work; verification is static inspection, a real diagnostic run, and
manual checks. The committed test/CI harness is `0006`'s scope.

| AC | Level | Mechanism |
| -- | ----- | --------- |
| AC1 | static | Inspect the README rows, `AGENTS.md` lists, `docs/workflow.md` bullet, and both `description:` fields for the maintainer-only marker. |
| AC2 | static + manual | Run the quickstart block verbatim into a scratch dir; assert no `doctor` agent/command in the result. |
| AC3 | static | Read the quickstart note and the labels; confirm maintainer-only, adoption-absence, and misreport warnings. |
| AC4 | static | Grep `.opencode/agent/doctor.md` for `file:line` citations and concrete counts in examples; expect none. |
| AC5 | static | Inspect `<completeness_rule>`; confirm it contains no inline agent enumeration and derives classification from `docs/workflow.md`. |
| AC6 | static + manual | Inspect the rule and command guard; optionally move `README.md` aside in a scratch copy and confirm one `SURFACE-MISSING` finding, no cascade. |
| AC7 | manual (prompt) | `opencode run --agent doctor "Run the framework consistency diagnostic."` on the framework repo → clean line + counts 14/12/10. |
| AC8 | static | Inspect `opencode.json` `instructions`; confirm `README.md` is absent and the diagnostic still reads it on demand. |
| AC9 | static + manual | Confirm no `permission:` block changed; `git status` identical before/after a `/doctor` run. |
| AC10 | static | `git diff` on the touched files shows only labeling/examples/completeness; no phase or command-argument change. |
| AC11 | manual (prompt) | The same clean `/doctor` run as AC7, plus review that inventories/counts/permission table/ignore rules still agree. |
