---
feature: 0003-framework-quality-hardening/0002-readiness-ship-state
phase: design
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Design — Readiness semantics and shipped-state detection

## Summary

Make `docs/workflow.md` → "Dependencies and readiness" the single authoritative
readiness definition; the status agent, `/status` command, and product agent's
blocked-start gate reference it instead of restating it. Keep the existing
`ship.md` record as the one machine-readable shipped signal and define it by
**presence** (never by contents and never by a detected pull request), grant the
shipper `edit` on both `work/**` patterns so it can actually write that record,
and extend the existing verification suite with an agreement assertion plus
updates to the assertions that encoded the removed branch and the permission
freeze.

## Approach

Four coordinated changes, all prompt/config/doc edits except one executable test
script. No runtime code, no new dependency, no state file.

### 1. One authoritative readiness definition (AC1, AC2, AC3, AC4, AC8)

`docs/workflow.md` is the authority. Its `satisfied()` block loses the
undetectable PR branch and its shipped key becomes `ship.md` presence:

```
satisfied(dep_local_id):
  child_dir = work/<parent>/<dep_local_id>/
  if child_dir does not exist        -> dangling; not satisfied
  if child_dir/ship.md exists        -> satisfied        # shipped; presence is the sole shipped signal
  if child_dir/review.md exists
       and its verdict == "approve"  -> satisfied        # approved, even if unshipped
  otherwise                          -> not satisfied

ready(child)      = every dependency of child is satisfied AND child is not in a cycle
blocked_by(child) = [dep_local_id for each unsatisfied dependency]
```

The prose below it (`docs/workflow.md:103-106`) is rewritten so approved-but-
unshipped is stated as **satisfied**, `ship.md` presence takes precedence over a
`request-changes` verdict, and presence — not URL contents — is what counts.
This is the only place the branch sequence lives.

Every other surface describes it by reference:

- `.opencode/agent/status.md` — replace the `<readiness_algorithm>` block with a
  short `<readiness>` note pointing at `docs/workflow.md` → "Dependencies and
  readiness" and forbidding restatement. Delete the contradicting bullet at
  `status.md:119-122`.
- `.opencode/command/status.md:17-22` — replace the restated algorithm with the
  same reference plus the settled one-line semantics (approve-even-unshipped and
  `ship.md` presence).
- `.opencode/agent/product.md:71-72` — **no change**; it already says "run the
  readiness algorithm in `docs/workflow.md` → 'Dependencies and readiness'". The
  new assertion guards it (AC1).

The derived-state table (`docs/workflow.md:233-245`) keys shipped state on the
same artifact and reorders so presence wins:

```
| `ship.md` present                                          | shipped      |
| `roadmap.md` present (check before `spec.md`)              | roadmap      |
...
| `review.md` verdict `approve`, no `ship.md`                | ship         |
```

The `ship.md` row moves above the review rows so the edge case "`ship.md` present
with a `request-changes` verdict → shipped" holds. The Ship phase's Artifact line
(`workflow.md:225`) becomes "branch, commits, PR, and `ship.md`".

### 2. One shipped signal (AC4, AC6)

Removing the detected-PR branch removes the only step the read-only status agent
could not execute. Concretely, delete the "infer shipped state" input at
`.opencode/agent/status.md:63-64` and the "`ship.md` or a detected PR" phrase at
`status.md:75`; change `.opencode/command/status.md:11` to name only `ship.md`.
The status agent's bash allowlist gains nothing — it still has no `gh` and needs
none, because shipped state is a file's presence. `docs/artifact-conventions.md`
keeps the `ship.md` schema and gains one clause naming its presence as the signal
consumed by readiness.

### 3. A writable shipped signal (AC5, AC7)

`.opencode/agent/shipper.md` frontmatter changes from `edit: deny` to the
artifact-writer shape already used by `product`/`architect`/`roadmap`:

```yaml
permission:
  edit:
    "*": deny
    "work/**": allow
    "**/work/**": allow
```

Both patterns are required (relative and absolute tool-path forms; doctor's
`PERMISSION-WORK-PATTERN` check enforces this). Writing `work/<item-ref>/ship.md`
becomes a required Ship step, not "optional", so shipped state is recorded on the
normal path even when `gh` is unavailable. The README Agents-table `shipper` row
changes from "none" to `` `work/**` + `**/work/**` `` so doctor's
`PERMISSION-TABLE-MISMATCH` check stays green.

### 4. A regression guard (AC9, AC10)

Extend `work/0002-agentic-roadmaps/verify-tests.sh` — the framework's existing
verification suite — with a content-based agreement assertion and update the
assertions this change invalidates. The guard is content-based, not diff-based,
so it holds after commit:

- the algorithm token `satisfied(dep_local_id):` appears in exactly one live
  surface (`docs/workflow.md`) among an explicit candidate list;
- status agent, `/status` command, and product agent each name "Dependencies and
  readiness";
- no live surface matches `PR is detected` / `PR detected` / `detected PR`;
- no live surface groups `approved-but-unshipped` with "not satisfied".

**Deliberate cross-item edit.** `work/0002-agentic-roadmaps/verify-tests.sh` is
another (shipped) item's test artifact. The spec mandates updating it (AC9,
AC10) and the roadmap defers relocation to sibling `0006-committed-tests-ci`.
Only executable assertions change; no historical record is rewritten.

## Alternatives considered

- **Duplicated-but-identical definitions plus an equality check.** Keep the
  algorithm in both `docs/workflow.md` and `.opencode/agent/status.md` and assert
  the two copies match. Pros: status is self-contained; the roadmap framed the
  task as "the two readiness definitions agree". Cons: leaves two sources that
  can drift between runs, and AC1 explicitly requires *exactly one* surface to
  state the algorithm and every other to describe it by reference. Rejected.
- **Re-implement the detected-PR branch by giving `status` `gh`.** Add
  `gh pr view*`/`gh pr list*` to the status allowlist. Pros: preserves the
  documented "or has been shipped" wording for hand-shipped items. Cons:
  contradicts the status agent's read-only, network-free design and AC6, makes
  `/status` fail or stall offline, and still misses branches without a PR.
  Rejected, matching the spec's resolved assumption.
- **A different shipped signal (git branch/tag) instead of `ship.md`.** Derive
  shipped state from a marker branch or tag using the git commands status already
  has. Pros: no new permission grant. Cons: branch/tag names collide with real
  branches, are deleted after merge, and have no schema; the spec fixed `ship.md`
  as the single signal. Rejected.
- **Chosen: single authority + `ship.md` presence + shipper work grant.**
  Satisfies AC1-AC10 with the fewest moving parts and no new dependency.

## Interfaces and data model

No new files, fields, or schemas. Changes are to prompt/config/doc text and one
test script.

### Authoritative readiness definition (`docs/workflow.md`)

Algorithm as shown above. Prose must contain the literal phrases the assertion
checks: `even if unshipped` and `presence is the sole shipped signal`, and must
state that `ship.md` presence takes precedence.

### Derived-state rows (`docs/workflow.md`)

| Observed state | Phase |
| -------------- | ----- |
| `ship.md` present | shipped |
| `review.md` verdict `approve`, no `ship.md` | ship |

Placed so the `ship.md` row precedes the `request-changes` row.

### Agent permission block (`.opencode/agent/shipper.md`)

```yaml
permission:
  edit:
    "*": deny
    "work/**": allow
    "**/work/**": allow
  bash: { ...unchanged... }
```

No change to `bash`, which stays the git/gh allowlist.

### `ship.md` (unchanged schema, clarified semantics)

Presence = shipped. Contents (branch, PR URL, commits) are informational and never
parsed. A `ship.md` with no PR URL (gh unavailable) still counts.

### Verification assertions (`work/0002-agentic-roadmaps/verify-tests.sh`)

Executable shell assertions only; the script always exits non-zero on any
failure. New and changed checks are enumerated in tasks T5.

## Affected areas

- `docs/workflow.md` — readiness algorithm and prose (`:87-107`), derived-state
  table (`:233-245`), Ship phase artifact (`:225`).
- `.opencode/agent/status.md` — `<readiness_algorithm>` block, prose
  contradiction (`:119-122`), inputs (`:63-64`), process (`:75`).
- `.opencode/command/status.md` — inputs and algorithm restatement (`:11`,
  `:17-22`).
- `.opencode/agent/shipper.md` — `permission.edit` (`:4-5`), process step 6
  (`:89-90`).
- `.opencode/command/ship.md` — final bullet (`:24-25`).
- `docs/artifact-conventions.md` — `ship.md` section heading/one clause (`:397`).
- `README.md` — Agents table `shipper` row (`:173`).
- `work/0002-agentic-roadmaps/verify-tests.sh` — assertions at `:76-84`,
  `:133`, `:219-222`, `:233-240`, plus a new assertion block.
- `.opencode/agent/product.md` — no change (already by reference).

## Backward compatibility and migrations

- **Existing `ship.md` files** (for example `work/0002-agentic-roadmaps/ship.md`)
  now satisfy shipped state by presence; the old "with PR URL" wording is a
  subset of presence, so nothing regresses.
- **Permission change is a widening** for `shipper` only; no other agent's block
  changes. `README.md` and doctor stay in agreement.
- **Historical artifacts under `work/**`** legitimately contain the old algorithm
  and the detected-PR text. The new assertion scans only an explicit candidate
  list of live surfaces and never `work/**`, so history is not rewritten and does
  not trip the guard.
- **`ship.md` "optional" wording** is reconciled: the artifact-conventions
  heading names it the shipped-state record; legacy items without one simply
  derive as `ship` (the accepted single-signal cost in the spec edge cases).
- **No migration step**; no state file, registry, or alloy introduced.

## Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
| ---- | ---------- | ------ | ---------- |
| Editing another shipped item's `verify-tests.sh` is treated as rewriting history or conflicts with `0002`'s frozen `verify.md`. | Medium | Medium | Change only executable assertions, never `verify.md`; call it out in the handoff; `0006` relocates the suite by design. |
| The "stated exactly once" assertion is brittle if a future file reuses the `satisfied(dep_local_id):` token. | Medium | Low | Scan an explicit candidate list, assert the exact single value `workflow.md`, and document the invariant here and in the commit. |
| A readiness surface silently keeps contradicting semantics (e.g. an old bullet not removed). | Medium | High | The new assertions grep every live surface for the detected-PR tokens and the approve-unshipped denial; run them before commit. |
| README `shipper` row and resolved grant drift, waking doctor's permission check. | Low | Medium | Update the README row in the same task as the frontmatter and verify with `/doctor`. |
| Making `ship.md` required breaks the suite's old "optional `ship.md`" expectations. | Medium | Low | T5 updates the affected derived-state assertions to the presence-based text. |
| The derived-state table still lets `request-changes` outrank `ship.md`. | Low | High | Move the `ship.md present` row above the review rows and assert the row text. |

## Test strategy

| Criterion | Level | Verification |
| --------- | ----- | ------------ |
| AC1 | static | Assertion block T5: `satisfied(dep_local_id):` in exactly one candidate file; status/command/product name "Dependencies and readiness". |
| AC2 | static + manual | Static: no surface denies approve-unshipped; workflow states `even if unshipped`. Manual: `/status` on `0003`'s parent reports `0001-state-model` ready via its `approve` verdict. |
| AC3 | static | Audit every readiness surface against the authority; new assertion greps for the contradicting grouping and detected-PR text. |
| AC4 | static | New assertion: no candidate surface matches the detected-PR tokens; derived-state rows keyed on `ship.md` presence. |
| AC5 | static | `fm shipper.md` grep for both `work/**` patterns; README row grep. |
| AC6 | static + manual | Static: `status.md` has no `gh` pattern and no PR step; readiness reference present. Manual: `/status` succeeds offline; no network command is issued. |
| AC7 | static + manual | Static: README `shipper` row matches the frontmatter. Manual: `/doctor` produces no `PERMISSION-TABLE-MISMATCH` / `PERMISSION-WORK-PATTERN` finding for `shipper`. |
| AC8 | static | Derived-state rows `ship.md` present → shipped, approve with no `ship.md` → ship; no state file. |
| AC9 | static (suite) | New `== AC9 ==` block passes. |
| AC10 | static (suite) | Full `bash work/0002-agentic-roadmaps/verify-tests.sh` exits 0 with `0 failed`. |
