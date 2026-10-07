---
feature: 0004-adoption-template-split/0002-bootstrap-quickstart-rework
phase: design
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0004-adoption-template-split
notes: "Resolves the spec's two design open questions. Guard representation = two ordered deny rules (`template/**`, `**/template/**`) appended to the bootstrap agent's `permission.edit` map, relying on opencode's documented last-match-wins evaluation. Committed split guards remain child 0003's; this item only keeps the existing agreements green (AC7/AC8). No `tests/checks/**` change."
---

# Design — Bootstrap and quickstart rework

## Summary

Point the documented quickstart at the adopter-pristine `template/` sources with
three explicit per-file `cp` commands, and reconcile the four copy-set surfaces
(`README.md`, `docs/customization.md`, `tests/README.md`, `CONTRIBUTING.md`) on
the `0001` split contract. Rework the `bootstrap` agent and its command so they
fill the adopter's *own* root `AGENTS.md`, `opencode.json`, and `.gitignore` and
never the framework repository's pristine sources, adding two ordered deny rules
(`template/**`, `**/template/**`) to the bootstrap agent's `permission.edit` map
as the hard guard AC3 requires.

## Approach

### 1. Quickstart copies the pristine sources (AC1, AC2, AC9)

Replace the single root-source copy line in `README.md`'s first ```bash block
(`README.md:49`) with three per-file copies to destination names:

```bash
cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md
cp "$FRAMEWORK/template/opencode.json" ./opencode.json
cp "$FRAMEWORK/template/.gitignore" ./.gitignore
```

No `template/` directory is created in the adopter. The rest of the block is
unchanged. `opencode.json` and `.gitignore` are currently byte-identical to the
root copies, but they are sourced from `template/` so the contract holds once
they diverge (edge case: byte-identical pristine pair). The existing merge
advisory (`README.md:83-84`) is preserved verbatim; no migration or deletion step
is added (AC9). The quickstart's `rm -f` removes only the maintainer-only doctor
files and predates this item.

### 2. Reconcile the copy-set surfaces (AC5, AC6)

Each of the four surfaces gains the same three facts, expressed in its own
register, naming `template/<file>` as the adopter's source for all three
bootstrap-mutable files, distinguishing the framework repository's own
bootstrapped copies, and stating that `.opencode/{agent,command,skill}` and
`docs/*.md` have a single source and are shared verbatim:

- `README.md` — Quickstart prose: the three copied root files come from
  `template/`; the framework repository's own root copies are maintainer
  bootstrapped and never copied.
- `docs/customization.md` — the "Adopter-pristine sources and framework copies"
  section already carries the mapping table and the shared-verbatim rule
  (`docs/customization.md:21-40`); the stale sentence at `docs/customization.md:64-67`
  ("These three are exactly the files the adoption quickstart copies") is
  rewritten to say the first arrives from `template/AGENTS.md` and the other two
  via the `docs/*.md` copy. Wording stays framework-repository organisation, not
  adopter instruction, because this file is copied verbatim (edge case:
  verbatim-copied docs).
- `tests/README.md` — the copy-set enumeration at `tests/README.md:5-11` names the
  `template/` sources. The mutation self-check's AC19 mutation replaces the
  literal `` `docs/*.md`) `` in this file (`tests/mutation.sh:263`), so that exact
  literal must remain the tail of the same parenthetical (AC8).
- `CONTRIBUTING.md` — the maintainer-only paragraph at `CONTRIBUTING.md:121-128`
  names the `template/` sources and adds the shared-verbatim sentence.

### 3. Rework `/bootstrap` (AC3, AC4)

**Guard (AC3).** Append two deny rules to `.opencode/agent/bootstrap.md`'s
`permission.edit` map, after every allow rule:

```yaml
  edit:
    "*": deny
    "AGENTS.md": allow
    "**/AGENTS.md": allow
    "opencode.json": allow
    "**/opencode.json": allow
    ".gitignore": allow
    "**/.gitignore": allow
    "work/**": allow
    "**/work/**": allow
    "template/**": deny
    "**/template/**": deny
```

This is the minimum change that satisfies AC3. The existing broad allows
`**/AGENTS.md`, `**/opencode.json`, and `**/.gitignore` currently match
`template/<file>`; because opencode evaluates permission objects last-match-wins
(`docs/customization.md:161-170`) and both path forms must be declared
(`README.md:218-224`), the two trailing deny rules deny the relative and absolute
forms of the whole `template/` subtree while leaving the adopter's root files
under the earlier allows. In an adopter repository there is no `template/`, so
the guard is inert (edge case: context mismatch / guard over-reach).

**Instructions (AC4).** Update `.opencode/agent/bootstrap.md` so its `<mission>`,
`<operating_principles>`, `<process>`, `<rules>`, and `<quality_bar>`, plus the
`.opencode/command/bootstrap.md` body, state that `/bootstrap` fills the adopter's
own root `AGENTS.md`, `opencode.json`, and `.gitignore` — the copies an adopter
received from the framework's adopter-pristine sources — and must never modify the
framework repository's sources under `template/`. The wording is truthful in both
contexts: it refers to `template/` as the framework repository's location, never
as a path an adopter has.

### 4. Keep the committed agreements green (AC7, AC8)

No `tests/checks/**` file changes. The touched surfaces are read by:

- `90-packaging.sh` AC19 (README, `tests/README.md`, `docs/customization.md`): the
  edits must not positively claim a packaging file is copied, and the quickstart
  bash block must not name one. The `docs/customization.md:64-67` rewrite is not a
  copy-set enumeration and contains no packaging filename.
- `90-packaging.sh` AC20 / `40-inventory.sh` / `50-instructions.sh` / `30-permissions.sh`:
  no Layout, count, instruction-set, or permission-class change originates here —
  the added deny rules do not alter the coarse `config+work` class
  (`tests/checks/30-permissions.sh:42-58` reads allow patterns only).
- `tests/mutation.sh`: `stage()` already copies `template/`
  (`tests/mutation.sh:66`); the AC19 mutation literal in `tests/README.md` is
  preserved as a design constraint above.

## Alternatives considered

- **Guard representation — prose-only instruction vs. ordered deny rules
  (chosen).** Prose alone cannot satisfy AC3, which requires an actual denied
  edit. The chosen rules are two lines, reuse the existing permission mechanism,
  and need no new file or tool.
- **Guard representation — rewrite the broad allows to be root-anchored (e.g.
  drop `**/AGENTS.md`).** opencode matches absolute tool paths only via `**/`
  patterns (`README.md:218-224`), so removing or root-anchoring them would deny
  the adopter's own absolute-path edits. Rejected.
- **Quickstart mechanism — `cp -r "$FRAMEWORK/template/." .` (one command).**
  Copies every present and future file under `template/` and relies on
  directory-merge semantics; the user decision fixes per-file copies to
  destination names, and a stray future `template/README.md` would leak into the
  adopter. Rejected.
- **Quickstart mechanism — a `for f in AGENTS.md opencode.json .gitignore; do cp
  "$FRAMEWORK/template/$f" "./$f"; done` loop.** Equivalent outcome but less
  legible in the quickstart an adopter reads and edits (the `FRAMEWORK` variable
  is the documented edit point). Rejected for clarity; the loop remains available
  if the destination names ever diverge.
- **Copy-set consolidation — one canonical copy-set block in
  `docs/customization.md` with the other surfaces linking to it.** The quickstart
  is the entry point adopters act on and README must stay self-contained; the
  surfaces are copied verbatim and read independently. Rejected.
- **Add a committed split guard here.** The spec fixes this to child `0003`
  (AC7 keeps the existing suite green); adding one now would duplicate `0003` and
  widen scope. Rejected.

## Interfaces and data model

### Quickstart copy mapping (`README.md`)

| Destination | Adopter-pristine source | Never copied from |
| ----------- | ----------------------- | ----------------- |
| `./AGENTS.md` | `template/AGENTS.md` | root `AGENTS.md` (bootstrapped profile) |
| `./opencode.json` | `template/opencode.json` | root `opencode.json` |
| `./.gitignore` | `template/.gitignore` | root `.gitignore` |

### Bootstrap `permission.edit` block

The exact block is in Approach §3. The two added rules `"template/**": deny` and
`"**/template/**": deny` are the last entries, after every `allow`, so
last-match-wins resolves any `template/` path to deny. `work/**`/`**/work/**`
remain allowed for artifact writes.

### Instruction invariants (bootstrap agent + command)

Both files must state, in substance:

1. `/bootstrap` fills the adopter's own root `AGENTS.md`, `opencode.json`, and
   `.gitignore` — the copies an adopter received from the framework's
   adopter-pristine sources.
2. It must never modify the framework repository's adopter-pristine sources under
   `template/`.

No new file, dependency, schema, migration, public interface, or config key is
introduced. Nothing is removed from the adopter copy set, and `template/` never
appears in an adopted repository.

## Affected areas

Modified:

- `README.md` — quickstart bash block (`README.md:44-52`) and copy-set prose
  (`README.md:54-91`).
- `docs/customization.md` — the sentence at `docs/customization.md:64-67`.
- `tests/README.md` — the copy-set paragraph (`tests/README.md:5-11`).
- `CONTRIBUTING.md` — the maintainer-only paragraph
  (`CONTRIBUTING.md:121-133`).
- `.opencode/agent/bootstrap.md` — `permission.edit` map and body.
- `.opencode/command/bootstrap.md` — body.

Unchanged: `opencode.json`, root `AGENTS.md`, `template/**`,
`.opencode/agent/doctor.md`, `.opencode/agent/ask.md`, `docs/workflow.md`,
`docs/artifact-conventions.md`, `tests/checks/**`, `tests/run.sh`,
`tests/lib.sh`, `tests/mutation.sh`, and `.github/**`.

## Risks and mitigations

- **Order-dependent permission evaluation.** Likelihood low / impact high — if
  opencode does not honour last-match-wins, the trailing denies may not override
  the earlier `**/…` allows and AC3 fails. Mitigation: place the denies strictly
  last; verify with `opencode debug agent bootstrap` (AC3) when the CLI is
  available, and otherwise a static ordered assertion; child `0003` adds the
  committed guard.
- **`tests/README.md` edit breaks the mutation self-check.** Likelihood medium /
  impact medium — AC8 fails if the `` `docs/*.md`) `` literal moves. Mitigation:
  keep that literal the tail of the same parenthetical; T4 runs
  `bash tests/mutation.sh`.
- **README prose trips the packaging copy-set check.** Likelihood medium /
  impact medium — AC7 fails if new wording matches `CLAIMED_RE` or puts a
  packaging filename near a "copy set" marker in the scanned surfaces.
  Mitigation: avoid "part of the copied set" phrasings and keep packaging names
  away from copy markers; run `bash tests/run.sh`.
- **Adopter-facing wording mentions a `template/` path adopters lack.**
  Likelihood medium / impact low — `docs/customization.md` is copied verbatim.
  Mitigation: frame every mention as the framework repository's organisation and
  state that the adopter acts on their own copies; the bootstrap wording names
  `template/` only as the framework repository's location.
- **Guard over-reach denies the adopter's root files.** Likelihood low / impact
  high — a too-broad pattern would break legitimate bootstrapping. Mitigation:
  patterns are scoped under `template/`; the earlier root-file allows still
  match; T6 asserts an adopter root path resolves allow and a `template/` path
  resolves deny.
- **Intermediate leak window is closed only by the README edit.** Likelihood
  certain before T1 / impact high — the spec forbids publishing a release while
  the documented quickstart still names the root copies. Mitigation: T1 is the
  first task; `/ship` must not run until the full suite is green (T8).

## Test strategy

| Criterion | Verification level | Task / evidence |
| --------- | ------------------ | --------------- |
| AC1 | unit (grep) | T1: README quickstart names the three `template/` sources and no root-source copy |
| AC2 | integration (scratch run) | T1: run the documented quickstart in `scratch/`; placeholder `AGENTS.md`, pristine `opencode.json`/`.gitignore`, no `template/` |
| AC3 | static + tool (optional) | T6: ordered deny rules in `permission.edit`; `opencode debug agent bootstrap` when available |
| AC4 | unit (grep) | T6, T7: agent and command state the adopter-copy ownership and the never-modify rule |
| AC5 | unit (grep) | T2, T3, T4, T5: each surface names `template/` sources, the framework copies, and shared-verbatim |
| AC6 | unit (grep) | T2, T3, T4, T5: no surface claims an adopter receives a root copy |
| AC7 | integration | T8: `bash tests/run.sh` exits 0 (also run per-task) |
| AC8 | integration | T8: `bash tests/mutation.sh` reports `MUTATION TOTAL: … 0 failed` (T4 re-runs it) |
| AC9 | unit (grep) | T1: merge advisory retained; no migration/deletion step added |
