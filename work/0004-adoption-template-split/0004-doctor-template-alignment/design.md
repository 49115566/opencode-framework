---
feature: 0004-adoption-template-split/0004-doctor-template-alignment
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Extends the existing /doctor catalogue in place; no new check step and no new finding code. Resolves the spec's three design-deferred open questions: (1) README Agents-table marker is a note below the table, per the shipped 0004-doctor-scope review recommendation, leaving the compared Can-edit/Can-run-bash cells byte-identical; (2) the template's supporting lists are validated for full name coverage in both directions, mirroring root AGENTS.md; (3) template/opencode.json and template/.gitignore need no coverage beyond the directory-level temp-path scan, and are explicitly declared non-compared. No committed tests change (child 0003 owns guards); README.md is the only non-doctor file touched."
---

# Design — Doctor alignment with the adoption template split

## Summary

Extend the existing `/doctor` diagnostic in place — same nine checks, same
finding codes — by declaring `template/AGENTS.md` a documentation surface
alongside root `AGENTS.md` and `README.md`, adding the `template/` directory to
the temp-path scan, and adding `template/AGENTS.md` to the required-surface
completeness rule. Then close the `0004-doctor-scope` residual by adding a
maintainer-only note below the README Agents table, without touching any cell
the diagnostic compares. The only files changed are `.opencode/agent/doctor.md`,
`.opencode/command/doctor.md`, and `README.md`.

## Approach

The split (child `0001`) introduced `template/AGENTS.md` as the adopter-facing
copy of the framework contract, and child `0002` pointed the quickstart at it.
`/doctor` still reads one `AGENTS.md` and enumerates only root-level and
`.opencode/` surfaces (`.opencode/agent/doctor.md:50-62`). Extending the
existing catalogue — rather than adding a check — keeps the audience, the
read-only guarantee, and the output contract unchanged (spec AC10) and matches
the structure of the completeness work shipped by `0004-doctor-scope`.

### 1. Declared inputs (AC1, AC6)

`<inputs>` currently names a single `AGENTS.md` (`.opencode/agent/doctor.md:55-56`).
Split that item into two named surfaces:

- root `AGENTS.md` — the framework's live, bootstrapped contract;
- `template/AGENTS.md` — the adopter-facing copy; its lifecycle table and
  supporting lists are checked identically.

Add one scope clause so expected pristine state is never a finding (AC6, spec
edge cases "Expected placeholder profile" and "Byte-identical pristine files"):

> `template/AGENTS.md` is the adopter's pristine copy: its unfilled Project
> profile is expected and is not a finding. `template/opencode.json` and
> `template/.gitignore` are not compared to the root copies; byte-identical
> content is valid.

Root `AGENTS.md` and `README.md` remain named as before. This is what makes the
diagnostic's declared surface list, not just its execution, include the template
(AC1).

### 2. Inventory coverage (AC4)

Checks 1 and 2 (`.opencode/agent/doctor.md:70-79`) currently require each
on-disk agent/command to appear as a row in the matching README table **and** by
name in `AGENTS.md`. The name requirement becomes: by name in the lifecycle
table or supporting lists of **both** root `AGENTS.md` and `template/AGENTS.md`,
with the phantom direction (`AGENT-PHANTOM` / `COMMAND-PHANTOM`) applying to a
name present in any of those surfaces with no on-disk file. Anchoring the name
surface to "lifecycle table or supporting lists" bounds the scan and makes the
reverse edge case ("a template name with no on-disk item") checkable.

`template/AGENTS.md` currently names all 14 agents and all 12 commands
(`template/AGENTS.md:35-55`), so the framework run stays clean. A drift in
either direction — an on-disk item missing from the template list, or a
template name with no file — is reported naming the surface and the item
(AC4).

### 3. Out-of-workspace temp-path scan (AC2)

`<inputs>` item 6 and check 8 (`.opencode/agent/doctor.md:60-61,112-120`) list
`docs/`, `.opencode/agent/`, `.opencode/command/`, and `.opencode/skill/`. Add
`template/` to both the declared scan locations and the check, so an absolute
system-temp path in a document under `template/` — the path that would ship to
adopters — is reported with its file and line. The scan stays directory-level;
only documentation surfaces can carry an instruction, and
`template/opencode.json`/`template/.gitignore` are inert (resolved open
question 3).

### 4. Required-surface completeness (AC3, AC6)

`<completeness_rule>` (`.opencode/agent/doctor.md:156-179`) lists two required
surfaces. Add `template/AGENTS.md` as a third, and state the per-surface
semantics already used:

- absent or unreadable emits exactly one
  `[SURFACE-MISSING] template/AGENTS.md: absent or unreadable; dependent
  template-list checks skipped.`;
- only the comparisons that depend on `template/AGENTS.md` are skipped — the
  README-table, root-`AGENTS.md`, counts, permissions, ignore-rule, skill, and
  temp-path checks still run, so the surface never suppresses unrelated
  findings and never cascades per inventory item;
- the template's unfilled Project profile is expected, so the inventory/
  count/permission/ignore/temp checks are the only ones applied to it (AC6).

### 5. Counts and the `## Layout` block (AC5)

Check 4 is unchanged. Its count matcher keys on the exact unit phrases `role
prompts`, `slash commands`, and `knowledge skills`; the `template/` lines in the
README `## Layout` block (`README.md:274-277`) carry none of those phrases, so
they cannot be read as an inventory count and no `COUNT-MISMATCH` can be caused
by the new layout entry. No new count assertion is introduced and the reported
counts remain the on-disk 14 agents / 12 commands / 10 skills.

### 6. README maintainer-only labeling (AC7, AC8)

The Commands table row already carries `— framework-maintainer only`
(`README.md:204`); root `AGENTS.md:46-53`, `docs/workflow.md:302`, and both
descriptions (`.opencode/agent/doctor.md:2`,
`.opencode/command/doctor.md:2`) already carry the marker. The only unlabeled
surface is the Agents table (`README.md:207-224`), whose `doctor` row has no
marker. Add a short note immediately below the table (before the existing `> †`
permission-caveat blockquote):

```
The `doctor` agent and `/doctor` command are **framework-maintainer only**; the
adoption quickstart removes both from the copied set.
```

A note below the table is the shipped `0004-doctor-scope` review's recommended
placement (`work/0003-framework-quality-hardening/0004-doctor-scope/review.md:88-92`)
because it labels the surface while leaving the `Can edit` and `Can run bash`
cells byte-identical, so the diagnostic's `PERMISSION-TABLE-MISMATCH` check and
the suite's `30-permissions.sh` parser are unaffected.

### 7. Command synchronization (AC10)

Mirror items 1-4 in `.opencode/command/doctor.md`: name `template/AGENTS.md` in
the required-surface guard (`.opencode/command/doctor.md:13-18`), note that agent
and command inventory is cross-checked against both `AGENTS.md` files, and note
that the temp-path scan covers `template/`. Keep the phrase "the nine checks"
and the full list of existing codes unchanged; the maintainer-only audience,
the output contract, and the read-only rules are untouched.

## Alternatives considered

- **Extended in place (chosen) vs. a new dedicated "template agreement" check
  and code.** A new numbered check would require a tenth code and a rewritten
  output/count story, and would restate the same presence/absence rule the
  completeness rule already owns. Rejected — AC10 requires the existing
  catalogue be preserved with the new coverage added rather than replaced, and
  `SURFACE-MISSING` plus the inventory codes already express the outcome.
- **Read the split contract from `docs/customization.md:21-40` as the authority
  for which surfaces to audit (alternative) vs. hard-code `template/AGENTS.md` as
  a declared surface (chosen).** Deriving the detector's input list from a
  mutable document means a stale contract silently changes what is audited —
  the opposite of a drift detector's job, and it could mask the very drift the
  item exists to catch. AC1 names `template/AGENTS.md` explicitly. Rejected.
- **README marker in the `doctor` row itself — a new column, or appended to the
  `Mode` cell (alternative) vs. a note below the table (chosen).** The row is a
  machine-read surface: `30-permissions.sh:102-119` parses its `Mode`, `Can
  edit`, and `Can run bash` cells, and the diagnostic's own permission check
  compares the capability cells. A note below the table labels the surface
  without entering any parsed cell, which is exactly what the shipped review
  recommended. Rejected.
- **Make `/doctor` adopter-aware — detect a non-framework repository and report
  "not applicable" (alternative) vs. treat `template/AGENTS.md` as one more
  required surface (chosen).** Adopter-awareness re-opens the shipped
  maintainer-only audience decision and its exclusion mechanism, both explicit
  spec non-goals. Rejected — the template is simply another surface, and its
  absence in an adopter context yields the existing single `SURFACE-MISSING`
  behavior rather than a new cascade.

## Interfaces and data model

No runtime interface, schema, or migration: the product is prompt and
documentation files. The contracts are:

- **Documentation surfaces.** Required: `README.md` (tables and Layout count
  comments), root `AGENTS.md` (lifecycle table + supporting lists),
  `template/AGENTS.md` (lifecycle table + supporting lists, new). Scanned for
  temp paths: `README.md`, root `AGENTS.md`, `template/` (new), `docs/`,
  `.opencode/agent/`, `.opencode/command/`, `.opencode/skill/`.
- **Finding codes.** Unchanged; no code is added. Reused:
  `SURFACE-MISSING` (at most one per missing/unreadable required surface),
  `AGENT-UNDOCUMENTED`/`AGENT-PHANTOM`,
  `COMMAND-UNDOCUMENTED`/`COMMAND-PHANTOM`,
  `TEMP-PATH-OUTSIDE-WORKSPACE`. Line shape unchanged:
  `[SURFACE-MISSING] <surface>: absent or unreadable; dependent inventory checks
  skipped.`
- **Coverage rule.** Every on-disk agent and command must appear as a row in the
  matching README table and by name in root `AGENTS.md` **and**
  `template/AGENTS.md`; every on-disk skill must appear in the README Skills
  table. Phantom names are reported in either direction.
- **Labeling contract.** The `doctor` / `/doctor` name tokens stay exact;
  maintainer-only text is added only outside compared cells. The audience stays
  framework-maintainer-only.
- **Backward compatibility.** The `doctor` permission block (`edit: deny`,
  read-only bash allowlist) is unchanged; no config or `opencode.json`
  instruction set changes; no file is added to the always-loaded set. In a
  repository without `template/`, the missing surface yields one
  `SURFACE-MISSING` finding and skips only template-dependent comparisons.

## Affected areas

Modified:

- `.opencode/agent/doctor.md` — `<inputs>` (`:50-62`), checks 1-2 (`:70-79`),
  check 8 (`:112-120`), the `SURFACE-MISSING` example (`:152`), and
  `<completeness_rule>` (`:156-179`).
- `.opencode/command/doctor.md` — required-surface guard (`:13-18`) and the
  check-list bullets (`:19-32`).
- `README.md` — a maintainer-only note below the Agents table (`:224-225`).

Unchanged and deliberately so: root `AGENTS.md` and `template/AGENTS.md` (both
already carry the marker and full lists), `docs/workflow.md` (already marked,
`:302`), `opencode.json` and `template/opencode.json`, root and template
`.gitignore`, `docs/customization.md`, and every file under `tests/**` (guards
belong to child `0003`).

## Risks and mitigations

- **Self-inflicted drift: extending a detector's inputs makes it report the
  repository it audits.** Likelihood: low. Impact: medium. Mitigation: the
  template lists currently cover the full inventory
  (`template/AGENTS.md:35-55`); T6 requires a clean `/doctor` run
  (`No findings — repository is consistent.`, counts 14/12/10).
- **The expected placeholder profile is reported as drift.** Likelihood: medium.
  Impact: low. Mitigation: the explicit scope clause (item 1) and completeness
  clause (item 4); T1/T3 greps assert the clause is present, T6 asserts a clean
  run.
- **A missing/renamed template produces a per-item cascade.** Likelihood: low.
  Impact: medium. Mitigation: template is an independent required surface with
  per-surface skip semantics; T3's scratch-clone check asserts exactly one
  finding and no cascade.
- **The README note is parsed as a table row.** Likelihood: low. Impact: medium
  (suite failure). Mitigation: the note is a plain paragraph with no leading
  `|`, placed outside the table; T5 runs `bash tests/run.sh` to exit 0.
- **Agent and command prompts disagree about the audited surfaces (AC10).**
  Likelihood: medium. Impact: low. Mitigation: T4 updates the command in
  lockstep from the finalized agent text and greps both files for the same
  surface and code set.
- **Overlap with `0005-surface-consistency-sweep`.** Likelihood: low. Impact:
  low. Mitigation: this item touches no command signature/usage string and no
  `ask.md`; 0005 is sequenced last and rebases onto a settled `README.md`.

## Test strategy

Prompt/doc work: verification is static inspection plus real diagnostic runs and
a scratch-clone injection for the missing-surface path. The committed suite
(`bash tests/run.sh`) is the regression guard and must stay green (AC11); no
test file changes.

| AC | Level | Mechanism |
| -- | ----- | --------- |
| AC1 | static | Grep `.opencode/agent/doctor.md` `<inputs>` for `template/AGENTS.md` alongside `AGENTS.md` and `README.md`; T6 clean run. |
| AC2 | static + manual | Grep `<inputs>` item 6 and check 8 for `template/`; in a scratch clone add an absolute `/tmp/...` path to `template/AGENTS.md`, run `/doctor`, confirm `TEMP-PATH-OUTSIDE-WORKSPACE` names the file and line, then discard. |
| AC3 | static + manual | Inspect `<completeness_rule>`; in a scratch clone rename `template/AGENTS.md`, run `/doctor`, confirm exactly one `SURFACE-MISSING` and no per-item cascade. |
| AC4 | static + manual | Inspect checks 1-2; in a scratch clone remove an agent name from `template/AGENTS.md`, run `/doctor`, confirm the finding names the surface and item. |
| AC5 | integration | T6 `/doctor` run reports counts 14/12/10 with no `COUNT-MISMATCH`; `bash tests/run.sh` (40-inventory) exits 0. |
| AC6 | static + integration | Inspect the expected-placeholder/pristine-config clauses; T6 clean `/doctor` run. |
| AC7 | static + integration | Inspect the README Agents table row (cells byte-identical) and the note naming `doctor` as framework-maintainer only; `bash tests/run.sh` (30-permissions, 40-inventory) exits 0. |
| AC8 | static | Grep every named surface (README Commands and Agents, `AGENTS.md`, `docs/workflow.md`, both descriptions) for the marker; confirm none omits it. |
| AC9 | integration + manual | `git status --porcelain` before/after a `/doctor` run is empty; `git diff` shows no permission block. |
| AC10 | static | Compare the agent and command surface descriptions; both name the same surfaces and the same code set; "nine checks" preserved. |
| AC11 | integration | `bash tests/run.sh` exits 0. |
