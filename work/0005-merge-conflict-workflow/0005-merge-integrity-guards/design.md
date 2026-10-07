---
feature: 0005-merge-conflict-workflow/0005-merge-integrity-guards
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
notes: "Prompt/doc-only behavior contract. Resolves the spec's two deferred questions: (1) surface placement — the guard contract is one new `### Merge-integrity guard` subsection inside `docs/workflow.md` → `## Merge conflicts`, with the merge-conflict skill, the status agent/command, and the shipper referencing it; no new file, command, agent, skill, phase, or artifact format, and tests/** is untouched. (2) Boundary with the 0001/0003 contract — generalizing the re-verification test-command reference from the literal `bash tests/run.sh` to the repository's own configured test command (the Project profile `Test:` value) is an additive portability clarification, not a change to 0001 policy: the policy (re-run the project's test command and the item's checks; both green before record/ship) is preserved and, for this repository whose Test value is `bash tests/run.sh` (AGENTS.md:17), resolves to the identical command. No user escalation required; recorded as risk R1. Per the spec, verification is the project's own configured suite plus surface inspection — no standalone verify-tests.sh and no new committed check. The two reconcile-record templates (docs/artifact-conventions.md ship.md and .opencode/skill/pr-workflow/SKILL.md) change only their illustrative re-verification command (same field, same shape)."
parent: 0005-merge-conflict-workflow
---

# Design — Merge-integrity guard as a portable behavior contract

## Summary

State the merge-integrity guard once, authoritatively, as a new
`### Merge-integrity guard` subsection inside `docs/workflow.md` →
`## Merge conflicts`: the invariant set (duplicate top-level/per-parent prefixes,
resolvable and acyclic roadmap dependencies, no missing/unlisted child, agreeing
duplicated inventory/count facts), its two prompt-only enforcement points
(`/status` offline and read-only; the `/ship` post-merge integrity pass), its
report-only finding contract, and its portability rule (verification names the
repository's own configured test command — the Project profile `Test:` value).
The `merge-conflict` skill, the `status` agent and `/status` command, and the
`shipper` reference that contract instead of restating a second one, and the
maintainer-only `bash tests/run.sh` re-verification literal on the adopter-shared
surfaces is replaced by the configured-test-command reference. No checker,
script, test area, command, agent, skill, phase, or artifact format is added, and
`tests/**` is unchanged.

## Approach

**The gap is a contract, not a tool.** Sibling `0002` already delivers detection:
the `merge-conflict` skill's read-only pre-flight and finding grammar
(`.opencode/skill/merge-conflict/SKILL.md:22-125`) and the `status` agent's
offline findings (`.opencode/agent/status.md:86-151`). Siblings `0001`/`0003`/`0004`
deliver the reconcile contract and the post-merge pass
(`docs/workflow.md:337-397`). What is missing is one durable statement that the
invariants exist, where the guard runs, and how a reader observes a violation —
and a portable verification reference so an adopter without the maintainer suite
can still follow it. This child adds exactly that statement and makes the
verification step portable; it re-specifies no detection.

**Home: the normative merge-conflict contract (`docs/workflow.md`).** The guard
is a *contract*, and `docs/workflow.md` is the document the skill names as the
source of truth on disagreement (`.opencode/skill/merge-conflict/SKILL.md:8-10`)
and already the normative home of `## Merge conflicts`. The new subsection is
placed inside that section, after `### Verification` (`:385-391`) and before
`### Relationship to renumbering` (`:393-397`), so it reads as part of the one
merge-conflict contract rather than a competing policy. The skill keeps the
operational pre-flight and post-merge checklist and the canonical code table; the
status surfaces keep the read-only window; all three point at the contract.
`docs/workflow.md` and `.opencode/**` are both in the adopter copy set
(`README.md:69-70`, `tests/README.md:5-16`), so the contract travels verbatim
(AC6).

### The guard contract (new subsection content)

The subsection must read, in substance, as follows. Required literals are
enumerated so the builder makes no design decision.

- **Report-only, prompt-only.** It states the guard is prompt behavior only,
  that there is **no committed checker, script, helper, or executable tool** and
  **no `tests/` agreement area**, and it names the two enforcement points:
  `/status` reports the invariants **offline and read-only** on demand; the
  `/ship` **post-merge integrity pass** runs after a merge to the default branch.
  Both observe the same invariant set and neither defines a separate guard.
- **Invariant set (AC1).** A table mapping each invariant to its `0002` finding
  code and `0001` class:

  | Invariant | Code | Class |
  | --------- | ---- | ----- |
  | no two top-level `work/` items share a 4-digit `NNNN` prefix | `DUPLICATE-PREFIX` | `(c)` |
  | no two children of one roadmap parent share a 4-digit `MMMM` | `DUPLICATE-CHILD` | `(c)` |
  | every roadmap `Depends on` resolves to an existing `Children` row and child directory | `DANGLING-DEP` | `(b)` |
  | the stored dependency graph is acyclic | `CYCLIC-DEP` | `(b)` |
  | no child is missing — a `Children` row whose child directory is absent | `MISSING-CHILD` | `(b)` |
  | no child is unlisted — a child directory absent from the `Children` table | `UNLISTED-CHILD` | `(b)` |
  | the duplicated inventory/count facts agree with disk | `DRIFT-FACT` | `(d)` |

- **Finding contract (AC3).** Findings use the `0002` grammar
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`; every
  finding names its code, its class, and the offending canonical reference, is
  **non-fatal**, is **never silently dropped** (the list is never truncated), and
  is **not auto-repaired**; the guard **modifies no file**. An empty `work/` tree
  and an already-up-to-date branch with no collision are no-ops that report no
  findings and do not error (AC8).
- **No second vocabulary or policy (AC7).** The codes and grammar are the
  detection vocabulary of the `merge-conflict` skill's `### Finding grammar`
  (`:94-125`), consumed unchanged; the guard defines **no second vocabulary and
  no second policy**.
- **Portability (AC5).** It names the repository's own configured test command —
  **the Project profile `Test:` value in `AGENTS.md`** — not a maintainer-only
  path, and states the duplicated-inventory/count-fact invariant is observable
  **offline through `/status`** without that command.

### Generalizing the re-verification reference (AC5)

Replace the maintainer-only literal `bash tests/run.sh` in the guard's
verification/re-verification instruction on every adopter-shared surface with a
reference to **the repository's own configured test command — the Project profile
`Test:` value in `AGENTS.md`**. Occurrences:

- `docs/workflow.md:363` (`### Lifecycle placement`, post-merge pass);
- `docs/workflow.md:387` (`### Verification`);
- `.opencode/skill/merge-conflict/SKILL.md:206` (sub-step 1.8), `:248`
  (procedure step 4), `:267` (post-merge pass step 6), `:396` (`work/` reconcile
  hand-back);
- `.opencode/agent/shipper.md:173` (work-item process step 2);
- `docs/artifact-conventions.md:419` (the `ship.md` template's illustrative
  `Re-verification:` command) and `.opencode/skill/pr-workflow/SKILL.md:54` (the
  PR description's matching `Re-verification:` line) — in both record templates
  the field name, order, and shape are unchanged, only the example command text
  becomes generic.

The literal remains correct and unchanged where it is the framework repository's
actual configured value or is maintainer-only: `AGENTS.md:17` (the Project
profile `Test:` value itself), `README.md:218` (the Agents-table capability cell),
`CONTRIBUTING.md:34`, `CHANGELOG.md:21`, and `tests/**`. The design deliberately
does not touch those.

### Boundary with the `0001` contract (resolves the spec's deferred question)

Generalizing `bash tests/run.sh` to the Project profile `Test:` reference is an
**additive clarification, not a policy change**, so no user escalation is
required. The `0001` policy is "after any resolution, re-run the repository's
test command and the affected item's checks; both must be green before the
resolution is recorded or shipped." The literal `bash tests/run.sh` is this
repository's instantiation of that command (its Project profile `Test:` value);
substituting the parameterized reference leaves the requirement, ordering, and
green gate byte-for-byte in effect and only changes which concrete command it
resolves to per repository. For the framework repository it resolves to the same
command as today. The `0001` taxonomy, lifecycle placement, ownership, resolution
principles, structural-auto/semantic-escalate rule, and the normative
"Renumbering after a parallel merge" rule in `docs/artifact-conventions.md` are
otherwise untouched. Risk R1 records the reviewer challenge and mitigation.

### Enforcement wiring

- `.opencode/skill/merge-conflict/SKILL.md` — generalize the four re-verification
  literals; at `### Finding grammar` (`:94-125`) add a sentence naming
  `docs/workflow.md` → `### Merge-integrity guard` as the single statement of the
  invariant set and the report-only contract; at the post-merge pass step
  (`:261-267`) state the pass is report-only (reports every finding, modifies no
  file) and uses the configured test command. The pre-flight and the `work/`
  reconcile are otherwise unchanged.
- `.opencode/agent/status.md` — `<inputs>` (`:54-66`) gains the guard contract as
  the canonical invariant source; `<findings>`/`<rules>` (`:122-151`, `:193-215`)
  gain a pointer that the offline report is the guard's read-only window
  (report-only, mutates nothing, never auto-repairs). The existing report-only,
  local-only, `CYCLIC-DEP`, and "integrity findings rather than failing" literals
  that `80-cycle-fixture.sh` pins are preserved.
- `.opencode/command/status.md` — the findings bullet (`:28-40`) gains the
  pointer to `### Merge-integrity guard` and restates that the report is
  non-fatal and modifies no file.
- `.opencode/agent/shipper.md` — generalize the re-verification literal
  (`:173`); `<rules>` (`:220-250`) gains a line that the post-merge integrity pass
  is the report-only guard (report findings per the contract; never auto-repair,
  never mutate a file for it). No permission-frontmatter change.

### Explicitly unchanged

`README.md`, `AGENTS.md`, `template/AGENTS.md`, `opencode.json`, every agent's
permission frontmatter, every lifecycle phase, the derived-state table, the
readiness model, the artifact formats and their fields, and the command/agent/
skill inventories. `tests/**` gains, loses, and changes nothing (AC4, AC9, AC10).
No new executable file anywhere.

## Alternatives considered

- **Put the guard contract only in the `merge-conflict` skill, leaving
  `docs/workflow.md` untouched.** Pros: no edit to the normative `0001` section.
  Cons: `docs/workflow.md` is the declared source of truth and the normative home
  of `## Merge conflicts`; a guard stated only in the operational skill reads as
  a second, lower-authority policy and weakens AC1's "when the contract is read".
  The contract would also not reach a reader who consults the workflow authority
  first. **Rejected** — home the single contract with the contract it guards.
- **Deliver committed fixture-based `tests/checks/` agreement areas plus
  `tests/mutation.sh` coverage (the roadmap's original vehicle,
  `roadmap.md:77,130-133`).** Pros: machine-enforced, catches a violation in CI.
  Cons: explicitly superseded by the user's re-scope; `tests/` is
  framework-maintainer-only and never copied to adopters (`tests/README.md:3-16`,
  `README.md:82-90`), and the suite never reads `work/**` (`tests/README.md:29`),
  so it would protect only the framework repo while adopters inherit no guard —
  the exact gap the spec names. **Rejected** — it fails the portability goal.
- **Duplicate the contract onto more adopter surfaces (`AGENTS.md`,
  `template/AGENTS.md`, `README.md`) for visibility.** Pros: broader discovery.
  Cons: multiplies the duplicated inventory/count facts this initiative exists to
  keep consistent, and adds README/Layout and signature-sweep surface area
  (`tests/checks/40-inventory.sh`, `96-signature-sweep.sh`) for no AC gain —
  AC6 is satisfied by `docs/*.md` and/or `.opencode/**`. **Rejected** — smallest
  change; avoid new derived-agreement drift.
- **A new `/guard` command plus a `guard` agent, or a runtime checker.** Pros:
  directly invocable and machine-enforced. Cons: violates the spec non-goals
  ("no executable checker, script, helper, runtime code, or adopter-installed
  tooling"; no new command/agent/skill) and the `0001` ownership decision
  (reconcile and its guard are steps owned by the shipper and the read-only status
  window); forces edits to `.opencode/{command,agent}/`, `opencode.json`, the
  README tables, and `tests/checks/40-inventory.sh`. **Rejected** — enlarges
  exactly the shared surfaces the initiative reconciles.

## Interfaces and data model

No runtime interfaces, schemas, migrations, or public APIs change. The required
contract is content on existing prompt/doc surfaces, so the builder and tester
verify by reading and by grepping for the literals below.

### `docs/workflow.md` — new `### Merge-integrity guard`

Placed after `### Verification` (ends `:391`), before `### Relationship to
renumbering` (`:393`).

| Region | Required literal(s) |
| ------ | ------------------- |
| Prompt-only / no tool | `prompt behavior only`; `no committed checker, script, helper, or executable tool`; `no tests/ agreement area`; `neither defines a separate guard` |
| Enforcement points | `/status`; `offline and read-only`; `/ship`; `post-merge integrity pass`; `after a merge to the default branch`; observes the same invariant set |
| Invariant set | the seven invariant rows and codes `DUPLICATE-PREFIX`, `DUPLICATE-CHILD`, `DANGLING-DEP`, `CYCLIC-DEP`, `MISSING-CHILD`, `UNLISTED-CHILD`, `DRIFT-FACT`, each with its class `(b)`/`(c)`/`(d)` |
| Finding contract | grammar `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>`; `non-fatal`; `never silently dropped`; `never truncated`; `not auto-repaired`; `modifies no file` |
| No second policy | `no second vocabulary`; `no second policy`; the grammar is the `merge-conflict` skill's `### Finding grammar` |
| Portability | `configured test command`; `Project profile`; `Test:`; `observable offline through /status` |
| No-op | empty `work/` tree and an already-up-to-date branch with no collision → `no findings`; `does not error` |

### `docs/workflow.md` — reference generalization

- `:363` and `:387`: replace the literal `bash tests/run.sh` with the
  configured-test-command reference (`the repository's own configured test
  command — the Project profile `Test:` value`).

### `.opencode/skill/merge-conflict/SKILL.md`

| Region | Required literal(s) |
| ------ | ------------------- |
| Contract pointer (`### Finding grammar`, `:94-125`) | `docs/workflow.md`; `### Merge-integrity guard`; guard defines `no second vocabulary` and `no second policy`; guard `modifies no file` |
| Post-merge pass (`:261-267`) | report-only; reports every finding; `modifies no file`; configured test command (Project profile `Test:` value) |
| Re-verification literals (`:206`, `:248`, `:396`) | configured test command (Project profile `Test:` value) in place of the `bash tests/run.sh` literal |

### `.opencode/agent/status.md`

- `<inputs>` (`:54-66`): add `docs/workflow.md` → `### Merge-integrity guard` as
  the canonical invariant set and enforcement points for the offline report.
- `<findings>`/`<rules>` (`:122-151`, `:193-215`): add that the offline report is
  the guard's read-only window — report-only, non-fatal, never auto-repaired,
  modifies no file. Preserve `integrity findings rather than failing`,
  `CYCLIC-DEP`, `cycle members are never reported ready`, `Dependencies and
  readiness`, and the local-only/no-fetch/no-dry-run literals.

### `.opencode/command/status.md`

- Findings bullet (`:28-40`): add the pointer to `### Merge-integrity guard` and
  that the report is non-fatal and modifies no file. Preserve `CYCLIC-DEP`,
  `Report them without failing`, and `a child in a cycle is never `ready``.

### `.opencode/agent/shipper.md`

- Process step 2 (`:173`): configured test command reference.
- `<rules>` (`:220-250`): add that the post-merge integrity pass is the
  report-only guard (`docs/workflow.md` → `### Merge-integrity guard`; report
  every finding; never auto-repair; never mutate a file for it). Frontmatter
  unchanged.

### The reconcile-record templates

- `docs/artifact-conventions.md:419` (the `ship.md` template) and
  `.opencode/skill/pr-workflow/SKILL.md:54` (the PR description's `## Reconcile`
  section): the illustrative `Re-verification:` command becomes the
  configured-test-command reference. Field name, order, and shape unchanged; no
  format/template field added or removed.

### Compatibility and migration

There is nothing to migrate. `.opencode/**` and `docs/*.md` are copied verbatim,
so adopters receive the contract and the portable reference on their next copy
(AC6). No `work/` artifact is rewritten; no frontmatter field, phase,
derived-state rule, or readiness rule changes. On the framework repository the
configured test command resolves to the same `bash tests/run.sh` as before.

## Affected areas

- `docs/workflow.md` — new `### Merge-integrity guard`; `:363` and `:387`
  reference generalization.
- `.opencode/skill/merge-conflict/SKILL.md` — contract pointer; `:206`, `:248`,
  `:267`, `:396` reference generalization; report-only statement on the
  post-merge pass.
- `.opencode/agent/status.md` and `.opencode/command/status.md` — pointers to the
  contract; report-only window statement.
- `.opencode/agent/shipper.md` — `:173` reference generalization; guard rule.
- `docs/artifact-conventions.md` `:419` and `.opencode/skill/pr-workflow/SKILL.md`
  `:54` — example command in the two reconcile-record templates only.
- Read for context, not changed: `docs/workflow.md:337-397` (the contract),
  `tests/checks/80-cycle-fixture.sh`, `tests/checks/10-readiness.sh`,
  `tests/checks/20-lifecycle.sh`, `tests/checks/96-signature-sweep.sh`,
  `tests/checks/30-permissions.sh`, `tests/checks/40-inventory.sh`,
  `tests/README.md:18-30`, `AGENTS.md:17`, `work/0005-merge-conflict-workflow/000{1,2,3,4}-*/**`.

## Risks and mitigations

- **R1 — The test-command generalization is read as a change to the `0001`
  policy.** Likelihood low / impact high. Mitigation: the requirement, ordering,
  and green gate are unchanged; only the concrete command reference is
  parameterized, resolving to the identical command here; the change is confined
  to the re-verification literal, and all other `0001` prose is untouched. The
  design records the additive reasoning (see "Boundary with the `0001`
  contract").
- **R2 — Vocabulary drift between the new docs table and the skill/status code
  table.** Likelihood medium / impact medium. Mitigation: the same seven codes
  and the same `(b)`/`(c)`/`(d)` classes; the subsection declares the skill's
  `### Finding grammar` canonical and defines no second vocabulary; the final
  gate cross-checks every code on both surfaces.
- **R3 — Duplicated invariant set across docs, skill, and status drifts.**
  Likelihood medium / impact medium. Mitigation: the docs subsection is the
  single enumeration of the invariant set; the skill and status carry only the
  operational specifics and reference the contract; the final gate greps both
  for agreement.
- **R4 — A committed-suite regression from editing `docs/workflow.md` or the
  prompts.** Likelihood low / impact high. Mitigation: no phase heading
  (`### N.`), command signature/usage string, inventory count, permission
  frontmatter, or readiness algorithm is touched; `80-cycle-fixture.sh`'s pinned
  literals (`integrity findings rather than failing`, `CYCLIC-DEP`, `cycle
  members are never reported ready`, `a child in a cycle is never `ready``) and
  `10-readiness.sh`'s `Dependencies and readiness` deferral are preserved;
  `bash tests/run.sh` runs after every task and at the gate.
- **R5 — A maintainer-only path survives on an adopter-shared surface (AC5
  under-met).** Likelihood medium / impact medium. Mitigation: the final gate
  greps every adopter-shared instruction surface — `docs/workflow.md`,
  `docs/artifact-conventions.md`, `.opencode/skill/merge-conflict/SKILL.md`,
  `.opencode/skill/pr-workflow/SKILL.md`, and `.opencode/agent/shipper.md` — for
  the `bash tests/run.sh` literal and requires it to remain only where it is the
  repository's configured value or maintainer-only tooling (the shipper's
  allowlist pattern and the maintainer-only root files).
- **R6 — Scope creep into `tests/**` or new tooling.** Likelihood low / impact
  high. Mitigation: explicit no-`tests/`-change gate; the final gate diffs
  `tests/` and confirms counts `12 commands / 14 agents / 11 skills` and no new
  executable.
- **R7 — The guard is read as a second policy or as reconciling.** Likelihood
  medium / impact medium. Mitigation: explicit `no second vocabulary`, `no second
  policy`, report-only, and not-auto-repaired literals in the contract; the guard
  is placed inside `## Merge conflicts` and defers to `0001`/`0002`.
- **R8 — An adopter's configured test command is outside the shipper's bash
  allowlist.** Likelihood medium / impact medium. Pre-existing and out of scope:
  AC5 requires the *instruction* to name the configured command; the guard is
  report-only and the shipper's allowlist is deliberately unchanged (widening it
  would regress `30-permissions.sh`). Recorded as a follow-up, not fixed here.

## Test strategy

The deliverable is prompt/doc content, and per the spec's resolved verification
note this child adds no `verify-tests.sh` and no committed `tests/**` check.
Verification is therefore (a) the repository's own configured suite
(`bash tests/run.sh`, the Project profile `Test:` value — `AGENTS.md:17`), which
covers AC9/AC10's regressions and structural invariants, plus (b) read-only
surface inspection of the literals and structure the ACs require. Each task runs
the suite; the final task is the independent gate.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | surface inspection: `docs/workflow.md` `### Merge-integrity guard` contains all seven invariant rows and their codes/classes |
| AC2 | surface inspection: the subsection states the two enforcement points (`/status` offline/read-only; `/ship` post-merge pass) and that no separate checker exists; skill/shipper restate report-only |
| AC3 | surface inspection: finding grammar, code + class + offender, non-fatal, never-dropped/never-truncated, not auto-repaired, modifies no file, on both the contract and the status surfaces |
| AC4 | inspection: `git diff --stat tests/` is empty; no new file under `.opencode/`; no executable added |
| AC5 | surface inspection: every guard/re-verify instruction on an adopter-shared surface names the configured test command (Project profile `Test:` value); drift invariant stated observable offline via `/status`; suite green |
| AC6 | surface inspection: the contract and invariant set are present in `docs/workflow.md` and referenced from `.opencode/skill/merge-conflict/SKILL.md` and `.opencode/agent/status.md` |
| AC7 | surface inspection: codes/invariants agree with the skill's `### Finding grammar`; explicit no-second-vocabulary/no-second-policy literals |
| AC8 | surface inspection: the contract states the empty-tree and already-up-to-date no-op (no findings, no error); the skill's `### Up to date and degraded paths` still states the no-op |
| AC9 | integration: `bash tests/run.sh` exits 0 with no `FAIL`; `tests/` diff is empty |
| AC10 | integration + inspection: suite green; command/agent/skill counts are 12/14/11; `docs/workflow.md` phase headings, `docs/artifact-conventions.md` artifact field set, `AGENTS.md`/`template/AGENTS.md` lifecycle, and every permission frontmatter are unchanged |

`bash tests/run.sh` is the project's canonical command and is run after every
task; the tester re-runs it independently for AC9/AC10.
