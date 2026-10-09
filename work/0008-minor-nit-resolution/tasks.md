---
feature: 0008-minor-nit-resolution
phase: tasks
status: final
created: 2026-10-09
updated: 2026-10-09
---

# Tasks — Minor and nit resolution routing

Ordered, dependency-aware. One task ≈ one focused commit. After every task,
`bash tests/run.sh` must stay green. Design authority: `design.md` (surface and
wording replacements are §2; guard sub-areas are §3; mutations are §4).

- [ ] **T1** — Rewrite the reviewer surfaces to the all-severity bar. In
      `.opencode/agent/reviewer.md` apply S1a (sustained-challenge recompute is
      `approve` iff no finding of any severity remains; a `Minor`/`Nit` still
      blocks), S1b (verdict is `request-changes` for any surviving severity), S1c
      (a question is genuine uncertainty, never a declined `Minor`/`Nit`), and
      S1d (handoff says "address findings"). In `.opencode/command/review.md`
      apply S2 (challenge recompute is `approve` iff no finding of any severity
      remains). Use the exact replacement text in design §2. [AC1, AC2, AC4, AC5, AC7]
      Verify: `bash tests/run.sh` → exit 0;
      `grep -n 'any severity' .opencode/agent/reviewer.md .opencode/command/review.md`
      shows the new phrases; `grep -nE 'Blocker or Major|not merge-blocking|the author may decline' .opencode/agent/reviewer.md .opencode/command/review.md` prints nothing.

- [ ] **T2** — Rewrite the two severity-definition authorities. In
      `.opencode/skill/code-review/SKILL.md` apply S3a (Minor/Nit `blocks the
      item`, fixed or overturned, not declinable), S3b (verdict is any severity),
      and S3c (sustained-challenge recompute is any severity; an adjustment to
      Minor/Nit still blocks). In `docs/artifact-conventions.md` apply S5 (the
      `review.md` severity meanings). Use the exact replacement text in design
      §2. [AC2, AC5, AC6, AC7, AC8]
      Verify: `bash tests/run.sh` → exit 0;
      `grep -nE 'not merge-blocking|the author may decline' .opencode/skill/code-review/SKILL.md docs/artifact-conventions.md`
      prints nothing; `grep -n 'blocks the item' .opencode/skill/code-review/SKILL.md docs/artifact-conventions.md`
      shows both Minor and Nit definitions.

- [ ] **T3** — Rewrite the workflow authority and lifecycle skill. In
      `docs/workflow.md` apply S4a (Review `Exit` states the any-severity bar),
      S4b (Review `Next` says "address findings"), and S4c (`### Outcomes and
      routing` recompute is any severity). In
      `.opencode/skill/workflow-lifecycle/SKILL.md` apply S6a (routing label
      `(rework findings)`, keeping the pinned prefix `review.md verdict
      request-changes`) and S6b (the `build (rework)` derived-state bullet names
      any severity). Use the exact replacement text in design §2. [AC2, AC3, AC6,
      AC8, AC9]
      Verify: `bash tests/run.sh` → exit 0 (in particular `20-lifecycle.sh`
      stays green);
      `grep -n 'finding of any severity' docs/workflow.md .opencode/skill/workflow-lifecycle/SKILL.md`
      shows the new phrases; `grep -n 'review.md verdict request-changes' .opencode/skill/workflow-lifecycle/SKILL.md`
      still matches.

- [ ] **T4** — Add `tests/checks/25-review-severity-bar.sh` (stable token
      `AC25`; pure bash/awk; Bash 3.2 compatible; sourced by `run.sh`, never
      `exit`): the file header (live-surface agreement check, never reads live
      `work/**`, the analogue of `50-instructions.sh`/`96-signature-sweep.sh`),
      the six surface constants from `lib.sh`, a flattened-text matcher
      (`tr '\n' ' ' | tr -s ' '`), the `AC25 all-severity-bar` positive pins and
      the `AC25 contract-preserved` positive pins and negative-absence pins from
      design §3, and a file-existence loop that `bad`s (never skips) on a missing
      surface. Every assertion is labelled `AC25 <sub-area>`. [AC1, AC2, AC5,
      AC6, AC7, AC8, AC10] [depends: T1, T2, T3]
      Verify: `bash tests/run.sh` → exit 0 with `AC25 all-severity-bar` and
      `AC25 contract-preserved` `ok` lines present; temporarily reverting one
      surface phrase makes the corresponding `AC25` line fail.

- [ ] **T5** — Extend `tests/mutation.sh` with the two mutations from design §4
      (`reviewer.md` `if any finding of any severity` → `if any finding of high
      severity`, expected `AC25 all-severity-bar`; `code-review/SKILL.md` first
      `blocks the item` → `not merge-blocking`, expected `AC25
      contract-preserved`), each followed by `restore_file` and
      `assert_clean_absent`; update the header comment's covered-area list to
      include `AC25`. No `stage()` change is needed (the surfaces are already
      staged). [AC12] [depends: T4]
      Verify: `bash tests/mutation.sh` → exit 0, reporting two `AC25` mutations
      "caught and named" and every clean run passing.

- [ ] **T6** — Document the new area in `tests/README.md`: add the Checks-table
      row for `25-review-severity-bar.sh` (suite token `AC25`); add the paragraph
      mapping `AC25` to this item's acceptance criteria, naming the two
      sub-areas and the never-reads-`work/**` contract, in the style of the
      existing `AC21`–`AC23` paragraphs; record the manual residual (a live re-review
      or an actual challenge adjudication is prompt behavior, not executable in
      CI). [AC8, AC10] [depends: T4]
      Verify: `bash tests/run.sh` → exit 0; `grep -n 'AC25' tests/README.md`
      shows the Checks row and the mapping paragraph, and the existing area
      list/tokens `AC18`–`AC23` are unchanged.

- [ ] **T7** — Final integration pass, no new behavior: confirm the change is
      forward-only and scoped. No already-approved or already-shipped `work/`
      artifact is edited or re-derived; no command, agent, skill, `phase` value,
      state file, frontmatter field, record type, or inventory count is added;
      the derived-state `request-changes` → `build (rework)` literal and route
      are unchanged. [AC9, AC10, AC11, AC12] [depends: T1, T2, T3, T4, T5, T6]
      Verify: `bash tests/run.sh` → exit 0; `bash tests/mutation.sh` → exit 0;
      `git status --porcelain -- work/` lists only `work/0008-minor-nit-resolution/`;
      `git diff --name-only` lists only `.opencode/agent/reviewer.md`,
      `.opencode/command/review.md`,
      `.opencode/skill/code-review/SKILL.md`,
      `.opencode/skill/workflow-lifecycle/SKILL.md`, `docs/workflow.md`,
      `docs/artifact-conventions.md`,
      `tests/checks/25-review-severity-bar.sh`, `tests/mutation.sh`, and
      `tests/README.md`.
