---
feature: 0005-merge-conflict-workflow/0001-conflict-model
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0005-merge-conflict-workflow
---

# Review — Merge-conflict model and resolution contract

## Verdict

**approve** — every acceptance criterion is satisfied against the diff; the
deliverable is additive documentation plus one skill, the committed-suite
invariants remain structurally consistent, and the single ambiguity (AC12 versus
the design-mandated `### 6. Ship` wiring) is a documented interpretation, not a
defect.

## Scope and base

The change is **uncommitted on `main`**. There is no item branch, so the base is
`HEAD` and the reviewed range is the working tree plus untracked files.

Commands used:

| Command | Purpose |
| ------- | ------- |
| `git status` | Confirmed 6 modified files, untracked `.opencode/skill/merge-conflict/` and `work/0005-merge-conflict-workflow/` |
| `git log --oneline -20` | Confirmed `HEAD` is a clean merge commit with no item commits |
| `git rev-parse HEAD` | Base ref `aae9b0d19c8f3fb2a3a8b6660b57b85fa9f636b7` |
| `git diff` / `git diff --stat` | Full tracked diff (6 files, +80/−6) |
| `git status --porcelain` (via reads) | Untracked new files read directly |

Files reviewed: `AGENTS.md`, `README.md`, `docs/workflow.md`,
`docs/artifact-conventions.md`, `docs/customization.md`, `template/AGENTS.md`,
`.opencode/skill/merge-conflict/SKILL.md` (new),
`work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh` (new).
No `visual.md` exists and none is required: the change has no user-facing UI, so
the optional visual pass is correctly skipped.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — taxonomy names classes (a)–(d), each with a surface | **met** | `docs/workflow.md:337-351`; four rows name (a) shared-surface textual conflict, (b) `work/` artifact conflict, (c) duplicate sequence number, (d) derived-agreement drift, each with affected surfaces |
| AC2 — pre-ship reconcile + post-merge integrity pass, each tied to its lifecycle point | **met** | `docs/workflow.md:353-366`; also the `### 6. Ship` pointer at `:222-224` |
| AC3 — `shipper` single owner; step inside `/ship`; no new command/agent | **met** | `docs/workflow.md:368-370` |
| AC4 — merge forward; never rebase a pushed branch; never force-push | **met** | `docs/workflow.md:374-376` |
| AC5 — preserve both intents; never silently accept a semantic conflict; escalate | **met** | `docs/workflow.md:377-380` |
| AC6 — auto-resolve mechanical/structural only, subject to re-verification | **met** | `docs/workflow.md:381-383` |
| AC7 — re-run `bash tests/run.sh` + item checks; green before record/ship | **met** | `docs/workflow.md:385-391` |
| AC8 — duplicate sequence numbers defer to the existing renumber rule (bidirectional) | **met** | `docs/workflow.md:393-397`; `docs/artifact-conventions.md:467-469` |
| AC9 — `merge-conflict` skill encodes the ordered procedure | **met** | `.opencode/skill/merge-conflict/SKILL.md:1-84` — source-of-truth declaration, Detect/Classify/Resolve/Re-verify/Record/Post-merge/Stop-and-escalate steps, mechanical vs semantic split, rebase/force-push and second-rule prohibitions |
| AC10 — `AGENTS.md` reference list + `README.md` Skills table name it | **met** | `README.md:265`; `AGENTS.md:136`; `template/AGENTS.md:138` (adopter copy) |
| AC11 — `bash tests/run.sh` passes incl. inventory agreement | **met** (static) | `README.md:273` is `# 11 knowledge skills`; on-disk `.opencode/skill/` has 11 dirs including `merge-conflict`; `README.md:253-265` lists all 11. Suite execution unavailable — see Not reviewed |
| AC12 — no lifecycle/artifact-format/readiness/state/command/agent change | **met** (interpretation noted) | No `.opencode/{command,agent}` file or `opencode.json` change; phases still 1–6; derived-state table, artifact templates, readiness/shipped-signal text unchanged. The one `### 6. Ship` prose line is design-mandated wiring — see M1 |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] The `### 6. Ship` prose edit sits in tension with AC12's "none of them changed"** — `docs/workflow.md:222-224`
  AC12 states the lifecycle phases did not change; this is the only hunk that
  edits a phase's text (the Ship `Process` bullet gains "Reconcile first …"). The
  design anticipates the tension and declares it "lifecycle wiring, not phase
  change" (`design.md:54-58`), and every structural lifecycle surface — phase
  set/order, entry/exit, derived-state table, artifact templates, readiness and
  shipped signal, command/agent inventories — is verifiably untouched, so this is
  a spec-wording question rather than a functional defect. `verify.md` flags the
  same interpretation (its "AC12 interpretation (flag for review)").
  Recommendation: keep the sentence (the design mandates it), but record the
  interpretation that additive cross-reference wiring is permitted — either in
  the item notes or by an explicit AC12 clarification — so a future reviewer does
  not read it as a violated criterion.

- **[M2] AC12's no-command/agent-change assertion only sees the working tree** — `work/0005-merge-conflict-workflow/0001-conflict-model/verify-tests.sh:238-243`
  The check derives "no command or agent changed" from
  `git status --porcelain -- .opencode/command .opencode/agent`. That observes
  uncommitted changes only; once the item is committed (or if a change were
  staged/committed on the branch), the check would pass vacuously and could mask
  a real command/agent edit. The count checks (`:244-247`) also pass if one file
  is swapped for another, since they count rather than compare sets. In this diff
  no such file changed, so AC12 holds.
  Recommendation: add a base-range comparison (e.g.
  `git diff --name-only <base>...HEAD -- .opencode/command .opencode/agent`) or
  assert the on-disk command/agent name set, so a committed change is caught.

### Nits

- **[N1] `### Ownership` is a single unwrapped ~125-character line** — `docs/workflow.md:370`
  Every sibling subsection wraps near 80 columns; this one does not. Purely
  cosmetic.
  Recommendation: wrap it to match the surrounding section.

- **[N2] Token estimates follow a KB/4 convention, not the stated "4 bytes per token"** — `docs/customization.md:59-62`
  `docs/workflow.md` is 22135 B; at 4 bytes/token that is ~5.5k, while the table
  says ~5.4k (it divides the KB value by 4 instead). This matches the table's
  pre-existing convention, so it is internally consistent; only the prose is
  imprecise.
  Recommendation: leave as-is, or recompute the token column from raw bytes if
  the stated rule is meant literally.

## Not reviewed

- **Suite execution.** The review environment's bash allowlist permits only
  read-only git/`ls`/`cat` commands, so I could not execute `bash tests/run.sh`
  (reported 210/0) or `verify-tests.sh` (reported 137/0). I instead verified
  statically every fact those suites assert about this diff: the inventory
  count/membership (11 skills both directions), the absence of any
  command/agent/config change, the lifecycle literals in `20-lifecycle.sh`, the
  packaging/Layout invariants in `90-packaging.sh`, the always-loaded set in
  `50-instructions.sh`, and the template split in `95-split-guard.sh`. All are
  consistent with the working tree. Re-running `bash tests/run.sh` before
  `/ship` remains the confirming step.
- Sibling children `0002`–`0005` and the `shipper` git-allowlist mechanics are
  out of scope for this item (`spec.md` non-goals).

## Scope check

The diff touches only the surfaces the design names: `docs/workflow.md` (new
section + two cross-references), the new skill, `README.md` (row + count),
`AGENTS.md`/`template/AGENTS.md` (Reference bullets), `docs/artifact-conventions.md`
(backward pointer), and `docs/customization.md` (cost-table refresh required by
that table's own refresh instruction). No command, agent, config, test, or
artifact-format change. No secrets. No unrelated refactors. The
`docs/customization.md` refresh is the only non-AC-mandated edit and is justified
by the table's explicit "refresh whenever a listed file changes" rule.
