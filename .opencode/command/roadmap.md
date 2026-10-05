---
description: "Decompose a multi-feature initiative into a roadmap and nested child work items. Usage: /roadmap <initiative>"
agent: roadmap
---

Run the **Roadmap** phase for the following initiative:

$ARGUMENTS

Follow your Roadmap agent instructions exactly. In particular:

- Read `AGENTS.md`, `docs/workflow.md` → "Roadmaps", and
  `docs/artifact-conventions.md` → "Work item references" and the `roadmap.md`
  template first.
- Recon existing work: list `work/` and scan `work/*/roadmap.md` and
  `work/*/spec.md` titles so you do not collide with or duplicate an initiative.
- Decompose the initiative into child features with stable local ids, scope
  sufficient to author a spec later, canonical references, and intra-roadmap
  dependencies. Never store a self-dependency or a cycle.
- Write `work/<NNNN-slug>/roadmap.md` using the template in
  `docs/artifact-conventions.md`, allocating the next `NNNN` and a kebab-case
  slug, and create `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` for every child.
- Run the quality bar and set `status: final`.

This run is **autonomous**: produce the roadmap artifact and the child directory
skeletons without a pre-write approval gate. Write no child specs and perform no
child phase work.

If `$ARGUMENTS` is empty, ask the user for the initiative before doing anything
else and create nothing. If the request is really a single feature, recommend
`/spec <feature>` instead of creating a one-child roadmap unless the user
insists.

End with the handoff block.
