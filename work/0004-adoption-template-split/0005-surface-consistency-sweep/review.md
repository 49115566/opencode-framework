---
feature: 0004-adoption-template-split/0005-surface-consistency-sweep
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Re-review after the /build pass that resolved the prior Major M1 (spec canonical `/status` row) under explicit user authorization. All nine acceptance criteria now pass; 0 blockers, 0 majors. Remaining items are minor/nit test-strength and cosmetic notes."
---

# Review — Command signature and prompt-surface sweep

## Verdict

**approve** — the prior Major M1 is resolved (the spec now records
`/status [item-ref]`, matching `.opencode/command/status.md`, and the four
stating surfaces plus the AC22 registry and required sets were updated
together), every acceptance criterion is met, and the remaining findings are
minor/nit test-strength and cosmetic notes that do not block merge.

## Scope and commands

Base ref: `aae9b0d19c8f3fb2a3a8b6660b57b85fa9f636b7` (`HEAD`, identical to
`git merge-base HEAD origin/main`). Every change for this item is uncommitted,
so `git diff <base>...HEAD` is empty; the diff is the working tree plus one new
untracked check file.

Commands used:

- `git rev-parse HEAD` → `aae9b0d19c8f3fb2a3a8b6660b57b85fa9f636b7`
- `git merge-base HEAD origin/main` → the same commit (base = working tree)
- `git status --short` → 10 modified tracked files + new
  `tests/checks/96-signature-sweep.sh` + the five untracked `work/<item-ref>/*.md`
- `git diff` and `git diff --stat` → 10 files, 66 insertions / 45 deletions
- `grep` over `.opencode/command/*.md` for every `Usage:` string
- Read of `spec.md`, `design.md`, `tasks.md`, `verify.md`, the new
  `tests/checks/96-signature-sweep.sh`, every in-scope surface, and every
  pre-existing check that parses a touched surface (`20`, `40`, `50`, `90`,
  `95`).

**Not re-run.** `bash tests/run.sh` / `bash tests/mutation.sh` are denied by the
review sandbox's bash allowlist. AC9 is therefore verified by static trace of the
guard against the live surfaces and by the recorded evidence in `verify.md`
(`284 passed, 0 failed`), not by re-execution.

**Authorized cross-phase edit.** The prior review routed M1 back to `/spec`.
`/spec` has no mature rerun path, and the user explicitly granted `/build`
permission to resolve the review finding even where it edits the spec, provided
the correction is right. `spec.md:8,89` now record `/status [item-ref]`, which is
the command's real argument (`Usage: /status [item-ref]`). The correction is
correct, so the cross-phase edit is accepted and not counted as a finding; it is
recorded here for the historical record.

## Resolution of the prior review

- **M1 (spec `/status` contradiction, reason for the prior request-changes)** —
  **closed.** `spec.md:89` now reads `/status [item-ref]`; the AC22 registry
  (`tests/checks/96-signature-sweep.sh:48`) and the four stating surfaces
  (`AGENTS.md:46`, `template/AGENTS.md:48`, `README.md:203`,
  `.opencode/skill/workflow-lifecycle/SKILL.md:41-42`) all carry the same form,
  matching `.opencode/command/status.md:2`. AC1's "no command states a divergent
  signature" now holds.
- **m1 (`/ship fix` file-wide grep)** — **closed.** The assertion is anchored to
  the full usage line at `tests/checks/96-signature-sweep.sh:286`.
- **m2 (invocation-shaped table cell skipped)** — **closed.** The README surface
  is checked with separate required sets — Commands table (12) and mermaid (7) —
  at `tests/checks/96-signature-sweep.sh:251-257`, so an invocation-shaped table
  cell is reported as a missing signature. The committed mutation at
  `tests/mutation.sh:288` targets the backticked table cell (the backticks
  distinguish it from the unbackticked mermaid label) and is caught.
- **m3 (no committed mutation for AC22)** — **closed.**
  `tests/mutation.sh:287-293` adds the AC22 case.

## Findings

### Blockers

None.

### Major

None. The one prior Major is resolved.

### Minor

- **[m1] An invocation-shaped value at a duplicated route position escapes the
  guard** — `tests/checks/96-signature-sweep.sh:179-218,229` and
  `.opencode/skill/workflow-lifecycle/SKILL.md:34,38`.
  `run_surface` skips any extracted token whose argument is not `<`/`[`-shaped
  (`:193-196`), and the per-command required set (`:212-217`) is satisfied by any
  one occurrence. In the skill routing block `/build` is stated on two routes and
  `/status` on two; changing one `/build [item-ref or task-id]` route to
  `/build 0001-x`, or one `/status [item-ref]` to `/status`, would not fail AC22
  because the surviving occurrence satisfies the required set. This is the
  residual of the spec's "Invocations are not signatures" edge case and does not
  affect the README (each command occurs once there and its required sets were
  split). Impact is low, but AC8's promise — every stated signature diverges →
  fail and name the file and command — is not fully enforced at duplicated
  positions.
  Recommendation: at a designated signature position (heading, route target,
  table cell, supporting-list token), require a signature-shaped token for every
  command except the one documented invocation (`/ship fix`), rather than relying
  solely on per-command presence; or key the required set by position. Not
  merge-blocking.

### Nits

- **[n1] `tests/mutation.sh` header is stale about AC22** — `tests/mutation.sh:15-17`.
  The docstring still says "for each agreement area AC6-AC13 and AC18-AC21",
  though an AC22 mutation was added at `:287-293`.
  Recommendation: add AC22 to the header enumeration.
- **[n2] README Commands-table column alignment drifted** — `README.md:194,196,198,201,203`.
  The widened cells no longer line up with the header/separator. Markdown
  tolerates it; carried from the prior review's n1.
  Recommendation: re-pad the pipes, or accept the drift.
- **[n3] Mermaid `/spec` label keeps a raw `|`** — `README.md:139`.
  `spec["/spec &lt;feature or problem description | item-ref&gt;"]` leaves the
  pipe literal; `design.md:241-245` flags the render as unverified and the guard
  only compares decoded text (`96-signature-sweep.sh:59-67`).
  Recommendation: confirm the label renders in the PR; if not, use `#124;` and
  extend `normalize_sig` to decode it.
- **[n4] Guard extractors remain broader than their comments** —
  `tests/checks/96-signature-sweep.sh:73-96,112-121`.
  `extract_agents_table` matches every `^|` row (not only the lifecycle table),
  and `extract_agents_supporting` runs through the `Supporting agents:` list to
  the next blank line. Neither misfires on the current files, but a future table
  or a backticked `/…` token in the agents list would be scanned.
  Recommendation: scope the table extractor to the lifecycle section and stop the
  supporting list at `Supporting agents:`.
- **[n5] Deliberately out-of-scope stale forms remain** — `docs/workflow.md:290`
  (`/fix <bug>`), `.opencode/command/status.md:36`,
  `.opencode/command/roadmap.md:31`, `.opencode/agent/status.md:66`,
  `.opencode/agent/roadmap.md:70` (`/spec <feature>`). The spec scopes
  `docs/workflow.md` to the six headings plus the `/visual` bullet and the
  command/agent files to `spec.md`/`ship.md`/`ask.md`, so these are not
  violations; recorded for a future sweep.
- **[n6] Stale test-internal comment left in place** — `tests/checks/20-lifecycle.sh:12`
  still attributes item-ref usage strings to the withdrawn `0009`. The spec lists
  this as an explicit non-goal; leaving it is correct and recorded only so it is
  not mistaken for an oversight.

## Acceptance criteria walk

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — each command usage string states the canonical signature; no command diverges | **met** | All 12 `.opencode/command/*.md` `Usage:` strings equal the registry (`grep`; `/status [item-ref]` at `status.md:2` now agrees, `spec.md:89`), asserted by the AC22 loop `96-signature-sweep.sh:269-280` plus the anchored `/ship` fix clause `:286`. |
| AC2 — root `AGENTS.md` lifecycle table + supporting list canonical; stale forms gone | **met** | Table `AGENTS.md:35-40` (six canonical, `/spec` `\|`-escaped); supporting list `:46-49` (`/fix <bug description>`, `/status [item-ref]`, `/roadmap <initiative>`, `/bootstrap`, `/visual [url or item-ref]`, `/doctor`); guard `run_surface AGENTS.md` extracts 12/12. |
| AC3 — `template/AGENTS.md` mirrors AC2; profile placeholders intact | **met** | Table `template/AGENTS.md:37-42`, supporting `:48-51`; `## Project profile` (`:15-24`) all `_placeholder_`; `95-split-guard.sh:225-284` placeholder assertions unaffected. |
| AC4 — six `docs/workflow.md` headings + `/visual` routing bullet canonical; stale forms gone | **met** | Headings `:139,153,170,184,204,217`; `/visual [url or item-ref]` bullet `:306`; no `/plan <feature>`/`/build [task-id]`/`/visual [url or slug]` in the scoped positions; guard extracts 7/7. |
| AC5 — `README.md` Commands table, mermaid, quickstart canonical; stale forms gone | **met** | Commands table `:194-205` (12, `/spec` `\|`-escaped), mermaid `:139-151` (7 labels, entity-decoded); no `/build [task]`/`/visual [url]`/`/fix <bug>`; quickstart `:123-130` and the `/status`/`/fix` prose at `:132` are concrete invocations and intentionally untouched per the spec edge case. Nit n3 on the raw mermaid pipe. |
| AC6 — skill routing block and rules canonical | **met** | `.opencode/skill/workflow-lifecycle/SKILL.md:31-42`; every route target canonical; `/ship fix` (`:40`) correctly classified as an invocation; guard extracts 11 occurrences / 9 required. Minor m1 notes the duplicated-route blind spot. |
| AC7 — `ask` description is the exact AC7 text, not `Ultra-Basic Read-Only Agent.` | **met** | `.opencode/agent/ask.md:2` matches the AC7 string verbatim; stale text absent; guard asserts both at `96-signature-sweep.sh:297-308`. |
| AC8 — committed check fails naming file + command on divergence; `tests/README.md` documents area and token | **met** | `tests/checks/96-signature-sweep.sh` sourced by `run.sh:42`; divergence, missing-signature, unknown-command, and missing-file each emit `bad` naming file and command; `tests/mutation.sh:287-293`; `tests/README.md:81,100-109`. Test-strength limit: m1. |
| AC9 — `bash tests/run.sh` exits `0`; split, inventory, packaging, lifecycle, instruction agreements unbroken | **met (not independently re-run)** | Static trace shows the guard passes on the live tree (75 `ok`, 0 `bad`); `20-lifecycle.sh`/`40-inventory.sh` parse the escaped `/spec` cells correctly (split on backticks / take `$1`); quickstart and template profile untouched for `95-split-guard.sh`; `90-packaging.sh`/`50-instructions.sh` read untouched surfaces. `verify.md` records `284 passed, 0 failed` and mutation `29/29`. Sandbox denied re-execution. |

Met 9/9.

## Other review axes

- **Correctness** — the ten edits are wording-only and match the canonical
  registry; the `\|` in table cells decodes correctly in the guard and does not
  disturb `20-lifecycle.sh` (backtick split) or `40-inventory.sh` (first token of
  the first cell). The registry's `/status` entry now agrees with
  `status.md:2`.
- **Security / secrets** — no secrets, credentials, `.env` content, or debug
  output in the diff. The new check is read-only (reads live surfaces, never
  `work/**`) and adds no dependency, network, or write capability.
- **Tests** — the AC22 guard is the deliverable and was read line by line;
  extraction, normalization (`\|`, `&lt;`/`&gt;`), classification, and
  presence logic are sound and non-vacuous on the current tree. Its residual gap
  is m1. The committed mutation and the tester's probes cover the prior m1–m3.
- **Convention fit** — the check follows the suite's sourced-file shape (`echo`
  banner, `ok`/`bad`, no `exit`, bash-3.2 compatible — no associative arrays or
  `mapfile`), and the `tests/README.md` row/paragraph mirror `90`/`95`.
- **Scope** — exactly the surfaces the spec enumerates plus the required guard,
  its `tests/README.md` documentation, and the mutation case; no unrelated
  refactor, reformat, or dependency. No scope creep.
- **Performance / backward compatibility** — not applicable (static docs and
  prompt text). The canonicalized signatures now describe the commands' real
  arguments, which is backward-compatible.

## Not reviewed

- Independent re-execution of `bash tests/run.sh` and `bash tests/mutation.sh`;
  denied by the sandbox's bash allowlist. I relied on reading the guard and the
  pre-existing checks and on the recorded results in `verify.md`.
- The five `work/<item-ref>/*.md` artifacts as deliverables (reviewed as the
  contract, not as code).
- Out-of-scope stale spellings intentionally left in place (n5, n6).
