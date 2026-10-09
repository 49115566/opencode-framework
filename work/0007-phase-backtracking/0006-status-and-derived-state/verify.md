---
feature: 0007-phase-backtracking/0006-status-and-derived-state
phase: test
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Documentation/prompt-only deliverable. Per spec.md non-goals ('Committed fixtures, agreement areas, and mutation coverage for the new reporting — owned by 0007-backtracking-guards') and design.md Test strategy ('committed fixtures and mutation coverage are 0007-backtracking-guards'), no committed tests/checks area or fixture was added; doing so would violate AC12 and this item's own scope fence. Verification is the configured suite (`bash tests/run.sh`) plus 89 recorded read-only content assertions over the four AC9 surfaces and two mutation probes, mirroring the sibling items. No UI surface, so no /visual pass. No open challenge exists (no challenges.md); no adjudication was required."
---

# Verification — Status, derived state, and readiness for backtracked items

## Scope and approach

The deliverable is framework documentation and prompts. The spec's AC12 and
non-goals, and the design's Test strategy, explicitly assign **committed
fixtures, agreement areas, and mutation coverage for the new reporting** to the
sibling `0007-backtracking-guards`. Adding a `tests/checks/*` agreement area here
would violate that non-goal and the item's own scope fence (only the four named
surfaces may change; `git diff --quiet -- tests/` is required clean). No test
file was therefore added, weakened, skipped, or deleted.

Each criterion is verified below either by the configured suite
(`bash tests/run.sh`) or by a recorded read-only content assertion over the four
AC9 surfaces. Two mutation probes honestly characterize what the committed suite
does **not** yet guard (deferred to `0007`).

The item's `tasks.md` has all five boxes checked and no `verify.md` preceded
this pass; there is no `challenges.md`, so no open challenge needed adjudication.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 345 passed, 0 failed, 0 skipped`; exit 0. |
| `bash tests/run.sh` (second run) | PASS | Determinism confirmed: `345 passed, 0 failed, 0 skipped`. |
| `bash tests/run.sh /tmp/opencode/mut-0006-fresh` (copy with `work/` removed) | PASS | `345 passed, 0 failed, 0 skipped` — the suite reads only live surfaces, never `work/**` (fresh-clone scenario). |
| inline content-assertion harness over the four AC9 surfaces | PASS | `CONTENT CHECKS: 89 passed, 0 failed` (read-only fixed-string/regex greps; see matrix). |
| Mutation probe A — delete ` on an item that has no \`ship.md\`` from the workflow `challenged (blocked)` row (throwaway copy) | Suite stays green | `345 passed, 0 failed` — the AC7 precondition has **no committed guard** (expected; `0007`). |
| Mutation probe B — strip the derived labels from `.opencode/agent/status.md` phase vocabulary (throwaway copy) | Suite stays green | `345 passed, 0 failed` — the derived-label vocabulary has **no committed guard** (expected; `0007`). |
| `git diff --name-only` | PASS | only `docs/workflow.md`, `.opencode/agent/status.md`, `.opencode/command/status.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`, and `work/.../tasks.md`. |
| `git ls-files --others --exclude-standard` | PASS | empty — no new file (no command/agent/skill/state file/fixture). |
| `git diff --quiet -- README.md AGENTS.md template/AGENTS.md docs/artifact-conventions.md tests/ opencode.json` | PASS | clean — scope fences untouched. |
| `grep -R 'satisfied(dep_local_id):' docs/workflow.md .opencode/agent .opencode/command .opencode/skill \| wc -l` | PASS | `1` (the single authority in `docs/workflow.md`). |
| Inventory counts: `ls .opencode/command/*.md`, `ls .opencode/agent/*.md` vs `HEAD` | PASS | `13` commands / `14` agents — unchanged; the six command→agent pairings unchanged (`spec→product`, `plan→architect`, `build→builder`, `test→tester`, `review→reviewer`, `ship→shipper`). |
| `grep -c 'satisfied(dep_local_id):' .opencode/agent/status.md .opencode/command/status.md` | PASS | `0` / `0` — the prompt surfaces defer, they do not restate the algorithm. |
| `grep -nF 'Dependencies and readiness' .opencode/agent/status.md .opencode/command/status.md` | PASS | present in both (deferral literal intact). |

## Acceptance coverage

| Criterion | Test(s) / inspection evidence | Result |
| --------- | ------------------------------ | ------ |
| AC1 — stale marker → `P (backtracked)`, never the pre-backtrack phase | `docs/workflow.md:1035` (row), `:1050-1054` (first-two-rows rule), `:1084-1086` (report mirrors the cell); `.opencode/agent/status.md:101-104,244-247`; `.opencode/command/status.md:18-19,70-71`; `SKILL.md:63-65`. Harness AC1 8/8. | PASS |
| AC2 — backtracked Notes name target phase + affected upstream artifact + invalidated downstream (or `none`) | `docs/workflow.md:1087-1090`; `.opencode/agent/status.md:248-250`; `.opencode/command/status.md:72-76`; `SKILL.md:82-84`. Harness AC2 12/12. | PASS |
| AC3 — `reopened:` marker → `P (reopened)`, not `shipped`, naming the recall | `docs/workflow.md:1036,1055-1059`; `.opencode/agent/status.md:102-103,251`; `.opencode/command/status.md:19,75-76`; `SKILL.md:66-68,77-79`. Harness AC3 5/5. | PASS |
| AC4 — recalled dependency → `blocked`, naming the recalled item; non-recalled unchanged; no stored value | `docs/workflow.md:110-114` (reporting sentence) + `:87-102` (single algorithm); `.opencode/agent/status.md:160-166`; `.opencode/command/status.md:34-38`; `10-readiness.sh` green (single `satisfied(dep_local_id):`, deferral literals, no contradiction). Harness AC4 8/8. | PASS |
| AC5 — unshipped open challenge → `challenged (blocked)`, named, not ready | `docs/workflow.md:1037` (row precondition) + `:1066-1075` (overlay position/blocking); `.opencode/agent/status.md:103-107,252-254`; `.opencode/command/status.md:20-22,76-77`; `SKILL.md:71-74`. Harness AC5 6/6. | PASS |
| AC6 — `request-changes` → `build (rework)`, distinct from `backtracked`, no second rework state | `docs/workflow.md:1046,1060-1064`; `.opencode/agent/status.md:244-246,294`; `SKILL.md:69-70`; `20-lifecycle.sh` pins `review.md` verdict `request-changes` green. Harness AC6 6/6. | PASS |
| AC7 — `ship.md`-present item with open challenge → `shipped`, out-of-scope; authority states unshipped precondition + precedence | `docs/workflow.md:1037` (no `ship.md` precondition), `:1066-1082` (unshipped-only; `out-of-scope for a challenge`; `post-ship reversal is recall's domain`; no shipped item derived `challenged`); `.opencode/agent/status.md:105-107,255-256`; `.opencode/command/status.md:22-23`; `SKILL.md:76-79`. Harness AC7 12/12. | PASS |
| AC8 — vocabulary includes `backtracked`/`reopened`/`challenged`; no new phase value / finding code / state file | `.opencode/agent/status.md:292-294` (base phases + derived labels); `.opencode/command/status.md:70-72`; `SKILL.md:59-74`; `docs/artifact-conventions.md` unchanged (frontmatter `phase` enum still eight values); the derived labels appear only inside parenthesized Phase cells, never as a standalone phase cell. Harness AC8 5/5. | PASS |
| AC9 — four surfaces consistent; authority referenced, not restated | `docs/workflow.md:1084-1094` reports the labels + Notes and names the table/readiness as single sources; `.opencode/agent/status.md`, `.opencode/command/status.md`, `SKILL.md:58` all reference `docs/workflow.md` → "Derived state"/"Dependencies and readiness". Harness AC9 16/16. | PASS |
| AC10 — readiness algorithm once; deferrals by name; seven pinned routing literals and core artifact names unchanged | `10-readiness.sh` green (`satisfied(dep_local_id):` exactly once in `docs/workflow.md`; status agent/command/product defer); `20-lifecycle.sh` green (seven route literals + `spec.md`/`design.md`/`tasks.md`/`verify.md`/`review.md`/`ship.md`); `git diff docs/workflow.md` shows the route literals byte-identical. | PASS |
| AC11 — `bash tests/run.sh` passes; commands/pairings/inventories/signatures unchanged | `bash tests/run.sh` → `345 passed, 0 failed, 0 skipped`, exit 0; `20-lifecycle.sh` (pairings), `40-inventory.sh` (14 agents / 13 commands / 11 skills), `96-signature-sweep.sh` (signatures) green; no new/removed command, agent, or skill. | PASS |
| AC12 — reuses `0001`/`0002`/`0003`/`0005` shapes; no fixture/mutation; no new command/agent/skill/`phase`/state file; does not re-open the model, routing, challenge loop, recall, readiness, or declared-conflict grammar | `git diff --name-only` = the four AC9 surfaces + `tasks.md`; `git ls-files --others` empty; `git diff --quiet -- ... tests/ ...` clean; the only rule change is the AC7 unshipped precondition (accepted by spec). | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Empty `work/` | `/status` reports no items and recommends `/spec` — unchanged (`.opencode/command/status.md:82-83`, agent process step 1 `:89-90`). | PASS (manual) |
| Backtrack with no downstream artifacts yet | "invalidated: none" stated in `docs/workflow.md:1088-1090`, `.opencode/agent/status.md:250`, `.opencode/command/status.md:75-76`, `SKILL.md:84`. | PASS |
| `stale: roadmap` token maps to `spec` | `docs/workflow.md:1054-1055`; `.opencode/agent/status.md:104-105`; `.opencode/command/status.md:23-24`; `SKILL.md:81-82`. | PASS |
| Sequential backtracks | earliest target named, later finding not dropped — `.opencode/agent/status.md:105-106`; `.opencode/command/status.md:24-25`. | PASS |
| Backtrack and challenge both open | blocked `challenged (blocked)` label wins; Notes carry backtrack detail — `.opencode/agent/status.md:106-108`; structural-before-overlay precedence `SKILL.md:80-81`. | PASS |
| Recalled item that also has stale markers | staleness first, so the report is consistent with the earliest `stale:` marker; the recall's stale marker and `reopened:` marker name the same `P` (`docs/workflow.md:1035-1036,1050-1059`). See residual note. | PASS (documented nuance) |
| Malformed / out-of-order record | `.opencode/agent/status.md:226-230` (plain Notes observation, never reordered, no new code); `.opencode/command/status.md:25-27`. | PASS |
| Absent records | no marker/record → byte-identical behavior; every added input is conditioned on presence (`.opencode/agent/status.md:62-66`). | PASS (by construction) |
| Shipped with an open challenge | `docs/workflow.md:1076-1082`; `.opencode/agent/status.md:255-256`; `.opencode/command/status.md:22-23`; `SKILL.md:76-79`. | PASS |
| Approved-but-unshipped | `10-readiness.sh` green; `docs/workflow.md:110-111` unchanged semantics; no contradiction regex matched. | PASS |
| `.gitkeep`-only child | `.opencode/command/status.md:28-29`; agent process step 2/4 `:91-93,115-116`. | PASS |
| Two items in parallel | record and marker reads are per-item (`work/<item-ref>/...`); no stored state introduced; readiness derived live. | PASS (by construction) |
| Read-only | `.opencode/agent/status.md:258` ("No file was modified"), role `:18-23`; `.opencode/command/status.md:6`. | PASS (manual) |

## Gaps and residual risk

- **No committed automated guard for the new reporting (deliberate, mutation-proven).**
  The spec's non-goals and the design's Test strategy assign fixture-based
  agreement areas and mutation coverage to `0007-backtracking-guards`; AC12 and the
  item's T5 fence require `tests/**` unchanged. Mutation probe A (dropping the AC7
  "no `ship.md`" precondition) and probe B (stripping the derived labels from the
  status vocabulary) both leave the suite at `345 passed, 0 failed`. Until `0007`
  lands, the derived labels, the Notes content, and the unshipped precedence are
  carried by prompt/doc prose and could drift without a failing test. This is the
  expected sequencing, not a defect of this item.
- **`stale:`-vs-`reopened:` label nuance.** A recall that also marks downstream
  artifacts `stale:` yields both a `stale:` marker and a `reopened:` marker naming
  the same phase `P`. Because the authority evaluates the stale row first, `/status`
  renders `P (backtracked)` rather than `P (reopened)` for that item. The spec's
  edge case "Recalled item that also has stale markers" explicitly calls for
  reporting "consistently with the earliest `stale:` marker", and the phase `P` is
  the same, so this matches the authority (AC3's `P (reopened)` applies to the
  marker-only case). Recorded for the reviewer as a documented nuance; it is not an
  acceptance-criterion failure. If a `P (reopened)` label is desired even when stale
  markers coexist, that is a future clarification to the `0005`/`0006` boundary, not
  a change this item may make.
- **Framework-internal, prompt-only contract.** Like the sibling items, correctness
  ultimately depends on the status agent following the authority text; there is no
  runtime enforcement. Residual risk is the ordinary one for a prompt-driven report
  and is unchanged from `0001`/`0002`/`0003`/`0005`.
- **`AGENTS.md` / `template/AGENTS.md` deliberately untouched** (design "Not
  touched" list; AC12). A maintainer reading only the always-loaded contract sees
  the backtracking model but not the `/status` Notes rendering until a later item;
  AC9's named surfaces do not include `AGENTS.md`.
- **No UI surface**, so no `/visual` pass was required.
- **Mutation coverage.** `tests/mutation.sh` is opt-in maintainer tooling extended
  by `0007`; not run here. The two probes above were run manually in a throwaway
  copy and are recorded, not added as committed coverage.

No acceptance criterion failed, no test was weakened, skipped, or deleted, and the
configured suite is green (`345 passed, 0 failed, 0 skipped`, twice, plus a
`work/`-less fresh-clone run).
