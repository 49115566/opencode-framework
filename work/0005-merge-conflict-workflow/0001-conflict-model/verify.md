---
feature: 0005-merge-conflict-workflow/0001-conflict-model
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
notes: "Docs + one skill; no runtime code, no committed CI. AC1-AC10 and the spec edge cases are encoded as content assertions in the new read-only item suite work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh; AC11/AC12 are integration-verified by the canonical bash tests/run.sh plus structural invariants. No defects found. Committed merge-integrity guards are intentionally deferred to sibling 0005-merge-integrity-guards."
---

# Verification — Merge-conflict model and resolution contract

## Summary

All twelve acceptance criteria of
`work/0005-merge-conflict-workflow/0001-conflict-model` are satisfied against the
current working tree. The deliverable is documentation plus one skill, so the
automatable evidence is a new read-only item suite,
`work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh`, which
encodes AC1–AC10 and every spec edge case as content assertions, plus the
canonical committed suite for AC11/AC12.

- The new item suite passes **137/137**.
- The canonical suite `bash tests/run.sh` passes **210 passed, 0 failed, 0 skipped**
  (includes `40-inventory.sh`, which agrees the README Layout count `11 knowledge
  skills` and the Skills table both match the on-disk set containing
  `merge-conflict`).
- No production file was modified by this verification pass. The only test file
  it added is `verify-tests.sh`; `git status --porcelain` shows the builder's six
  modified surfaces plus the new `.opencode/skill/merge-conflict/` and
  `work/0005-merge-conflict-workflow/` trees, exactly the scope the design
  declares.

No defects were found. One interpretation note on AC12 is recorded under residual
risk (the `### 6. Ship` process bullet gained the reconcile cross-reference the
design mandates; the phase/model itself is unchanged).

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | 210 passed, 0 failed, 0 skipped — `/tmp/opencode/suite.log` |
| `bash work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` | PASS | 137 passed, 0 failed |
| `bash -n work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` | PASS | syntax OK |
| `git status --porcelain -- .opencode/agent .opencode/command opencode.json` | PASS | empty — no command, agent, or config change (AC12) |
| `wc -c AGENTS.md docs/workflow.md docs/artifact-conventions.md` | PASS | cost-table figures consistent with the table's own refresh convention (T7) |

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — Taxonomy names (a)–(d), each with an affected surface | `verify-tests.sh` AC1: `## Merge conflicts` + `### Conflict taxonomy` headings; the four class labels; each row's surfaces (`README.md`/`AGENTS.md`/`docs/*.md`/`.opencode/{agent,command,skill}/**`/`template/**`/`tests/checks/**`; roadmap `Children`/`Depends on`/frontmatter/nested-child; top-level `work/<NNNN-slug>` and per-parent `work/<NNNN-slug>/<MMMM-slug>`; README Layout counts/Skills table); section sits between `## Multiple work items` and `## Resuming and interruption`; cross-reference line names the three non-renumbering classes | PASS |
| AC2 — Pre-ship reconcile + post-merge integrity pass, each tied to its lifecycle point | `verify-tests.sh` AC2: `### Lifecycle placement`; `pre-ship reconcile`; `before the shipper performs any ship operation`; `post-merge integrity pass`; `after a merge to the default branch`; merges forward; post-merge checklist scans duplicate prefixes and re-checks `Depends on` for dangling/missing/unlisted/cyclic; `### 6. Ship` "Reconcile first" pointer | PASS |
| AC3 — `shipper` is sole owner; step inside `/ship`; no new command/agent | `verify-tests.sh` AC3: `### Ownership`; "The `shipper` is the single owner of reconciliation"; "a step inside `/ship`"; "adds no new command or agent" | PASS |
| AC4 — Merge default branch forward; never rebase a pushed branch; never force-push | `verify-tests.sh` AC4: `### Resolution principles`; `Merge the default branch forward`; `Never rebase a pushed branch`; `never force-push` | PASS |
| AC5 — Preserve both intents; never silently accept a semantic conflict; escalate | `verify-tests.sh` AC5: `Preserve both branches' intent`; "Keep both sides … rather than dropping one"; `semantic conflict`; `never silently accept it`; `escalate it to the user for explicit approval`; `before proceeding` | PASS |
| AC6 — Auto-resolve mechanical/structural only, subject to re-verification | `verify-tests.sh` AC6: `Auto-resolve the mechanical`; `mechanical or structural`; excludes "choosing between competing intents"; `subject to the re-verification below` | PASS |
| AC7 — Re-run suite + item checks; green before record/ship | `verify-tests.sh` AC7: `### Verification`; `re-run \`bash tests/run.sh\` and the affected item`; "Both must be green before the resolved merge is recorded or shipped"; "A clean merge is not evidence of correctness"; conflict-free merges still run the suite | PASS |
| AC8 — Duplicate sequence numbers defer to the existing renumber rule | `verify-tests.sh` AC8: `### Relationship to renumbering`; names `Renumbering after a parallel merge`; "defers to and extends that rule"; "never defines a second renumbering rule"; class (c) routed to it; `docs/artifact-conventions.md` gains the bidirectional pointer back to `## Merge conflicts` | PASS |
| AC9 — `merge-conflict` skill encodes the ordered procedure | `verify-tests.sh` AC9: file exists; frontmatter `name: merge-conflict`; trigger keywords; names `docs/workflow.md` as `source of truth`; ordered steps Detect/Classify/Resolve/Re-verify/Record/Post-merge integrity pass/Stop and escalate; mechanical-vs-semantic split; re-verification via `bash tests/run.sh` + item checks; records resolved paths and evidence; refuses to proceed silently; escalation without a response stays blocked; forbids rebase/force-push and a second renumber rule | PASS |
| AC10 — `AGENTS.md` Reference and `README.md` Skills table reference it | `verify-tests.sh` AC10: README `| \`merge-conflict\`` row with a description; `AGENTS.md` Reference bullet naming the skill and `## Merge conflicts`; `template/AGENTS.md` carries the same reference to adopters | PASS |
| AC11 — `bash tests/run.sh` passes, including inventory agreement | `verify-tests.sh` AC11 runs the canonical suite (exit 0, no `FAIL`); README Layout is `# 11 knowledge skills`; on-disk skill set is 11 entries including `merge-conflict`. Independently, `tests/checks/40-inventory.sh` asserts both membership directions | PASS |
| AC12 — No lifecycle/artifact-format/readiness/state/command/agent change | `verify-tests.sh` AC12: no `.opencode/command`/`.opencode/agent` file changed; counts 12 commands / 14 agents; six phases present with no seventh; derived-state table literals intact; `There is no state file.`; all seven artifact templates retained; "presence is the sole shipped signal" unchanged; customization cost row refreshed. `tests/checks/20-lifecycle.sh` independently agrees the lifecycle surfaces | PASS |

### Edge cases

| Edge case | Test(s) | Result |
| --------- | ------- | ------ |
| Overlapping `work/` artifact edits → keep both records, re-check graph | `verify-tests.sh` AC1 (taxonomy (b)) + AC2 (post-merge `Depends on` re-check; dangling/missing/unlisted/cyclic) | PASS |
| Duplicate top-level sequence | `verify-tests.sh` AC8 + EDGE (same `NNNN` named) | PASS |
| Duplicate per-parent child sequence | `verify-tests.sh` AC8 + EDGE (same per-parent `MMMM` named) | PASS |
| Textually clean but semantically drifted merge | `verify-tests.sh` AC1 (taxonomy (d)) + AC7 ("A clean merge is not evidence of correctness", conflict-free merge still runs the suite) | PASS |
| Contradictory contract rules require intent judgment | `verify-tests.sh` AC5 + EDGE (`judgment about competing intents` → escalate) | PASS |
| Branch behind but conflict-free | `verify-tests.sh` AC7 | PASS |
| Nothing to reconcile → no-op, no error | `verify-tests.sh` AC2 ("both steps are no-ops and do not error") | PASS |
| One branch deleted a file the other changed | `verify-tests.sh` AC5 ("Keep both sides … rather than dropping one"); skill step 3 "never drop one side" | PASS |
| Escalation with no user response | `verify-tests.sh` AC9 ("stays blocked until the user responds") + AC5 | PASS |

## Gaps and residual risk

- **Content criteria are literal-presence checks, not semantic proofs.** The
  deliverable is prose plus a prompt file; there is no runtime harness for
  document content, so AC1–AC10 and the edge cases are verified by grepping the
  required literals from the finished artifacts (the design's test strategy).
  Each assertion targets a specific required phrase and the suite includes
  negative controls (e.g. no seventh phase). A literal assertion cannot prove
  the surrounding prose is well-formed, only that the mandated content is
  present; a reviewer still reads the contract for coherence.
- **The post-merge integrity pass is not executed.** It is defined as a
  documented, shipper-owned checklist (design decision resolving the spec's
  deferred open question), not code. Running it against a real merged default
  branch would require a merge and is out of scope for this child; committed,
  fixture-based guards are explicitly sibling `0005-merge-integrity-guards`.
- **AC12 interpretation (flag for review).** `docs/workflow.md` `### 6. Ship`
  gained one leading reconcile sentence, mandated by AC2 and the design's
  "lifecycle wiring, not phase change". I read AC12's "lifecycle phases … none
  of them changed" as the phase set/model — six phases, derived-state table,
  artifact templates, readiness/shipped signal, and command/agent inventories —
  all of which this suite asserts unchanged. If the reviewer reads AC12 as
  forbidding *any* prose edit to the Ship process, that is a spec/design
  tension to resolve upstream, not an implementation defect.
- **Real two-branch merge and real escalation are not exercised.** They require
  live git state and a user decision; the contract and skill text are the
  deliverable here, so only their required content is asserted. The operational
  reconcile itself is implemented by siblings `0003-shared-surface-reconcile`
  and `0004-artifact-reconcile`.
- **`docs/customization.md` cost table is not AC-gated.** T7 refreshes it as
  documentation consistency only. The figures are internally consistent with the
  table's pre-existing convention (KiB ÷ 4 tokens) and the ACs do not bind them;
  a drift here would not fail the committed suite by design.
- **No new committed check was added, deliberately.** `tests/README.md` line 29
  fixes the suite as read-only and not reading `work/**`, and the design defers
  committed guards to sibling `0005`. The new `verify-tests.sh` is item-level
  evidence under `work/`, consistent with the `0001`–`0003` item suites.
