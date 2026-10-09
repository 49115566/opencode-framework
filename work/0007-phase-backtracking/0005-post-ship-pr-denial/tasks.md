---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: tasks
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
---

# Tasks — Post-ship PR denial, recall, and reopen

Ordered, dependency-aware. One task ≈ one focused commit. All work is framework
documentation, prompts, and one test assertion; no runtime code.

- [ ] **T1** — In `docs/workflow.md`, expand `## Phase reversal (backtracking)` → `### Shipped items and reopen` (`:788-795`) into the post-ship authority: enumerate the states (open PR denied / closed / changes-requested; PR never opened; branch abandoned) and distinguish them from pre-ship and a normally shipped item; add the `/ship recall <item-ref> <phase>` route (`<phase> ∈ {spec, design, build}`, strictly earlier than ship, refused otherwise and refused when no `ship.md` exists); the `/ship`-detecting `backtracks.md` finding entry shape; the `reopened: <phase>` revocation on the existing `ship.md`; the per-phase downstream `stale:` marker table (`build`→`verify.md`/`review.md` `stale: build`; `design`→`verify.md`/`review.md` `stale: design`; `spec`→`design.md`/`tasks.md`/`verify.md`/`review.md` `stale: spec`); the re-entry and re-ship behavior; and the no-auto-detection rule. Reconcile the `## Derived state` prose clause (`:823-826`) so readiness consumes the revocation. Add a `## Routing heuristics` `/ship recall` bullet and a `### 6. Ship` mention. Change no table row and none of the `20-lifecycle.sh:60-78` route literals. [AC1, AC2, AC3, AC4, AC6, AC7, AC9, AC11, AC12, AC14]
      Verify: `rg -n 'recall|reopened|branch abandoned|never opened' docs/workflow.md` finds the route, the states, and the marker; `rg -n 'stale: build|stale: design|stale: spec' docs/workflow.md` shows the marker table; `bash tests/run.sh` exits 0.

- [ ] **T2** — In `docs/workflow.md` → `## Roadmaps` → `### Dependencies and readiness` (`:87-108`), add the recalled-item branch to the single `satisfied(dep_local_id)` authority: a `ship.md` carrying a `reopened:` marker is not satisfied; a non-recalled `ship.md` still satisfies. Add the deferred clause that a recalled item blocks its dependents until it re-ships, referencing the reopen authority. Keep the pinned phrases `satisfied(dep_local_id):` (once), `even if unshipped`, `presence is the sole shipped signal`, and `ship.md` presence takes precedence verbatim. [AC5, AC10, AC12, AC13] [depends: T1]
      Verify: `rg -n 'satisfied\(dep_local_id\):' docs/workflow.md` returns exactly one hit; `rg -n 'presence is the sole shipped signal|presence takes precedence|reopened' docs/workflow.md` shows the pinned phrases plus the recalled branch; `bash tests/checks/10-readiness.sh` (via `bash tests/run.sh`) is green.

- [ ] **T3** — In `docs/artifact-conventions.md`, expand the `reopened` bullet (`:53-56`) to state it is set by `/ship recall`, names the re-entry phase label (`spec | design | build`), revokes the shipped signal without deleting the historical `ship.md`, is distinct from `status`, and is cleared only when the shipper writes a fresh `ship.md` on re-ship. Add a note to the `backtracks.md` template section that the detecting phase may be `/ship` for a post-ship recall. [AC3, AC12] [depends: T1]
      Verify: `rg -n 'reopened|/ship recall|detecting phase' docs/artifact-conventions.md` shows the expanded bullet and the note; `bash tests/run.sh` exits 0.

- [ ] **T4** — In `.opencode/agent/shipper.md`, add the `recall` mode: the usage form `/ship recall <item-ref> <phase>` in mission/inputs; the preconditions (explicit invocation, `ship.md` present, `<phase> ∈ {spec, design, build}`, else refuse); the six-step process (append the `/ship` finding to `backtracks.md`; add the `reopened: <phase>` marker and refresh `updated` without touching the body; apply the per-phase `stale:` markers; commit the revocation; report the push/open commands when `gh`/the branch is unavailable; hand off to the re-entry phase). Add the re-ship clause (recalled item: reuse the branch/PR, add commits, update the PR or open a new one when pruned, never force-push/rebase/rewrite, never delete/close the denied PR, then write a fresh `ship.md` without the marker). Keep the work-item, fix, and plan modes unchanged. [AC1, AC2, AC3, AC6, AC7, AC8, AC9, AC11] [depends: T1]
      Verify: `rg -n 'recall|reopened|re-ship|force-push' .opencode/agent/shipper.md` finds the mode and the re-ship clause; `bash tests/run.sh` exits 0.

- [ ] **T5** — In `.opencode/command/ship.md`, update the `description:`/usage line to add `| /ship recall <item-ref> <phase>` (keeping `Usage: /ship [item-ref]` and the fix clause as prefixes) and add the argument-grammar entry plus a `recall`-mode body mirroring the agent: preconditions, the record/revoke/mark/commit steps, and the re-ship clause. Keep the base canonical signature `/ship [item-ref]` unchanged. [AC8, AC12] [depends: T4]
      Verify: `rg -n 'Usage: /ship \[item-ref\].*recall' .opencode/command/ship.md` finds the extended usage; `rg -n 'recall' .opencode/command/ship.md` finds the mode body; `bash tests/run.sh` exits 0.

- [ ] **T6** — In `tests/checks/96-signature-sweep.sh`, add a `/ship recall` usage assertion in the `/ship` section (analogous to the existing `/ship fix` assertion) so the pinned command-signature agreement covers the new mode, while keeping the canonical registry `/ship [item-ref]` and the existing `/ship fix` literal unchanged. [AC8, AC13] [depends: T5]
      Verify: `rg -n 'ship recall|/ship \[item-ref\]' tests/checks/96-signature-sweep.sh` shows the new assertion and the unchanged base; `bash tests/run.sh` exits 0 with the sweep green.

- [ ] **T7** — In `.opencode/skill/workflow-lifecycle/SKILL.md`, add a line to the `## Which command now?` fence such as `ship.md present but PR denied/closed/changes-requested?→ /ship recall <item-ref> <phase>   (recall; revoke and re-enter)` (two-plus spaces before the trailing prose) and mention the recall in the rules section. Keep the existing seven route literals and the `/ship [item-ref]` line. [AC12] [depends: T1]
      Verify: `rg -n 'ship recall|reopened' .opencode/skill/workflow-lifecycle/SKILL.md` finds the route; `bash tests/run.sh` exits 0 (the skill route extractor skips the concrete `/ship recall` invocation).

- [ ] **T8** — In `AGENTS.md` and `template/AGENTS.md`, extend the Working-agreements `Backtracking` bullet with the post-ship recall: a shipped item whose PR is denied/closed/changes-requested (or never opened/branch abandoned) is recalled with `/ship recall <item-ref> <phase>`, which appends the finding, adds the `reopened:` marker to `ship.md` (revoking the signal without deleting it), marks the downstream artifacts `stale:`, blocks dependents until re-ship, and re-enters that phase. Add no lifecycle-table row and no `Supporting commands:` token. Keep the two shared bodies byte-identical outside the Project profile. [AC12] [depends: T1]
      Verify: `rg -n 'ship recall|reopened' AGENTS.md template/AGENTS.md` finds the bullet in both; the two Working-agreements sections diff clean outside the Project profile; `bash tests/run.sh` exits 0.

- [ ] **T9** — In `.opencode/agent/status.md` and `.opencode/command/status.md`, add the readiness-deferring clause: a recalled item (`ship.md` carrying a `reopened:` marker) does not satisfy a dependency and its dependents are reported blocked until it re-ships; keep the deferral to `docs/workflow.md` → "Dependencies and readiness" by name and add no branch sequence. [AC5, AC12] [depends: T2]
      Verify: `rg -n 'reopened|Dependencies and readiness' .opencode/agent/status.md .opencode/command/status.md` shows the clause plus the deferral; `bash tests/run.sh` exits 0.

- [ ] **T10** — In `.opencode/agent/builder.md` and `.opencode/command/build.md`, add the `/build` target-side re-entry: before selecting a task, read `work/<item-ref>/backtracks.md` for an open finding targeting `/build`; if present, this is a recall re-entry — revise the implementation/`tasks.md` per the finding, append a `## Resolution <n>` entry, clear any `stale:` marker on artifacts the builder owns, and resume forward. Keep the plan gate and the existing `/build`→`/plan` detecting edge unchanged, and do not add the `/test`/`/review`→`/build` detecting edges. [AC6, AC14] [depends: T1]
      Verify: `rg -n 'targeting /build|target.*/build|Resolution' .opencode/agent/builder.md .opencode/command/build.md` shows the re-entry; `bash tests/run.sh` exits 0.

- [ ] **T11** — Final consistency and scope pass: grep every surface named by AC12 for the route and confirm agreement; confirm no new file under `.opencode/{agent,command,skill}`, the six `phase` values, the command→agent pairings, and the `40-inventory.sh` counts are unchanged; confirm the `## Declared-conflict check` compared set and the sibling reverse edges are untouched; run the full suite. [AC10, AC12, AC13, AC14] [depends: T1, T2, T3, T4, T5, T6, T7, T8, T9, T10]
      Verify: `bash tests/run.sh` exits 0 with `0 failed`; `git diff --stat` lists only the surfaces named in `design.md`; `git status --short` shows no new `.opencode/` file.
