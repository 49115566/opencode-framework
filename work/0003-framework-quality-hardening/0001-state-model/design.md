---
feature: 0003-framework-quality-hardening/0001-state-model
phase: design
status: final
created: 2026-10-04
updated: 2026-10-04
parent: 0003-framework-quality-hardening
---

# Design — Artifact persistence and state model

## Summary

Adopt the committed model the user chose: remove the `work/*` exclusion from
`.gitignore` so every artifact under `work/` (phase artifacts, nested child
`.gitkeep` reservations, and visual screenshots) is version-controlled, while
`scratch/`, `.playwright-mcp/`, and opencode's generated state stay ignored.
Rewrite the persistence claims in the always-loaded contract, lifecycle docs,
README, prompts, and skills so one sentence is true everywhere, make numbering
durable by allocating from the committed tree plus git history, define a
merge-time renumbering procedure for parallel branches, and make `/bootstrap`
install and repair the committed policy.

## Approach

This is a documentation-and-configuration change; no runtime code or dependency
is introduced. It has five parts.

1. **Ignore policy.** Delete the `work/*` / `!work/.gitkeep` pair from the root
   `.gitignore`. Nothing replaces it: with no matching rule, `work/` contents are
   trackable, and the already-tracked `work/.gitkeep` keeps the root directory.
   The existing non-artifact entries (`.playwright-mcp/`, `scratch/`, the
   `.opencode/` generated-state block, and the stack entries) are retained
   verbatim so `doctor`'s `IGNORE-MISSING` policy is untouched.

2. **One canonical persistence statement.** Every surface that describes where
   state lives states the committed model. We reuse one wording so the surfaces
   cannot drift and `doctor`-style agreement checks can compare literals:

   > Workflow artifacts under `work/` are **committed working state**:
   > version-controlled so a fresh clone, a teammate, and CI derive the same
   > phase. Only `scratch/` and opencode's generated state are ignored.

   `git-ignored` / `not deliverables` framing is removed from `AGENTS.md`,
   `docs/workflow.md`, `README.md`, and the `.gitignore` comment.

3. **Durable numbering.** The allocation rule stops being "list `work/` and add
   one" and becomes "take the greatest 4-digit prefix that has *ever* appeared in
   the committed history of `work/`, add one." Git history is the durable ledger,
   so a deleted directory cannot free its number and a fresh clone sees the same
   maximum. No ledger file is introduced (AC12).

4. **Parallel-branch reconciliation.** Because two branches can each create
   `0004-*`, merging does not conflict at the filesystem level and can silently
   produce two items sharing number `0004`. The lifecycle documents a
   deterministic resolution: detect duplicate prefixes, pick one item, renumber
   it to the next free number, and update every reference in the same change.

5. **Adoption and handoff.** `/bootstrap` now guarantees `work/` exists and is
   *not* ignored, and repairs an adopter's pre-existing `work/` ignore rule;
   the quickstart documents the guarantee and that a local-only posture is an
   unsupported override. The shipper is told to stage `work/<item-ref>/` as part
   of the item so the artifact links in the PR resolve.

## Alternatives considered

- **Local-only model** (keep `work/*` ignored; remove artifact links from PR
  bodies; state plainly that teammates/CI cannot see artifacts). *Pros:* smaller
  repository, no binary-growth trade-off, no merge concerns. *Cons:* abandons the
  framework's central "artifacts are the state" claim, kills the PR handoff, and
  leaves "complete state" false for a fresh clone. **Rejected** — the user's
  2026-10-04 decision recorded in the spec; this is exactly the option the spec
  frames as the one not taken.

- **Committed artifacts behind a committed ledger file** (e.g. a tracked
  `work/.allocations` recording every number ever issued). *Pros:* makes "never
  reuse" explicit and trivially machine-checkable. *Cons:* introduces a second
  state store, which the spec non-goals and AC12 forbid; it duplicates a fact
  already present in the committed tree and its history and can drift from them.
  **Rejected** — git history is already the durable ledger.

- **Keep ignoring `work/`, force-add artifacts per PR (`git add -f`).**
  *Pros:* no `.gitignore` change, so the existing contradiction is "fixed" at
  commit time. *Cons:* `git status` and `git check-ignore` still report artifacts
  as ignored, failing AC1; adopters and CI get no default; every producer must
  remember to force-add. **Rejected** — it preserves the defect the spec exists to
  remove.

- **Binary-evidence size policy now (Git LFS or `.gitattributes`).** *Pros:*
  controls repository growth from screenshots. *Cons:* explicitly a spec
  non-goal; adds tooling. **Rejected** — out of scope; surfaced as an accepted
  trade-off instead.

## Interfaces and data model

No code interfaces. The concrete contracts are the ignore file, the allocation
algorithm, the reconciliation procedure, and the adoption postconditions.

### `.gitignore` — before / after

Before (lines 5–8):

```
# Workflow artifacts are working state, not source. One directory per feature
# lives under work/. Keep the directory itself so `work/` always exists.
work/*
!work/.gitkeep
```

After — the block is replaced with a comment marking artifacts as committed;
no `work/` pattern remains:

```
# Workflow artifacts under work/ are committed working state. Do not ignore
# them. Only scratch/ and tooling output below are ignored.
```

Everything else (`.opencode` generated state, `.playwright-mcp/`, `scratch/`,
stack, editors) is unchanged.

### Allocation contract (`next_work_number`)

- **Source set:** the union of every 4-digit prefix in (a) directory names under
  `work/` at HEAD (`ls work/`) and (b) every path ever committed under `work/`,
  read with `git log --all --name-only --pretty=format: -- work/` (the history
  call is what makes deletion-safe allocation possible).
- **Result:** `max(source_set) + 1`, zero-padded to 4 digits, or `0001` when the
  set is empty.
- **Invariant:** a number is never reused, even after its directory is deleted;
  the deleted number stays visible in committed history and therefore in the
  source set.
- **Constraint:** the algorithm must not create a registry or any other file.
  Both commands are already within `product`/`roadmap` bash allowlists
  (`git log*`, `ls*`), so no permissions change is required.

### Parallel-merge reconciliation

Requested by AC10 and the "two branches allocate the same next number" edge
case. Procedure, performed on the merged tree before shipping the affected item:

1. **Detect.** Any top-level `work/` directory whose 4-digit prefix equals
   another's is a collision; likewise any two canonical references that differ
   only by slug under the same number. Also check each roadmap parent's child
   numbers for duplicates.
2. **Choose one.** Renumber the item that is *not yet approved/shipped*; if both
   are unshipped, renumber the one whose directory was added later by commit
   time (`git log --diff-filter=A`), breaking ties by slug order. The chosen
   number stays spent and is never reassigned.
3. **Renumber.** `git mv work/<old>/ work/<new>/` using the allocation contract.
4. **Update every reference in the same change:** the directory name; the
   artifact `feature:` frontmatter value; a nested child's `parent:` value; the
   roadmap `Children` table `Canonical reference` cells; `ship.md` and PR/handoff
   paths; and any prose that names the old reference.
5. **Record.** Note the renumber in the item's newest artifact frontmatter
   `notes` (or the PR description when the artifacts are already immutable
   history).

Renumbering is the one sanctioned mechanical cross-phase edit: it changes
references, never decisions or content. It happens at merge time, before the
item ships, so it does not rewrite historical records to fit the new model.

### Adoption contract (`/bootstrap`)

Postconditions replace the current "ignore `work/`" requirement:

- `work/` exists.
- `.gitignore` contains no rule matching `work/` (a pre-existing `work/*` or
  `work/` rule is removed).
- `scratch/` and `.playwright-mcp/` remain ignored.
- If the adopter demands local-only artifacts, bootstrap stops and states what
  will not work: PR artifact links and fresh-clone/teammate/CI state.

### Ship contract

`shipper` stages and commits `work/<item-ref>/` together with the item, so that
`work/<item-ref>/spec.md`, `design.md`, `verify.md`, and `review.md` exist on the
branch the PR is opened from (AC7). The existing rule against staging
`.gitignore`-matched files is unchanged and now does not exclude artifacts.

### Derived state

Unchanged. Phase, task progress, verdict, and shipped state continue to be
derived from file existence and content. No state file or registry is added
(AC12); git history is used only as a read source for numbering.

## Affected areas

| File | Change |
| ---- | ------ |
| `.gitignore:5-8` | Remove `work/*` and `!work/.gitkeep`; replace working-state comment with committed-state comment. |
| `AGENTS.md:65` | State the canonical committed model in the artifact contract. |
| `docs/workflow.md:13-14,55` | "Complete state" qualified as committed; remove "git-ignored / not deliverables". |
| `docs/workflow.md:272-276` | Keep "proceed in parallel"; add duplicate-number detection and the renumber procedure pointer; note artifacts travel with the branch. |
| `docs/artifact-conventions.md` (top + `## Sequence allocation`) | Add the canonical persistence statement; replace allocation rule with the history-aware contract; document reconciliation; preserve the literals `Never reuse` and `never reused within that parent`. |
| `README.md:17-18,199-212` | Layout marks `work/` committed and `scratch/` ignored; "Artifacts before code" notes portability. |
| `README.md:33-53` | Quickstart note: copied `.gitignore` does not ignore `work/`; `/bootstrap` repairs an existing rule; local-only is unsupported. |
| `.opencode/agent/bootstrap.md:58,93-94,100-107,122-128` | Inputs mention the committed policy; step 5, quality bar, and handoff ensure `work/` is not ignored and repair an adopter rule. |
| `.opencode/command/bootstrap.md:20-21` | Wording: ensure `work/` and `.gitignore` reflect the committed model. |
| `.opencode/agent/shipper.md:35-39,75-88,90-99` | Stage/commit `work/<item-ref>/`; links resolve; ignore rule unchanged. |
| `.opencode/skill/pr-workflow/SKILL.md:11-16,43-49` | Note that linked artifact paths resolve because `work/` is committed. |
| `.opencode/agent/visual.md:43-44` / `.opencode/skill/browser-verification/SKILL.md:46-48,65-66` | Note screenshots under `work/` are committed; only `scratch/` is ignored. |
| `.opencode/agent/product.md:77` / `.opencode/agent/roadmap.md:91-99` | Allocation uses the committed tree + history contract; child `.gitkeep` reservations persist. |
| `.opencode/skill/workflow-lifecycle/SKILL.md:17-24` | Note state lives in committed `work/` artifacts. |
| `.opencode/agent/status.md:36-45` | One-line persistence qualifier ("committed"). |
| `.opencode/agent/doctor.md` / `.opencode/command/doctor.md` | **No catalogue change** — owned by sibling `0004-doctor-scope`; confirm the `.playwright-mcp/`+`scratch/` policy survives and stays clean (AC6). |

Existing static suites `work/0001-framework-consistency-hardening/verify-tests.sh`
and `work/0002-agentic-roadmaps/verify-tests.sh` must continue to pass. Two of
their assertions bound the edits: `0002` requires the literals `Never reuse`,
`never reused within that parent`, and `proceed in parallel` to survive, and
forbids the token `"git add` (etc.) in `roadmap.md`; `0001` requires
`.playwright-mcp/` and `scratch/` to stay ignored and forbids `/tmp` guidance in
the swept surfaces.

### Migration note

The first `/ship` under this change includes the previously untracked corpus
(`0001-*`, `0002-*`, `0003-*`, including their `verify-tests.sh`, `verify.md`,
`ship.md`, and all nested child `.gitkeep` files) in the same PR. That is
intended by the spec goal to bring the existing corpus under version control. The
shipper must scan staged content for secrets as usual; artifacts are prose and
scripts, so the risk is low but not zero.

## Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
| ---- | ---------- | ------ | ---------- |
| Committing the whole historical corpus in one PR makes it large and hard to review. | High | Low | Call it out in the PR description as a one-time migration; the shipper commits artifacts as their own logical unit, separate from the framework edits. |
| An artifact accidentally contains a secret or a machine-specific absolute path. | Low | High | Shipper's existing secrets scan and "only work-item changes" precondition apply; the builder must not add such content, and the design keeps changes to config/prose. |
| `shipper.md` staging guidance overlaps sibling `0002-readiness-ship-state`, which also edits `shipper.md` (`edit` permission, `ship.md` fate). | Medium | Medium | Keep this item's shipper edit additive and confined to staging/links; leave permissions and `ship.md` untouched; note the overlap in the handoff. |
| A future contributor re-adds a `work/` ignore rule out of habit. | Medium | Medium | The canonical comment in `.gitignore` plus the bootstrap postcondition and the docs sweep; sibling `0006` can add a regression assertion. |
| Renumbering after a merge edits artifacts owned by other phases, clashing with immutability. | Low | Medium | Scope renumbering to reference-only mechanical edits at merge time, before ship; document it as the single sanctioned cross-phase edit; never rewrite decisions. |
| Duplicate numbers can exist undetected after a merge because git does not conflict on distinct directory names. | Medium | Medium | Document detection and resolution (AC10); recommend the duplicate-prefix scan in `docs/workflow.md`; hand off a machine assertion to sibling `0006`. |
| Repository size grows with committed screenshots. | Medium | Low | Accepted spec trade-off; documented for adopters; no LFS policy in scope. |
| `.opencode/.gitignore` self-ignores and stays untracked, which could confuse readers expecting it committed. | Low | Low | Leave it as opencode generated state (spec says generated state stays ignored); it is not an artifact surface. |

## Test strategy

Verification is read-only shell assertions plus real agent invocations, matching
the framework's existing approach. `AC8` and the branch half of `AC10` are
integration/manual and are called out as such.

| Criterion | Verification level | How it is verified |
| --------- | ------------------ | ------------------ |
| AC1 | static | `git check-ignore work/example/spec.md` must exit non-zero; `git status --porcelain -uall work/` lists artifacts. |
| AC2 | static | `git check-ignore -q .playwright-mcp/x` and `git check-ignore -q scratch/y` succeed; `git check-ignore work/x` fails. |
| AC3 | static | `git check-ignore work/0003-framework-quality-hardening/0002-readiness-ship-state/.gitkeep` exits non-zero; `git status -uall` lists the `.gitkeep` files. |
| AC4 | static | `rg -n "git-ignored\|gitignored\|not deliverables" AGENTS.md README.md docs .opencode` returns no artifact-persistence claim; every persistence surface contains "committed". Existing historical `work/` artifacts are excluded. |
| AC5 | integration + manual | Bootstrap's documented postconditions are asserted by grep; a temp fixture with a `work/*` rule is repaired so `git check-ignore work/x` fails and `scratch/y` still passes. A real `/bootstrap` run is the LLM half. |
| AC6 | static + manual | `doctor.md` catalogue still requires only `.playwright-mcp/` and `scratch/`; `git check-ignore -v .playwright-mcp/x scratch/y` matches and `work/x` does not, so `IGNORE-MISSING` has no finding. A `/doctor` run confirms. |
| AC7 | integration + manual | After ship, `git ls-tree -r <branch> -- work/<item-ref>/` contains spec/design/verify/review; reviewer opens the PR links. |
| AC8 | manual (post-merge) | Clone the shipped branch to a clean directory and compare derived phase/task/verdict/shipped state against the source; requires committed artifacts and is deferred to after ship. |
| AC9 | static + fixture | A scan asserts unique 4-digit prefixes at HEAD and at each roadmap level; a fixture with a deleted number asserts the documented allocation returns a new, greater number. |
| AC10 | manual / scripted fixture | Create two synthetic branches each adding a `0004-*` item, merge, run the documented renumber procedure, and assert no duplicate canonical reference remains and all references were updated. |
| AC11 | static | `git check-ignore work/example/visual/desktop.png` exits non-zero; the visual surfaces state evidence is committed. |
| AC12 | static | `git status` shows no new state/ledger file; docs still state state is derived from artifact existence and content. |

## Follow-ups (out of scope for this item)

- Machine-readable regression assertions for duplicate numbers, ignore policy,
  and surface agreement belong to sibling `0006-committed-tests-ci` (relocating
  the suite) and are not added here.
- `/doctor` catalogue changes (e.g. an inverse "`work/` must not be ignored"
  check) belong to sibling `0004-doctor-scope`; this item deliberately does not
  touch that catalogue.
- Binary-evidence size policy (LFS/`.gitattributes`) remains out of scope per the
  spec non-goals.
</content>
</invoke>
