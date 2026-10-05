---
feature: 0001-framework-consistency-hardening
phase: design
status: final
created: 2026-10-02
updated: 2026-10-02
notes: "Diagnostic implemented as a read-only doctor agent + /doctor command, following the existing /status pattern, per the spec's prompt-only assumption."
---

# Design — Framework consistency and permission hardening

## Summary

Correct the four classes of drift the spec names — stale inventories/counts,
undocumented permission semantics, missing ignore rules, and `/tmp` temp-file
guidance — and add a single read-only diagnostic (`/doctor`, backed by a new
`doctor` agent) that compares the documented inventory, counts, permission
blocks, and ignore rules against what is actually on disk. The diagnostic
mirrors the existing `/status` command+agent pattern: a primary agent with
`edit: deny` and a read-only bash allowlist, invoked by a thin command.

## Approach

Four coordinated changes, all confined to documentation, config, and two new
prompt files. No runtime code and no dependency is added.

### 1. Ignore non-source tooling output (AC7)

Add two entries to the root `.gitignore`:

```
# Tooling output (created on demand; never commit)
.playwright-mcp/
scratch/
```

Both are directory patterns, so they neither require the directory to exist nor
create a tracked-directory side effect. No `.gitkeep` is added for `scratch/`;
the convention is "create it when you need it," and a tracked `.gitkeep` would
contradict the requirement that the rules not depend on directory existence.

### 2. In-repo temp-file convention (AC8)

`scratch/` becomes the single documented location for temporary files and
background process logs. The one violating instruction,
`.opencode/skill/browser-verification/SKILL.md:46`
(`npm run dev > /tmp/dev-server.log 2>&1 &`), is rewritten to
`scratch/dev-server.log`, with a one-line note that `scratch/` is gitignored and
created on demand. A matching working-agreement bullet is added to `AGENTS.md`,
and `scratch/` is added to the README layout block. This is the only `/tmp`
occurrence in the repo (excluding `node_modules/` and `work/`).

### 3. Document the permission model truthfully (AC5, AC6)

Two doc surfaces carry permission facts:

- `docs/customization.md` "Permissions" — the authoritative explanation. Extend
  it to state plainly that opencode's `edit` permission covers **create, write,
  and patch** (no separate `write` grant exists); that tool paths can be
  relative (`work/<slug>/spec.md`) or absolute (`/repo/work/<slug>/spec.md`);
  that artifact-writing agents therefore declare **both** `work/**` and
  `**/work/**`; that permission objects are last-match-wins; and that read-only
  agents use `edit: deny`. Point at `opencode debug agent <name>` for the
  resolved check.
- `README.md` Agents table (README.md:145-159) — the enforcement summary. The
  "Can edit" column currently says `work/**` only, which is what is stale. Each
  artifact-writing row becomes `` `work/**` + `**/work/**` `` and a short
  paragraph under the table repeats the `edit`-covers-create/write/patch fact and
  links to `docs/customization.md`. `builder` (`edit: allow`) and the read-only
  agents (`none`) are unchanged in meaning.

### 4. New read-only diagnostic: `/doctor` (AC1, AC2, AC4, AC5, AC7, AC9–AC11)

A new primary agent `.opencode/agent/doctor.md` plus a thin command
`.opencode/command/doctor.md`, modelled directly on the existing
`status` agent + `/status` command pair (`opencode/agent/status.md`,
`opencode/command/status.md`). The diagnostic runs nine deterministic checks,
each producing a finding that names both the source of truth and the stale
location. It never edits and never runs a write command.

The check catalogue (the agent's process):

| Code | Source of truth | Compared against |
| --- | --- | --- |
| `AGENT-UNDOCUMENTED` | `.opencode/agent/*.md` | README Agents table rows **and** AGENTS.md (phase/supporting lists) |
| `AGENT-PHANTOM` | README Agents table + AGENTS.md names | `.opencode/agent/*.md` |
| `COMMAND-UNDOCUMENTED` | `.opencode/command/*.md` | README Commands table **and** AGENTS.md |
| `COMMAND-PHANTOM` | README Commands table + AGENTS.md names | `.opencode/command/*.md` |
| `SKILL-UNDOCUMENTED` | `.opencode/skill/*/` | README Skills table |
| `SKILL-PHANTOM` | README Skills table names | `.opencode/skill/*/` |
| `COUNT-MISMATCH` | file/dir counts in `.opencode/{agent,command,skill}/` | integer in README layout block (`# N role prompts`, `# N slash commands`, `# N knowledge skills`) |
| `PERMISSION-WORK-PATTERN` | each agent's `permission.edit` object that contains any `work` pattern | must contain both `"work/**"` and `"**/work/**"` |
| `PERMISSION-TABLE-MISMATCH` | each agent's resolved `permission` block | the matching README Agents-table row |
| `IGNORE-MISSING` | required policy (`.playwright-mcp/`, `scratch/`) | root `.gitignore` |
| `TEMP-PATH-OUTSIDE-WORKSPACE` | temp-file policy | any `/tmp` path in `README.md`, `AGENTS.md`, `docs/`, `.opencode/agent/`, `.opencode/command/`, `.opencode/skill/` |
| `SKILL-NAME-MISMATCH` | skill directory name | frontmatter `name:` in its `SKILL.md` |

Completeness rule (per the AC2 clarification): every on-disk agent and command
must appear in **README and AGENTS.md**; every on-disk skill must appear in the
**README Skills table**. `docs/workflow.md` phase lists are checked only for the
lifecycle agents they already name; non-lifecycle agents (`ask`, `doctor`,
`scout`, `scribe`, `status`, `bootstrap`) are not required to appear there. The
`ask` agent has no command, which is intentional and not a finding.

Finding format (names source of truth and stale location):

```
[CODE] <source-of-truth> <-> <stale location>: <detail>
```

Examples:

```
[AGENT-UNDOCUMENTED] .opencode/agent/ask.md <-> README.md Agents table: not listed.
[COUNT-MISMATCH] .opencode/agent/ (12 files) <-> README.md:182 ("11 role prompts").
[PERMISSION-WORK-PATTERN] .opencode/agent/product.md <-> its permission.edit: missing "**/work/**".
[PERMISSION-TABLE-MISMATCH] .opencode/agent/product.md <-> README.md Agents table "product" row: says "work/** only"; actual grants both.
[IGNORE-MISSING] policy (.playwright-mcp/, scratch/) <-> .gitignore: missing "scratch/".
[TEMP-PATH-OUTSIDE-WORKSPACE] temp-file policy <-> .opencode/skill/browser-verification/SKILL.md:46: writes to /tmp.
[SKILL-NAME-MISMATCH] .opencode/skill/<dir>/ <-> frontmatter name "<name>".
```

Clean result (AC10): the exact line `No findings — repository is consistent.`
followed by the checked counts. The agent resolves the repo root once with
`git rev-parse --show-toplevel` so it works from any working directory (edge
case: wrong working directory) and normalises whitespace/table alignment before
comparing so formatting noise cannot produce false positives. It reports a
snapshot; concurrent edits are out of scope.

The diagnostic's own files are part of the inventory: once `doctor.md` and
`/doctor` exist they must be listed in README and AGENTS.md and counted, which
tasks T6–T8 do.

### Documentation inventory corrections (AC2, AC3, AC4)

- `README.md`: add `ask` (primary, no edits, no bash) and `doctor` (primary, no
  edits, read-only allowlist) rows; add `/doctor` to the Commands table; update
  the layout counts from `11 role prompts` / `10 slash commands` to
  `13 role prompts` / `11 slash commands`; add `scratch/` to the layout block.
- `AGENTS.md`: add `ask` and `doctor` to the supporting-agents list and
  `/doctor` to the supporting-commands list.
- `docs/workflow.md`: add a `/doctor` routing-heuristic bullet. No lifecycle
  phase table, input, output, exit criterion, or command behavior changes
  (AC12). `ask` and other non-lifecycle agents stay out of the phase lists by
  design.

## Alternatives considered

- **Standalone script (`scripts/framework-doctor.sh` or a Node/Python script).**
  Pros: deterministic, unit-testable, could run in CI. Cons: the spec's
  Assumption fixes the diagnostic to opencode's prompt-only model, and the
  Dependencies section forbids an installed runtime dependency. A script also
  breaks the "copy the framework files into any repo" adoption story. Rejected
  on the spec's stated constraint.
- **Reuse the existing `status` agent for `/doctor`.** Pros: one fewer agent to
  document and count; `status` is already read-only with the right allowlist.
  Cons: `status`'s mission is deriving per-work-item lifecycle phase from
  `work/`; folding a framework-configuration audit into it conflates two
  unrelated jobs, widens its mandate, and would make both prompts drift.
  Rejected for cohesion; the additive `doctor` agent costs one documented row.
- **Documentation-only fix with no diagnostic.** Pros: smallest change; fixes
  today's drift. Cons: fails the goal and AC9–AC11 — nothing prevents the drift
  from recurring, which is the core of the spec. Rejected.
- **Keep `/tmp`, gitignore nothing.** Pros: zero doc churn. Cons: keeps the
  external-directory approval friction and the accidental-commit risk the spec
  exists to remove. Rejected.
- **Name the temp directory `tmp/` instead of `scratch/`.** Rejected: the
  spec's Assumptions fix `scratch/` as the desired name.

Chosen approach is option "new read-only `doctor` agent + `/doctor` command."

## Interfaces and data model

No data model and no schema migrations; this is a prompt/config product.

**New `.opencode/agent/doctor.md` frontmatter** (the exact permission contract):

```yaml
description: Framework consistency agent. Read-only diagnostic that compares documented agents, commands, skills, counts, permission blocks, and ignore rules against the repository. Runs /doctor.
mode: primary
temperature: 0
permission:
  edit: deny
  bash:
    "*": deny
    "git rev-parse*": allow
    "git status*": allow
    "git diff*": allow
    "git check-ignore*": allow
    "ls*": allow
    "cat*": allow
    "rg*": allow
    "find*": allow
    "tree*": allow
  question: allow
```

`edit: deny` and the absence of any write-capable bash pattern are the AC11
enforcement. `temperature: 0` reduces run-to-run variance in the LLM findings.
`git rev-parse` resolves the repo root; `git check-ignore` validates the ignore
rules without creating files.

**New `.opencode/command/doctor.md` frontmatter**:

```yaml
description: "Read-only diagnostic for framework drift — inventory, counts, permissions, and ignore rules. Usage: /doctor"
agent: doctor
```

Body: a short read-only statement plus a checklist mirroring the check
catalogue, ending with the handoff block (same shape as
`.opencode/command/status.md`).

**README inventory contract the diagnostic parses** (must stay greppable):

- Rows in the Agents table (README.md:145+) and Commands table (README.md:132+).
- The three layout counts (README.md:182-184): `# 13 role prompts`,
  `# 11 slash commands`, `# 10 knowledge skills`.
- The Skills table (README.md:163+).

**`.gitignore` lines added** (root):

```
.playwright-mcp/
scratch/
```

**Backward compatibility / migration.** All changes are additive or corrective:
adopters copy the framework files wholesale, so corrected docs and the two
ignore lines need no migration. Existing `work/` directories are untouched
(`work/*` is already ignored). Adding `doctor` does not change any lifecycle
phase's inputs, outputs, exit criteria, or command behavior, satisfying AC12.
`/doctor` is a new supporting command, not a lifecycle phase.

## Affected areas

- `.opencode/agent/doctor.md` — **new** read-only diagnostic agent.
- `.opencode/command/doctor.md` — **new** `/doctor` command.
- `.gitignore` — add `.playwright-mcp/` and `scratch/`.
- `.opencode/skill/browser-verification/SKILL.md:46` — `/tmp` → `scratch/`.
- `AGENTS.md` — working-agreement temp-file bullet; supporting-agents and
  supporting-commands lists.
- `README.md` — Agents table (`ask`, `doctor`, both path forms), Commands table
  (`/doctor`), layout counts and `scratch/`, permission note.
- `docs/customization.md` — Permissions section (create/write/patch, both path
  forms, read-only agents).
- `docs/workflow.md` — `/doctor` routing-heuristic bullet only.
- Unchanged: all 12 existing agent permission blocks (the seven already carry
  both `work/**` and `**/work/**`; the fix landed during `/spec`), all skill
  bodies except browser-verification, `opencode.json`, lifecycle phase tables.

## Risks and mitigations

- **LLM diagnostic is non-deterministic or misses a check** — likelihood:
  medium / impact: medium.
  Mitigation: `temperature: 0`; an enumerated nine-check catalogue with exact
  finding codes; a fixed clean-result string; grep/`ls`-based steps so the
  comparisons are mechanical; the tester seeds drift and confirms the expected
  codes (task T10). Residual risk is documented in `verify.md`.
- **The diagnostic must inventory itself, so it flags its own absence during
  implementation** — likelihood: high / impact: low.
  Mitigation: accept the transient findings while T4–T5 land; tasks T6–T8 add
  `doctor` to the docs and counts; T9 confirms the clean result. No bootstrap
  paradox, because there is no build step gating the check.
- **README permission table is only semantically matchable** — likelihood:
  medium / impact: medium.
  Mitigation: fix the column to one canonical form
  (`` `work/**` + `**/work/**` ``) and have the diagnostic compare agent name →
  expected edit capability, not free text. `builder` and read-only rows keep
  single canonical strings (`any source`, `none`).
- **Formatting/whitespace or table alignment creates false positives** —
  likelihood: medium / impact: low.
  Mitigation: compare normalised names and integers, never raw table text; the
  spec calls this out as an edge case.
- **A future agent/command/skill add silently reintroduces drift** —
  likelihood: medium / impact: high.
  Mitigation: that is exactly what `/doctor` catches; README and AGENTS.md are
  the checked inventory surfaces.
- **`/tmp` returns via a new prompt** — likelihood: low / impact: medium.
  Mitigation: the `TEMP-PATH-OUTSIDE-WORKSPACE` check scans all framework docs,
  agents, commands, and skills for `/tmp`.
- **Playwright MCP writes somewhere other than `.playwright-mcp/`** —
  likelihood: low / impact: low.
  Mitigation: the spec assumes `.playwright-mcp/` is the correct path; note the
  assumption in the design and revisit if output appears elsewhere.

## Test strategy

There is no test harness in this repo (no root `package.json`/`pyproject.toml`);
framework "tests" are read-only shell assertions plus manual agent invocation.
Task Verify steps encode the automatable checks; the `/test` phase records the
manual ones as such.

| AC | Verification | Level |
| --- | --- | --- |
| AC1 | `rg` asserts all seven artifact-writing agents declare both `work/**` and `**/work/**`; `/doctor` reports `PERMISSION-WORK-PATTERN` when one is removed in a probe; manual create+update of a file under `work/<slug>/` by `product`/`scribe` succeeds. | shell + manual |
| AC2 | Shell loop asserts every `.opencode/agent/*.md` and `.opencode/command/*.md` name appears in `README.md` and `AGENTS.md`, and every skill name in the README Skills table; `/doctor` clean. | shell + manual |
| AC3 | `rg` finds `ask` with its read-only profile in `README.md` and `AGENTS.md`. | shell |
| AC4 | Parse README layout counts (13/11/10) and compare to `ls` counts. | shell |
| AC5 | `rg` finds both path forms in every README artifact-writer row; `/doctor` clean on `PERMISSION-TABLE-MISMATCH`. | shell + manual |
| AC6 | `rg` finds create/write/patch, `work/**`, and `**/work/**` in `docs/customization.md` and the README permission note. | shell |
| AC7 | `git check-ignore -v .playwright-mcp/x scratch/y` prints both rules; `git status --porcelain` stays clean after creating both dirs and files. | shell |
| AC8 | `rg -n "/tmp"` over docs/agents/commands/skills is empty; `rg` finds `scratch/` guidance in the skill, `AGENTS.md`, and README. | shell |
| AC9 | Manual: seed an unlisted probe agent and temporarily move `ask.md` aside; `/doctor` reports `AGENT-UNDOCUMENTED`, `COUNT-MISMATCH`, and `AGENT-PHANTOM` with sources and locations; restore. | manual |
| AC10 | Manual: `/doctor` on the consistent repo prints `No findings — repository is consistent.` | manual |
| AC11 | `edit: deny` plus no write-capable bash allowlist in `doctor.md`; `git status` unchanged by a `/doctor` run. | shell + manual |
| AC12 | `git diff` review of `docs/workflow.md`/`AGENTS.md` shows only the added `/doctor` heuristic and inventory rows; no phase input/output/exit changes. | manual |

Acceptance criteria AC9–AC11 are verified manually because the diagnostic is an
LLM-driven agent and cannot be exercised by a CI test runner in this
prompt-only repo; this residual risk is recorded in `verify.md`.
