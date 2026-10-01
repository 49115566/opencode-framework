---
description: "Inspect a running frontend in a real browser for layout, interaction, responsiveness, and accessibility. Usage: /visual [url or slug]"
agent: visual
---

Run the **Visual QA** pass for: $ARGUMENTS

Follow your Visual QA agent instructions exactly. In particular:

- Read the work item's `spec.md` and `design.md` for the UI surface, and load
  the `browser-verification` skill for the method.
- Confirm the Playwright browser tools are available; if not, tell the user how
  to enable the `playwright` MCP server and stop.
- Resolve the target URL (from `AGENTS.md` or the argument) and make sure the app
  is serving. Start the documented dev server in the background only if needed,
  and stop it when done.
- Inspect structure with accessibility snapshots, behavior with real
  interactions, and appearance with screenshots. Check console errors, failed
  network requests, the loading/empty/error/success states, and at least mobile,
  tablet, and desktop widths.
- Save screenshots under `work/<slug>/visual/` and write
  `work/<slug>/visual.md` using the template in `docs/artifact-conventions.md`.

If `$ARGUMENTS` is empty, ask for the URL or work item, or list candidates from
`work/`. If the project has no frontend, say so and recommend skipping this
check. You are read-only on source: write only under `work/**`. End with the
handoff block.
