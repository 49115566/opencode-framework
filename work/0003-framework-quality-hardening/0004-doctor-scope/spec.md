---
feature: 0003-framework-quality-hardening/0004-doctor-scope
phase: spec
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
notes: "Ready: no dependencies (Depends on: —). User decisions recorded: /doctor is framework-maintainer-only; README stays out of always-loaded instructions (token tax accepted); the doctor agent and command are excluded from the adoption copy set."
---

# Doctor audience and diagnostic accuracy

## Problem

`/doctor` is the framework's only drift detector, but it is scoped to a
repository it does not always run in, and its own guidance has begun to rot.

The diagnostic reads `README.md`'s Agents table, Commands table, Skills table,
and layout counts (`doctor.md:53-57`, `:72-92`) — surfaces that exist only in the
framework repository. The adoption quickstart copies `.opencode/agent/`,
`.opencode/command/`, and `.opencode/skill/` wholesale and then copies
`AGENTS.md`, `opencode.json`, `.gitignore`, and `docs/*.md` — but never
`README.md` (`README.md:39-46`). `README.md` is also not an always-loaded
instruction (`opencode.json:6-10`). An adopter who follows the quickstart
therefore receives a `/doctor` command whose required surface is absent from
their repository: it either cannot run or reports a cascade of false
"undocumented" findings against their project's own README. They cannot tell
real drift from noise, and the docs never warn them.

For framework maintainers the detector is also losing credibility. The sample
finding in its own prompt is stale — it shows `.opencode/agent/ (12 files)` and
`README.md:182 ("11 role prompts")` (`doctor.md:148`) while the directory now
holds 14 files and the README layout comment says "14 role prompts". The
examples cite brittle line numbers (`README.md:182`, `SKILL.md:46`), which drift
the moment any file above them changes. And the completeness rule
(`doctor.md:157-164`) decides which agents are exempt from which surface using an
inline, hand-maintained enumeration of agent names; that snapshot duplicates
repository state and can silently go stale, so the one check meant to catch
drift can itself miss it.

Who is affected: **framework maintainers**, who need a detector they can trust
and whose own examples do not contradict the repository; and **adopters**, who
currently receive a misfiring command and no explanation of why.

## Goals

- `/doctor`, the `doctor` agent, and the `/doctor` command are unambiguously
  labeled framework-maintainer-only everywhere they are documented.
- Following the documented adoption path never installs a diagnostic that
  requires framework-only surfaces, and the documentation explains the
  maintainer-only scope and why the command is absent from an adopted repo.
- The diagnostic's own guidance is durable: its examples contain no stale
  hard-coded counts and no brittle `file:line` citations, using symbolic
  locations instead.
- The completeness rule is well-founded: which agents/commands/skills must appear
  in which documentation surface is determined by the repository's declared
  state, not by an inline snapshot inside the diagnostic that can silently go
  stale.
- A missing or unreadable documentation surface produces one clear finding, not a
  per-item cascade of false positives.
- `/doctor` remains accurate and read-only for the framework repository, and no
  lifecycle phase, artifact, or command behavior changes.

## Non-goals

- Making `/doctor` adopter-usable. The rejected alternative (reworking its
  checks to read adopter-available surfaces such as `AGENTS.md`, or adding a
  README inventory to adopters) is explicitly out of scope; the product serves
  framework maintainers.
- Adding `README.md` to the always-loaded instruction set. The token tax is
  accepted as not worth paying; README is read on demand.
- Broad read-only permission-token hardening for `doctor` or any other agent
  (`find*` with `-delete`/`-exec`, `cat*` redirection, `rg --pre`, `git ... --output=`).
  That is owned by `0003-readonly-permissions`.
- Expanding, reducing, or redesigning the diagnostic's catalogue of checks beyond
  the accuracy and completeness-rule fixes described here.
- Adoption packaging, versioning, licensing, or CI (`0006`, `0008`), beyond
  reflecting the doctor exclusion in the adoption instructions.
- The general prompt/documentation surface sweep for `item-ref` usage strings and
  the framework project profile, owned by `0009-surface-consistency`.
- Auto-fixing drift. The diagnostic reports; it never edits.

## Users and stories

- **As a** framework maintainer, **I want** `/doctor` to be clearly marked
  framework-maintainer-only, **so that** I run it in the repository it was
  written for and know its findings apply there.
- **As a** framework maintainer, **I want** the diagnostic's own examples and
  completeness rule not to contradict the repository or go stale, **so that** I
  trust the detector and stop auditing it by hand.
- **As an** adopter, **I want** the documented adoption path to not install a
  command that misfires on my repository, **so that** my first experience with
  the framework is not a wall of false drift findings.
- **As an** adopter, **I want** the documentation to explain that `/doctor` is
  framework-maintainer-only, **so that** I understand why it is not available and
  do not assume my adoption is broken.

## Acceptance criteria

1. **AC1** — Given the places `/doctor` is documented (the README Commands
   table, the `AGENTS.md` supporting-commands list, and the command/agent
   descriptions), when a reader looks up `/doctor`, then each place identifies it
   as framework-maintainer-only rather than as a general-purpose adopter command.
2. **AC2** — Given a maintainer performs a fresh adoption by following only the
   documented quickstart, when the copy step completes, then the target
   repository contains no `doctor` agent and no `/doctor` command, and no
   `/doctor` command is registered from the framework.
3. **AC3** — Given an adopter notices that `/doctor` is not installed, when they
   read the quickstart or README, then the documentation states that `/doctor`
   and the `doctor` agent are framework-maintainer-only, not part of the adopted
   set, and will misreport outside the framework repository if copied there.
4. **AC4** — Given the diagnostic's sample findings and any other illustrative
   examples in its prompt, when they are inspected, then none asserts a concrete
   current agent, command, or skill count and none cites a `file:line` location;
   each location is given symbolically (for example, by naming the document and
   the table, row, or layout comment involved).
5. **AC5** — Given the completeness rule, when an agent, command, or skill is
   added to or removed from disk without editing the diagnostic's prompt, then
   the rule's documentation requirements for that item are determined by the
   repository's declared state and the item is not silently exempted by a
   hard-coded enumeration that has gone stale.
6. **AC6** — Given the diagnostic runs in a repository where a documentation
   surface it references is absent or unreadable, when it completes, then it
   reports exactly one finding naming the missing surface and does not emit one
   false finding per inventory item or exit without a clear result.
7. **AC7** — Given the framework repository is internally consistent after this
   change, when `/doctor` runs there, then it reports the clean result with the
   checked counts (agents, commands, skills), consistent with its existing
   behavior.
8. **AC8** — Given `opencode.json`, when its always-loaded instruction list is
   inspected, then `README.md` is not included, and the diagnostic still obtains
   the README-derived facts it needs when run in the framework repository.
9. **AC9** — Given `/doctor` runs, when it completes, then it has created,
   edited, moved, or deleted no file and run no write command; its read-only
   guarantee is unchanged.
10. **AC10** — Given the changes in this item, when the lifecycle is inspected,
    then no phase's inputs, outputs, exit criteria, or command behavior changes;
    only `/doctor`'s audience labeling, adoption presence, examples, and
    completeness rule change.
11. **AC11** — Given the framework's own consistency diagnostic, when it runs
    after this item's changes, then the doctor-specific facts it checks
    (inventories, counts, permission table, ignore rules) remain in agreement and
    this item introduces no new drift.

## Edge cases

- **Upgrading an existing adoption**: a repository adopted before this change
  already contains `.opencode/agent/doctor.md` and `.opencode/command/doctor.md`.
  The documentation must tell the adopter these are now maintainer-only and how
  to treat them; `/doctor` running there must not be presented as authoritative.
- **Out-of-band copy**: a user copies `.opencode/` by means other than the
  documented quickstart and so receives the doctor files anyway. The docs must
  warn that `/doctor` is only valid in the framework repository and will
  misreport elsewhere.
- **Missing documentation surface**: `README.md` is deleted or renamed, or a doc
  is unreadable. The diagnostic emits a single finding about the missing surface
  rather than one false finding per inventory item (AC6).
- **New inventory item added without docs**: a new agent/command/skill on disk is
  not covered by any exemption that has gone stale; it is checked against the
  required surfaces (AC5).
- **Documented item deleted**: a doc names an agent/command/skill with no file on
  disk; the phantom is still reported (existing behavior preserved).
- **Empty `work/` state**: running `/doctor` in the framework repository with no
  work items still yields a clean result and does not error.
- **Wrong working directory**: `/doctor` invoked from a subdirectory still
  resolves the framework root rather than the process working directory
  (existing behavior preserved).
- **Concurrent activity**: running `/doctor` while another agent edits files
  neither corrupts state nor writes (read-only, AC9).

## Open questions

- [x] `/doctor` audience — resolved by user decision (2026-10-05):
  **framework-maintainer-only**; it is not reworked to serve adopters.
- [x] Adoption handling for a maintainer-only diagnostic — resolved by user
  decision (2026-10-05): **exclude the doctor agent and command from the
  quickstart copy set**, and label `/doctor` maintainer-only in the docs.
- [x] Always-loaded instruction set — resolved by user decision (2026-10-05):
  **keep `README.md` out** of `opencode.json` instructions; the token tax is not
  worth paying and on-demand reads are sufficient.
- [ ] Exact mechanism for excluding the doctor files from adoption (for example,
  an explicit removal step in the quickstart versus relocating them to a
  maintainer-only source directory) — owner: architect, needed by: `/plan`. This
  is a design choice; the spec fixes only the outcome that a fresh adoption does
  not install them (AC2).

## Dependencies and constraints

- **Ready item**: the roadmap `Depends on` cell for `0004-doctor-scope` is `—`,
  so there are no blocking children.
- **Framework-internal, prompt/config-only**: this changes agent, command, and
  documentation files only. No installed runtime dependency is introduced.
- **No duplication of shipped work**: `0001-framework-consistency-hardening`
  already shipped `/doctor`, its nine checks, and the `PERMISSION-WORK-PATTERN`,
  inventory, count, and ignore checks. This item extends and corrects that
  surface; it must not re-implement or fork the diagnostic.
- **Boundary with `0003-readonly-permissions`**: doctor's `edit: deny` and bash
  allowlist are not changed here, even though its allowlist includes
  write-capable tokens. That hardening belongs to `0003`.
- **Boundary with `0009-surface-consistency`**: the framework-wide sweep of
  command usage strings and the project profile is owned by `0009`. This item
  owns only the doctor-specific labeling and the doctor references it touches.
- **Boundary with `0008-adoption-packaging`**: if adoption packaging or the
  copied-file list changes, the doctor exclusion must remain reflected there;
  otherwise the quickstart is the single adoption path this item edits.
- **Committed `work/` model**: this item's artifacts are committed working state,
  per the state model. The documentation changes here ship with the item.
- **Backward compatibility**: adopters who already have the doctor files are not
  broken by this change; they receive documentation, not a forced deletion. No
  migration is required.
- **Verification is largely static/manual**: the product surface is prompts and
  docs, so acceptance is checked by inspecting files and running `/doctor` in the
  framework repository, not by a runtime test suite (the committed test/CI
  harness is owned by `0006`).

## Assumptions

- **Assumption**: `AGENTS.md` is shipped to adopters and is the appropriate place
  to mark `/doctor` maintainer-only, alongside the README (which is not shipped).
- **Assumption**: the documented quickstart copy list is the canonical adoption
  path; there is no second supported installation route that must also exclude
  the doctor files.
- **Assumption**: no command, phase, or documented workflow depends on the
  `doctor` agent or `/doctor` command being present in an adopter's repository.
- **Assumption**: the diagnostic's remaining checks are otherwise accurate for
  the framework repository, and only the example, completeness-rule, and
  brittle-citation defects described here need correction.
