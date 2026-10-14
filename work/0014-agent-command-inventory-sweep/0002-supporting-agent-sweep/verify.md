---
feature: 0014-agent-command-inventory-sweep/0002-supporting-agent-sweep
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Verification — Supporting-agent recursive sweep

## Scope of the change under test

A prose-only sweep of three supporting-agent prompts against an uncommitted
working tree (base `HEAD` = `abc19a5`, the `plan/...0002-supporting-agent-sweep`
merge): `.opencode/agent/status.md`, `.opencode/agent/visual.md`, and
`.opencode/agent/scribe.md`. No runtime code exists; the "implementation" is
prompt wording, so every acceptance criterion below is verified by static
inspection of the live prompts plus the committed suite. This matches the
design's Test strategy ("No new committed test is added"), which the spec's
Non-goals and AC13 make binding.

No `challenges.md` exists for this item, so there was no open challenge to
adjudicate.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 503 passed, 0 failed, 0 skipped`; exit 0. The suite reads the live prompts, so it exercised the uncommitted changes. |
| `grep -nF 'containing `manifest.md`' .opencode/agent/status.md` | PASS | `48:- A directory containing `manifest.md` is a **decomposing node** …` (AC1). |
| `grep -nF 'container phase `manifest`' .opencode/agent/status.md` | PASS | `55: … derives the container phase `manifest`.` (AC2). |
| `grep -nF 'stale: manifest' / 'stale: roadmap' .opencode/agent/status.md` | PASS | Both on line 122: "Map both `stale: manifest` and its retained legacy alias `stale: roadmap` to `spec`." (AC3). |
| `grep -nF 'the `manifest.md` template' .opencode/agent/status.md` | PASS | `91: … the `manifest.md` template (the Children table contract; `roadmap.md` is the retained legacy alias)` (AC4). |
| `grep -nF "a nested child's own \`design.md\` declaration" .opencode/agent/status.md` | PASS | `248` (AC5). |
| `sed -n '330,332p' .opencode/agent/status.md` | PASS | Base phases end `… `shipped`, `manifest`;` — no `roadmap` (AC6). |
| `grep -nF 'Manifest 0002-agentic-roadmaps' / 'phases: manifest 1' .opencode/agent/status.md` | PASS | Lines 311–312; example phase column at 300–301 reads `manifest` (AC7). |
| `grep -nF 'at any depth, per `docs/artifact-conventions.md` → "Work item references"' .opencode/agent/visual.md` | PASS | Line 60; `grep -nF 'for a roadmap child'` returns nothing (AC8). |
| `grep -nF 'canonical reference' .opencode/agent/scribe.md` | PASS | Line 44, within `<process>` step 1 beside `work/<item-ref>/<file>` (AC9). |
| `grep -rnF 'roadmap' .opencode/agent/scout.md .opencode/agent/ask.md .opencode/agent/bootstrap.md` | PASS | No matches; `git diff --name-only` lists none of them (AC10). |
| Protect-block diff (frontmatter / `permission:` / `<handoff>` extracted from `HEAD` vs worktree, compared) | PASS | All UNCHANGED for all three prompts; the only `<rules>` change is `status.md` lines 337–340, the sanctioned alias/manifest wording (phase behavior identical) (AC11). |
| `grep -niE 'roadmap' .opencode/agent/status.md .opencode/agent/visual.md .opencode/agent/scribe.md` | PASS | Every hit is either a legacy-labelled alias or an in-example identifier; `visual.md`/`scribe.md` have zero hits (AC12). |
| `git diff --name-only` | PASS | Exactly `.opencode/agent/{status,visual,scribe}.md` + `.../tasks.md` (AC13). |
| Pinned-literal greps (see AC14) | PASS | All six literals present verbatim (AC14). |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — `status` detects a decomposing node by `manifest.md` with `roadmap.md` labelled legacy | static: `grep -nF 'containing `manifest.md`'`; `grep -niE 'roadmap'` audit (`status.md:48`, `50`, `54`, `106`, `132`, `342`) | PASS |
| AC2 — container phase is `manifest`, never `roadmap` | static: `grep -nF 'container phase `manifest`'` (`status.md:55`); phase-usage grep `phase .roadmap`/`` `roadmap` `` returns nothing | PASS |
| AC3 — `stale: roadmap` paired with `stale: manifest`, both → `spec`, legacy labelled | static: `grep -nF 'stale: manifest'` + `'stale: roadmap'` both on `status.md:122`; no second mapping/derived label introduced | PASS |
| AC4 — names the `manifest.md` template (legacy alias labelled) | static: `grep -nF 'the `manifest.md` template'` (`status.md:91`) | PASS |
| AC5 — `DRIFT-FACT` says "a nested child's own `design.md` declaration" | static: `grep -nF "a nested child's own \`design.md\` declaration"` (`status.md:248`); `grep -nF 'roadmap child'` returns nothing | PASS |
| AC6 — base-phase list contains `manifest`, not `roadmap` | static: `sed -n '330,332p'` | PASS |
| AC7 — output example uses `manifest` phase/tally/summary, keeps identifiers | static: `status.md:300–301` phase column = `manifest`; `311–312` = `Manifest …` / `phases: manifest 1`; identifiers `0002-agentic-roadmaps`, `0001-roadmap-model` retained | PASS |
| AC8 — `visual.md` states canonical recursive form, no "for a roadmap child" | static: `grep -nF 'at any depth … "Work item references"'`; negative grep | PASS |
| AC9 — `scribe.md` pairs `work/<item-ref>/<file>` with the canonical reference | static: `grep -nF 'canonical reference'` (`scribe.md:44`) | PASS |
| AC10 — `scout`/`ask`/`bootstrap` carry no `roadmap` and are unchanged | static: `grep -rnF 'roadmap'` (no matches); `git diff --name-only` (absent) | PASS |
| AC11 — frontmatter/`permission`/`<handoff>` and phase behavior unchanged | diff: block-extraction comparison of `HEAD` vs worktree | PASS |
| AC12 — every remaining `roadmap.md`/`stale: roadmap` is legacy-labelled; none is a current phase/spelling | static: full `grep -niE 'roadmap'` audit of the three prompts | PASS |
| AC13 — only the three prompts + item artifacts changed | static: `git diff --name-only`; no untracked files (`git status --porcelain`) | PASS |
| AC14 — suite green + pinned phrases survive | integration: `bash tests/run.sh` → 503/0/0; six pinned-literal greps all FOUND | PASS |

## Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Legacy item still reportable (`roadmap.md`, `stale: roadmap`) | `status.md:50,54,92,106,122,132,342` retain and label both | PASS |
| Mixed stale tokens — no second mapping/derived label | `status.md:122` maps both to `spec` only | PASS |
| Pinned phrases survive rewording | AC14 greps: `A child in a cycle is never \`ready\``, `CYCLIC-DEP`, `informational and never fatal`, flattened `members of a cycle are never reported`, `Dependencies and readiness`, `## Declared-conflict check` all present | PASS |
| Hybrid node precedence (own artifacts first) survives | `status.md:53–56` keeps "its own phase artifacts first; only a node with a manifest … derives the container phase `manifest`" | PASS |
| Empty/clean prompts untouched | AC10 | PASS |
| Example vs. live claim — identifiers kept, no `roadmap` phase | `status.md:300–317` phase column/tally/summaries use `manifest`; identifiers retained | PASS |
| Nested child at any depth | `visual.md:58–60` and `scribe.md:43–46` say "nested … at any depth" | PASS |

## Gaps and residual risk

- **No committed automated test guards this sweep, by design.** The spec's
  Non-goals and AC13 forbid touching `tests/` or adding fixtures/guards, so no
  test was added; adding one would itself violate AC13 and expand the changeset.
  Regression protection for the swept wording is therefore the static checks
  recorded above plus the suite's pinned-phrase assertions. If a future edit
  re-introduces `roadmap` as a current phase, only the pinned-phrase checks would
  fail; the wording-level ACs have no committed guard. This is a scope constraint
  of the item, not a defect.
- **Working tree is uncommitted and the local branch is 4 commits behind
  `origin/main`** (sibling `plan/…` merges). Verification ran against the working
  tree, which is the correct implementation state; the shipper's pre-ship
  reconcile merges the default branch forward. Not a defect for this phase.
- **Illustrative identifiers intentionally retain the `roadmap` token**
  (`0002-agentic-roadmaps`, `0001-roadmap-model`) inside the output example.
  AC12 and the spec's Edge cases explicitly exempt them; a careless reader could
  confuse them, but they are not `roadmap.md`/`stale: roadmap` tokens.
- **The paired `/status` command prompt** still carries the retired vocabulary,
  but it is explicitly out of scope here (owned by sibling `0003-command-sweep`);
  it is not a defect of this item.
