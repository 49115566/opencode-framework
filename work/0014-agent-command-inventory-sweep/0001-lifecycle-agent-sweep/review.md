---
feature: 0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep
phase: review
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Review — Lifecycle-agent recursive sweep

## Verdict

**approve** — the six lifecycle prompts are swept onto the recursive model
exactly as the spec and design fix it: the retired `roadmap` vocabulary is gone
except the one sanctioned labelled legacy alias, the canonical item-ref sentence
is replicated byte-for-byte across all six inputs, the prose-only invariant holds,
and every acceptance criterion is met by inspection.

## Diff under review

- Base ref: `git merge-base HEAD origin/main` → `efe1782` (equals `HEAD` and
  `origin/main`; the item's plan was merged at PR #81 / `d7f30d2`).
- Commands: `git status`, `git diff --stat`, `git diff -- .opencode/agent/`,
  `git diff -- work/0014-agent-command-inventory-sweep/0001-lifecycle-agent-sweep/tasks.md`.
- The builder's changes are **uncommitted working-tree edits** on `main` (the
  builder does not commit). The reviewed range is therefore `git diff` against
  `HEAD`, not `HEAD...origin/main`: the latter is empty.
- Changed paths: `.opencode/agent/{architect,builder,product,reviewer,shipper,tester}.md`
  and the item's `tasks.md` (check boxes only). `verify.md` is the tester's new,
  untracked artifact. No authority doc, fixture, test, command, or frontmatter is
  touched.
- No `challenges.md` exists in the item, so there is no open challenge to
  adjudicate.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- None.

### Nits

- None.

## Acceptance criteria walkthrough

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 — `product` parent-node guidance names the parent manifest, target phase `manifest`, `/plan <parent-ref>`, cites "Revising a decomposition", no retired routes/paths | **met** | `.opencode/agent/product.md:116-124`: names the **parent's manifest**, `/plan <parent-ref>`, target phase `manifest`, affected `work/<parent-ref>/manifest.md`, and cites `docs/workflow.md` → "Phase reversal (backtracking)" and "Revising a decomposition". Case-insensitive grep over the six prompts returns no `parent roadmap`, `/roadmap revise`, `work/<parent-ref>/roadmap.md`, or `roadmap` token in `product.md`. |
| AC2 — `product` nested-child step resolves the parent `work/<NNNN-slug>/manifest.md`; readiness/override preserved | **met** | `.opencode/agent/product.md:75-83`: step 6 now resolves `work/<NNNN-slug>/manifest.md` and cites the manifest template; the readiness tail (`docs/workflow.md` → "Dependencies and readiness", blocking-children stop, explicit-override + `notes` record, "Refusing must touch no existing file.") is byte-unchanged — the diff hunk ends immediately after the inserted clause. |
| AC3 — `shipper` merge/reconcile/renumber guidance names the manifest dependency graph and manifest `Children`, semantics unchanged | **met** | `.opencode/agent/shipper.md:129-130` ("manifest dependency-graph fault"), `:200-202` ("every manifest's dependency graph"), `:375` ("the manifest `Children` `Local id` and `Canonical reference` cells"). The renumber steps, the reconcile sequence, and the plan-publication/recall `manifest.md` wording (`:96`, `:103`) are untouched. |
| AC4 — one canonical item-ref sentence, byte-identical in all six inputs, no "roadmap child" | **met** | Identical substring `` `NNNN-slug` for a standalone item, or a nested `NNNN-slug/MMMM-slug` at any depth; a canonical reference per `docs/artifact-conventions.md` → "Work item references", resolving to the directory `work/<item-ref>/`. `` appears exactly once at `product.md:55`, `architect.md:86`, `builder.md:69`, `tester.md:97`, `reviewer.md:62`, `shipper.md:93`. It matches the exact string fixed in `design.md:33`. Grep for "roadmap child" over the six returns nothing. |
| AC5 — `tester` and `reviewer` inputs address a decomposing node's `manifest.md`, nested children by canonical reference, and a hybrid node | **met** | `tester.md:98-100` and `reviewer.md:63-65` each add a final input item naming the decomposing node's `manifest.md`, its nested children addressed by canonical reference, and a hybrid node's own deliverable alongside its phase artifacts, citing "Work item references". |
| AC6 — every `roadmap` occurrence is a clearly-labelled legacy alias mention | **met** | Case-insensitive grep over the six returns exactly one hit: `architect.md:102` — ``an existing `work/<item-ref>/manifest.md` (or the legacy `roadmap.md` artifact alias)`` — explicitly labelled `legacy`. `product.md`, `builder.md`, `tester.md`, `reviewer.md`, and `shipper.md` contain zero `roadmap` tokens. |
| AC7 — frontmatter `description`/`mode`/`permission` and the `<handoff>` block byte-identical; prose-only | **met** | Every diff hunk falls inside `<inputs>`, `<process>`, or `<rules>`; no hunk touches lines 1–~20 (frontmatter) or a `<handoff>…</handoff>` block in any of the six files. |
| AC8 — `bash tests/run.sh` exits 0; inventory 13 agents / 12 commands / 11 skills | **met (static)** | Disk counts confirmed: `.opencode/agent` 13, `.opencode/command` 12, `.opencode/skill` 11; `README.md:272-274` documents `# 13 role prompts` / `# 12 slash commands` / `# 11 knowledge skills`. No committed check pins the changed prose (see "Tests" below), so the sweep cannot perturb the suite; `verify.md` records the run at 503 passed / 0 failed / exit 0. Suite not re-executed in this pass (see "Not reviewed"). |
| AC9 — recursive-model statements cite the authority by name; no new `phase` value, finding code, or reference grammar | **met** | New statements cite "Work item references" (canonical sentence), "`manifest.md` — the manifest of a decomposing node" and "Dependencies and readiness" (`product.md:76-79`), "Phase reversal (backtracking)" + "Revising a decomposition" (`product.md:122-123`), and "Dependencies and readiness" (`shipper.md:130`). All are existing section names; no new `phase` value, finding code, or reference production is introduced. |

## Security, error handling, and scope

- **Security / secrets.** Prose-only edit to agent prompts; no credentials, tokens,
  or `.env` content introduced or exposed. No change to any `permission` block, so
  the least-privilege postures are unchanged (AC7).
- **Error handling / behavior.** The changed sentences preserve the pre-existing
  behavioral clauses (blocked-child stop, explicit-override recording, renumber
  and integrity semantics); the diff only swaps vocabulary. No control flow in any
  prompt is altered.
- **Scope.** The diff is confined to the six named lifecycle prompts plus the
  item's own `tasks.md` check boxes; `0002`/`0003`/`0004`/`0005` surfaces
  (`status.md`, `visual.md`, commands, skills, inventories) are untouched. No
  scope creep, no unrelated reformatting, no new file.
- **Backward compatibility.** Prompt text is shared verbatim with adopters; the
  sweep removes only superseded vocabulary and keeps the one labelled legacy
  `roadmap.md` alias for readers of historical `work/` content (spec edge case).

## Tests

- Read `tests/checks/40-inventory.sh`, `30-permissions.sh`, `50-instructions.sh`,
  `60-default-agent.sh`, `96-signature-sweep.sh`, `10-readiness.sh`, and
  `25-review-severity-bar.sh`. The first four read only counts/membership and the
  agents' frontmatter `mode`/`permission` (unchanged); `96-signature-sweep` reads
  command/README/AGENTS/skill signatures, never agent prompt bodies; `10-readiness`
  requires `product.md` to contain "Dependencies and readiness", which it still
  does (`product.md:79`); `25-review-severity-bar` pins phrases in `reviewer.md`'s
  `<process>`/role sections, which the sweep does not touch. No committed test
  pins the changed boilerplate, so the sweep neither weakens nor perturbs coverage.
- Consistent with the spec's non-goal, no committed recursive-sweep guard is added
  (that boundary is Roadmap 5); the tester's inline inspection harness is recorded
  verbatim in `verify.md`'s appendix.

## Not reviewed

- `bash tests/run.sh` was not re-executed in this pass: the review environment's
  tool policy permits only read/inspection commands, not arbitrary program
  execution. AC8 is therefore marked **met (static)** on the strength of the
  on-disk counts, the unchanged frontmatter/inventory surfaces, the absence of any
  test that reads the changed prose, and `verify.md`'s recorded run. A reviewer
  with execution access should confirm the 503-pass claim before merge.
- Cross-child byte-identity of the canonical sentence with
  `0003-command-sweep` is outside this item's surface and is `0003`'s own
  verification (noted in `verify.md`).
- The internal line-wrap aesthetics of the reflowed `shipper.md` reconcile
  paragraph are cosmetic only (the flattened prose is correct); no finding raised.
