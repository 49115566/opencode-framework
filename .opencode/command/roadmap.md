---
description: "Decompose a multi-feature initiative into a roadmap and nested child work items, or revise an existing roadmap in place. Usage: /roadmap <initiative> | /roadmap revise <item-ref>"
agent: roadmap
---

Run the **Roadmap** phase for: $ARGUMENTS

Follow your Roadmap agent instructions exactly. The argument grammar is:

```
/roadmap <initiative>       -> create mode; decompose a new initiative into a
                               parent roadmap and its child directory skeletons
/roadmap revise <item-ref>  -> revise mode; revise an existing parent roadmap in
                               place
(empty)                     -> ask for the initiative and create nothing
```

**Create mode** (`/roadmap <initiative>`):

- Read `AGENTS.md`, `docs/workflow.md` → "Roadmaps" and "Revising a roadmap", and
  `docs/artifact-conventions.md` → "Work item references" and the `roadmap.md`
  template first.
- Recon existing work: list `work/` and scan `work/*/roadmap.md` and
  `work/*/spec.md` titles so you do not collide with or duplicate an initiative.
- Decompose the initiative into child features with stable local ids, scope
  sufficient to author a spec later, canonical references, and intra-roadmap
  dependencies. Never store a self-dependency or a cycle.
- Optionally declare per-row conflicts: each row may name the targets it expects
  to collide with in its `conflicts-with` cell, using the `ConflictTargetList`
  grammar in `docs/workflow.md` → "Declared conflicts (`conflicts-with`)", or `—`
  when the row declares none. Declarations are advisory — they never change
  `Depends on` or a child's readiness.
- Write `work/<NNNN-slug>/roadmap.md` using the template in
  `docs/artifact-conventions.md`, allocating the next `NNNN` and a kebab-case
  slug, and create `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` for every child.
- Run the quality bar and set `status: final`.

**Revise mode** (`/roadmap revise <item-ref>`):

- `<item-ref>` must resolve to an existing `work/<item-ref>/roadmap.md`; a
  reference that is not a roadmap parent is refused, because revise mode revises
  a parent and never creates one.
- Load the triggering child's `backtracks.md` finding when present, then apply the
  four operations of `docs/workflow.md` → "Revising a roadmap" in one pass:
  re-scope, add, withdraw, and re-sequence. Allocate any new local `MMMM` from the
  parent's committed history, validate the graph, and recompute `## Sequencing`.
- Mark each affected existing unshipped child's phase artifacts `stale: roadmap`,
  record the withdrawal and revision note under `## Open issues`, and append the
  triggering child's resolution entry to its `backtracks.md`.
- Refuse to re-scope or re-sequence a shipped child (`ship.md` present) and
  surface the conflict instead. A request that changes nothing is a no-op and
  modifies no file.
- Write only the parent `roadmap.md`, plus the triggering child's `backtracks.md`
  resolution entry and new child `.gitkeep` skeletons. Write no child phase
  artifact.

Both modes are **autonomous**: produce or revise the roadmap artifact and the
child directory skeletons without a pre-write approval gate; the user reviews the
committed artifact after the fact. Write no child specs and perform no child phase
work.

If `$ARGUMENTS` is empty, ask the user for the initiative before doing anything
else and create nothing. If the request is really a single feature, recommend
`/spec <feature>` instead of creating a one-child roadmap unless the user
insists.

End with the handoff block.
