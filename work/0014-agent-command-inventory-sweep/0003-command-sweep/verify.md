---
feature: 0014-agent-command-inventory-sweep/0003-command-sweep
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0014-agent-command-inventory-sweep
---

# Verification — Command-surface recursive sweep

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 503 passed, 0 failed, 0 skipped`; exit `0` |
| `git diff --name-only` | PASS | Exactly the eight swept commands + this item's `tasks.md`; see AC10 |
| `git diff -- .opencode/command/conflicts.md .opencode/command/fix.md .opencode/command/bootstrap.md .opencode/command/doctor.md` | PASS | Empty — the four excluded commands are byte-identical |
| `git diff -U0 -- .opencode/command/ \| grep '^[+-]' \| grep -E '^(agent:\|description:\|usage:\|name:)'` | PASS | No frontmatter field lines changed (AC9) |
| `grep -rnF 'for a roadmap child' .opencode/command/` | PASS | No matches (AC4, AC6) |
| `grep -rn 'roadmap' <8 swept commands>` | PASS | Exactly three matches, all labelled legacy aliases (AC8) |
| `for f in spec plan build test review ship visual; do grep -A3 -F 'A work-item reference (`item-ref`) is' .opencode/command/$f.md; done \| sha256sum` | PASS | One unique digest `fed8bd48…` across all seven (AC6) |
| `ls .opencode/agent/*.md \| wc -l`, `ls .opencode/command/*.md \| wc -l`, `ls -d .opencode/skill/*/ \| wc -l` | PASS | 13 agents / 12 commands / 11 skills (AC11) |

## Coverage matrix

Every acceptance criterion and edge case maps to a static-inspection check or to
the committed suite. No new committed test is added: the spec's Non-goals forbid
new fixtures/guards (Roadmap 5) and AC10 forbids touching `tests/`, and
`design.md` → "Test strategy" fixes verification as static inspection of the live
prompts plus the existing suite. The greps below are the sanctioned evidence.

| Criterion | Verification (exact evidence) | Result |
| --------- | ----------------------------- | ------ |
| AC1 — `status.md` detects a decomposing node by `manifest.md` (legacy `roadmap.md` labelled) | `grep -nF 'by the presence of `manifest.md` (or the legacy' .opencode/command/status.md` → `status.md:15`; `grep -nF 'presence of `roadmap.md`'` → no match | PASS |
| AC2 — container phase is `manifest`, never `roadmap` | `status.md:20` = ``derives the container phase `manifest`.``; `grep 'phase.*roadmap'` in the eight commands → no match | PASS |
| AC3 — `stale: roadmap` presented with `stale: manifest`, both → `spec`, alias labelled | `status.md:28` = `` `stale: manifest` token — or its retained legacy alias `stale: roadmap` — to `spec` `` | PASS |
| AC4 — `spec.md` nested-child allocation states canonical recursive form; "for a roadmap child" gone | `spec.md:24-26` = "for a nested child, use the supplied canonical reference (`NNNN-slug/MMMM-slug`, nesting to arbitrary depth per `docs/artifact-conventions.md` → \"Work item references\")"; `grep -rnF 'for a roadmap child'` → none | PASS |
| AC5 — `ship.md` reconcile re-checks the manifest's dependency graph; "roadmap dependency graph" gone | `ship.md:40` = "re-check the manifest's"; `grep -nF 'roadmap dependency graph'` → no match | PASS |
| AC6 — seven item-ref sentences byte-identical, canonical form, cite authority, no "roadmap child" | Extracted four-line block from all seven; `sha256sum` yields one unique digest `fed8bd48…`; each cites `docs/artifact-conventions.md` → "Work item references"; no "roadmap child" anywhere | PASS |
| AC7 — `plan.md` retains a clearly-labelled legacy `roadmap.md` alias | `plan.md:33` = "(or the legacy `roadmap.md` artifact alias)"; exactly one `roadmap` token in `plan.md` | PASS |
| AC8 — every `roadmap` token in the eight commands is a labelled deprecated alias; no current phase/artifact/route; no regressed `manifest.md` wording | `grep -rn roadmap` on the eight → exactly `plan.md:33`, `status.md:16`, `status.md:28`, each labelled "legacy"/"alias"; `status.md` manifest wording at `:15,:19,:20,:28`; `ship.md` plan-publication `manifest.md` wording at `:94,:95,:107` unchanged (not in diff) | PASS |
| AC9 — `agent:` value and `Usage:` signature byte-identical; prose-only change | `git diff` touches no `agent:`/`description:` line; `tests/run.sh` AC22 usage-string checks pass for all 13 commands (incl. the eight swept) | PASS |
| AC10 — change set is exactly the eight swept commands + this item's artifacts; excluded commands identical; no docs/README/AGENTS/template/tests/agent changes | `git diff --name-only` = `build.md plan.md review.md ship.md spec.md status.md test.md visual.md` + `.../tasks.md`; excluded-command diff empty; `grep -E 'docs/\|README\|AGENTS\|template/\|tests/\|.opencode/agent/'` on the name list → none | PASS |
| AC11 — `bash tests/run.sh` exits 0, `96-signature-sweep` stays green, inventory 13/12/11 | Suite `503 passed, 0 failed, 0 skipped`, exit 0; AC22 signature checks all green; physical counts 13/12/11 | PASS |
| AC12 — recursive statements cite the authority by name; no new `phase` value/finding code/grammar; sentence matches the paired agents | `status.md:21` cites `docs/workflow.md` "Derived state"; `spec.md:15,26` cite "Work item references"; agent prompts carry the same sentence (`product.md:55`, `architect.md:86`, `builder.md:69`, `tester.md:97`, `reviewer.md:62`, `shipper.md:93`); no new phase/code/grammar introduced | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| `spec.md` retired wording in two places (boilerplate + allocation) — both swept | Boilerplate `spec.md:13-16`; allocation `spec.md:24-26`; no "roadmap child" remains | PASS |
| `plan.md` retains exactly one clearly-labelled legacy `roadmap.md` alias | `plan.md:33`; only `roadmap` token in the file | PASS |
| `status.md` already named "manifest"; correct phase/artifact without regressing it | `status.md:15,19,20,28` all well-formed; no `phase: roadmap`/container `roadmap` | PASS |
| `ship.md` already named `manifest.md` in plan-publication/recall; not regressed | `ship.md:94,95,107` unchanged (absent from `git diff`) | PASS |
| `doctor.md` excluded and unchanged | Excluded-command diff empty | PASS |
| Canonical sentence stable across the seven commands | Single `sha256` digest `fed8bd48…` | PASS |
| Nested child reads as unbounded depth, not two segments | All seven sentences say "at any depth"; `spec.md:25` "nesting to arbitrary depth" | PASS |
| Sweep disjoint from `0004`/`0005`; consumes `0001`/`0002` agent wording | Changed set is only the eight commands; command sentence content matches the agent sentence (`product`/`architect`/`builder`/`tester`/`reviewer`/`shipper`) | PASS |

## Gaps and residual risk

- **Static-only verification.** The committed suite is read-only and never reads
  live `work/**` (`tests/run.sh:20`); it pins command `Usage:`/`agent:`
  signatures but does not assert the recursive prose. The sweep's correctness
  therefore rests on the grep/diff evidence above, and future drift in this
  wording is not automatically caught. A committed fixture is explicitly Roadmap
  5 / `0005` and out of scope here, so this is a known, sanctioned limitation
  rather than a gap in this item.
- **AC10's committed artifacts.** `spec.md`, `design.md`, and `tasks.md` were
  committed by the plan merge (`164503c` / `54817dd`); only the `tasks.md` check
  boxes are uncommitted. The `git diff HEAD` name list therefore omits the
  already-committed artifacts. Verified via `git ls-tree` that the item directory
  holds only `.gitkeep`, `spec.md`, `design.md`, `tasks.md`.
- **Upstream coupling.** The canonical sentence mirrors the shipped `0001`/`0002`
  agent wording (spec Edge case). If that agent wording is later revised, this
  command wording must be revisited — tracked as a documented follow-up, not a
  defect.
- **No defects found.** No implementation, spec, or design fault was identified;
  no `backtracks.md` finding was recorded and no `stale:` marker was applied.
