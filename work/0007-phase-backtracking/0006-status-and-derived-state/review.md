---
feature: 0007-phase-backtracking/0006-status-and-derived-state
phase: review
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Review — Status, derived state, and readiness for backtracked items

## Verdict

**approve** — every acceptance criterion is met on inspection, the change is a
correct, additive reporting layer over the `0001`/`0002`/`0003`/`0005` state
shapes, and the only findings are two Minor consistency gaps and two Nits, none
of which is merge-blocking.

## Base and diff

- `git merge-base HEAD origin/main` → `f834067bd9a891578990f5bd23c606de5cbb54c8`
- `git rev-parse HEAD` → `f834067bd9a891578990f5bd23c606de5cbb54c8`
- `git rev-parse origin/main` → `f834067bd9a891578990f5bd23c606de5cbb54c8`

HEAD, `origin/main`, and the merge base are the same commit (the merged
`plan/0007-phase-backtracking-0006-status-and-derived-state` PR, `2dc002a` /
merge `f834067`). The implementation is therefore **uncommitted working-tree
state** plus one untracked artifact:

- `git diff --stat` (working tree vs `HEAD`): `.opencode/agent/status.md` (+104/-),
  `.opencode/command/status.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`,
  `docs/workflow.md`, `work/0007-phase-backtracking/0006-status-and-derived-state/tasks.md`
  (box ticks only).
- `git ls-files --others --exclude-standard`: `.../verify.md` (the tester
  artifact). No new file under `.opencode/` or `tests/`.
- `git diff --quiet -- README.md AGENTS.md template/AGENTS.md docs/artifact-conventions.md tests/ opencode.json`
  is clean (verified by reading the diff hunk paths; none appear in `git diff`).

There is no `work/<item-ref>/challenges.md`, so no challenge was open and no
adjudication was required.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — `stale:` → `P (backtracked)` | **met** | `docs/workflow.md:1035` (row), `:1050-1054` (first-two-rows rule), `:1084-1086` (report mirrors the cell). `.opencode/agent/status.md:101-104,244-247`; `.opencode/command/status.md:18-19,70-71`; `SKILL.md:63-65`. |
| AC2 — backtracked Notes name target phase + affected upstream + invalidated downstream (or `none`) | **met** | `docs/workflow.md:1087-1090`; `.opencode/agent/status.md:248-250`; `.opencode/command/status.md:72-76`; `SKILL.md:82-84`. |
| AC3 — `reopened:` → `P (reopened)`, not `shipped`, naming the recall | **met** | `docs/workflow.md:1036,1055-1059`; `.opencode/agent/status.md:102-103,251`; `.opencode/command/status.md:19,75-76`; `SKILL.md:66-68`. The stale-vs-reopened coexistence nuance is genuine but is explicitly scoped by the spec edge case ("Recalled item that also has stale markers" → report consistently with the earliest `stale:` marker) and recorded in `verify.md:95-105`. |
| AC4 — recalled dependency → `blocked`, named; non-recalled unchanged; no stored value | **met** | `docs/workflow.md:110-114` (reporting sentence) + `:87-102` (single algorithm unchanged); `.opencode/agent/status.md:160-166`; `.opencode/command/status.md:34-38`. `satisfied(dep_local_id):` still occurs exactly once across the live candidate set (`docs/workflow.md:90`). |
| AC5 — unshipped open challenge → `challenged (blocked)`, named, not ready | **met** | `docs/workflow.md:1037,1066-1075`; `.opencode/agent/status.md:103-107,252-254`; `.opencode/command/status.md:20-22,76-77`; `SKILL.md:71-74`. |
| AC6 — `request-changes` → `build (rework)`, distinct, no second rework state | **met** | `docs/workflow.md:1046,1060-1064` (row/literal byte-unchanged); `.opencode/agent/status.md:244-246,294`; `SKILL.md:69-70`. |
| AC7 — `ship.md`-present + open challenge → `shipped`, out-of-scope; authority states unshipped precondition | **met** | `docs/workflow.md:1037` (row precondition), `:1066-1082` (unshipped-only, out-of-scope, "no shipped item is ever derived `challenged`"); `.opencode/agent/status.md:105-107,255-256`; `.opencode/command/status.md:22-23`; `SKILL.md:76-79`. See **M2** for two sibling prose passages not updated. |
| AC8 — vocabulary includes `backtracked`/`reopened`/`challenged`; no new `phase`/code/state file | **met** | `.opencode/agent/status.md:292-294`; `.opencode/command/status.md:70-72`; `SKILL.md:59-74`. Labels appear only inside parenthesized Phase cells; `docs/artifact-conventions.md` frontmatter `phase` enum untouched. |
| AC9 — four surfaces consistent; authority referenced, not restated | **met** | All four surfaces carry the labels and Notes content and reference `docs/workflow.md` → "Derived state"/"Dependencies and readiness" by name; none forks the table or the algorithm. |
| AC10 — readiness once; deferrals by name; seven route literals + core artifact names unchanged | **met** | `git diff docs/workflow.md` shows the seven pinned route literals (`20-lifecycle.sh:60-78`) and the single `satisfied(dep_local_id):` are byte-identical; the diff only adds prose around them. |
| AC11 — `bash tests/run.sh` passes; pairings/inventories/signatures unchanged | **met** (evidence-based) | No command/agent/skill file added or removed (`git status`/`git diff --name-only`); frontmatter of `status.md` unchanged, so `30-permissions.sh`/`60-default-agent.sh` classes are unaffected; no test pins any changed literal (`grep` of `tests/` for `rework|backtracked|reopened|challenged` → no matches). `verify.md:35-47` records `345 passed, 0 failed, 0 skipped`, twice, plus a `work/`-less run. I could not independently re-run `bash tests/run.sh` in this read-only session (the bash allowlist permits only `git`/`ls`/`cat`); the conclusion rests on the recorded run plus reading every check that sources the four changed surfaces (`10-readiness.sh`, `20-lifecycle.sh`, `30-permissions.sh`, `40-inventory.sh`, `50-instructions.sh`, `60-default-agent.sh`, `70-pin.sh`, `85-conflict-guards.sh`, `90-packaging.sh`, `95-split-guard.sh`, `96-signature-sweep.sh`). |
| AC12 — reuses existing shapes; no fixture; scope fenced | **met** | `git diff --name-only` = the four AC9 surfaces + `tasks.md`; `git ls-files --others` holds only `verify.md`; `tests/`, `README.md`, `AGENTS.md`, `template/AGENTS.md`, `docs/artifact-conventions.md`, `opencode.json` untouched. The only rule change is the AC7 unshipped precondition. |

12/12 acceptance criteria met.

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] Simultaneous "backtrack + open challenge" Phase-label precedence is under-specified and the status agent's rendering is not stated by the authority** — `docs/workflow.md:1066-1082`, `.opencode/agent/status.md:106-108`, `.opencode/skill/workflow-lifecycle/SKILL.md:80-81`.
  The spec edge case ("Backtrack and challenge both open") says the `stale:`/`reopened:` structural derivation "is evaluated first and the `challenged` overlay after it, matching the authority's precedence; `/status` reports both conditions rather than only one." The authority's established first-match convention is stated at `docs/workflow.md:1050` ("The first two rows are evaluated **before** the artifact-presence rows below them"), which reads as precedence. On that reading a stale marker outranks the challenged overlay and the Phase cell should stay `P (backtracked)` with the challenge reported in Notes. The status agent instead asserts the opposite — "the blocked `challenged (blocked)` label wins the Phase column while the Notes still carry the backtrack detail" — and the skill only says the structural states are "evaluated before the challenged overlay". The authority never says which label wins when both fire, so the two prompt surfaces can be read to disagree in this rare case. `verify.md:74` cites the skill's "structural-before-overlay" line as support for the overlay winning, which is at best circular.
  **Fix (recommended):** add one sentence to `## Derived state` stating explicitly whether the challenged overlay replaces or annotates a structural `P (backtracked)`/`P (reopened)` label, and make `.opencode/agent/status.md` and the skill mirror that sentence. This is a clarification, not a behavior change to any forward phase; it does not block merge. **Question for the user/design owner:** is the design's "challenged wins the Phase column" (`design.md:85-87`) the intended reading? If the authority is meant to be first-match-wins, the agent's line 106-108 is the side that is wrong.

- **[M2] The unshipped challenge precondition landed only in `## Derived state`; two sibling authority passages still state the challenge block unconditionally** — `docs/workflow.md:401-403` (`### 6. Ship` entry) and `docs/workflow.md:973-981` (`### The challenged (blocked) condition`).
  AC7 required the derived-state authority to state the unshipped precondition, and it does (`:1037`, `:1066-1082`). But the same document's challenge-condition subsection still says "While `challenges.md` holds any challenge with no matching `Response` or `Withdrawal`, the item is **challenged**: it does not advance to its next forward phase, including `/ship`", and the Ship entry still says "the item is not **challenged** — an open challenge in `challenges.md` blocks it", with no `ship.md` qualifier. A reader applying those passages to a `ship.md`-present item can conclude it is challenged/blocked, which contradicts the new derived-state rule and 0003's own recorded residual (`.../0003-findings-challenge-loop/verify.md:97-111`, whose recommended fix was "a one-line clarification in the authority that challenges apply to unshipped items"). `/status` itself is correct because the agent derives from the derived-state row, so this is a documentation-coherence gap, not a reporting bug.
  **Fix (recommended):** qualify both passages (or cross-reference the derived-state unshipped precondition) — e.g. "an open challenge on an **unshipped** item" and "post-ship reversal is `/ship recall`". Small, additive, no rule change.

### Nits

- **[N1] The `/status` example recommends `/status` as the next command for a challenged item** — `.opencode/agent/status.md:271,287` shows `| 0005-ledger | challenged (blocked) | 1/3 tasks | /status 0005-ledger |`. The `workflow-lifecycle` routing block (`SKILL.md:44-45`) routes an open challenge to `/review [item-ref]` / `/test [item-ref]` for adjudication, which is the action that unblocks the item; recommending `/status` re-invokes the read-only report the user just ran. Consider naming the adjudicating phase (or noting that the next command depends on the challenge's target) in the example. Not an AC.
- **[N2] Self-inflicted advisory `DRIFT-FACT (d)` on the merged tree** — `design.md:9` declares `conflicts-with` as the four edited surfaces, a strict superset of the parent 0006 row's cell `docs/workflow.md, .opencode/agent/status.md` (`work/0007-phase-backtracking/roadmap.md:88`). Both are present and non-`—`, so the read-only declaration check will report `DRIFT-FACT (d)` for this item until the roadmap owner updates the parent cell. This is documented and deliberately deferred (`design.md:8`, `verify.md`), so it is a maintainer note rather than a defect.

## Not reviewed

- Independent execution of `bash tests/run.sh` (read-only session; the bash
  allowlist permits only `git`/`ls`/`cat`). Suite results are taken from
  `verify.md` and corroborated by reading every check that consumes the four
  changed surfaces.
- The `0001`/`0002`/`0003`/`0005` parent model, the declared-conflict grammar,
  the merge-conflict contract, and every sibling child's surfaces — out of scope
  per `spec.md` non-goals and AC12.
- `verify.md` and `backtracks.md` content beyond their role as evidence (owned by
  other phases).
