---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: review
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Review — Post-ship PR denial, recall, and reopen

## Verdict

**approve** — the recall/reopen route is coherent and complete across every named
surface, all 14 acceptance criteria are met on the current tree, and the prior
request-changes blocker [M1] (`artifact-conventions.md` contents-independent
readiness) plus [m2] (status "presence alone") are resolved; the only surviving
items are wording residuals that breach no acceptance criterion.

## Scope and method

Base and evidence commands (the item's build is **uncommitted working state** on
top of the merged plan commit):

```
git status                              # branch main, up to date with origin/main;
                                        #   13 modified, 2 untracked (verify.md, review.md)
git merge-base HEAD origin/main         # f74fbdf2839ff36ebba1b7557dca5c5d1ce261d7
git log --oneline -15                   # HEAD = merge of the item's plan PR (#39)
git diff --stat HEAD                    # 13 files, +390/-49
git diff HEAD -- docs/workflow.md docs/artifact-conventions.md
git diff HEAD -- .opencode/agent/shipper.md .opencode/command/ship.md
git diff HEAD -- .opencode/agent/status.md .opencode/command/status.md \
                 .opencode/agent/builder.md .opencode/command/build.md \
                 .opencode/skill/workflow-lifecycle/SKILL.md
git diff HEAD -- AGENTS.md template/AGENTS.md tests/checks/96-signature-sweep.sh
git diff HEAD -- work/0007-phase-backtracking/0005-post-ship-pr-denial/tasks.md
git show HEAD:.opencode/agent/shipper.md   # confirm the base precondition shape
git show HEAD:docs/workflow.md             # confirm derived-state/readiness base
```

The base is unambiguous: `HEAD == origin/main == main == f74fbdf`, the merge of
the item's plan PR (#39). The reviewed range is the unstaged working tree
(`git diff HEAD`) plus the untracked `verify.md`.

`bash tests/run.sh` is outside this pass's read-only bash allowlist, so the suite
was **not executed here**. The AC13 result is taken from `verify.md` and
corroborated by static inspection of every changed pinned literal
(`tests/checks/10-readiness.sh`, `20-lifecycle.sh`, `40-inventory.sh`,
`95-split-guard.sh`, `96-signature-sweep.sh`).

## Acceptance criteria

| AC | Status | Evidence |
| -- | ------ | -------- |
| AC1 — post-ship states enumerated and distinguished | **met** | `docs/workflow.md:808-828`: Pre-ship / Shipped (open-merged, never opened, branch abandoned) / Recalled-reopened, with denied/closed/changes-requested explicitly "not a state by itself". |
| AC2 — recall records condition, evidence, re-entry phase; append-only | **met** | `docs/workflow.md:851-867`, `.opencode/agent/shipper.md:300-317`, `.opencode/command/ship.md:133-148`: `/ship`-detecting finding with `target phase`, `evidence`, `status: open`, "sequential and append-only — never edit, reorder, or remove a prior entry". |
| AC3 — historical `ship.md` retained, gains `reopened:`; distinct from `status` | **met** | `docs/workflow.md:868-872`, `shipper.md:318-325`, `ship.md:149-154`, `docs/artifact-conventions.md:53-63`: "leave the recorded branch, commits, PR URL, and body intact", "distinct from the frontmatter `status`". |
| AC4 — derives `P` (reopened); marker and `stale:` name the same `P` | **met** | Derived row `docs/workflow.md:925`; rows 1–2 evaluated first (`:938-947`); marker table pairs `reopened: build/design/spec` with `stale: build/design/spec` (`:879-883`). |
| AC5 — recalled item unsatisfied; non-recalled unchanged; no second signal | **met** | `docs/workflow.md:93-95` recalled branch precedes the plain-presence branch, prose `:110-113`; `.opencode/agent/status.md:128-136`, `.opencode/command/status.md:18-25`; `tests/checks/10-readiness.sh` pins intact; no stored value. |
| AC6 — downstream `stale:` per 0002; re-entry revises/appends/resumes | **met** | `docs/workflow.md:873-883` marker table, `:896-905` re-entry; `/build` target-side re-entry in `.opencode/agent/builder.md:43-47,66-72` and `.opencode/command/build.md:16-21`; `/plan`,`/spec` from 0002. |
| AC7 — earlier phase, recorded/deterministic, refused otherwise | **met** | `docs/workflow.md:840-848` (`<phase> ∈ {spec,design,build}`, "strictly earlier than ship"; refused when no `ship.md`); `shipper.md:165-178`; `command/ship.md:129-132`. |
| AC8 — mode of existing `/ship`; signatures consistent; no new inventory | **met** | `command/ship.md:2,11,122-180`; canonical `/ship [item-ref]` registry unchanged; `tests/checks/96-signature-sweep.sh:293-300` adds the recall usage assertion matching the description; `git status` shows no new `.opencode/` file; `40-inventory.sh` counts unchanged. |
| AC9 — re-ship reuses branch/PR; never force-push/rebase/rewrite; never close PR | **met** | `docs/workflow.md:906-914`; `shipper.md:239-247,380-389`; `command/ship.md:175-180`. |
| AC10 — non-recalled contract unchanged; no second signal/state file | **met** | Recalled branch is additive; pinned phrases preserved at `docs/workflow.md:95,105,107`; six `phase` values unchanged; no new artifact/state file. |
| AC11 — never-opened/abandoned stay shipped; no auto-detection | **met** | `docs/workflow.md:815-819,826-828`: "stay shipped until an explicit recall; no automatic detection and no automatic revocation occurs". |
| AC12 — all named surfaces consistent; no irrevocable presence | **met** (one Minor residual) | Route present in the workflow + artifact-conventions authorities, shipper/`/ship`, skill, root+`template/AGENTS.md`, status agent/command, builder/`/build`. The prior [M1] sentence is fixed (`artifact-conventions.md:474-477`); the resolved form is a Minor wording residual at `docs/workflow.md:104-106` (see [m1]). |
| AC13 — configured test command passes; agreements updated | **met** (reported/static) | `verify.md`: `bash tests/run.sh` → `341 passed, 0 failed, 0 skipped`; the sole pre-recall agreement (`96-signature-sweep.sh`) was updated with the usage change; static inspection of every changed pinned literal is consistent (suite not re-executed here). |
| AC14 — scope fence; siblings untouched; no second vocabulary | **met** | `git diff --stat HEAD` lists only the design's Affected areas plus `tasks.md` checkboxes; no new `.opencode/{agent,command,skill}` file; six `phase` values, command→agent pairings, merge-conflict contract, sibling edges, `/status` vocabulary, and committed guards untouched; `/build` adds only the target-side open-finding check. |

**ACs met: 14/14.**

## Findings

### Blockers

- none.

### Major

- none. The prior review's [M1]
  (`docs/artifact-conventions.md` "keyed on the file existing, never on its
  contents") is verified fixed in the current tree at `:474-477` ("a `reopened:`
  marker on the file revokes that signal"), and [m2]
  (`.opencode/agent/status.md` "presence alone") is fixed at `:128-130`
  ("presence is the sole shipped signal, revoked by a `reopened:` marker"). No
  surviving Major.

### Minor

- **[m1] The readiness prose still calls the signal contents-independent** —
  `docs/workflow.md:104-106`
  "its presence is the sole shipped signal, **keyed on presence rather than
  contents**" is now literally false: the recalled branch four lines above reads
  the `reopened:` marker **from the file's contents** (`:93-94`). Unlike the
  [M1] sentence this replaces in `artifact-conventions.md`, it sits directly above
  the algorithm and the exception, and the surface as a whole states the
  revocation, so it does not present presence as irrevocable — but the clause
  alone overstates. **Fix:** reword to keep the pinned phrase while carving the
  exception, e.g. "its presence is the sole shipped signal — unless the file
  carries a `reopened:` marker (see 'Shipped items and reopen')". `verify.md:86-93`
  records this same residual.

- **[m2] Declared-conflict compared set still excludes a recalled item** —
  `docs/workflow.md` → "Declared-conflict check" → "The compared set"
  The check defines the unshipped set by "a child whose `work/.../ship.md` exists
  is **excluded**" (and "A `ship.md` excludes it" for a standalone item). A
  recalled item has `ship.md` present (with `reopened:`) yet is unshipped under
  this item's own model, so its (possibly revised) declarations are silently
  dropped from the comparison. The design fences this surface out
  (`design.md:319-320`) and it changes no AC, but it is a latent inconsistency
  with the recall semantics. **Recommendation:** either record that the exclusion
  should key on `ship.md` present **without** a `reopened:` marker (a one-line
  consistency fix), or explicitly leave it to `0006`/`0007` in a follow-up.

- **[m3] `verify.md` reports a resolved residual as open** —
  `work/0007-phase-backtracking/0005-post-ship-pr-denial/verify.md:94-99`
  The verifier lists "[m3] the recall finding template's `affected:` hardcodes
  `ship.md`/`verify.md`/`review.md`". The live templates are now variable: they
  read "`ship.md` (shipped signal revoked), plus the downstream artifacts marked
  `stale: <phase>`" (`docs/workflow.md:863-864`, `.opencode/agent/shipper.md:316-317`,
  `.opencode/command/ship.md:144-145`). Only the illustrative `Interfaces` template
  in `design.md:269` still hardcodes. The stale residual could send a maintainer
  after a non-issue. **Fix:** note m3 resolved for the live surfaces (or scope
  it to `design.md`'s example).

### Nits

- **[n1] Skill routing line omits two triggers** —
  `.opencode/skill/workflow-lifecycle/SKILL.md:45` names only
  "PR denied/closed/changes-requested?" while the rule below it (`:75-80`) and
  every authority also cover a PR never opened and a branch abandoned.
  Discoverability only.
- **[n2] Branch selection precedes the re-ship override** —
  `.opencode/agent/shipper.md:236-247`: work-item step 4 ("Create or switch to a
  branch name per the `conventional-commits` skill") precedes step 10 ("reuse the
  branch recorded in `ship.md`"). Step 10 is a clear override, but a one-clause
  "skip branch selection on a recalled item" would remove the ambiguity.

## Not reviewed

- **The readiness revocation has no committed fixture guard.** `verify.md`'s
  mutation probe shows deleting the recalled branch from `docs/workflow.md` still
  yields `341 passed, 0 failed`. This is explicitly deferred to
  `0007-backtracking-guards` by the spec's non-goals/AC14 and the parent roadmap,
  so it is not a defect of this item — but the recall contract is carried by
  prompt/doc prose until `0007` lands.
- **I did not execute `bash tests/run.sh`** (not in the read-only bash allowlist).
  The `verify.md` suite claim is taken as reported and corroborated by static
  inspection of the changed pinned literals; the new `96-signature-sweep.sh`
  assertion is a fixed-string match against `command/ship.md`'s actual
  description and is consistent.
- **The declared-conflict `DRIFT-FACT`** for this child (its `design.md`
  `conflicts-with` is a superset of the parent `Children` row's cell) is correct
  per the check's algorithm — both sides present and unequal — and is advisory;
  the parent cell is the roadmap owner's write.
- **The pre-existing multiple `</preconditions>` closings in
  `.opencode/agent/shipper.md`** (one opener at `:115`, closers at `:154`, `:166`,
  `:179`) predate this item — the base already carried the fix-landing and
  plan-publication closers this way — so this item follows the file's established
  shape rather than introducing it.
