---
name: workflow-lifecycle
description: The opencode-framework development lifecycle. Use when unsure which phase or command comes next, what artifact a phase produces, how phase state is derived, or how a handoff should be reported. Triggers on "next step", "what now", "where are we", /status, /spec, /plan, /build, /test, /review, /ship.
---

# Workflow lifecycle

`docs/workflow.md` is the source of truth; this skill is the quick operational
view. If they disagree, follow `docs/workflow.md` and correct this file.

## Phase order

```
/spec → /plan → /build → /test → /review → /ship
```

Each phase reads the previous artifact and writes its own, under
`work/<item-ref>/`. Artifacts are **committed working state**, so a fresh clone,
a teammate, and CI derive the same phase; state is derived from those files,
never recorded separately.

A **roadmap** is a parent item at `work/<NNNN-slug>/roadmap.md` whose children
are nested at `work/<NNNN-slug>/<MMMM-slug>/`. Address a child by its
**canonical reference** — `NNNN-slug/MMMM-slug` — which resolves to
`work/<NNNN-slug>/<MMMM-slug>/`. A one-segment reference (`NNNN-slug`) is a
standalone item and behaves exactly as before.

## Which command now?

```
Broad, multi-feature initiative? → /roadmap <initiative> | /roadmap revise <item-ref>
No spec.md?                      → /spec <feature or problem description | item-ref>
spec.md, no design.md?           → /plan <item-ref>
design.md, tasks.md unchecked?   → /build [item-ref or task-id]
all tasks checked, no verify.md? → /test [item-ref]
UI work, before /review?         → /visual [url or item-ref]   (optional)
verify.md, no review.md?         → /review [item-ref]
review.md verdict request-changes→ /build [item-ref or task-id]   (rework blockers)
review.md verdict approve, no ship.md?→ /ship [item-ref]
build finds the design wrong?    → /plan <item-ref>   (reverse edge; record the finding)
plan finds the spec wrong?       → /spec <feature or problem description | item-ref>   (reverse edge; record the finding)
open finding targets /plan?      → /plan <item-ref>   (re-entry; revise and resolve)
open finding targets /spec?      → /spec <feature or problem description | item-ref>   (re-entry; revise and resolve)
open challenge on a review finding?→ /review [item-ref]   (adjudicate; respond in challenges.md)
open challenge on a verify defect?→ /test [item-ref]   (adjudicate; respond in challenges.md)
/test defect is a design fault?  → /plan <item-ref>   (reverse edge; record the finding)
/test defect is a spec fault?    → /spec <feature or problem description | item-ref>   (reverse edge; record the finding)
plan/<ref> PR denied/changes-requested?→ /plan <item-ref>   (re-run; republish with /ship plan <item-ref>)
ship.md present but PR denied/closed/changes-requested?→ /ship recall <item-ref> <phase>   (recall; revoke and re-enter)
Verified /fix complete?          → /ship fix   (explicit request; shipper lands it)
Declared plan conflicts?         → /conflicts [item-ref]   (read-only, advisory)
Blocked child (dependency unmet)?→ wait, or override explicitly; /status [item-ref]
Unclear?                         → /status [item-ref]
```

## Derived states

`docs/workflow.md` → "Derived state" is the authority; this is the quick view.
The Phase column mirrors that table's Phase cell: the base phases (`not started`,
`spec`, `design`, `build`, `test`, `review`, `ship`, `shipped`, `roadmap`) plus
these derived labels.

- `P (backtracked)` — the earliest `stale:` marker across the item's artifacts
  names phase `P`. The marked artifact is not the item's current phase artifact
  and is never read as a satisfied downstream prerequisite.
- `P (reopened)` — the item's `ship.md` carries a `reopened:` marker naming phase
  `P`. The shipped signal is revoked: the item derives `P` and does not satisfy
  its dependents until it re-ships.
- `build (rework)` — the existing `review.md` verdict `request-changes` row. It
  is distinct from `backtracked` and is not a second rework state.
- `challenged (blocked)` — an open `challenges.md` challenge (a `Challenge <n>`
  with no matching `Response n`/`Withdrawal n`) on an item **that has no
  `ship.md`**. The item is blocked from advancing or shipping until the challenge
  is adjudicated or withdrawn.

The `challenged` overlay applies to **unshipped items only**. A `ship.md`-present
item derives `shipped` (or `P (reopened)` when recalled) and its open challenge is
out-of-scope for a challenge, because post-ship reversal is recall's domain
(`/ship recall`); no shipped item is ever derived `challenged`. The
`stale:`/`reopened:` structural states are evaluated before the challenged
overlay, which is evaluated before the artifact-presence and verdict rows. A
`stale: roadmap` token maps to `spec`. `/status` adds a per-item Notes line naming
the target phase and affected upstream artifact and the invalidated downstream
artifacts (or `none`), the recall, or the open challenge; readiness is unchanged —
a recalled dependency does not satisfy a dependent, while a non-recalled `ship.md`
presence and an `approve` verdict still do (`docs/workflow.md` → "Dependencies
and readiness").

## Handoff block

End every phase with:

```
Done: <artifacts by path>
Checks: <commands run and results>
Next: <exact command, e.g. /plan 0001-add-dark-mode>
Blockers: <or none>
```

## Rules that keep the workflow honest

- Only the owning phase writes its artifact. Never rewrite another phase's file.
- Never skip a phase silently. If the user asks to skip, note it in the next
  artifact's frontmatter `notes`.
- Never start downstream work to "help". If upstream is broken, record the
  finding and take the sanctioned reverse transition (`docs/workflow.md` →
  "Phase reversal (backtracking)"), then hand off `Next: /plan <item-ref>` or
  `Next: /spec <item-ref>`.
- Only the `shipper` commits, and only on `/ship` or explicit request: an
  approved work item on `/ship <item-ref>`, or a verified fix on `/ship fix`.
  Every other agent never writes git.
- A shipped item whose PR is denied, closed, or sent back for changes (or whose
  PR was never opened, or whose branch was abandoned) is not a dead end: the
  maintainer invokes `/ship recall <item-ref> <phase>` (`spec | design | build`),
  which records the finding, revokes the shipped signal with the `reopened:`
  marker without deleting the historical `ship.md`, marks the downstream
  artifacts `stale:`, and re-enters that phase until the item re-ships.
- Trivial fixes use `/fix`; new behavior uses the full lifecycle. A verified fix
  lands through `/ship fix` (no review artifact and no `ship.md`); when unsure,
  ask.

## Choosing the track

| Situation                                       | Track            |
| ----------------------------------------------- | ---------------- |
| Typo, one-liner, no behavior change             | `/fix`           |
| Defect with a known correct behavior            | `/fix`           |
| New feature, behavior change, public interface  | Full lifecycle   |
| Ambiguous scope                                 | Ask the user     |
