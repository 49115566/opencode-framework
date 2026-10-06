---
feature: 0003-framework-quality-hardening/0007-config-hardening
phase: review
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Review — Default config safety and reproducibility

## Verdict

**approve** — the config/doc change matches the design line for line, every
acceptance criterion is met, and the only findings are low-impact documentation
wording that need not block merge.

## Diff and base

Commands used:

- `git merge-base HEAD origin/main` → `ff5a2faf3830d672d855fe7bbcd597a58ef568a0` (== `HEAD`; branch is `main`)
- `git status --short` / `git diff --stat` / `git diff` — the five product files are uncommitted working-tree changes
- Read directly (untracked, so absent from `git diff`): `work/0003-framework-quality-hardening/0007-config-hardening/{spec,design,tasks,verify}.md`, `verify-tests.sh`

The base is unambiguous: the work item is not on a branch; all product edits are
uncommitted on `main` at `ff5a2fa`, which equals `origin/main`.

Changed product files (5, exactly the design's "Affected areas" — no scope
creep): `opencode.json`, `docs/customization.md`, `README.md`,
`.opencode/agent/builder.md`, `.opencode/skill/browser-verification/SKILL.md`.

## Acceptance criteria

| Criterion | Result | Evidence |
| --------- | ------ | -------- |
| AC1 default agent `product`; enabled `primary`; edit limited to work artifacts | **met** | `opencode.json:5` = `product`; `.opencode/agent/product.md:3` `mode: primary`; `:5-8` edit `*: deny`, `work/**`, `**/work/**` allow; `product` not in `opencode.json:12-23` disabled built-ins |
| AC2 all live default-agent mentions agree; no file still says `builder` | **met** | `README.md:166` `primary (default)`, `:225` `(`product`)`; `builder.md:2` dropped `(default)`, `:20-21` attributed `/build`//`/fix` to routing. `rg` over `README.md`, `AGENTS.md`, `docs/**`, `.opencode/**` finds only routing/role `builder` mentions (`README.md:151,156,169`, `docs/customization.md:88`, command `agent: builder`), no default claim |
| AC3 one exact Playwright version; no floating tag; same version in docs | **met** | `opencode.json:42` `@playwright/mcp@0.0.83`; `docs/customization.md:183` and `.opencode/skill/browser-verification/SKILL.md:21` mirror it. Registry independently confirms `0.0.83` is published (`registry.npmjs.org/@playwright/mcp/0.0.83` → `"version":"0.0.83"`). No `latest`/`*`/`^`/`~` on any live surface |
| AC4 instructions exactly the three files; each quickstart-copied | **met** | `opencode.json:6-10` exactly `AGENTS.md`, `docs/workflow.md`, `docs/artifact-conventions.md`; `README.md:44` copies `AGENTS.md`, `:45` copies `docs/*.md` — all three guaranteed |
| AC5 each entry's purpose + total per-request cost stated | **met** | `docs/customization.md:17-42`; per-entry purpose and cost table with total `~9.3k tokens (~37 KB)` and stated measuring basis. Figures check out against actual sizes (7452 B + 16601 B + 13190 B ≈ 37.2 KB → ~9.3k tokens) |
| AC6 model docs: vision-capable, strongest, no overrides; no text-only-degradation claim | **met** | `docs/customization.md:121-127`, `README.md:232-234`. No live surface pairs `text-only` with degradation; only occurrence is the `visual.md` template field `docs/artifact-conventions.md:304` |
| AC7 no agent declares its own `model` override | **met** | `rg -n '^model:' .opencode/agent/` returns nothing across all 14 agents |
| AC8 config parses; default resolves without a disabled agent | **met** | `opencode.json` is well-formed and points at the enabled custom primary `product`; `verify.md` records `opencode debug config` and `opencode debug agent product` PASS. (I could not re-execute `opencode`; see "Not reviewed".) |

Edge cases: the merged-config, partial-copy, `small_model`-unchanged, and
no-vision-fallback cases are all satisfied by shipped text (`README.md:53-54`,
`docs/customization.md:191-193`, `opencode.json`). The supersession case is met
by `docs/customization.md:195-200`, which now makes bumping the pin the
sanctioned path and forbids restoring a floating tag — the prior pass's blocking
gap is fixed. The user-broken-default case is discussed under M3.

## Findings

### Blockers

None.

### Major

None.

### Minor

- **[M1] Overstated "exactly the files the adoption quickstart copies"** —
  `docs/customization.md:40-42`
  The quickstart copies `AGENTS.md`, `opencode.json`, `.gitignore`,
  `.opencode/{agent,command,skill}`, and all of `docs/*.md` (`README.md:43-45`),
  not only these three. As written the sentence claims the quickstart copies
  exactly three files, which is false. The intended meaning (these three
  instruction files are all guaranteed by the quickstart) is what AC4 needs.
  Recommendation: reword to "these three instruction files are all copied by the
  adoption quickstart, so every listed path exists in a freshly adopted
  repository."

- **[M2] `small_model` "tracks it" implies automatic derivation** —
  `docs/customization.md:125-126`
  `model` and `small_model` are independent config keys; both are set explicitly
  in `opencode.json:3-4`. An adopter who changes only `model` leaves
  `small_model` stale, so "which tracks it" is misleading.
  Recommendation: "change the global `model` and keep `small_model` equal to
  it."

- **[M3] A user-broken default is not explicitly surfaced by the documented
  validation loop** — `docs/customization.md:202-213`
  The spec edge case "Default agent disabled or renamed by a user" requires
  validation to surface the broken default. `opencode debug config` exits 0 for
  a `default_agent` naming a disabled agent (as `verify.md` records); the loop
  lists `opencode debug agent` but never says to confirm the configured default
  actually resolves. The shipped config is valid, so this is not merge-blocking,
  but one line closes a spec edge case the tester honestly flagged as
  PARTIAL/MANUAL.
  Recommendation: add `opencode debug agent <default_agent>` (or a sentence
  "confirm the `default_agent` name resolves and is not disabled") to the
  validation loop.

### Nits

- **[N1] README Agents table alignment** — `README.md:166`
  Inserting `primary (default)` widens one cell and misaligns the table's pipes.
  It still renders as valid Markdown; reflow the column for readability.
- **[N2] Missing space before a table pipe** — `docs/customization.md:37`
  `**~9.3k tokens (~37 KB)**|` is missing the conventional space before `|`;
  cosmetic only.

## Notes on the review

- **Scope:** the five-file diff maps exactly to the design's affected areas. No
  unrelated refactors, reformatting, dependency additions, secret material, or
  debug logging. The `SKILL.md` pin and `builder.md` wording changes are required
  by AC3/AC2, not scope creep.
- **Tests:** `verify-tests.sh` is thorough (51 assertions), includes targeted
  mutation evidence, and its supersession guard is a real strengthening rather
  than a word-presence check. No test was weakened, skipped, or deleted field
  (the one `0001-state-model` failure is independently attributed to that item's
  committed-artifact snapshot checks, not this diff).
- **Historical-record scoping (AC2/AC6):** excluding committed `work/**`
  artifacts from "no file" is the correct reading — the artifact contract
  forbids rewriting another phase's artifact, and `verify.md` discloses the
  residual historical mentions. I accept this interpretation.

## Not reviewed

- I could not execute `verify-tests.sh` or `opencode debug ...` in this pass:
  the review sandbox's bash allowlist permits only read-only `git`/`ls`/`cat`/
  `rg`/`find`. I instead verified the objectively checkable claims statically
  (registry pin, JSON values, agent frontmatter, grep sweeps, instruction-file
  sizes). The tester's recorded PASS results are consistent with that evidence.
- The domain fact that `deepseek/deepseek-flash` is vision-capable and the
  strongest shipped option is taken from the spec's "Verified context" (user
  clarification); I did not independently confirm model capabilities.
