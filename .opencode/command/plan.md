---
description: "Design a solution and break it into tasks from an approved spec, or create/decompose a work item at any depth. Usage: /plan <item-ref or initiative>"
agent: architect
---

Run the **Design** phase for the work item: $ARGUMENTS

Follow your Architect agent instructions exactly. In particular:

- Re-entry: read `work/<item-ref>/backtracks.md` for an entry whose target phase
  is `/plan` with no matching `## Resolution` (see `docs/workflow.md` → "Phase
  reversal (backtracking)" → "Re-entry"). If one is open, revise
  `design.md`/`tasks.md` for it, append a `## Resolution <n>` entry, clear the
  `stale:` marker on any artifact you own that you re-ran, and resume forward;
  with no open finding, plan as ordinary progression.
- Read the work item's `spec.md` first when the node has one, plus `AGENTS.md`,
  `docs/workflow.md` — especially "Where decomposition is authored and recorded",
  "Revising a decomposition", and "Plan publication", the writer authority — and
  `docs/artifact-conventions.md`.
- If `spec.md` exists and is ambiguous or wrong, take the `/plan`→`/spec` reverse
  edge: append a `## Finding <n>` entry to `work/<item-ref>/backtracks.md`
  (detecting `/plan`, target `/spec`, affected `spec.md`, `status: open`), mark the
  existing downstream artifacts (`design.md`, `tasks.md`, `verify.md`,
  `review.md`) `stale: spec`, do not edit `spec.md`, and end with
  `Next: /spec <item-ref>`.
- A work-item reference (`item-ref`) is `NNNN-slug` for a standalone item or
  `NNNN-slug/MMMM-slug` for a roadmap child; every `work/<item-ref>/` path
  resolves to that item's directory.
- Recon the affected code and its conventions. Delegate broad recon to the
  `scout` subagent.
- Select the planning path from the argument and the node's committed state: an
  existing `work/<item-ref>/manifest.md` (or the legacy `roadmap.md` artifact
  alias) selects **revise**; a node that decomposes and has no own `spec.md` — a
  `.gitkeep`-reserved child or a pure container — selects **author**, because a
  genuine single feature always has a `spec.md` from `/spec`; otherwise plan the
  single feature. The decomposition path needs no node `spec.md`, and writes none.
- **Create mode** — when the argument resolves to no existing `work/<item-ref>/`,
  create a brand-new top-level decomposing node exactly as the planning step's
  create path: reconnoitre `work/` so the request neither collides with nor
  duplicates an item, allocate the next top-level `NNNN` (the greatest 4-digit
  prefix ever committed under `work/`, plus one) and a 2–4 word kebab-case slug,
  author `work/<NNNN-slug>/manifest.md` carrying `phase: manifest`, and reserve
  each enumerated child as `work/<NNNN-slug>/<MMMM-slug>/.gitkeep` — writing **no
  child phase artifact**. A token shaped like `NNNN-slug` that resolves to no item
  is not an existing item and takes this path; the reconnoitre keeps a typo from
  silently creating a duplicate. When the request is really a single feature,
  recommend `/spec <feature>` and create nothing.
- **Decomposition path** — author or revise the node's manifest
  `work/<item-ref>/manifest.md` and reserve each child
  `work/<item-ref>/<MMMM-slug>/.gitkeep`, allocating each `MMMM` per the immediate
  parent and writing **no child phase artifact**, autonomously (no pre-write
  approval gate; the user reviews the committed artifact). The produced manifest
  must satisfy the manifest quality bar of `docs/artifact-conventions.md` →
  "`manifest.md` — the manifest of a decomposing node" by reference (six-column
  `Children`, acyclic `Depends on`, resolving `Canonical reference`, well-formed
  `conflicts-with`). A hybrid node also gets its own `design.md`/`tasks.md`; a pure
  container gets neither.
- **Single-feature path** — evaluate at least one real alternative, then write
  `work/<item-ref>/design.md` and `work/<item-ref>/tasks.md` using the templates
  in `docs/artifact-conventions.md`.
- Author the plan's declared conflict targets as the `conflicts-with` value in
  `design.md` frontmatter, using the grammar in `docs/workflow.md` → "Declared
  conflicts (`conflicts-with`)" (`—` when the plan declares none); do not restate
  that grammar.
- Ensure every acceptance criterion maps to at least one task, and every task has
  a `Verify:` step and its dependencies annotated.
- Run the design quality bar and set `status: final`.
- If a `plan/<ref>` pull request is denied, closed, or sent back for changes,
  re-run `/plan <item-ref>` to revise the plan and republish with
  `/ship plan <item-ref>` on the same branch (a new PR if the branch was pruned);
  never force-push. This plan-publication revision flow is not a backtrack.

If `$ARGUMENTS` is empty, ask which work item to plan, or list candidates by
reading `work/`. If a `spec.md` exists and is ambiguous or wrong, take the
`/plan`→`/spec` reverse edge above rather than designing from assumptions; a
missing `spec.md` alone selects the decomposition author path, not the reverse
edge — a `.gitkeep`-reserved child or a pure container has none.

Do not write any code. End with the handoff block whose `Next:` is
`/spec <item-ref>` if you took the `/plan`→`/spec` reverse edge; otherwise
`/ship plan <item-ref>` — the plan is published and merged before development
begins — and for a decomposing node also name `/spec <child-ref>` for each ready
child. The decomposition handoff reports the manifest and the reserved child
directories; the single-feature handoff reports `design.md` and `tasks.md`.
