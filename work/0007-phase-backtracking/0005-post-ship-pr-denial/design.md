---
feature: 0007-phase-backtracking/0005-post-ship-pr-denial
phase: design
status: final
created: 2026-10-09
updated: 2026-10-09
parent: 0007-phase-backtracking
notes: "Resolves the spec's deferred open items (exact recall syntax, record wording, marker mechanics). The recall is a mode of the existing /ship command — `/ship recall <item-ref> <phase>` with the phase label `spec | design | build` — with no new command/agent/skill/phase value/state file. The shipper appends a `/ship`-detecting finding to the item's `backtracks.md`, adds the forward-declared `reopened: <phase>` marker to the existing `ship.md` (revoking the signal without deleting it), applies the 0002 `stale:` markers to the artifacts strictly downstream of the re-entry phase, and hands off to that phase. The readiness authority gains a recalled-item exclusion keyed on that same marker; a non-recalled `ship.md` is unchanged. Re-entry reuses 0002 unchanged for `/plan` and `/spec`; the `/build` target gains the target-side re-entry check in the builder and `/build` command because 0002 wired only `/plan` and `/spec` (target-side only — the `/test`/`/review`→`/build` detecting edges remain siblings' scope). Re-ship is the ordinary `/ship` work-item path (extend the branch/PR, never force-push). The spec's two assumptions (explicit maintainer action; re-ship reuses ordinary `/ship`) are adopted; the spec body's non-goals and AC9/AC11 already state them. The design's `conflicts-with` lists the full edited surface set, a superset of the parent row's cell, so the read-only declaration check reports DRIFT-FACT by design (advisory; updating the parent cell is the roadmap owner's write)."
conflicts-with: "docs/workflow.md, docs/artifact-conventions.md, AGENTS.md, template/AGENTS.md, .opencode/agent/shipper.md, .opencode/command/ship.md, .opencode/skill/workflow-lifecycle/SKILL.md, .opencode/agent/status.md, .opencode/command/status.md, .opencode/agent/builder.md, .opencode/command/build.md, tests/checks/96-signature-sweep.sh"
---

# Design — Post-ship PR denial, recall, and reopen

## Summary

A post-ship denial is handled by a **recall** that is a mode of the existing
`/ship` command — `/ship recall <item-ref> <phase>` — which appends a finding to
the item's `backtracks.md` (detecting `/ship`, target the re-entry phase),
populates the forward-declared `reopened: <phase>` marker on the existing
`ship.md` (revoking the shipped signal without deleting or rewriting it),
applies the shipped `0002` `stale:` markers to the artifacts strictly downstream
of the re-entry phase, and hands off to that phase. The readiness authority gains
one recalled-item branch keyed on the same marker, so a recalled item stops
satisfying its dependents until it re-ships; every other contract — the six
`phase` values, the command/agent/skill inventories, the non-recalled shipped
signal, and the `0001`/`0002` record and re-entry — is unchanged. Re-ship is the
ordinary `/ship` work-item path, extending the existing branch/PR and never
force-pushing.

## Approach

### 1. Post-ship states (AC1, AC11)

The authority is `docs/workflow.md` → `## Phase reversal (backtracking)` →
`### Shipped items and reopen` (currently a forward pointer at `:788-795`). It is
expanded to enumerate the states and keep them distinct from the pre-ship states
and a normally shipped item:

- **Pre-ship** (no `ship.md`): the item is anywhere from `spec` through `review`;
  a defect is handled by the `0001`/`0002` reverse edges, never a recall.
- **Shipped-N (`ship.md` present, no `reopened:` marker): a PR is open and
  awaiting human review, or merged, or was **never opened** (for example `gh` was
  unavailable and only local commits exist), or its **branch was abandoned**.
  All four are the same state under the single shipped signal and stay shipped
  until an explicit recall.
- **Recalled/reopened** (`ship.md` present with `reopened: <phase>`): the shipped
  signal is revoked; the item derives the named phase (reopened) and does not
  satisfy dependents.
- **Denied / closed / changes-requested** is not a state by itself: it is the
  triggering condition a maintainer reports when invoking a recall. No automatic
  detection and no automatic revocation occurs (AC11).

### 2. Recall invocation (AC7, AC8)

The recall is a documented **mode of the existing `/ship` command**; no new
command, agent, skill, `phase` value, or state file is added:

```
/ship recall <item-ref> <phase>
  <phase> ∈ { spec | design | build }     # phase labels, strictly earlier than ship
  spec   -> re-enter /spec   (record target phase `/spec`)
  design -> re-enter /plan   (record target phase `/plan`)
  build  -> re-enter /build  (record target phase `/build`)
```

- The argument is the **phase label** used by the `reopened:` marker, the `stale:`
  markers, and the derived-state table (`spec | design | build`), so the write is
  a direct copy. The record's `target phase` and the handoff use the corresponding
  command (`/spec`, `/plan`, `/build`) because the `0001` finding template and the
  `0002` re-entry predicate (`architect.md:70-72`) are expressed as commands.
- `<phase>` is refused unless it is strictly earlier than ship; `test`, `review`,
  and `ship` are refused. The mode is refused when no `ship.md` exists (an
  unshipped item is an ordinary backtrack, not a recall) (AC7, AC11).
- The mode requires the user's explicit invocation, which is the consent to
  record and commit the revocation; the shipper is the only git writer.

### 3. The recall procedure (AC2, AC3, AC6, AC7)

Stated once in the authority; implemented in the shipper. The shipper:

1. **Verify** the preconditions: `work/<item-ref>/ship.md` exists, `<phase>` is one
   of `spec | design | build`, and the user explicitly invoked the mode.
2. **Record the finding.** Append a `## Finding <n>` entry to
   `work/<item-ref>/backtracks.md` (creating the record with the `0001` frontmatter
   `feature`, `record: backtracks`, `created`, `updated` when absent). Numbering is
   sequential and append-only; no prior entry is edited or removed:

   ```markdown
   ## Finding <n> — YYYY-MM-DD

   - detecting phase: `/ship`
   - target phase: `/build` | `/plan` | `/spec`
   - affected: `ship.md` (shipped signal revoked), plus the downstream artifacts
     marked `stale: <phase>`
   - evidence: <triggering condition — PR denied / closed / changes-requested, PR
     never opened, or branch abandoned — and its observable evidence>
   - status: open
   ```

3. **Revoke the shipped signal.** Add the `reopened: <phase>` field to the
   `ship.md` frontmatter and refresh `updated`; leave the recorded branch, commits,
   PR URL, and `## Reconcile` body intact. The marker is distinct from the
   frontmatter `status` and does not overload it (AC3).
4. **Mark the downstream artifacts `stale: <phase>`**, reusing `0002`'s
   non-destructive mechanical marking (the detecting phase applies it; the target
   phase's own artifacts are revised, not marked):

   | Re-entry phase | `ship.md` marker | Artifacts marked `stale:` |
   | -------------- | ---------------- | ------------------------- |
   | `build` (`/build`) | `reopened: build` | `verify.md`, `review.md` → `stale: build` |
   | `design` (`/plan`) | `reopened: design` | `verify.md`, `review.md` → `stale: design` |
   | `spec` (`/spec`) | `reopened: spec` | `design.md`, `tasks.md`, `verify.md`, `review.md` → `stale: spec` |

   Whichever downstream artifacts exist are marked; absent ones are skipped
   (mirrors `0002`'s finding-only case). Nothing is deleted or silently rewritten;
   the pre-revision content stays recoverable from committed git history (AC6).
5. **Commit and report.** Commit the revocation and record with a conventional
   message on the item's branch (`docs(work): recall <item-ref>`); when no branch
   exists, make the local commits and report the exact commands the user runs to
   push. The mode requires no network: a `gh`-unavailable run still records and
   revokes through local committed state (edge cases).
6. **Hand off** `Next: /build <item-ref>` / `/plan <item-ref>` / `/spec <item-ref>`.

A second recall (for example after a re-ship and a new denial) appends a new
finding and re-applies/updates the `reopened:` marker; no prior entry is erased
and the marker names the latest re-entry phase (edge case).

### 4. Readiness revocation (AC5, AC10)

`docs/workflow.md` → `## Roadmaps` → `### Dependencies and readiness` states the
readiness algorithm exactly once; it gains one branch, keyed on the same
`ship.md` marker (no second signal, no stored value):

```
satisfied(dep_local_id):
  child_dir = work/<parent>/<dep_local_id>/
  if child_dir does not exist        -> dangling; not satisfied
  if child_dir/ship.md exists
       and it carries a `reopened:` marker -> not satisfied   # recalled; signal revoked
  if child_dir/ship.md exists        -> satisfied   # shipped; presence is the sole shipped signal
  if child_dir/review.md exists
       and its verdict == "approve"  -> satisfied   # approved, even if unshipped
  otherwise                          -> not satisfied
```

A recalled item therefore blocks its dependents until it re-ships; a non-recalled
`ship.md` presence and an `approve` verdict still satisfy exactly as before. The
pinned phrases `presence is the sole shipped signal` and
`ship.md` presence takes precedence are preserved (`tests/checks/10-readiness.sh`).
The readiness-deferring surfaces (`status` agent, `/status` command) gain the
recalled-item clause; they keep deferring to the authority by name.

### 5. Derived state and re-entry (AC4, AC6)

The `reopened:` derived-state row already exists from `0001`; the item derives
`P (reopened)` while the marker is present. The `## Derived state` prose clause
that currently calls the readiness signal "`ship.md` presence alone" is adjusted
to say readiness consumes the revocation, pointing at the recall authority. While
downstream `stale:` markers exist the earliest-`stale:` row derives the same `P`
(backtracked), so the phase is `P` throughout the recall.

Re-entry is `0002`'s unchanged: the target phase's owner reads the open finding
targeting its phase, revises its own artifact(s), appends a `## Resolution <n>`
entry, clears the `stale:` markers on artifacts it owns, and resumes forward.
- `/plan` (architect) and `/spec` (product) re-entry already exists from `0002`.
- `/build` (builder) re-entry is wired by this item because `0002` wired only
  `/plan` and `/spec`: the builder's process gains the same open-finding-target
  `/build` check. This is the **target side** of the recall only; the
  `/test`/`/review`→`/build` detecting edges stay a sibling's scope (AC14).

The target owner clears its own `stale:` markers but **not** the `reopened:`
marker; the item stays recalled (and dependents stay blocked) until it re-ships.

### 6. Re-ship (AC9)

Re-ship is the ordinary `/ship <item-ref>` work-item path. For a recalled item
(`ship.md` present with `reopened:`, a fresh `review.md` `approve`), the shipper,
mirroring the plan-publication revision flow: reuses the branch recorded in
`ship.md`, adds commits, pushes without force, updates the existing PR or opens a
new one when the branch was pruned, never rebases a pushed branch, never
force-pushes, never rewrites pushed history, and never deletes or closes the
denied PR. It then writes a fresh `ship.md` for the new ship **without** the
`reopened:` marker (the shipper's own artifact), so the item derives `shipped`
and satisfies its dependents again; the recall stays auditable in `backtracks.md`
and in git history. The marker is the only thing that revokes the signal, so
clearing it is the ship-side counterpart of the recall.

### 7. Surface consistency (AC8, AC12)

The recall route is stated consistently on the surfaces AC12 names, and the
`/ship` mode is documented on the command/agent:
- `docs/workflow.md` — the authority (§1, §3, §4, §5, §6), a
  `## Routing heuristics` bullet, and a `### 6. Ship` mention.
- `docs/artifact-conventions.md` — the `reopened` field bullet (set by
  `/ship recall`, names the re-entry phase, revokes the shipped signal, cleared
  when the item re-ships) and a `backtracks.md` note that the detecting phase may
  be `/ship`.
- `.opencode/agent/shipper.md` and `.opencode/command/ship.md` — the mode.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — a routing line.
- `AGENTS.md` and `template/AGENTS.md` — one Working-agreements bullet each,
  kept in agreement (the two shared bodies stay byte-identical outside the
  Project profile, per `tests/checks/95-split-guard.sh`).
- `.opencode/agent/status.md` and `.opencode/command/status.md` — the readiness
  clause.
- `.opencode/agent/builder.md` and `.opencode/command/build.md` — the `/build`
  re-entry.

The `/ship` **canonical base signature** stays `/ship [item-ref]` on every
signature surface (AGENTS/template table, README Commands table and mermaid, the
skill routing line, the workflow phase heading); only the command's own usage
string enumerates the new mode, exactly as `/ship fix` and `/ship plan` are
already handled. `tests/checks/96-signature-sweep.sh` keeps its `/ship [item-ref]`
assertion and the `Usage: /ship [item-ref] | /ship fix [short description]`
assertion, and gains a `/ship recall` usage assertion so the pinned agreement
covers the new form. No file is added under `.opencode/`, so
`tests/checks/40-inventory.sh` and the command→agent pairings are unchanged.

## Alternatives considered

- **Chosen — reuse `/ship` as a recall mode and revoke through the existing
  `reopened:` marker.** Pros: no new command/agent/skill/phase value/state file;
  reuses the `0001` marker, the `backtracks.md` record, the `stale:` marker, and
  the `0002` re-entry; keeps the inventories and the readiness single-source
  intact; matches the spec's resolved user forks. Cons: the recall is carried by
  prompt prose, so correctness depends on the shipper following the authority.
- **Rejected — a new `/reopen <item-ref> <phase>` command.** Pros: an explicit
  mechanical entry point. Cons: adds a command, changing the README Layout counts
  and `## Commands` table, the `AGENTS.md` `Supporting commands:` line, the
  command→agent pairings, `96-signature-sweep.sh`, and `/doctor`'s inventories —
  contradicting AC8's no-new-command constraint and the spec's resolved
  invocation fork. "Reopen" also collides with the GitHub PR-reopen action.
- **Rejected — revoke with a new `revoked:`/`superseded:` field or a superseding
  artifact.** Pros: an explicit revocation record. Cons: forks the `0001`
  marker vocabulary, adds an artifact-presence row / state file the spec forbids,
  and would require `0006` to learn a second state; the forward-declared
  `reopened:` marker already expresses exactly this and is user-resolved.
- **Rejected — readiness reads a stored readiness/revocation value.** Pros:
  simple display. Cons: violates "readiness is derived live, never stored" and
  introduces a second signal; AC5 requires the single presence-keyed signal to be
  extended, not duplicated.
- **Rejected — expand the canonical `/ship` signature to all modes on every
  surface.** Pros: one fully enumerating signature. Cons: churns the AGENTS and
  README tables, the README mermaid, the skill routing line, and the workflow
  heading, and diverges from the shipped `/ship fix`/`/ship plan` treatment where
  the modes live only on the command usage line; AC8 is satisfied by the usage
  string plus the sweep.
- **Rejected — recall argument as the command (`/plan`) instead of the phase
  label (`design`).** Cons: the `reopened:`/`stale:` tokens are the derived-phase
  labels (`design` for the plan phase), so a command argument would need a lossy
  mapping on the safety-critical marker write; the record and handoff map once
  and in the direction the templates already use.

## Interfaces and data model

### Invocation

```
/ship [item-ref] | /ship plan <item-ref> | /ship fix [short description] | /ship recall <item-ref> <phase>
  recall  -> post-ship recall/reopen mode; <phase> ∈ { spec | design | build }
```

### `backtracks.md` finding entry (shape is `0001`'s; this item fixes the values)

```markdown
## Finding <n> — YYYY-MM-DD

- detecting phase: `/ship`
- target phase: `/build` | `/plan` | `/spec`
- affected: `ship.md` (shipped signal revoked), `verify.md`, `review.md`
- evidence: <trigger condition + evidence>
- status: open
```

The target's owner appends the matching `## Resolution <n>` per `0002`.

### `ship.md` frontmatter

```yaml
reopened: design   # optional; set by /ship recall to the re-entry phase label
                   # (spec | design | build); revoked signal until re-ship
updated: YYYY-MM-DD
```

Cleared only when the shipper writes a fresh `ship.md` on re-ship. Distinct from
`status` (`draft`/`final`/`blocked`).

### Readiness predicate

The single `satisfied(dep_local_id)` authority gains the recalled-item branch
shown in §4. Backward compatible: an absent marker is byte-identical behavior.

### Derived state

No table change — the `0001` `reopened:` row is used as shipped. Only its prose
clause about the readiness signal is reconciled (§5).

## Affected areas

- `docs/workflow.md` — `### Shipped items and reopen` (`:788-795`) expanded to
  the post-ship states and recall authority; `### Dependencies and readiness`
  (`:87-108`) recalled branch; `## Derived state` prose (`:818-830`); a
  `## Routing heuristics` bullet (`:864+`); a `### 6. Ship` mention (`:385-405`).
- `docs/artifact-conventions.md` — the `reopened` bullet (`:53-56`); the
  `backtracks.md` template note (`:471-520`).
- `.opencode/agent/shipper.md` — mission, inputs, preconditions, process, rules,
  handoff: the recall mode and the re-ship clause.
- `.opencode/command/ship.md` — description/usage, argument grammar, recall-mode
  body, re-ship clause.
- `.opencode/skill/workflow-lifecycle/SKILL.md` — `## Which command now?` line.
- `AGENTS.md`, `template/AGENTS.md` — Working-agreements bullet (kept in parity).
- `.opencode/agent/status.md`, `.opencode/command/status.md` — readiness clause.
- `.opencode/agent/builder.md`, `.opencode/command/build.md` — `/build` re-entry.
- `tests/checks/96-signature-sweep.sh` — the `/ship recall` usage assertion.

**Not touched (scope fence, AC14):** any new file under
`.opencode/{agent,command,skill}`; the six `phase` values; the command→agent
pairings; `40-inventory.sh` counts; `README.md` (canonical `/ship` unchanged);
`20-lifecycle.sh` route literals; `80-cycle-fixture.sh`, `85-conflict-guards.sh`,
`10-readiness.sh` literals; the `## Declared-conflict check` compared set (its
`ship.md` exclusion is not an irrevocability claim; committed guards are
`0007`'s scope); the merge-conflict contract; and the sibling reverse edges
(`0002`), challenge loop (`0003`), roadmap revision (`0004`), `/status`
vocabulary (`0006`), and committed guards (`0007`).

## Risks and mitigations

- **Readiness pinned literals** — `tests/checks/10-readiness.sh` requires
  `satisfied(dep_local_id):` exactly once in `docs/workflow.md`,
  `presence is the sole shipped signal`, and `ship.md` presence takes
  precedence. *Likelihood high (we edit that block) / impact high (false
  regression) / mitigation:* add the recalled branch and keep every pinned
  phrase verbatim (algorithm comment plus prose); no second algorithm statement;
  run `bash tests/run.sh`.
- **Derived-state literal drift** — `tests/checks/20-lifecycle.sh:60-78` pins the
  seven route literals and the derived-state artifact names. *Likelihood medium /
  impact high / mitigation:* change only the readiness clause of the derived-state
  prose; leave every table row and route literal untouched; run the suite.
- **Signature-sweep coupling** — `96-signature-sweep.sh` pins the `/ship` usage
  string and the canonical `/ship [item-ref]`. *Likelihood high (we extend the
  usage line) / impact high / mitigation:* keep the base canonical and the repair
  literal (`Usage: /ship [item-ref] | /ship fix [short description]`) present as
  prefixes; add a sibling `/ship recall` assertion; run the suite.
- **Root vs adopter-pristine `AGENTS.md` drift** — `tests/checks/95-split-guard.sh`
  requires the two bodies byte-identical outside the Project profile.
  *Likelihood medium / impact high / mitigation:* add the identical Working-
  agreements bullet to both in one task and diff the shared sections; run the suite.
- **Inventory drift** — `40-inventory.sh` counts agents/commands/skills.
  *Likelihood low / impact high / mitigation:* add no file under `.opencode/`;
  edit existing files only; run the suite.
- **Re-entry gap for the `/build` target** — `0002` wired only `/plan` and
  `/spec`, so a `/build` recall would leave the finding unresolved. *Likelihood
  high (by construction) / impact medium / mitigation:* add the target-side
  open-finding check to the builder and `/build` command; state it as target-side
  only and leave the `/test`/`/review`→`/build` detecting edges to siblings.
- **Marker vs status confusion** — the recall could be read as overloading the
  frontmatter `status`. *Likelihood medium / impact medium / mitigation:* state
  that `reopened:` is distinct from `status` and adds no `phase` value, in the
  authority and `docs/artifact-conventions.md`.
- **Derived phase during the recall re-work** — the item derives `P`
  (backtracked/reopened) throughout, so the fine-grained "next command" during
  the recall is `0006`'s reporting scope. *Likelihood medium / impact low /
  mitigation:* state the domain boundary explicitly; this item fixes the state
  shapes and leaves the vocabulary to `0006`.
- **Recall commit branch mechanics** — which branch carries the revocation.
  *Likelihood medium / impact medium / mitigation:* mirror the shipped
  plan-publication revision wording (uses the item branch; local commits when no
  branch/network); never force-push; re-ship extends.
- **No committed guard** — fixtures and mutation coverage are `0007`'s scope.
  *Likelihood high / impact low / mitigation:* the test strategy maps every AC to
  a suite run or a recorded surface inspection; the residual is recorded.

## Test strategy

The deliverable is framework documentation and prompts; committed fixtures and
mutation coverage are `0007-backtracking-guards`. Verification is the existing
suite plus observable inspection of the named surfaces, recorded in `verify.md`.

| Criterion | Verification level |
| --------- | ------------------ |
| AC1 | Manual: `### Shipped items and reopen` enumerates the post-ship states and distinguishes pre-ship/shipped/recalled. |
| AC2 | Manual: the shipper recall process appends the `/ship` finding with condition, evidence, and re-entry phase; append-only. |
| AC3 | Manual: `reopened:` added to the existing `ship.md`; body untouched; distinct from `status`; `artifact-conventions.md` bullet. |
| AC4 | Manual + suite: the `0001` `reopened:` derived row is used; the readiness prose clause reconciled; no new row. |
| AC5 | Suite: `bash tests/checks/10-readiness.sh` green; the recalled branch present; the `status` deferring clause present. |
| AC6 | Manual: the recall marker table + the re-entry section; `/build`/`/plan`/`/spec` owners read the open finding and append a resolution. |
| AC7 | Manual: `<phase> ∈ {spec, design, build}`, strictly earlier than ship, refused otherwise; deterministic from the record. |
| AC8 | Suite: `96-signature-sweep.sh` green with the `/ship recall` usage assertion; `40-inventory.sh` green; no new command/agent/skill. |
| AC9 | Manual: the shipper re-ship clause reuses the branch/PR, opens a new PR when pruned, never force-pushes, never closes the PR. |
| AC10 | Suite + manual: a non-recalled `ship.md` satisfies exactly as before; no second signal/state file/phase value. |
| AC11 | Manual: never-opened/abandoned remain shipped until an explicit recall; no detection code or auto-revoke. |
| AC12 | Manual grep of all named surfaces; root vs `template/AGENTS.md` bullets agree. |
| AC13 | Suite: `bash tests/run.sh` → exit 0, `0 failed`; the signature agreement updated with the change. |
| AC14 | Manual + `git diff --stat`: only the named surfaces; no new `.opencode/` file; sibling scope untouched. |

## Compatibility and migration

- **Additive.** An item without a `reopened:` marker is byte-identical behavior;
  no existing `ship.md`, `backtracks.md`, or `design.md` needs migration.
- **Readiness.** The single authority is extended; the absent-marker path is the
  shipped contract. No stored readiness value is introduced.
- **No new dependency.** Docs, prompts, and one test assertion; no runtime,
  build, or CI change.

## Follow-ups (out of scope; no expansion without user approval)

- `0006-status-and-derived-state` owns the full `/status` and derived-state
  reporting vocabulary for recalled/reopened items.
- `0007-backtracking-guards` owns the committed fixture and mutation coverage for
  the recall signal, the readiness no-longer-satisfied rule, and the derived
  states.
- If desired later, the parent `Children` row's `conflicts-with` cell can be
  updated to match this item's declaration; the roadmap owner owns that write.
