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
`work/<item-ref>/`. State is derived from files, never recorded separately.

A **roadmap** is a parent item at `work/<NNNN-slug>/roadmap.md` whose children
are nested at `work/<NNNN-slug>/<MMMM-slug>/`. Address a child by its
**canonical reference** — `NNNN-slug/MMMM-slug` — which resolves to
`work/<NNNN-slug>/<MMMM-slug>/`. A one-segment reference (`NNNN-slug`) is a
standalone item and behaves exactly as before.

## Which command now?

```
Broad, multi-feature initiative? → /roadmap <initiative>
No spec.md?                      → /spec <feature>
spec.md, no design.md?           → /plan <item-ref>
design.md, tasks.md unchecked?   → /build <item-ref>
all tasks checked, no verify.md? → /test
UI work, before /review?         → /visual [url or item-ref]   (optional)
verify.md, no review.md?         → /review
review.md verdict request-changes→ /build <item-ref>   (rework blockers)
review.md verdict approve, no PR?→ /ship
Blocked child (dependency unmet)?→ wait, or override explicitly; /status
Unclear?                         → /status
```

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
- Never start downstream work to "help". If upstream is broken, stop and report.
- Only the `shipper` commits, and only on `/ship` or explicit request.
- Trivial fixes use `/fix`; new behavior uses the full lifecycle. When unsure, ask.

## Choosing the track

| Situation                                       | Track            |
| ----------------------------------------------- | ---------------- |
| Typo, one-liner, no behavior change             | `/fix`           |
| Defect with a known correct behavior            | `/fix`           |
| New feature, behavior change, public interface  | Full lifecycle   |
| Ambiguous scope                                 | Ask the user     |
