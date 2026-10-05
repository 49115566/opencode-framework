---
feature: 0003-framework-quality-hardening/0002-readiness-ship-state
phase: review
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Review — Readiness semantics and shipped-state detection

## Verdict

**approve** — all ten acceptance criteria are met; the prior review's M1 (the
sole shipped signal was written after the commit/push/PR and never committed) is
genuinely fixed in all three surfaces and guarded by the suite, and the only
findings are a non-hermetic test sweep and a documented latent table-ordering
edge, neither of which blocks merge.

## Base and diff

- Base: working tree only. `git merge-base HEAD origin/main` →
  `a900b14920058ad5e16b940c4350053c62d79cc8`; `git rev-parse HEAD origin/main`
  prints that same hash for both, so every change is uncommitted and this commit
  is the base. Range reviewed: `a900b14` → working tree.
- Commands run: `git merge-base HEAD origin/main`, `git rev-parse HEAD
  origin/main`, `git status --porcelain`, `git diff --stat`, `git diff --
  <path>...`, `git diff --check`, plus read-only `rg`/`find` sweeps. `git diff
  --check` is clean.
- Scope: 10 modified tracked files — `.opencode/agent/shipper.md`,
  `.opencode/agent/status.md`, `.opencode/command/ship.md`,
  `.opencode/command/status.md`, `.opencode/skill/workflow-lifecycle/SKILL.md`,
  `AGENTS.md`, `README.md`, `docs/artifact-conventions.md`, `docs/workflow.md`,
  `work/0002-agentic-roadmaps/verify-tests.sh` — plus this item's 6 untracked
  artifacts (`spec/design/tasks/verify.md`, the new `verify-tests.sh`, and this
  pass's `review.md`, which replaces the stale `request-changes` one).
- **Execution limitation:** this review sandbox permits only `git read`, `ls`,
  `cat`, `rg`, and `find`; `bash <script>` is denied. I therefore could not
  re-run either suite or `/doctor`. AC7/AC9/AC10 rest on a static read of the
  scripts plus the tester's recorded runs (`verify.md:66-83`); the pass counts
  and `/doctor` output are not independently reproduced here.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 exactly one surface states the algorithm; others defer by reference | **Met** | `satisfied(dep_local_id):` occurs in exactly one live surface, `docs/workflow.md:90` (whole-tree `rg`). `.opencode/agent/status.md:100`, `.opencode/command/status.md:18-19`, and `.opencode/agent/product.md:71-72` all name "Dependencies and readiness". |
| AC2 approve-unshipped satisfies; no surface denies it | **Met** | `docs/workflow.md:105` (`even if unshipped`); `status.md:104` and `command/status.md:20-21` (`even when unshipped`). The contradiction regex matches nothing outside `work/`. |
| AC3 surfaces agree branch-for-branch; workflow grouping corrected | **Met** | The old grouping at `docs/workflow.md:102-108` now states precedence and the `with no ship.md` qualifier; the removed `or a PR detected for` clause is gone. `status.md:100-107` and `command/status.md:18-23` defer and forbid restatement. |
| AC4 `ship.md` presence sole condition; no PR signal | **Met** | `docs/workflow.md:93` (`presence is the sole shipped signal`), `:102-107`; derived-state rows keyed on `ship.md` (`:251,253`). No live surface contains `PR is detected`/`PR detected`/`detected PR`/`no PR?` (`rg`). See m1 for the one latent ordering edge. |
| AC5 shipper write grant, documented | **Met** | `.opencode/agent/shipper.md:5-8` grants `"*": deny` + `"work/**"` + `"**/work/**"`; `README.md:173` documents it; the write is required at `shipper.md:92-99` and `command/ship.md:24-29`; `docs/artifact-conventions.md:397,415-417` names the presence signal. |
| AC6 status agent executable, no `gh`/network | **Met** | `status.md:5` (`edit: deny`); allowlist `:6-17` has no `gh`; the "current git branch … infer shipped state" input is deleted and `:74` now names only `ship.md`; no body command invokes `gh`. |
| AC7 docs, resolved grant, drift check agree | **Met** (static) | `README.md:173` matches the resolved frontmatter and every work-granting agent declares both forms (`rg`); `doctor.md:94-106` requires exactly that. `verify.md:55-57,64` records `/doctor` clean with no shipper `PERMISSION-*`. Not re-run here. |
| AC8 standalone derivation; no state file | **Met** | `docs/workflow.md:251` (`ship.md` present → shipped), `:253` (`approve`, no `ship.md` → ship), `:239` (`There is no state file.`). |
| AC9 suite asserts one definition and fails on drift | **Met** (static) | New `== AC9 ==` block at `work/0002-agentic-roadmaps/verify-tests.sh:240-274`, plus the item suite `:51-61,239-261`; mutation evidence `verify.md:121-136`. Not re-executed here. |
| AC10 suite passes; obsolete assertions updated | **Met** (static) | The detected-PR block is replaced (`verify-tests.sh:219-222`) and the blanket permission freeze is replaced with content assertions (`:233-238`); stale derived-state tokens updated (`:133`). `rg` confirms no other suite encodes the removed branch or a permission freeze. `verify.md:70` records 179/0. Not re-executed here. |

All ten ACs are met; the four "static" rows are marked so because the sandbox
cannot execute the scripts, not because the implementation is in doubt.

## Findings

### Blockers

- None.

### Major

- None. The prior review's **[M1]** (ship.md written after the commit/push/PR and
  never committed) is fixed: `docs/workflow.md:222-234` now writes `ship.md`,
  commits it (`docs(work): record ship state for <item-ref>`), and pushes;
  `.opencode/agent/shipper.md:92-99` adds the required step 7; and
  `.opencode/command/ship.md:24-29` matches. The item suite asserts all three
  (`verify-tests.sh:169-174`) and `verify.md:128` records a mutation proving the
  guard bites.

### Minor

- **[m1] The derived-state `ship.md` row is still shadowed by the
  `verify.md present, review.md missing` row** — `docs/workflow.md:250-251`
  (previously flagged as n1; raised to Minor here because it touches AC4.) The
  table is read top-down and first-match-wins; `verify.md` present with no
  `review.md` derives `review` at `:250` before `ship.md present → shipped` at
  `:251` is reached. An item holding `ship.md` with no `review.md` therefore
  derives `review`, not `shipped`, which is in tension with AC4's "presence … is
  the sole condition". It is latent and unreachable on the normal path (the Ship
  precondition requires an approved `review.md`), and the item's own suites
  assert the row order only against the `request-changes` and `visual.md` rows
  (`verify-tests.sh:106-117`), not this one; `verify.md:159-165` records it as the
  known follow-up. Recommended fix: move the `ship.md present` row directly
  beneath the `roadmap.md` row (or above `:250`) and extend the ordering
  assertion to cover it.

- **[m2] The new broad-sweep assertions are non-hermetic — they scan
  `.opencode/node_modules/*.md`** — `work/0003-framework-quality-hardening/0002-readiness-ship-state/verify-tests.sh:134,249,260`
  Each sweep is fed by `find .opencode docs -type f -name '*.md' -not -path
  './work/*'`. That `-not -path` excludes nothing relevant and does not exclude
  `.opencode/node_modules/`, which currently holds ~28 installed dependency
  markdown files (`rg` confirms none contain a swept token today, so the suite
  passes). This makes the guard's result depend on installed, gitignored
  third-party READMEs: a future `@opencode-ai/plugin`/`@playwright/mcp` bump
  whose README contains `no PR?`, `detected PR`, or a stray code sample could
  fail the suite for an unrelated reason, and the scanned count (`verify.md:170`
  reports 41–71) varies with the install state. Recommended fix: add
  `-not -path '*/node_modules/*'` (and, for symmetry, keep the `work/` exclusion)
  to all three `find` invocations.

### Nits

- **[n1] `ship.md` commit field wording differs between the schema and the
  process** — `docs/artifact-conventions.md:412` says `Commits: <short hashes +
  subjects>`, while `.opencode/agent/shipper.md:92` and
  `.opencode/command/ship.md:24` now say "commit subjects". Presence is all that
  is read, so this is cosmetic; align the two for clarity.
- **[n2] The `gh`-unavailable path leaves the ship.md push ambiguous** —
  `.opencode/agent/shipper.md:96-99` requires committing *and pushing* `ship.md`,
  but `:110-111` and `command/ship.md:34-36` say that when `gh` is unavailable the
  agent finishes local commits and reports the push commands for the user.
  `docs/workflow.md:228-231` accepts "the local-commit path". A sentence stating
  that a local commit of `ship.md` satisfies the requirement until the user pushes
  would remove the ambiguity. Not blocking.
- **[n3] 0002's frozen `verify.md` still records superseded behavior** —
  `work/0002-agentic-roadmaps/verify.md:7,105` states "169/169" and lists
  "readiness missed a detected PR" as a fixed defect — the branch this item
  removes. This is the acknowledged cost of the deliberate cross-item edit
  (`design.md:124-127`); do not rewrite the historical record, but mention the
  supersession in the PR body.

## Tests

- The item suite `work/0003-.../0002-.../verify-tests.sh` is read-only,
  content-based (survives commit and a fresh clone), and adds real coverage the
  0002 suite lacks: derived-state row precedence and order, README-vs-frontmatter
  agreement, the required and committed `ship.md` write, and the read-only status
  surface's freedom from `gh`/PR. Its assertions match the current files on static
  inspection, including the trickier ones (frontmatter-only `fm` scan, `line_of`
  ordering, and the broad `.opencode`+`docs` sweep for the removed `no PR?`
  token).
- `work/0002-agentic-roadmaps/verify-tests.sh` correctly removes the now-false
  status-algorithm and permission-freeze assertions and replaces them with
  content checks (`:76-84`, `:219-222`, `:233-274`). No assertion still encodes
  the detected-PR branch or a frozen permission block; I checked the other two
  suites (`0001-framework-consistency-hardening`, `0001-state-model`) and neither
  encodes either (`rg`).
- Neither suite was executed here (sandbox limitation). The recorded `179/0` and
  `69/0` and the mutation table are internally consistent with my static read but
  are not independently confirmed; they should be green in CI before merge.
- The tests now cover the M1 class directly (the committed-signal assertions at
  `verify-tests.sh:165-174`), so the durability gap that survived the prior
  review no longer rests on prose alone. The Minor `node_modules` exposure above
  is a false-positive risk, not a detection gap.

## Security and permissions

- The shipper's widening is the intended change and is bounded: `"*": deny`
  remains the default with only the relative and absolute `work` forms allowed
  (`shipper.md:5-8`). `bash` is untouched. No other agent's permission block
  changes; every agent granting `work/**` also grants `**/work/**`, and `status`,
  `doctor`, `ask`, and `scout` still deny both (`rg`). Doctor's
  `PERMISSION-WORK-PATTERN` and `PERMISSION-TABLE-MISMATCH` constraints are
  satisfied on static reading.
- No secrets, credentials, debug logging, or commented-out code appear in the
  diff. No new dependency or network path is introduced; removing the detected-PR
  branch narrows the read-only status agent's behavior. `git diff --check` is
  clean.

## Not reviewed

- Runtime truth of both suites, `/doctor`, `/status`, and `opencode debug agent
  shipper` (recorded in `verify.md`, not re-run under this sandbox's `bash` deny).
- The pre-existing 4-failure set in
  `work/0003-framework-quality-hardening/0001-state-model/verify-tests.sh`. Its
  AC1 checks `git status` for 0001's `spec/design/tasks.md` (`:79-85`) and its
  `.gitkeep` (`:109-110`); those artifacts were committed in `b14c0d3`, so the
  failures are structural to that item's own suite and unrelated to this diff —
  consistent with the tester's clean-`HEAD`-clone reproduction.
- Sibling roadmap children `0003`–`0009` and any `visual`-skill behavior beyond
  the derived-state row (no `visual.md` exists for this non-UI item).

## Notes on scope

No scope creep. The ten tracked edits fall inside `design.md:194-209` plus the
consistency follow-ups in `AGENTS.md:38-43` and
`.opencode/skill/workflow-lifecycle/SKILL.md:39`, which serve the item's stated
Goal 4 ("every documented permission and behavior surface stays consistent with
the chosen shipped signal"). `work/0002-agentic-roadmaps/verify-tests.sh` is
another shipped item's artifact; only executable assertions changed and no
historical record was rewritten, exactly as `design.md:124-127` planned.
`work/0002-agentic-roadmaps/verify.md` is untouched.
