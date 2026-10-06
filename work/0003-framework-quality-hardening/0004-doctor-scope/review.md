---
feature: 0003-framework-quality-hardening/0004-doctor-scope
phase: review
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Re-review after the prior request-changes. Prior M1 (committed-tree durability), m1 (node_modules sweep), m2 (label in a compared cell), and m3 (nine-vs-ten list) are all confirmed fixed. Verdict flips to approve."
---

# Review — Doctor audience and diagnostic accuracy

## Verdict

**approve** — all eleven acceptance criteria are met, the prompt/docs change is
internally consistent and read-only, and the one prior Major (the verification
suite failing on a committed tree) is genuinely fixed; the remaining items are
non-blocking documentation and test-quality nits.

## Base and diff

All work is in the **uncommitted working tree**; `HEAD` equals `origin/main`.
Commands used:

- `git rev-parse HEAD origin/main` → `ff5a2faf3830d672d855fe7bbcd597a58ef568a0`
  for both.
- `git merge-base HEAD origin/main` → `ff5a2fa…`. `HEAD` is the base; no item
  commit exists yet.
- `git status` / `git diff --name-only HEAD` → five modified tracked files.
- `git diff --stat HEAD` → 5 files changed, 58 insertions(+), 24 deletions(-).
- `git diff --check HEAD` → clean.
- `git diff HEAD` read in full; changed files read in full via editor.
- `rg --hidden`, `find .opencode docs -type f -name '*.md'`, `ls`, `cat`.

Change set is exactly the five files named in `design.md` → "Affected areas":
`.opencode/agent/doctor.md`, `.opencode/command/doctor.md`, `AGENTS.md`,
`README.md`, `docs/workflow.md`. No config, source, or lifecycle-phase change —
no scope creep.

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — every documented `/doctor` surface marks it maintainer-only | **Met** | Marker present in `README.md:169` (Commands row), `AGENTS.md:50-51` (`/doctor`) and `:54-55` (`doctor`), `docs/workflow.md:274`, `.opencode/agent/doctor.md:2`, `.opencode/command/doctor.md:2`. `rg --hidden` over the tree finds no other live `/doctor` mention. Name/agent cells unchanged (`README.md:169` is still `` \| `/doctor` \| `doctor` ``). See m1 for the one residual surface. |
| AC2 — fresh adoption installs no doctor agent/command | **Met** | `README.md:44` adds `rm -f .opencode/agent/doctor.md .opencode/command/doctor.md` after the directory copy; the framework repo still holds both files (`ls`). |
| AC3 — docs state maintainer-only, adoption absence, misreport warning | **Met** | `README.md:54-61` states maintainer-only, "this quickstart never copies", "not authoritative outside the framework repository", "remove or ignore" for prior adopters, and the out-of-band "will make `/doctor` misreport" warning. |
| AC4 — examples carry no count and no `file:line` | **Met** | `rg '\.md:[0-9]+'` and `rg '[0-9]+ (files\|role prompts\|…)'` over both doctor files → no matches; `<finding_format>` (`agent:137-156`) carries no digit and names each location symbolically. The old factually-wrong `SKILL.md:46` example is gone (and the design's premise holds: `.opencode/skill/browser-verification/SKILL.md:46` writes to in-repo `scratch/dev-server.log`). |
| AC5 — classification derived from declared state, no inline snapshot | **Met** | `<completeness_rule>` (`agent:158-181`) contains no `(ask, doctor, …)` enumeration and derives lifecycle status from `docs/workflow.md` phase tables; a command-less agent is stated not to be a finding (`agent:179-180`, `command:22-23`). |
| AC6 — one finding for a missing surface, no per-item cascade | **Met** | Rule at `agent:167-169` ("exactly one … Never emit one finding per inventory item"); guard at `command/doctor.md:13-18`. The real README-missing run is recorded in `verify.md:69,95`. |
| AC7 — clean framework run with checked counts | **Met** | Disk is 14 agents / 12 commands / 10 skills (`ls`), matching `README.md:219-221`; `verify.md:68` records a real run: `No findings` with 14/12/10. |
| AC8 — README stays out of always-loaded instructions | **Met** | `opencode.json` `instructions` = `AGENTS.md`, `docs/workflow.md`, `docs/artifact-conventions.md` — no README; `opencode.json` is unmodified (not in the change set); the agent still declares `README.md` under `<inputs>` (`agent:55`). |
| AC9 — read-only guarantee unchanged | **Met** | `agent:5-18` permission block is byte-identical to `HEAD` (diff touches only `description` and body); `edit: deny` and `"*": deny` intact; read-only rules preserved in both files. |
| AC10 — no phase/input/output/exit/command behavior change | **Met** | `git diff --name-only HEAD` = the five expected files; the only `docs/workflow.md` hunk is the `/doctor` routing bullet (`:274`), not the `## Phases` section. |
| AC11 — doctor facts remain in agreement, no new drift | **Met** | All twelve catalogue codes survive in the agent; the real run exercised all nine checks with no finding (`verify.md:68`). |

**Tally: 11/11 met.** Three criteria (AC6, AC7, AC11) include a model-invocation
half that this sandbox cannot re-run; their static preconditions were
independently re-derived and hold.

## Prior findings — confirmed resolved

| Prior finding | State | Independent check |
| ------------- | ----- | ----------------- |
| **M1** — suite's change-set assertion failed once committed | **Fixed** | `verify-tests.sh:279-285` and `:293-299` now pass when `git diff --name-only HEAD` is empty, so the suite is green on a committed branch and a fresh clone. |
| **m1** — AC1 sweep scanned `node_modules` | **Fixed** | `verify-tests.sh:97` adds `-not -path '*/node_modules/*'`; `find` now returns the 39 tracked markdown files. |
| **m2** — marker placed inside the compared README capability cell | **Fixed** | `README.md:189` is byte-identical to `HEAD` (`git diff` shows no Agents-row change). |
| **m3** — "nine checks" followed by ten bullets | **Fixed** | `command/doctor.md:13-18` is a separate guard bullet before the numbered list (`:19-32`), which holds exactly nine items. |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[m1] The `doctor` row in the README Agents table carries no maintainer-only
  label** — `README.md:189`.
  Goal 1 says the agent is labeled "everywhere it is documented", and the Agents
  table documents `doctor` alongside ordinary adopted agents. AC1's enumerated
  surfaces (Commands table, `AGENTS.md` list, both descriptions) are all met, so
  this is not an acceptance failure, and leaving the compared capability cell
  untouched (prior m2) was the right call. The residual is fixable without
  re-introducing self-drift:
  Recommendation: add a footnote line below the Agents table (after
  `README.md:189`) such as "The `doctor` agent is framework-maintainer only and
  is removed by the adoption quickstart." That labels the surface without
  altering any cell the diagnostic compares.

- **[m2] The AC2 quickstart simulation hard-codes the documented commands instead
  of executing the README block** — `verify-tests.sh:107-117`.
  The sub-shell repeats `cp -r …` and `rm -f …` literally, so a divergence
  between the README block (`README.md:40-48`) and reality would only be caught
  for the single `rm -f` string asserted at `:103`; a wrong `cp -r` source or a
  missing step would still pass. This weakens the "run the block verbatim"
  claim in `verify.md:71`.
  Recommendation: extract the fenced `bash` block from `README.md` and `eval` it
  (or assert the full normalized block text), so the test executes what the
  quickstart actually says.

### Nits

- **[n1] `design.md` line citations are stale** — `design.md:26,57-66,174-181`
  cite `README.md:159`/`:179`/`:209-211`; the rows are now at `:169`/`:189`/
  `:219-221`. Already disclosed in `verify.md:158-160`; planning-artifact drift,
  no action required.
- **[n2] `SURFACE-MISSING` example granularity is ambiguous** — `agent:154`
  names a sub-surface (`README.md Skills table`) while the rule at
  `agent:167-169` treats the surface at file granularity (`README.md`). A
  missing table in an existing file is undefined. Harmless in the tested
  README-deleted case; one clarifying clause would close it.
- **[n3] The AC4 suite assertion is stricter than the criterion** —
  `verify-tests.sh:158-162` forbids any digit in `<finding_format>`, whereas AC4
  forbids concrete inventory counts and `file:line` citations. It passes today;
  a future illustrative example that legitimately needs a number would fail
  spuriously.
- **[n4] Dead path filter** — `verify-tests.sh:97` adds
  `-not -path './work/*'`, but the `find` roots are `.opencode` and `docs`, so
  `work/` is never traversed. Harmless.

## Security, error handling, and compatibility

- **Secrets.** No credentials, tokens, or `.env` content in the diff or the test
  script; `rg` hits are policy prose only (`AGENTS.md:108`,
  `docs/workflow.md:222`). `git diff --check` clean.
- **Error handling / edge cases.** No runtime code. The missing-surface guard
  (AC6), the out-of-band-copy warning, and the existing-adopter note are
  present; the diagnostic stays read-only (`edit: deny`, no write-capable
  allowlist change).
- **Backward compatibility.** Prior adopters are told to remove or ignore the
  two files; nothing is deleted from their disk by this change. The doc-only
  labels do not alter the name tokens the diagnostic matches on.
- **Performance.** Not applicable (prompt/docs only).

## Test quality notes

- `verify-tests.sh` (66 assertions) is read-only, content-based, and durable
  across a commit; it covers all ACs and the spec edge cases. The four prior
  findings are fixed and the fixes are correct on static inspection.
- The suite honestly delegates the model-dependent halves (AC6/AC7/AC11) to
  `verify.md`, and `verify.md` reports the pre-existing `0001-state-model`
  failures rather than hiding them.
- The one genuine weakness is m2 above (the quickstart simulation duplicates the
  documented block). It is a test-fidelity gap, not an acceptance gap.

## Execution limitation

This review sandbox permits only `git diff/log/show/status/rev-parse/merge-base`,
`ls`, `cat`, `rg`, and `find`; `bash` is denied, so I could not re-run
`verify-tests.sh` or invoke `/doctor`. The AC1/AC2/AC3/AC4/AC5/AC8/AC9/AC10
evidence above was re-derived statically; AC6/AC7/AC11 rest on the runs recorded
in `verify.md` plus the static preconditions those runs depend on, all of which
hold.

## Not reviewed

- The live `/doctor` model output and the mutation runs recorded in `verify.md`
  (not reproducible without executing the script / invoking a model).
- Sibling roadmap children `0003`, `0005`-`0009` (only their boundary notes were
  consulted).
- Pre-existing failures in `0001-state-model/verify-tests.sh`, documented in
  `verify.md` as a separate cross-item issue.
