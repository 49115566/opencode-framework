---
feature: 0003-framework-quality-hardening
phase: roadmap
status: final
created: 2026-10-04
updated: 2026-10-06
---

# Roadmap — Framework quality hardening

## Initiative

A broad program of framework-internal quality work prompted by an external
review of opencode-framework. The reviewer read the full framework (agents,
commands, skills, docs, `opencode.json`, `.gitignore`, and the dogfooded `work/`
corpus) and delivered a value-first critique whose central finding is that the
framework treats `work/` as the source of truth while simultaneously excluding
it from the repository — then builds PR handoffs, shipped-state detection, and
test evidence on top of that contradiction. Layered on it are a genuinely
unwritable `ship.md`, a live semantic contradiction in the readiness definition,
a "read-only / enforced permissions" story the bash allowlists do not back up,
maintainer tooling shipped as user tooling, an orphan `/fix` track, no committed
tests or CI, and assorted adoption and surface gaps.

This initiative serves two audiences: **framework maintainers**, who need the
product's documented behavior and its actual permissions/state to agree and to
be regression-guarded; and **adopters**, who copy the framework into arbitrary
repositories and currently receive an over-claimed permission model, dead PR
artifact links, a framework-repo-only `/doctor`, and no license. The outcome is
a framework whose state model is decided rather than contradictory, whose
correctness claims are true, whose tests are committed and runnable, and whose
adoption path is complete.

## Assumptions

- The external review is a **candidate backlog, not authoritative scope**. Findings
  were recorded during work item 0002's test phase and may be stale; each child
  spec must re-verify every cited finding against the current files before acting.
- The work is **framework-internal and prompt/config-only**: it changes agents,
  commands, skills, docs, `README.md`, `AGENTS.md`, `opencode.json`, `.gitignore`,
  and repository-root packaging. No installed runtime dependency is introduced,
  except a committed static test script and a CI workflow file.
- The **user owns the two framing decisions** this program depends on: whether
  `work/` artifacts are committed or kept local-only, and which agent is the
  default. Children present options with trade-offs and recommend; they do not
  decide unilaterally.
- Children are numbered locally to this parent and are independent of the
  top-level sequence and of other roadmaps.
- The two existing flat items (`0001-framework-consistency-hardening`,
  `0002-agentic-roadmaps`) are treated as approved/shipped context and are not
  modified by this roadmap; children must avoid redoing their work.
- `scratch/` remains the in-repo temporary location and `work/` remains the
  artifact root; this roadmap does not invent a second store.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-state-model | Artifact persistence and state model | Resolve the contradiction between "the `work/` directory plus the diff is the complete state" (`docs/workflow.md`) and `work/*` being git-ignored (`.gitignore:7-8`). Decide and document one model: **committed** (rework `.gitignore`, including making nested child `.gitkeep` reservation files trackable, and keep PR artifact-path links) or **local-only** (remove artifact-path links from PR bodies — `pr-workflow` skill, `shipper.md:84` — retitle "state" as local working state, and state plainly that teammates/CI cannot see artifacts). Reconcile the "never reuse a number" claim and the "parallel items on separate branches" claim under the chosen model. Evidence: `docs/workflow.md:16`, `.gitignore:7-8`, `pr-workflow/SKILL.md`, `shipper.md:84`, `work/0002-agentic-roadmaps/review.md`. | — | 0003-framework-quality-hardening/0001-state-model |
| 0002-readiness-ship-state | Readiness semantics and shipped-state detection | Make dependency satisfaction consistent and executable. Fix the `status.md` prose that contradicts its own algorithm (`status.md:117-120` says approved-but-unshipped is not satisfied; `status.md:108-109` and `docs/workflow.md:85-104` say it is). Decide `ship.md`'s fate: grant `shipper` `edit` on `work/**` + `**/work/**` (it is `edit: deny` at `shipper.md:5` yet told to write `ship.md` at `:86`) **or** drop the artifact and designate a single machine-readable shipped signal. Resolve the "PR detected" branch `status` cannot execute (`status.md:107` vs its git/gh-free allowlist). Add a test asserting the two readiness definitions agree. Evidence: `shipper.md:5,86`, `status.md:98-122`, `docs/workflow.md:85-104`, `README.md:165`, `work/0002-agentic-roadmaps/review.md` m1. | 0001-state-model | 0003-framework-quality-hardening/0002-readiness-ship-state |
| 0003-readonly-permissions | Read-only agent permissions and enforcement claims | Close the gap between "read-only" agents and their bash allowlists. Remove or constrain write-capable tokens (`find*` with `-delete`/`-exec`, `cat*` redirection, `rg --pre`, `git diff/log --output=`) from `product`, `architect`, `roadmap`, `status`, `reviewer`, `doctor`, `scout`, and `ask`, **or** soften the README's enforcement claims (`README.md:22-23,173`) to what opencode actually guarantees. Broaden `tester`'s test-path allowlist so it need not fall back to broad bash for common layouts (`e2e/`, `spec/`, `integration/`). Document the residual broad-bash limitation for `tester`/`visual`/`scout`/`bootstrap` honestly. Evidence: `README.md:22-23,173`, `docs/customization.md:133-136`, `product.md:15`, `status.md:16`, `reviewer.md:19`, `doctor.md:16`, `work/0001-framework-consistency-hardening/review.md` m1. | — | 0003-framework-quality-hardening/0003-readonly-permissions |
| 0004-doctor-scope | Doctor audience and diagnostic accuracy | Decide `/doctor`'s audience and make it correct for it. If framework-maintainer-only, mark it as such and exclude it from the adopted command set (`README.md:39-46` does not copy `README.md` into the target repo). If adopter-usable, make it read a surface adopters actually have (e.g. `AGENTS.md`) or add a README inventory to the quickstart. Replace the stale count example (`doctor.md:148`) and brittle line-number citations with symbolic references. Address the circular completeness rule (`doctor.md:157-164`). Decide whether `README.md` should be an always-loaded instruction or the token tax is acceptable. Evidence: `doctor.md:53-57,72-92,128-135,148,157-164`, `README.md:39-46`. | — | 0003-framework-quality-hardening/0004-doctor-scope |
| 0005-fix-landing | Fix-track landing path | Give `/fix` a way to land. Decide and implement either a minimal auto-created work item for a fix, or an explicit rule that the shipper may commit a verified `/fix` on request. Currently `command/fix.md:24` and the builder prompt forbid commits and `/ship` requires a reviewed work item, so a fix dead-ends. Reconcile `command/fix.md`, the `builder` prompt, `AGENTS.md`, and `docs/workflow.md` routing without introducing new behavior beyond the landing path. Evidence: `command/fix.md:24`, `builder.md:77`, `shipper.md:66-68`. | 0001-state-model | 0003-framework-quality-hardening/0005-fix-landing |
| 0006-committed-tests-ci | Committed test harness and CI | Move the framework's static verification suite out of the git-ignored `work/` directory (`work/0002-agentic-roadmaps/verify-tests.sh`) into a committed location (e.g. `tests/` or `scripts/`), make it runnable in CI, and add a CI workflow. Add semantic agreement assertions — e.g. that duplicated readiness/lifecycle/permission facts in different files agree — which the current name/count checks miss. Note and, where possible, cover the roadmap cycle diagnostic that today can only be produced by hand. Distinguish framework-maintainer tooling from shipped user tooling. Evidence: `work/0002-agentic-roadmaps/verify-tests.sh`, `work/0002-agentic-roadmaps/review.md`, no committed test/CI files exist. | — | 0003-framework-quality-hardening/0006-committed-tests-ci |
| 0007-config-hardening | Default config safety and reproducibility | Harden `opencode.json` defaults. Reconsider `default_agent: builder` — the most privileged agent — against the framework's discipline framing. Decide per-agent model specialization (at least `visual` and `reviewer`) and document that visual QA degrades on a text-only model under the shipped global default. Pin the Playwright MCP package instead of `@playwright/mcp@latest`. Keep the always-loaded instruction set intentional. Evidence: `opencode.json:3-5,38-46`, `docs/customization.md:88-92,148`. | — | 0003-framework-quality-hardening/0007-config-hardening |
| 0008-adoption-packaging | Adoption packaging and versioning | Close the adoption gaps: add a `LICENSE` (a practical blocker for copying into arbitrary repos), `CONTRIBUTING`, `CHANGELOG`, and a root version manifest; decide the framework's versioning and release model. Ensure the quickstart and any copied-file list stay consistent with the added files. Evidence: no `LICENSE`/`CONTRIBUTING`/`CHANGELOG`/version manifest on disk; `README.md:33-53`. | — | 0003-framework-quality-hardening/0008-adoption-packaging |

## Sequencing

1. 0001-state-model
2. 0002-readiness-ship-state
3. 0003-readonly-permissions
4. 0004-doctor-scope
5. 0005-fix-landing
6. 0006-committed-tests-ci
7. 0007-config-hardening
8. 0008-adoption-packaging

`0001-state-model` is the keystone: its committed-versus-local decision reshapes
the PR handoff and any `/fix` landing path, so `0002` and `0005` follow it.
`0003`, `0004`, `0006`, `0007`, and `0008` have no unmet prerequisites and may
proceed in parallel; `0006` in particular is worth landing early so later fixes
gain committed regression coverage.

## Open issues

- **Withdrawn child — `0009-surface-consistency`.** Withdrawn by user decision on
  2026-10-06 and removed from the Children table and Sequencing above, so
  `/status` no longer presents it as a ready or active child. Its directory
  (`work/0003-framework-quality-hardening/0009-surface-consistency/`) keeps only
  the withdrawal `spec.md`; the number 0009 stays spent. The former scope — the
  command signature/usage-string sweep (including the stale `/visual [url|slug]`
  spelling), the non-conforming `ask.md` description, and the
  maintainer-vs-adopter bootstrapped-file split — is re-homed to a successor
  roadmap authored via `/roadmap`.
- **No stored cycle.** The `Depends on` graph is acyclic; no `CYCLIC-DEP` is
  expected. Recorded here because the roadmap agent never stores a cycle by
  design.
- **Unresolved user decision — artifact persistence.** Committed versus local-only
  `work/` artifacts is a genuine fork that child `0001-state-model` must resolve
  with the user. It materially changes `0002-readiness-ship-state` and
  `0005-fix-landing`. The roadmap does not decide it.
- **Unresolved user decision — default agent.** Whether to keep `builder` as the
  default (most privileged) or move to a least-privilege default belongs to child
  `0007-config-hardening`.
- **Possible overlap with existing work.** `0001-framework-consistency-hardening`
  already shipped doc/config drift detection and `/doctor`
  (`PERMISSION-WORK-PATTERN`, inventory/count checks); child `0004-doctor-scope`
  extends that area and must not duplicate it.
  `0002-agentic-roadmaps` owns the readiness algorithm; child
  `0002-readiness-ship-state` overlaps its recorded minor m1 (the PR-detection
  branch) and should reference and supersede it rather than fork a second
  definition.
- **Staleness of the input.** The external findings were produced during work item
  0002's test phase (per the user's note) and some may already be fixed; a finding
  is not in scope until the owning child's spec re-verifies it against current
  files.
- **`/fix` landing choice.** If the user rejects any new artifact type for
  `/fix`, child `0005-fix-landing` must choose the "shipper may commit a verified
  fix on request" option, which touches `AGENTS.md` and `docs/workflow.md`.
- **No duplicate roadmap.** No existing `roadmap.md` covers this initiative; the
  two present items are flat specs, not roadmaps. No collision was found.
