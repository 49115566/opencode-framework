---
description: "Deprecated alias for the planning step (`/plan`). Create a brand-new top-level decomposition or revise an existing one at any depth. Usage: /roadmap <initiative> | /roadmap revise <item-ref>"
agent: roadmap
---

Run the **Roadmap** phase for: $ARGUMENTS

`/roadmap` is the thin **deprecated alias** for the planning step (`/plan`,
`architect`). The writer contract is stated once in `docs/workflow.md` → "Where
decomposition is authored and recorded", "Revising a roadmap", and "Plan
publication"; follow it and state no competing grammar. The argument grammar is:

```
/roadmap <initiative>       -> create mode; create a brand-new top-level
                               decomposing node (the next top-level NNNN) and
                               reserve its child directory skeletons
/roadmap revise <item-ref>  -> revise mode; revise an existing decomposition at
                               any depth in place
(empty)                     -> ask for the initiative and create nothing
```

**Create mode** (`/roadmap <initiative>`):

- Read `AGENTS.md`, `docs/workflow.md` → "Where decomposition is authored and
  recorded" and "Revising a roadmap", and `docs/artifact-conventions.md` → "Work
  item references", "Sequence allocation", and the `roadmap.md` template first.
- Recon existing work so you do not collide with or duplicate an initiative; when
  the request is really a single feature, recommend `/spec <feature>` instead of a
  one-child roadmap unless the user insists.
- Write `work/<NNNN-slug>/roadmap.md` (allocating the next top-level `NNNN` and a
  kebab-case slug) using the template, and create
  `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` for every enumerated child — and nothing
  else. Write no child phase artifact.
- Run the quality bar and set `status: final`.

**Revise mode** (`/roadmap revise <item-ref>`):

- `<item-ref>` must resolve to an existing `work/<item-ref>/roadmap.md`; a
  reference with no manifest is refused. Revise mode revises an existing
  decomposition at **any depth** and never creates one.
- Apply the four operations of `docs/workflow.md` → "Revising a roadmap"
  (re-scope, add, withdraw, re-sequence) in one pass, validate the final state, and
  mark affected existing unshipped children `stale: roadmap`. Refuse and surface a
  shipped child (`ship.md` present) rather than rewriting it; a request that
  changes nothing is a no-op and modifies no file.
- Record the triggering child's `backtracks.md` resolution entry and the revision
  note under `## Open issues`.
- Write only the node's `roadmap.md`, plus the triggering child's `backtracks.md`
  resolution entry and new child `.gitkeep` skeletons. Write no child phase
  artifact.

Both modes are **autonomous**: produce or revise the manifest and the child
directory skeletons without a pre-write approval gate; the user reviews the
committed artifact after the fact. Write no child phase artifact and perform no
child phase work.

If `$ARGUMENTS` is empty, ask the user for the initiative before doing anything
else and create nothing.

End with the handoff block.
