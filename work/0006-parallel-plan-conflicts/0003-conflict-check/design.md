---
feature: 0006-parallel-plan-conflicts/0003-conflict-check
phase: design
status: final
created: 2026-10-08
updated: 2026-10-08
parent: 0006-parallel-plan-conflicts
notes: "User resolved the two spec open questions on 2026-10-08: (1) the check reuses the shipped finding codes rather than adding one — a declared conflict renders as TEXTUAL-CONFLICT with class (a)/(b) by target kind, an unresolved declaration as DANGLING-DEP (b), and the parent/item discrepancy as DRIFT-FACT (d); (2) a child's own declaration and its parent Children cell disagree when both are present (neither `—`) and the two sets are not identical (a subset relationship still counts). OQ2 is resolved in the design: the check is expressible at the /build gate read-only and advisory, so /conflicts, /status, and the gate are all surfaces."
conflicts-with: "0004-conflict-guards, tests/checks"
---

# Design — Pre-development parallel-plan conflict check

## Summary

Add one authoritative `## Declared-conflict check` section to
`docs/workflow.md` that defines a read-only, offline comparison of the
`conflicts-with` declarations of every **unshipped** plan under `work/`. A new
read-only `/conflicts [item-ref]` command (routed to the existing `status` agent)
performs it, `/status` reports the same findings in its existing integrity
window, and the `builder` surfaces the findings involving an item at the
`/build` plan gate — always advisory, never gating. The check reuses the shipped
`(a)`–`(d)` class labels, finding-line grammar, and finding codes unchanged; it
adds no agent, artifact, `phase` value, taxonomy, or committed script.

## Approach

### 1. One authoritative statement

`docs/workflow.md` gains a top-level `## Declared-conflict check` section between
`## Plan publication` (ends at `:428`) and `## Derived state` (`:430`). It is the
single normative statement of the algorithm, the compared set, the pair
predicate, the finding rendering, and the advisory/offline/read-only contract;
every other surface references it by name ("`docs/workflow.md` → `## Declared-conflict
check`") and does not restate the algorithm. This mirrors how
`### Merge-integrity guard` is the single statement of the integrity invariant
set and `/status` is its read-only window.

The existing `### Declared conflicts (conflicts-with)` subsection (`:110-177`)
remains the single authority for the grammar and the resolution algorithm; the
new section consumes it and restates nothing.

### 2. The compared set (AC1, AC3, AC14)

The check reads only committed `work/` state. It builds the set of **unshipped
plans with a non-empty declaration**:

- **Roadmap parent** — never an entity itself. Its `Children` table supplies
  each row's declaration. Parse each row's `Local id` and `conflicts-with` cell;
  a missing column (roadmap authored before the column) is `—` for every row.
- **Roadmap child** — one entity per `Children` row, even when the child
  directory holds only `.gitkeep` (the parent cell still represents it). A child
  whose `work/<parent>/<local-id>/ship.md` exists is **excluded** (AC3); a child
  with no `ship.md` is included.
  - `own` = the child's `design.md` frontmatter `conflicts-with` (absent/`—` →
    empty).
  - `cell` = the row's `conflicts-with` cell (absent column or `—` → empty).
  - `declared` = `own ∪ cell` (AC5).
  - If `own` and `cell` are **both present** (neither `—`) and their sets are
    **not identical**, report the discrepancy (AC8). A one-sided record (`—` on
    one side) is the union and is not a discrepancy.
- **Standalone item** — one entity per top-level item directory that is not a
  roadmap parent and has a `spec.md`. Its declaration is its `design.md`
  frontmatter `conflicts-with`. A `ship.md` excludes it (AC3).

An entity with an empty `declared` set yields no finding (AC14) and is not a
counterpart. A shipped item still **resolves** as a target but is not a
counterpart; naming it produces neither a conflict nor an unresolved finding
(edge case).

### 3. Resolution (reuse `0001`, no second grammar)

Each target token is resolved with the single algorithm in
`docs/workflow.md` → "Declared conflicts (`conflicts-with`)": reference-vs-path
discriminator, sibling-first precedence for a bare `MMMM-slug`, exact
repository-relative surface paths, no globs/`..`/absolute paths. A reference
token resolves to a canonical item reference (a sibling row's
`<parent>/<local-id>` or a `work/<NNNN-slug>[/<MMMM-slug>]/` directory); a
surface token resolves to its repository-relative path. A token that is
malformed (empty/whitespace-only, glob metacharacter, `..`, absolute) or that
resolves to no sibling row, no `work/<ref>/`, and no existing path is an
**unresolved declaration** and is reported, never dropped or repaired (AC7).

### 4. The pair predicate (AC4, edge cases)

For unshipped entities `A` and `B` in the compared set, `conflict(A, B)` is true
exactly when one of:

1. **Shared target** — some target of `A` and some target of `B` are the same
   target. Two targets share identity when their trimmed repository-relative
   paths are equal (surface targets) or when both resolve to the same canonical
   item reference (reference targets). Equal trimmed reference tokens that
   resolve to *different* items (for example the same sibling local id in two
   different roadmaps) are **not** the same target — a target's identity is what
   it resolves to, which is the "share a target" reading of AC4's "equal after
   trimming" and avoids a cross-roadmap false positive.
2. **One side names the other** — a target of `A` resolves to `B`'s canonical
   reference, or a target of `B` resolves to `A`'s. A one-sided declaration
   suffices; no reciprocity is required.

Each unordered pair is reported **once**: reciprocal naming, or a pair that both
shares a target and names the other, yields exactly one finding. The finding
list is never truncated (many conflicts for one item all appear); repeated runs
on unchanged plans yield identical findings; concurrent runs touch no lock and
write nothing.

### 5. Findings (AC6, AC7, AC8, AC13)

Findings use the shipped grammar
`- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` and a class
label from the shipped `(a)`–`(d)` set. No new class, code, or policy is added.

| Situation | Code | Class | Offender / detail |
| --------- | ---- | ----- | ----------------- |
| Two unshipped plans share a surface target outside `work/` | `TEXTUAL-CONFLICT` | `(a)` | the two item refs; detail names the shared path |
| Two unshipped plans share a `work/` path or name each other | `TEXTUAL-CONFLICT` | `(b)` | the two item refs; detail names the shared target |
| A declared target is malformed or resolves to nothing | `DANGLING-DEP` | `(b)` | the declaring item ref; detail names the target |
| A child's own declaration and parent cell disagree (both non-`—`, sets unequal) | `DRIFT-FACT` | `(d)` | the child ref; detail shows both sets |

These are the shipped codes; the check **broadens their planning-time meaning**
and does not fork the taxonomy. The two shipped notes that call
`TEXTUAL-CONFLICT` "pre-flight-only" are scoped to the *dry-run-detected* case:
`/status` performs no dry-run merge, but it (and `/conflicts`) may report a
*declared* `TEXTUAL-CONFLICT`. `DANGLING-DEP` and `DRIFT-FACT` gain the
planning-time instances above alongside their existing meanings. The
`## Declared-conflict check` section states this once; the `status` agent and the
`merge-conflict` skill repeat the canonical code list consistently.

The check performs no fetch, remote read, merge, or dry-run merge, takes no
lock, and modifies no file (AC12). It operates on committed plan declarations
only and does not reproduce the shipped pre-ship branch/textual detection
(AC13).

### 6. Surfaces and invocation

- **`/conflicts [item-ref]`** — a new read-only command routed to the `status`
  agent. With no argument it reports every declared conflict, unresolved
  declaration, and discrepancy across the whole `work/` tree (AC1); with an
  item-ref it reports only the findings that involve that item and names each
  counterpart (AC2). It is additive and read-only; it does not advance a phase.
- **`/status`** — the status agent's report gains the declared-conflict findings
  in its existing integrity/findings output (AC10), still read-only and
  local-only.
- **`/build` gate** — when the `plan_gate` outcome is PROCEED, the builder runs
  the focused check for the item, prints the findings, and continues; it never
  changes the gate outcome (AC9, AC11). The check at the gate performs no fetch
  (the gate's own best-effort ref refresh is separate); when the gate refuses for
  an unmerged plan, it stops for that reason.
- **Routing** — `docs/workflow.md` → "Routing heuristics" and the
  `workflow-lifecycle` skill gain a `/conflicts [item-ref]` route.

### 7. Prompt-only, like the integrity guard

There is **no committed checker, script, helper, or executable tool**: the check
is agent behavior, exactly as the merge-integrity guard is prompt-only. This
keeps the committed suite read-only over live surfaces and never reading live
`work/**` (`tests/README.md:29`). Fixture-based guards and mutation coverage for
the check are child `0004-conflict-guards`.

Adding a command changes the on-disk command set, so the README inventory
(`Commands` table and `Layout` `# N slash commands`), the `AGENTS.md` /
`template/AGENTS.md` supporting-commands lists, the `workflow-lifecycle` skill
route, and the signature-sweep registry (`tests/checks/96-signature-sweep.sh`)
must move in the same change to keep `bash tests/run.sh` green (AC15). The
inventory check `tests/checks/40-inventory.sh` is generic and needs no edit.

## Alternatives considered

- **Reuse the `status` agent for the check (chosen) vs. a new `conflicts`
  agent.** A new agent is cleaner by name but adds an agent to disk: the README
  `Agents` table, the `Layout` `# N role prompts` count, the `30-permissions`
  agreement, and the `40-inventory` count must all move, and the command needs
  its own permission block. The `status` agent already owns the read-only,
  local-only reporting window and the shipped finding vocabulary; `/conflicts` is
  the target-focused mode of that same capability, exactly as `/status [item-ref]`
  is. **Rejected** for the reused agent.
- **A committed Bash checker that parses `work/`.** It would make the check
  reproducible and testable directly, but it contradicts the shipped guard
  contract ("there is no committed checker, script, helper, or executable tool"),
  introduces runtime code and a new surface to keep in sync, and would tempt the
  suite to read live `work/**` (forbidden). **Rejected** for prompt behavior with
  a precise algorithm.
- **A new finding code (`DECLARED-CONFLICT`, `UNRESOLVED-DECLARATION`).**
  Semantically clean, but the `0001` authority already states "There is no new
  class, finding code, or policy defined for declarations", the spec's non-goals
  forbid a new finding code, and `TEXTUAL-CONFLICT` (the `(a)`/`(b)` code) and
  `DANGLING-DEP` already name the two events. **Rejected** (user-confirmed) for
  reusing the shipped codes and broadening their planning-time meaning.
- **Literal trimmed-token equality for "share a target".** Simplest and most
  literal reading of AC4, but it reports a false conflict between the same
  `MMMM-slug` in two different roadmaps, which resolve to different items.
  **Rejected** for identity-by-resolution, which honours "share a target".
- **State the algorithm in the `status` agent and reference it from the workflow
  doc.** Keeps the prompt self-contained, but inverts the framework's authority
  layering (`docs/workflow.md` is the source of truth; prompts are operational
  views) and risks the builder and `/status` drifting. **Rejected** for the
  workflow authority.
- **Extend the `### Merge-integrity guard` subsection instead of a new section.**
  Co-locates the reporting contract with the other offline window, but the guard
  is a merge-time invariant set over the `work/` tree and inventory facts, while
  this is planning-time declaration comparison; conflating them would blur the
  distinct merge-time/planning-time contract the roadmap deliberately keeps
  separate. **Rejected** for a separate section.

## Interfaces and data model

**New command (`/conflicts`):**

```
/conflicts [item-ref]
  (no argument)  -> global read-only report of every declared conflict,
                    unresolved declaration, and declaration discrepancy
  <item-ref>     -> focus on the findings that involve that item; name each
                    counterpart
```

Frontmatter: `agent: status`; `description:` carries
`Usage: /conflicts [item-ref]` (the signature-sweep contract). No new agent.

**Authority section:** `docs/workflow.md` → `## Declared-conflict check`, stating
the compared set, the reused resolution reference, the predicate, the findings
table above, the advisory/offline/read-only contract, the enforcement points
(`/conflicts`, `/status`, `/build` gate), and the distinction from the merge-time
branch contract.

**Compared-set entity (algorithm shape):**

```
entity := { ref: <canonical item-ref>, declared: [<resolved target>, ...] }
target := { kind: surface | item-ref, identity: <repo path | canonical ref> }
```

**Pair predicate (normative):**

```
conflict(A, B) :=
     (exists t in A.declared, u in B.declared : same_target(t, u))
  or (exists t in A.declared : t.identity == B.ref)
  or (exists t in B.declared : t.identity == A.ref)

same_target(t, u) :=
     t.kind == surface  and u.kind == surface  and t.identity == u.identity
  or t.kind == item-ref and u.kind == item-ref and t.identity == u.identity
# each unordered pair reported once; one-sided naming suffices
```

**Findings (reused code/class; see the table in Approach §5):** unchanged
finding-line grammar from `.opencode/skill/merge-conflict/SKILL.md` → "Finding
grammar"; no new vocabulary.

**`/build` gate integration:** the existing `plan_gate` in
`docs/workflow.md` → "The `/build` plan gate" is unchanged; the builder adds a
read-only focused check *after* a PROCEED and before selecting a task, prints the
findings, and continues. Advisory only.

**Declaration home:** unchanged. This item adds no artifact, `phase` value,
frontmatter field, registry, or derived-state row. The new command is the only
new on-disk command; no agent, skill, or artifact is added.

**Backward compatibility and migrations:** none required. An absent declaration
or `—` means no declared conflicts (AC14); historical items and roadmaps stay
valid with no migration; the check reads committed state only. `/conflicts` is
additive; `/status` and `/build` gain advisory output but no behavior change.
The command inventory moves in the same change as the command (AC15). No runtime
dependency, service, network access, or toolchain is introduced.

## Affected areas

- `docs/workflow.md` — new `## Declared-conflict check` section; `/conflicts`
  routing-heuristics bullet. (The `### Declared conflicts` grammar and the
  `### Merge-integrity guard` invariant set are unchanged.)
- `.opencode/skill/merge-conflict/SKILL.md` — the planning-time meanings of
  `TEXTUAL-CONFLICT`, `DANGLING-DEP`, `DRIFT-FACT`; scope the pre-flight-only note.
- `.opencode/agent/status.md` — run and report the check (global, focused, and in
  `/status`); reference the authority; preserve the existing readiness/cycle/
  finding literals.
- `.opencode/command/status.md` — surface the check in the `/status` report.
- `.opencode/command/conflicts.md` — **new** command file.
- `.opencode/agent/builder.md`, `.opencode/command/build.md` — surface the
  advisory findings at the `/build` gate.
- `README.md` — `Commands` table row for `/conflicts [item-ref]`; `Layout`
  `# 12 slash commands` → `# 13 slash commands`.
- `AGENTS.md`, `template/AGENTS.md` — supporting-commands list gains
  `/conflicts [item-ref]`.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — routing block gains the
  `/conflicts [item-ref]` route.
- `tests/checks/96-signature-sweep.sh` — `canonical_signature` case,
  `ALL_COMMANDS`, and the `AGENTS`/`README`/`SKILL` required sets gain
  `/conflicts` (the live-surface signature/inventory agreement; fixture and
  mutation coverage remain `0004-conflict-guards`).

**Deliberately unchanged:** `tests/checks/40-inventory.sh` (generic),
`tests/fixtures/**`, `tests/mutation.sh`, `tests/README.md` (owned by `0004`);
`docs/artifact-conventions.md`; `opencode.json`; the derived-state table; the
`phase` vocabulary; the readiness algorithm.

## Risks and mitigations

- **Reusing `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT` for planning-time
  instances blurs the shipped merge-time meanings** — likelihood medium / impact
  high. Mitigation: state the planning-time meanings once in the authority and
  consistently in the skill and `status` agent; scope the two "pre-flight-only"
  notes to the dry-run-detected case; keep the `(a)`–`(d)` classes and grammar
  untouched (AC6, AC13).
- **Cross-roadmap same-local-id false positive** — likelihood medium / impact
  medium. Mitigation: identity-by-resolution (approaching §4), so two equal
  `MMMM-slug` tokens in different roadmaps resolve to different items and do not
  conflict.
- **Command-inventory drift keeps the suite red** — likelihood certain / impact
  medium. Mitigation: one atomic task adds the command and moves README
  (table + count), both `AGENTS.md` files, the skill route, and the
  signature-sweep registry together; `bash tests/run.sh` is the gate (AC15).
- **The check becomes blocking at the `/build` gate** — likelihood medium /
  impact high. Mitigation: the authority states the gate outcome is unchanged and
  the findings are printed, not acted on; AC9/AC11 verification reads the builder
  prompt and command (AC9).
- **`status` agent growth restates the readiness algorithm or drops a required
  literal** — likelihood low / impact high. Mitigation: reference the authority,
  add no `satisfied(dep_local_id):` marker, and preserve the
  `CYCLIC-DEP`/`informational and never fatal`/`members of a cycle are never
  reported` literals; `10-readiness`/`80-cycle-fixture` stay green.
- **A prompt-only check is not machine-enforced** — likelihood medium / impact
  medium. Mitigation: state the algorithm and predicate precisely so it is
  reproducible; fixture-based guards and mutation coverage are `0004-conflict-guards`.
- **Shared-surface collision with the sibling `0004-conflict-guards`** on
  `tests/checks` — likelihood medium / impact low. Mitigation: this plan declares
  `0004-conflict-guards, tests/checks` in its `conflicts-with`; the declaration is
  advisory and `0004` is dependency-blocked on this item.

## Test strategy

This item changes documents and prompts only; it adds no runtime code, and the
committed suite never reads live `work/**`. The reproducible behavior is verified
by content/consistency inspection and the existing suite as a regression gate;
fixture-based behavior guards are child `0004-conflict-guards`.

| Criterion | Verification |
| --------- | ------------ |
| AC1 | Read `## Declared-conflict check` + `/conflicts` command + `status` agent: no-argument mode reports every conflict and writes no file. |
| AC2 | Read the command/agent: an item-ref focuses on findings involving that item and names each counterpart. |
| AC3 | Read the authority compared-set rules: `ship.md` excludes; its absence includes; a shipped item still resolves as a target. |
| AC4 | Read the predicate §4: shared resolved target or one-sided naming; one finding per pair. |
| AC5 | Read the authority: child declared set = own `design.md` value ∪ parent `Children` cell; a row with no own declaration uses the cell. |
| AC6 | Read the findings table + skill: shipped grammar and `(a)`–`(d)` class; no new class/code/policy; `bash tests/run.sh` green. |
| AC7 | Read the authority + `/conflicts`: a malformed/unresolvable target is reported and neither dropped nor repaired. |
| AC8 | Read the authority: both present and sets unequal → `DRIFT-FACT`; one-sided `—` is not a discrepancy. |
| AC9 | Read `## Declared-conflict check` + builder/build: advisory; gate outcome and readiness unchanged. |
| AC10 | Read `status` agent + `/status` command: the same findings appear; no file modified. |
| AC11 | Read builder/build gate: focused findings printed after PROCEED; build not stopped. |
| AC12 | Read the authority: reads committed `work/` + local repo only; no fetch/remote/merge/dry-run/lock/write. |
| AC13 | Read the authority: operates on committed plans; no branch/dry-run detection. |
| AC14 | Read the authority: absent/`—` declaration yields no finding; historical items valid with no migration. |
| AC15 | `bash tests/run.sh` exit 0: README count/table, `AGENTS.md`/`template/AGENTS.md`, skill route, and signature-sweep registry all include `/conflicts`; `40-inventory`/`96-signature-sweep` green. |
| AC16 | Cross-surface read (`rg -n '/conflicts' docs .opencode README.md AGENTS.md template/AGENTS.md`): one authoritative statement, others reference it without restating. |
