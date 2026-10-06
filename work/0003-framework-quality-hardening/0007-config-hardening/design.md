---
feature: 0003-framework-quality-hardening/0007-config-hardening
phase: design
status: final
created: 2026-10-05
updated: 2026-10-05
notes: "Resolved the spec's deferred open question: pin @playwright/mcp@0.0.83 (exact published version verified from the npm registry). Config/doc-only change; no code, no new files, no committed tests (0006 owns the harness)."
parent: 0003-framework-quality-hardening
---

# Design — Default config safety and reproducibility

## Summary

Change `opencode.json`'s `default_agent` from `builder` to `product` (the
least-privilege lifecycle entry), pin the Playwright MCP command to the exact
published version `@playwright/mcp@0.0.83`, and add the missing rationale to the
configuration documentation: why the three always-loaded instruction files are
loaded and what they cost per request, and that the shipped default model is
vision-capable and the strongest option so `/visual` and `/reviewer` need no
per-agent overrides. Two stale "builder is the default" claims in `builder.md`
and `README.md` are corrected so every surface agrees with the config. No code,
no new files, no new dependency.

## Approach

All changes are to shipped configuration and documentation; nothing executes at
build time and there is no state to migrate. The work is five independent edits
plus a final validation sweep.

### 1. Default agent (`opencode.json:5`)

`"default_agent": "builder"` → `"default_agent": "product"`.

`product` already satisfies every structural constraint without modification:
`.opencode/agent/product.md:3` is `mode: primary`, its `permission.edit` block
(`product.md:5-8`) denies `*` and grants only `"work/**"` and `"**/work/**"`, and
it is not among the disabled built-in agents listed at `opencode.json:12-23`.
A fresh session therefore opens as a read-only-on-source agent that can only
write lifecycle artifacts. `/build` and `/fix` still route to `builder` via
their command `agent:` fields, so capability is unchanged — only the *initial*
agent is de-privileged.

### 2. MCP pin (`opencode.json:39-45`)

The command array element `"@playwright/mcp@latest"` becomes
`"@playwright/mcp@0.0.83"`. `0.0.83` is the exact version the npm `latest`
dist-tag resolves to (verified against the registry during design:
`dist.tarball` = `.../mcp-0.0.83.tgz`, `engines.node >= 18`). The
`npx -y` runner still fetches it on demand; pinning only removes the floating
tag. The same literal must appear in `docs/customization.md:148` and in the
`browser-verification` skill's copied example (`SKILL.md:21`) so no surface
still advertises `@latest`.

### 3. Always-loaded instruction rationale (`docs/customization.md`, `README.md`)

Add a short "Always-loaded instructions" subsection to
`docs/customization.md` that names the three entries and, for each, its purpose
and approximate per-request token cost, plus the total. The set is unchanged
(`AGENTS.md`, `docs/workflow.md`, `docs/artifact-conventions.md`) — it already
matches what the adoption quickstart copies (`README.md:40-47` copies
`AGENTS.md`, `opencode.json`, `.gitignore`, and `docs/*.md`). The section exists
to make the token tax a stated decision and to give drift a rationale to cite.
`README.md`'s Configuration paragraph gains a one-sentence summary that links
to it.

### 4. Model capability documentation (`docs/customization.md`, `README.md`)

Extend the "Changing models" section (`customization.md:88-92`) to state that
the shipped global default `deepseek/deepseek-flash` is vision-capable and the
strongest shipped option, that agents intentionally inherit it, and that
`/visual` and `/reviewer` need no per-agent `model:` overrides. It also records
that no agent declares an override, so the default is inherited everywhere. Add
a matching sentence to the README Configuration paragraph. This replaces the
roadmap's disproven text-only premise with the verified capability (spec
"Verified context", 2026-10-05).

### 5. Remove "builder is the default" claims

- `.opencode/agent/builder.md:2` — drop `(default)` from the description.
- `.opencode/agent/builder.md:20` — rewrite "You are the default agent, so you
  also handle lightweight bug fixes" to attribute `/fix` to the command's
  routing, not to default status.
- `README.md:225` — `the default agent (builder)` → `the default agent
  (product)`.
- `README.md:166` — mark the `product` row `primary (default)` in the Agents
  table so the configured value is discoverable where agents are listed.

`AGENTS.md:39` and other `builder` mentions are lifecycle/role references, not
default-agent claims, and are left untouched (surface sweep is `0009`). Artifacts
under `work/**` (notably the roadmap at `work/0003-framework-quality-hardening/
roadmap.md:65,98` and this item's own `spec.md`) are immutable historical records
that predate the change and are never rewritten by a later phase; AC2's "every
mention" is therefore read against shipped surfaces (config, agents, README,
docs), not the `work/` audit trail.

## Alternatives considered

- **Extend existing docs in place (chosen).** `docs/customization.md` is already
  the canonical "extend agents/skills/commands" reference and `README.md` its
  summary; the new rationale belongs in the existing model and MCP sections.
  Smallest diff, no new files for `/doctor` to inventory, no duplicate surface.
- **Create a dedicated `docs/configuration.md`.** Rejected: adds a fourth
  always-*available* doc that must be kept in sync with README and
  customization, increases the doctor inventory, and duplicates facts that have
  one natural home. The AC asks for the facts to be stated, not for a new file.
- **Add a new minimal-privilege "entry"/triage agent as the default.** Rejected:
  `product` is already the least-privilege primary lifecycle entry and the spec
  resolved to it; a new agent adds a config surface, another doctor inventory
  row, and a prompt to maintain for no capability gain. It also risks a default
  the lifecycle never designed for.
- **Pin via a root `package.json` + lockfile (or vendored MCP) instead of an
  exact `npx` version.** Rejected: the framework deliberately ships no runtime
  dependencies (`README.md:5-6`, customization "nothing to compile"), and
  adoption copies files rather than installing. A lockfile would add an install
  step to adoption and still need the command edited. The exact-version suffix
  is the smallest change that satisfies AC3 through the same runner.
- **Add per-agent `model:` overrides for `visual`/`reviewer`.** Rejected by spec
  and AC7: the global default already has vision and is the strongest option, so
  overrides would be redundant and would contradict AC7.

## Interfaces and data model

No runtime interfaces; the "schema" is `opencode.json` and the documented
config facts.

### `opencode.json` (exact edits)

```json
{
  "model": "deepseek/deepseek-flash",
  "small_model": "deepseek/deepseek-flash",
  "default_agent": "product",
  "instructions": ["AGENTS.md", "docs/workflow.md", "docs/artifact-conventions.md"],
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@0.0.83", "--headless", "--isolated"],
      "enabled": false
    }
  }
}
```

`model`, `small_model`, `instructions`, the disabled built-ins, and the baseline
`permission` block are unchanged.

### Documented facts (single source per fact)

| Fact | Canonical location | Mirrored (pointer/summary) |
| ---- | ------------------ | -------------------------- |
| Default agent = `product` | `opencode.json:5` | `README.md` Configuration + Agents table; `builder.md` corrected |
| Playwright pin = `0.0.83` | `opencode.json` command | `docs/customization.md` MCP snippet; `browser-verification/SKILL.md` example |
| Always-loaded set + purpose + cost | `docs/customization.md` | `README.md` Configuration (summary + link) |
| Default model vision + no overrides | `docs/customization.md` | `README.md` Configuration (summary + link) |

### Instruction rationale content (added to `docs/customization.md`)

| Path | Purpose | Approx cost |
| ---- | ------- | ----------- |
| `AGENTS.md` | Workflow contract every agent needs: lifecycle, artifact contract, guardrails, project profile | ~1.9k tokens (~7.5 KB) |
| `docs/workflow.md` | Authoritative lifecycle, phase entry/exit, derived state, routing | ~4.1k tokens (~16.6 KB) |
| `docs/artifact-conventions.md` | Exact frontmatter and templates for every artifact | ~3.3k tokens (~13.2 KB) |
| **Total per request** | | **~9.3k tokens (~37 KB)** |

Costs are approximate; the doc states the measuring basis (current file size
÷ ~4 bytes/token). Precise integers are not required by AC5 and would rot;
the total and the per-entry share are the decision-grade facts.

## Affected areas

- `opencode.json` — `default_agent` (:5) and the Playwright command (:42).
- `docs/customization.md` — "Changing models" (:88-92), "MCP servers"
  (:138-158), and a new "Always-loaded instructions" subsection.
- `README.md` — Configuration paragraph (:222-235), Agents table row for
  `product` (:166), and the builder-default sentence (:225).
- `.opencode/agent/builder.md` — description (:2) and role (:20); no permission
  or behavior change.
- `.opencode/skill/browser-verification/SKILL.md` — copied MCP example (:21).
- Not touched: `AGENTS.md` (profile/lifecycle owned by `0009`), any agent
  permission block (`0003-readonly-permissions`), any `work/**` artifact, and
  the committed test/CI area (`0006`).

## Backward compatibility and migration

- The default-agent change is a behavior change only for a *fresh* session. An
  adopter who already set `default_agent` explicitly and merges the shipped
  config keeps their value; `README.md:53-54` and the customization guidance
  already instruct merge-not-overwrite, and the new rationale makes the intended
  default explicit so a merge is conscious.
- The MCP pin is behavior-preserving: the same `npx` runner fetches a specific
  version instead of whatever `latest` pointed at. `enabled: false` still means
  zero runtime cost until `/bootstrap` opts in.
- No files are renamed or removed, so `/doctor` inventories and counts are
  unaffected.

## Risks and mitigations

- **Adopter keeps their own default and is surprised by ours** — likelihood
  medium / impact low. Mitigation: README and customization state the shipped
  default and the least-privilege rationale; merge-not-overwrite is already
  documented.
- **Pin later yanked or superseded** — likelihood medium / impact medium.
  Mitigation: documentation makes bumping the pin the sanctioned path (edit the
  one literal in `opencode.json` and its two mirror snippets); a floating tag is
  never the fix.
- **A stale "builder is default" mention survives somewhere** — likelihood low /
  impact medium. Mitigation: T7 greps the whole tree for default-agent claims and
  for `@latest`.
- **Token-cost figures drift as instruction files change** — likelihood medium /
  impact low. Mitigation: state approximate values and the measuring method;
  mark the section as needing a refresh when the instruction set changes.
- **`product` as default surprises adopters who expected `builder`** —
  likelihood medium / impact low. Mitigation: least-privilege is the point of
  the change; the README rationale and the untouched `/build` routing keep the
  path to building one command away.
- **The three MCP literals drift apart** — likelihood low / impact medium.
  Mitigation: T7 asserts one exact version across `opencode.json`,
  `customization.md`, and the skill; no `latest` anywhere.

## Test strategy

No committed test suite or CI is added — the spec assigns the committed harness
to `0006-committed-tests-ci`. Verification is static shell assertions plus the
framework's own debug commands, matching the existing `work/*/verify-tests.sh`
style but not committed here.

| Criterion | Verification level | How |
| --------- | ------------------ | --- |
| AC1 | integration | `opencode debug agent product` resolves as enabled `primary` with edit limited to `work/**` + `**/work/**`; config default is `product` |
| AC2 | static | `rg -n "default agent\|\(default\)"` over shipped surfaces (`README.md`, `.opencode/agent/`) shows no builder-as-default claim; README names `product`. `work/` records are historical and excluded |
| AC3 | static + install | one exact version in `opencode.json`, `customization.md`, `SKILL.md`; no `latest`/`*`/`^`/`~`; `npx -y @playwright/mcp@0.0.83 --help` resolves |
| AC4 | static | instructions array is exactly the three files; each appears in the quickstart copy lines `README.md:40-47` |
| AC5 | manual | reader finds per-entry purpose and total per-request cost in `docs/customization.md` |
| AC6 | manual | model docs state vision + strongest + no `/visual`/`/reviewer` overrides; `rg` finds no text-only-degradation claim in shipped docs |
| AC7 | static | no `model:` key in any `.opencode/agent/*.md` frontmatter |
| AC8 | integration | restart opencode, `opencode debug config` parses; `opencode debug agent` resolves the default without a disabled agent |
