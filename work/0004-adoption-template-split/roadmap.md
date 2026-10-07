---
feature: 0004-adoption-template-split
phase: roadmap
status: final
created: 2026-10-06
updated: 2026-10-06
---

# Roadmap — Adoption template split and surface consistency

## Initiative

This is the successor roadmap for the scope re-homed when
`0003-framework-quality-hardening/0009-surface-consistency` was withdrawn by user
decision on 2026-10-06. The parent roadmap records that withdrawal and names this
successor as the vehicle for the former scope. The withdrawn child had found that
the framework's `AGENTS.md` is simultaneously the repository's live always-loaded
contract and the template the adoption quickstart copies into other repositories
(`README.md:49`, `.opencode/agent/bootstrap.md:69-73`); filling its Project
profile would therefore ship the maintainers' bootstrapped configuration to every
adopter. The correct resolution is not a surface edit but an **adoption-template
split**: separate maintainer-bootstrapped files from adopter-pristine templates
and rework `/bootstrap`, the quickstart copy set, `opencode.json`, the committed
test suite, and `/doctor` around that split. The remaining former-0009 findings —
the command signature/usage-string sweep (including the stale `/visual [url|slug]`
spelling) and the non-conforming `ask.md` description — are entangled with the
same `AGENTS.md`/`README.md`/`docs/workflow.md` files the split will touch and are
re-homed here too.

The initiative serves two audiences. **Framework maintainers** need the
repository's own `AGENTS.md` to be correctly bootstrapped for the framework
without that configuration leaking to adopters, and the docs/prompt surfaces to
agree on command signatures. **Adopters** need the documented quickstart to copy
adopter-pristine templates — never the maintainers' model, permissions, MCP, or
Project profile — and the documentation to say so unambiguously. The outcome is an
adoption path that cannot ship maintainer configuration, guarded by the committed
suite, with the framework's command surface internally consistent.

## Assumptions

- **Whole former scope is re-homed.** The withdrawn spec (`0009-surface-consistency`,
  Open questions) left open whether the successor carries the entire former scope
  or only the split. This roadmap assumes the whole scope is re-homed; the
  decomposition below decides how to place it (the split, the signature sweep, and
  the `ask.md` fix).
- **The split is the sanctioned resolution.** The maintainer-bootstrapped vs
  adopter-pristine separation is recorded as the correct resolution in the
  withdrawal spec (`work/0003-framework-quality-hardening/0009-surface-consistency/spec.md:19-30`).
  Its exact shape — where pristine templates live, which copied files are
  templated, and how `opencode.json` and `docs/*.md` are treated — is a design
  decision owned by child `0001-adopter-template-split`, not by this roadmap.
- **Framework-internal and prompt/config/doc/test only.** No installed runtime
  dependency, install step, or network access is introduced. The surfaces in scope
  are root `AGENTS.md`, `opencode.json`, `.gitignore`, `README.md`, `docs/`,
  `.opencode/agent/bootstrap.md`, `.opencode/agent/doctor.md`,
  `.opencode/agent/ask.md`, the `workflow-lifecycle` skill, and `tests/`.
- **Downstream checks stay green.** The committed suite `bash tests/run.sh`
  (`tests/README.md:13-25`) must pass at every step; the split and the sweep must
  not regress the packaging/copy-set guards already shipped by
  `0003-framework-quality-hardening/0006-committed-tests-ci` and
  `0008-adoption-packaging` (`tests/checks/90-packaging.sh`, `40-inventory.sh`).
- **Shipped siblings are context, not scope.** Children `0001`–`0008` of the parent
  roadmap `0003-framework-quality-hardening` are treated as approved/shipped; this
  roadmap does not redo their work. In particular it does not change `/doctor`'s
  maintainer-only audience or re-open the packaging/versioning decisions.
- **`0009` stays spent.** The withdrawn child's number is not reused or
  renumbered; its directory keeps only the withdrawal `spec.md` as required.
- **The user owns the split's user-visible choices.** If the split changes what
  adopters copy or how `/bootstrap` behaves, the owning child presents options with
  trade-offs and recommends; it does not decide unilaterally.
- Child numbers are local to this parent and independent of the top-level
  sequence and of other roadmaps.

## Children

| Local id | Title | Scope | Depends on | Canonical reference |
| -------- | ----- | ----- | ---------- | ------------------- |
| 0001-adopter-template-split | Adopter/maintainer template split | Define and stand up the maintainer-bootstrapped vs adopter-pristine separation. Introduce the adopter-pristine source for the files the quickstart copies (`AGENTS.md`, `opencode.json`, `.gitignore`, and any generic `docs/*.md`), and convert the framework repository's own copies to maintainer-bootstrapped values — including filling the framework's `AGENTS.md` Project profile with verified commands (`AGENTS.md:11-27`) so the maintainer configuration no longer doubles as the adopter template. Decide and document the split contract (source of truth per file, how `/bootstrap` targets the adopter copy). This is the keystone; the other children consume the split. Evidence: `AGENTS.md:11-27`, `README.md:38-52`, `.opencode/agent/bootstrap.md:57-104`, `work/0003-framework-quality-hardening/0009-surface-consistency/spec.md:19-30`. | — | 0004-adoption-template-split/0001-adopter-template-split |
| 0002-bootstrap-quickstart-rework | Bootstrap and quickstart rework | Rework `/bootstrap` and the documented adoption quickstart around the split. Update `.opencode/agent/bootstrap.md` so its detect/confirm/apply steps and quality bar operate on adopter-pristine files and fill the adopter's own profile, and update every surface that describes the copied file set (`README.md` quickstart and copy-set prose, `docs/customization.md:43-51`, `tests/README.md:5-11`) so maintainer-only files and adopter-pristine files are unambiguous. Evidence: `README.md:38-92`, `docs/customization.md:43-51`, `tests/README.md:5-11`, `.opencode/agent/bootstrap.md:57-104`. | 0001-adopter-template-split | 0004-adoption-template-split/0002-bootstrap-quickstart-rework |
| 0003-split-guard-tests | Committed split guards | Extend the committed suite (`tests/`) to guard the split: assert that the adopter copy source is the pristine template and that the maintainer-bootstrapped files cannot leak into the copy set, and keep the existing copy-set/inventory agreements green (`tests/checks/90-packaging.sh:87-198`, `tests/checks/40-inventory.sh`). Update `tests/README.md` to document the new agreement area. Evidence: `tests/run.sh`, `tests/checks/90-packaging.sh`, `tests/checks/40-inventory.sh`, `tests/README.md:59-79`. | 0001-adopter-template-split, 0002-bootstrap-quickstart-rework | 0004-adoption-template-split/0003-split-guard-tests |
| 0004-doctor-template-alignment | Doctor alignment with the split | Align `/doctor` and the `doctor` agent with the split layout so its README-derived inventory/layout facts and maintainer-only labeling stay true after the split. Preserve its maintainer-only audience and read-only behavior and do not re-open or duplicate the shipped `0004-doctor-scope` work. Evidence: `.opencode/agent/doctor.md:50-62,156-179`, `README.md:249-270`, `tests/checks/40-inventory.sh`. | 0001-adopter-template-split, 0002-bootstrap-quickstart-rework | 0004-adoption-template-split/0004-doctor-template-alignment |
| 0005-surface-consistency-sweep | Command signature and prompt-surface sweep | Canonicalize command signatures and usage strings across `AGENTS.md` (lifecycle table and supporting-commands list), `docs/workflow.md` (phase headings and routing bullet), `README.md` (Commands table, lifecycle mermaid, quickstart example), and the `workflow-lifecycle` skill — including the stale `/visual [url\|slug]` spelling — and bring the non-conforming `ask.md` frontmatter description (`ask.md:2`) into line with the other agent descriptions. Sequenced last so it edits already-settled surfaces. Evidence: `AGENTS.md:37-50`, `docs/workflow.md:139,153,170,184,204,217,306`, `README.md:109-135,180-186`, `.opencode/skill/workflow-lifecycle/SKILL.md:31-39`, `.opencode/agent/ask.md:2`. | 0001-adopter-template-split, 0002-bootstrap-quickstart-rework, 0004-doctor-template-alignment | 0004-adoption-template-split/0005-surface-consistency-sweep |

## Sequencing

1. 0001-adopter-template-split
2. 0002-bootstrap-quickstart-rework
3. 0003-split-guard-tests
4. 0004-doctor-template-alignment
5. 0005-surface-consistency-sweep

`0001-adopter-template-split` is the keystone: nothing else can be specified until
the split's source-of-truth layout is decided, because every other child edits a
surface the split moves or redefines. `0002-bootstrap-quickstart-rework` then makes
the adoption path consume the split. `0003-split-guard-tests` and
`0004-doctor-template-alignment` both build on the settled split and reworked
quickstart and may proceed in parallel once `0002` lands. `0005` is deliberately
last: it edits `AGENTS.md`, `README.md`, and `docs/workflow.md`, the same files the
split and the doctor alignment touch, so running it earlier would invite
conflicting edits. Landing `0003` early is worthwhile so the split and the sweep
gain committed regression coverage.

## Open issues

- **Successor re-homing.** This roadmap replaces the withdrawn
  `0003-framework-quality-hardening/0009-surface-consistency`. The former child
  keeps its `spec.md` (withdrawal record) and its number stays spent. No parent
  roadmap is amended: `/roadmap` creates a new parent, which is why this item
  exists as a separate top-level `0004`.
- **Bundled `ask.md` finding.** The withdrawn child listed the non-conforming
  `ask.md` description as a distinct finding from the signature sweep. This
  roadmap places both in child `0005-surface-consistency-sweep` because both are
  pure prompt/doc-conformance edits to the same surface set. If `0005`'s spec finds
  they must be delivered separately, that is its call — the roadmap does not
  prescribe the split.
- **Resolved-by-assumption re-homing question.** The withdrawn spec's open
  question — whether the successor carries the entire former scope or only the
  split — is resolved here by assumption (entire scope). If the user disagrees, the
  child set changes before any `/spec` run.
- **Unresolved split shape.** Where adopter-pristine templates live, which copied
  files are templated, and how the framework's own `opencode.json`/`.gitignore`/docs
  diverge from the template are genuine design forks. Child
  `0001-adopter-template-split` must resolve them with the user; they materially
  change `0002`, `0003`, and `0004`. The roadmap does not decide them.
- **Possible overlap with shipped work.** Child `0004-doctor-template-alignment`
  extends the shipped `0004-doctor-scope`; it must not re-implement or re-open
  `/doctor`'s audience decision. Child `0005-surface-consistency-sweep` edits the
  command surface that `0004-doctor-scope` and `0008-adoption-packaging` also
  touched; it must keep `tests/checks/40-inventory.sh` and `90-packaging.sh` green
  rather than forking their agreements.
- **Cycle check.** The stored `Depends on` graph is acyclic by construction; no
  `CYCLIC-DEP` is expected. Recorded here because the roadmap agent never stores a
  cycle.
- **Single-feature check.** The initiative is genuinely multi-feature (the split
  spans bootstrap, the quickstart copy set, `opencode.json`, the committed suite,
  and `/doctor`, plus the independent surface sweep), so a roadmap is the right
  vehicle rather than a standalone `/spec`.
- **No duplicate roadmap.** Recon of `work/` found one existing roadmap
  (`0003-framework-quality-hardening`) and two flat specs (`0001`, `0002`); none
  covers the re-homed scope. No collision was found.
