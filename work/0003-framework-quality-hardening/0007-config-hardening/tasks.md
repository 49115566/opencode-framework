---
feature: 0003-framework-quality-hardening/0007-config-hardening
phase: tasks
status: final
created: 2026-10-05
updated: 2026-10-05
notes: "Config/doc-only. Verification uses static shell assertions and the framework's own debug commands; no committed tests (owned by 0006). T1 done 2026-10-05. T2 done 2026-10-05. T3 done 2026-10-05. T4 done 2026-10-05. T5 done 2026-10-05. T6 done 2026-10-05: opencode debug config/agent product, pins, no ^model:, instructions all pass. Rework 2026-10-05: fixed the tester-reported EDGE-supersession gap — docs/customization.md now makes bumping the Playwright pin the sanctioned upgrade path; item suite 51/0."
parent: 0003-framework-quality-hardening
---

# Tasks — Default config safety and reproducibility

Ordered, dependency-aware. One task ≈ one focused commit.

- [x] **T1** — Pin the Playwright MCP version everywhere it is written. Change
      the command element in `opencode.json:42` from `@playwright/mcp@latest` to
      `@playwright/mcp@0.0.83`, the same literal in
      `docs/customization.md:148`, and the copied example in
      `.opencode/skill/browser-verification/SKILL.md:21`. [AC3]
      Verify: `rg -n '@playwright/mcp' opencode.json docs/customization.md .opencode/skill/browser-verification/SKILL.md`
      shows `@0.0.83` in all three and no `latest`, `*`, `^`, or `~`; then
      `npx -y @playwright/mcp@0.0.83 --help` resolves (exits without a fetch
      error).

- [x] **T2** — Change the shipped default agent. Set `"default_agent":
      "product"` in `opencode.json:5`. Do not touch `model`, `small_model`,
      `instructions`, the disabled built-ins, or any permission block. [AC1]
      Verify: `rg -n '"default_agent"' opencode.json` prints `"product"`; with
      opencode restarted, `opencode debug agent product` resolves and shows
      `mode: primary` with `edit` granting `work/**` and `**/work/**` and no
      `disable`.

- [x] **T3** — Reconcile every default-agent mention with the config. Drop
      `(default)` from `.opencode/agent/builder.md:2` and rewrite the role
      sentence at `builder.md:20` so `/fix` is attributed to the command's
      routing, not to default status. In `README.md`, change the Configuration
      sentence at :225 to name `product`, and mark the `product` row of the
      Agents table (:166) `primary (default)`. [AC2]
      Verify: `rg -n 'default agent|\(default\)' README.md .opencode/agent`
      shows the default agent is `product` and no remaining claim that
      `builder` is the default; `rg -n 'Implementation agent' .opencode/agent/builder.md`
      no longer contains `(default)`.

- [x] **T4** — Document the always-loaded instruction set. Add an
      "Always-loaded instructions" subsection to `docs/customization.md` with a
      table listing `AGENTS.md`, `docs/workflow.md`, and
      `docs/artifact-conventions.md`, each entry's purpose, its approximate
      per-request token cost, and the total (~9.3k tokens / ~37 KB), plus the
      measuring basis. State that these are exactly the files the adoption
      quickstart copies. Add a one-sentence summary and link in the README
      Configuration paragraph. [AC4] [AC5]
      Verify: reading `docs/customization.md` yields a purpose and a cost for
      each of the three paths and a stated total; `rg -n 'AGENTS.md|workflow.md|artifact-conventions.md' docs/customization.md`
      lists all three; `rg -n 'instructions' opencode.json` still shows exactly
      the same three paths, and each path appears in the quickstart copy lines
      `README.md:40-47`.

- [x] **T5** — Document the model capability and the no-override decision.
      Extend the "Changing models" section of `docs/customization.md` (:88-92)
      to state that the shipped global default `deepseek/deepseek-flash` is
      vision-capable and the strongest shipped option, that agents intentionally
      inherit it, that no agent declares a `model:` override, and that `/visual`
      and `/reviewer` need none. Add a matching sentence to the README
      Configuration paragraph. [AC6] [AC7]
      Verify: `docs/customization.md` states vision capability, "strongest",
      and no `/visual`/`/reviewer` overrides; `rg -n '^model:' .opencode/agent/*.md`
      returns nothing (no per-agent override); `rg -n 'text-only' README.md docs/`
      returns only the `visual.md` template field in
      `docs/artifact-conventions.md:304`, not a claim that QA degrades.

- [x] **T6** — Final validation sweep. Run the acceptance checks below and
      report; if one fails, fix the line owned by the corresponding task and
      re-run. [AC1] [AC3] [AC4] [AC7] [AC8] [depends: T1, T2, T3, T4, T5]
      Verify, with opencode restarted:
      `opencode debug config` parses without error;
      `opencode debug agent product` resolves the default and names no disabled
      agent; `rg -n '"default_agent"' opencode.json` is `product`;
      `rg -n '@playwright/mcp@' opencode.json docs/customization.md .opencode/skill/browser-verification/SKILL.md`
      shows one identical exact version and no floating tag;
      `rg -n '^model:' .opencode/agent/*.md` is empty; and
      `rg -n '"instructions"' -A4 opencode.json` lists exactly the three
      contract files.
