---
name: browser-verification
description: "Use ONLY when verifying a user-facing web UI in a real browser — layout, responsiveness, interaction states, accessibility, console/network errors, or visual polish. Triggers on frontend, UI, page, screen, layout, CSS, Tailwind, responsive, viewport, screenshot, browser, Playwright, accessibility, console error. Do not use for backend-only or non-visual tasks."
---

# Browser verification

Automated tests prove behavior; they do not prove that a page *looks* right or
that a real browser renders it without errors. Use a browser to check the parts
assertions cannot.

## Tooling

**Preferred: the Playwright MCP server.** It exposes an accessible, structured
view of the live page and drives a real browser. Enable it in `opencode.json`:

```json
"mcp": {
  "playwright": {
    "type": "local",
    "command": ["npx", "-y", "@playwright/mcp@latest", "--headless", "--isolated"],
    "enabled": true
  }
}
```

`--headless` keeps it from stealing focus; `--isolated` avoids persisting a
profile. After changing this, restart opencode. If the `browser_*` tools are not
present, the server is not enabled.

Key tools: `browser_navigate`, `browser_snapshot` (accessibility tree —
**prefer this over screenshots for structure and actions**),
`browser_take_screenshot`, `browser_console_messages`, `browser_network_requests`,
`browser_resize`, `browser_emulate_media`, `browser_evaluate`, `browser_click`,
`browser_type`, `browser_hover`, `browser_wait_for`, `browser_find`.

**Alternative: the Playwright test runner.** For durable regression checks, write
Playwright tests instead (or as well) — that belongs to the `tester` agent. The
MCP is for interactive inspection; the runner is for repeatable assertions.

## Method

1. **Ensure a server is running.** Check `AGENTS.md` for the dev command and any
   URL. If nothing responds, start the documented server in the background and
   wait for it to be ready:
   `npm run dev > /tmp/dev-server.log 2>&1 &` then poll the URL. Stop it when
   done. Ask the user if the command or port is unknown.
2. **Snapshot first.** Navigate, then take an accessibility snapshot. It is
   cheaper, deterministic, and reveals structure, roles, and names that a
   screenshot hides. Reach for screenshots to judge appearance.
3. **Read the console and network.** List console messages at `error` level, and
   network requests. An uncaught exception or a failed core request is a defect
   even if the page "looks fine."
4. **Walk the states.** For each UI-relevant acceptance criterion, trigger the
   real flow. Then force the states people forget: loading, empty, error,
   success, disabled, and long/extreme content.
5. **Resize.** Check at least 375×812 (mobile), 768×1024 (tablet), and
   1440×900 (desktop). Look for horizontal overflow, clipped or overlapping
   text, and controls that become unreachable.
6. **Check accessibility.** Semantic roles/names from the snapshot, labels on
   inputs, `alt` on images, keyboard focus order and a visible focus indicator,
   and color contrast on key text. Compute contrast with `browser_evaluate` on
   the relevant elements.
7. **Capture evidence.** Save screenshots per viewport and per defect into
   `work/<NNNN-slug>/visual/`. Keep the snapshot and logs for the worst states.
8. **Clean up.** Stop any server you started.

## Vision-aware judgement

- If the model accepts image input, view screenshots and judge alignment,
  spacing, contrast, typography hierarchy, and consistency directly. The
  Playwright accessibility tree still drives interactions — screenshots are for
  judgement.
- If not, rely on the snapshot plus geometry and styles from `browser_evaluate`,
  and save screenshots for humans. State which mode you used.

## Starting from a URL or a slug

- Given a URL: inspect directly.
- Given a work item: read its spec/design for the UI surface and criteria, then
  inspect the routes they describe.
- Neither: ask for the URL, or find the dev script and confirm.

## Quality checklist

- [ ] Server reachable; URL and how it was started recorded.
- [ ] Console errors and failed core requests checked.
- [ ] Loading, empty, error, success, and long-content states exercised.
- [ ] Three viewports checked for overflow/clipping/overlap.
- [ ] Labels, focus order, and contrast checked.
- [ ] Every UI-relevant acceptance criterion marked met / partial / not met.
- [ ] Evidence saved under `work/<slug>/visual/` and referenced in the artifact.
- [ ] Any server you started is stopped.

## Common pitfalls

- Judging only the happy-path render and missing the error/empty states.
- Trusting a screenshot alone: pixel changes hide broken structure. Use the
  snapshot for structure and actions.
- Testing one width. Most layout defects are responsive.
- Reporting taste as a defect. Separate defects (blockers/majors) from polish
  (minors/nits), consistent with the `code-review` severity model.
- Leaving a dev server running in the background.
