---
feature: 0004-adoption-template-split/0005-surface-consistency-sweep
phase: design
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
---

# Design — Command signature and prompt-surface sweep

## Summary

Repair the two incomplete command usage strings (`/spec`, `/ship`) into one
canonical registry, propagate that registry verbatim to the five in-scope
documented surfaces (root and template `AGENTS.md`, `docs/workflow.md`,
`README.md`, and the `workflow-lifecycle` skill), fix the `ask` agent
description, and add one self-contained committed check
(`tests/checks/96-signature-sweep.sh`, suite token `AC22`) that extracts each
stated signature from a designated position on each surface, decodes the
markdown-table and mermaid encodings, and fails naming the file and command when
a signature diverges. All changes are wording-only; no command behavior, phase,
routing, lifecycle, or artifact format changes.

## Approach

The spec's "Canonical signatures" table is the single source of truth. The design
turns it into a registry and applies it in four steps.

1. **Register.** Encode the table as the function `canonical_signature` in the new
   check (exact strings in "Interfaces and data model").
2. **Repair the sources.** Edit the two command usage strings the spec names as
   incomplete: `/spec` gains its item-ref form and `/ship` gains its fix-landing
   form (AC1). Every other command usage string is already canonical and is not
   edited (the spec's Non-goals restrict command-file edits to these two).
3. **Propagate.** Replace each divergent rendering with the canonical string on
   the five documented surfaces (AC2–AC6). Rendering is surface-specific because
   markdown tables and mermaid treat `|` and `<`/`>` specially (see below).
4. **Guard.** Add `96-signature-sweep.sh` (AC8) and document its area/token in
   `tests/README.md`.

### Per-surface rendering (exact)

The canonical registry contains a literal `|`, which is a cell separator in
markdown tables; table cells therefore write it escaped as `\|`. Mermaid node
labels HTML-escape `<`/`>` as `&lt;`/`&gt;`. Fenced blocks and prose headings,
which are not tables, use the raw string. The guard decodes both encodings
before comparing (spec Edge case "HTML-escaped signatures in mermaid").

| Surface | Position | Commands changed | Rendering |
| ------- | -------- | ---------------- | --------- |
| `AGENTS.md`, `template/AGENTS.md` | lifecycle table Command cell | `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` | backticked; pipe backslash-escaped in `/spec` |
| `AGENTS.md`, `template/AGENTS.md` | `Supporting commands:` list | `/fix`, `/visual` | backticked; raw |
| `docs/workflow.md` | six phase headings | `/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship` | backticked; raw |
| `docs/workflow.md` | `/visual` routing bullet | `/visual` | backticked; raw |
| `README.md` | `## Commands` table Command cell | `/spec`, `/build`, `/visual`, `/fix` | backticked; pipe backslash-escaped in `/spec` |
| `README.md` | lifecycle mermaid command node labels | `/spec`, `/build`, `/test`, `/review`, `/ship`, `/visual` | angle brackets HTML-escaped; pipe left literal |
| `.opencode/skill/workflow-lifecycle/SKILL.md` | "Which command now?" fenced block route targets | `/spec`, `/build`, `/test`, `/review`, `/ship` | raw (fenced block) |
| `.opencode/command/spec.md` | `Usage:` string | `/spec` | raw (YAML quoted scalar) |
| `.opencode/command/ship.md` | `Usage:` string | `/ship` | raw (YAML quoted scalar) |

Concretely, the target strings are:

- `/spec` — `/spec <feature or problem description | item-ref>`
- `/plan` — `/plan <item-ref>`
- `/build` — `/build [item-ref or task-id]`
- `/test` — `/test [item-ref]`
- `/review` — `/review [item-ref]`
- `/ship` — `/ship [item-ref]` (command usage also names `/ship fix [short description]`)
- `/visual` — `/visual [url or item-ref]`
- `/fix` — `/fix <bug description>`
- `/roadmap` — `/roadmap <initiative>`
- `/status` — `/status [item-ref]`
- `/doctor`, `/bootstrap` — the bare command name

Nothing else on a surface changes. In particular the `README.md` quickstart
bash block (`/spec add dark mode`, `/plan 0001-add-dark-mode`, bare `/build`,
`/test`, `/review`, `/ship`), handoff examples, the `AGENTS.md` guardrail XML,
the `docs/workflow.md` `/fix <bug>` routing bullet, and the `README.md`
Agents/Skills tables are concrete invocations or out of the enumerated scope and
are left untouched (spec Edge case "Invocations are not signatures"; Non-goals).

`ask.md` line 2 becomes exactly:

```
description: Q&A agent. Answers whatever the user has on their mind with plain, thorough explanations. Read-only.
```

### Guard mechanics

`tests/checks/96-signature-sweep.sh` is sourced by `tests/run.sh` like every
other check. It reads only live surfaces (never `work/**`) and uses bash + awk/
grep/sed only. It emits `ok`/`FAIL` lines labelled `AC22`, prints nothing else to
stdout except its `== AC22 … ==` banner, and never calls `exit`.

- **Extract** one `command<TAB>signature` pair per signature occurrence from the
  *designated positions only* (see "Interfaces and data model"). No free-prose
  scanning, so concrete invocations such as `/plan 0001-add-dark-mode` or
  `/build T2` are never treated as signatures.
- **Normalize** each extracted signature: trim, strip surrounding backticks,
  collapse internal whitespace runs to one space, decode `\|` → `|`, `&lt;` → `<`,
  `&gt;` → `>`.
- **Classify** the token: `cmd` is the first whitespace-delimited word. If `arg`
  is empty it is a signature (a bare command must equal a bare canonical, else it
  must be expanded); if `arg` begins with `<` or `[` it is a signature; otherwise
  it is a concrete invocation and is skipped (this is how `/ship fix` and
  `/spec add dark mode` stay legal).
- **Compare** each signature against `canonical_signature "$cmd"`:
  - match → `ok "AC22 <file> states canonical <cmd>"`.
  - mismatch → `bad "AC22 <file> states a divergent signature for <cmd>: found '<found>', expected '<canonical>'"`.
  - a command required on a surface but absent → `bad "AC22 <file> does not state a signature for <cmd>"` (the spec Edge case "Missing surface or command"; keeps the check non-vacuous).
- **Usage strings.** Assert `.opencode/command/spec.md` contains the canonical
  `/spec … | item-ref>` string; assert `.opencode/command/ship.md` contains the
  exact usage line `/ship [item-ref] | /ship fix [short description]` (the spec
  Edge case "The `/ship` alternate form": accept the phase form as canonical
  while still requiring fix mode in the command usage, anchored to the usage line
  so body prose cannot satisfy it).
- **ask description.** Assert `.opencode/agent/ask.md` carries the exact AC7
  description, so that finding is machine-verified too.

Required signature sets per surface: root and template `AGENTS.md` — lifecycle
`{spec, plan, build, test, review, ship}` plus supporting
`{fix, status, roadmap, bootstrap, visual, doctor}`; `docs/workflow.md` — the six
phase commands plus `visual`; `README.md` — Commands table all twelve commands
plus mermaid `{spec, plan, build, test, review, ship, visual}`; the skill —
routing block `{roadmap, spec, plan, build, test, visual, review, ship, status}`.

**Scoping note (`/status`).** `/status`'s own command file declares
`Usage: /status [item-ref]` and its body supports an optional argument, so the
canonical table records `/status [item-ref]` (see "Interfaces and data model").
The four surfaces that state `/status` — the root and template `AGENTS.md`
supporting list, the `README.md` Commands table, and the skill routing block —
are updated to match, and the guard registry and required sets carry the same
form. `.opencode/command/status.md` already matches and is edited by no one, so
the sweep stays inside the spec's Non-goals. This supersedes an earlier reading
of the spec table that listed bare `/status`, which would have made AC1 ("no
command states a divergent signature") unsatisfiable.

## Alternatives considered

- **Option A — global canonical-presence plus stale-string absence greps.**
  Pros: trivial to write. Cons: the spec's forms collide as substrings (bare
  `/test` is a substring of `/test [item-ref]`, `/spec <feature>` prefixes the
  canonical `/spec <feature or problem description | item-ref>`), and valid
  invocations match the stale shapes, so it both over- and under-fires and cannot
  name the offending command. Rejected.
- **Option B — extend `20-lifecycle.sh` to also compare argument signatures.**
  Pros: no new file. Cons: the spec's Dependencies and constraints state
  `20-lifecycle.sh` deliberately ignores argument signatures and that the new
  guard is additive so it "does not fork that agreement"; folding would couple two
  agreement areas and risk regressing AC7. Rejected.
- **Option C — chosen.** Structured extraction from designated signature
  positions into `file<TAB>command<TAB>signature` records, normalized and compared
  to a canonical registry, with presence assertions. It matches the suite's
  existing parser style (`95-split-guard.sh`), cannot confuse invocations with
  signatures, names file and command on every failure, and covers exactly the
  positions the spec enumerates for AC2–AC6.

## Interfaces and data model

This change has no runtime interface; its "interfaces" are the canonical registry
and the guard's extraction contract. Both are fully specified here so no builder
decision remains.

Canonical registry (bash; the guard's only source of truth):

```sh
canonical_signature() {
  case "$1" in
    /spec)    printf '%s' '/spec <feature or problem description | item-ref>' ;;
    /plan)    printf '%s' '/plan <item-ref>' ;;
    /build)   printf '%s' '/build [item-ref or task-id]' ;;
    /test)    printf '%s' '/test [item-ref]' ;;
    /review)  printf '%s' '/review [item-ref]' ;;
    /ship)    printf '%s' '/ship [item-ref]' ;;
    /visual)  printf '%s' '/visual [url or item-ref]' ;;
    /fix)     printf '%s' '/fix <bug description>' ;;
    /roadmap) printf '%s' '/roadmap <initiative>' ;;
    /status)  printf '%s' '/status [item-ref]' ;;
    /doctor|/bootstrap) printf '%s' "$1" ;;
  esac
}
```

Extraction contract (designated positions; first backticked `/…` token unless
noted):

1. **AGENTS lifecycle table** (`AGENTS.md`, `template/AGENTS.md`) — every line
   matching `^|` from which the first backticked `/…` token is taken (the Command
   cell). The file's only table is the lifecycle table.
2. **AGENTS supporting list** — the `Supporting commands:` line and its
   continuation up to the next blank line; every backticked `/…` token.
3. **`docs/workflow.md` phase headings** — every line matching `^### [0-9]+[.] `;
   its first backticked `/…` token.
4. **`docs/workflow.md` `/visual` bullet** — the line matching `^- [*][*]` that
   contains a backticked `/visual` token; that token.
5. **`README.md` Commands table** — within `## Commands`, every `^|` row's first
   backticked `/…` token.
6. **`README.md` mermaid** — every `["/…"]` label; content between `["` and `"]`.
7. **skill routing block** — within the fenced block under `## Which command now?`,
   for each line containing `→`, the substring beginning at the first `/` after
   the arrow and ending before the next run of two-or-more spaces (or end of
   line), trimmed. This yields `/status [item-ref]` even on the
   `… → wait, or override explicitly; /status [item-ref]` line.
8. **usage strings** — literal substrings in `.opencode/command/spec.md` and
   `.opencode/command/ship.md`.
9. **ask description** — literal substring in `.opencode/agent/ask.md`.

Normalization and classification are defined in "Guard mechanics" above.
No new dependency, install step, build step, or network access is introduced;
the check runs on bash + git. There is no data migration: the surfaces are
static text.

## Affected areas

- `AGENTS.md` — lifecycle table (lines 35–40) and `Supporting commands:` list
  (lines 46–48).
- `template/AGENTS.md` — the same two positions (lines 35–40, 46–48); its
  `## Project profile` (lines 11–27) is untouched so the `95-split-guard.sh`
  placeholder assertion keeps passing.
- `docs/workflow.md` — phase headings at lines 139, 153, 170, 184, 204, 217 and
  the `/visual` routing bullet at line 306.
- `README.md` — Commands table (lines 194–201) and lifecycle mermaid labels
  (lines 139–151).
- `.opencode/skill/workflow-lifecycle/SKILL.md` — the "Which command now?" block
  (lines 31–43).
- `.opencode/command/spec.md`, `.opencode/command/ship.md` — the `description:`
  `Usage:` strings (line 2).
- `.opencode/agent/ask.md` — `description:` (line 2).
- `tests/checks/96-signature-sweep.sh` — new.
- `tests/README.md` — Checks table row and the AC22 token explanation.

Existing checks that read these files and must stay green: `20-lifecycle.sh`
(parses the two tables by backticks — a `\|` inside a backticked cell does not
disturb it), `40-inventory.sh` (reads each README Commands row's first cell,
whose leading `/name` is preserved), `90-packaging.sh`, `50-instructions.sh`, and
`95-split-guard.sh` (quickstart block and template profile unchanged).

## Risks and mitigations

- **Table pipe breaks rendering/parsing.** The canonical `/spec` string contains
  `|`; written raw in a markdown table it splits the cell. *Likelihood:* high if
  unescaped / *Impact:* medium. *Mitigation:* write `\|` in table cells, decode
  `\|` in the guard, and re-run `20-lifecycle.sh` and `40-inventory.sh`; both
  parse by backticks/first-token and were checked to tolerate the escape.
- **Mermaid label with `|` fails to render.** The `/spec` label carries a raw `|`
  inside a quoted node label. *Likelihood:* low / *Impact:* low (docs only).
  *Mitigation:* keep it inside `["…"]`; verify rendering manually in the PR; fall
  back to the numeric entity `#124;` and add it to the decoder only if a real
  render fails.
- **Guard confuses invocations with signatures.** A loose scan would reject
  `/build T2` or bare routing invocations. *Likelihood:* medium / *Impact:* high
  (false failures block the suite). *Mitigation:* extraction is restricted to the
  designated positions and concrete-argument tokens are classified as
  invocations; the AC8 task verifies the guard passes on the real surfaces.
- **Guard passes vacuously.** A deleted signature could pass if only comparisons
  run. *Likelihood:* medium / *Impact:* high. *Mitigation:* per-surface required
  sets produce a `bad` naming the file and command when a required signature is
  absent, and the AC8 task verifies sensitivity by mutating one surface and
  confirming the failure names it.
- **`/status` diverged from its command file.** `.opencode/command/status.md`
  declares `Usage: /status [item-ref]`, which the spec's table originally listed
  as bare `/status`. *Likelihood:* certain / *Impact:* medium (AC1 would be
  unsatisfiable). *Mitigation:* the canonical row records `/status [item-ref]`;
  the four stating surfaces and the guard registry are updated together, and
  `status.md` is left untouched because it already matches.
- **`docs/workflow.md` `/fix <bug>` routing bullet left stale.** The spec scopes
  workflow.md to the six headings plus the `/visual` bullet, so this divergent
  `/fix` rendering remains. *Likelihood:* certain / *Impact:* low. *Mitigation:*
  recorded as a follow-up for the user to decide whether to widen scope.
- **Sibling checkout coupling.** Editing README/AGENTS could break the split,
  inventory, lifecycle, packaging, or instruction agreements. *Likelihood:*
  medium / *Impact:* high. *Mitigation:* the AC9 task runs the whole suite after
  every surface edit; extraction uses code spans, the quickstart block and
  template profile are untouched.
- **Future command additions fail the guard by design.** *Likelihood:* intended /
  *Impact:* low. *Mitigation:* the canonical registry and the guard are updated
  together, as the spec's Edge case "Future command changes" requires.

## Test strategy

| Acceptance criterion | Verification level | Where |
| -------------------- | ------------------ | ----- |
| AC1 | static + guard | T1 greps both usage strings; AC22 asserts them |
| AC2 | static + guard | T2 greps root `AGENTS.md`; AC22 extracts its table and supporting list |
| AC3 | static + guard | T3 greps `template/AGENTS.md` and re-runs `95-split-guard.sh`; AC22 extracts it |
| AC4 | static + guard | T4 greps `docs/workflow.md`; AC22 extracts the six headings and `/visual` bullet |
| AC5 | static + guard | T5 greps `README.md`; AC22 extracts the Commands table and mermaid labels (entity-decoded) |
| AC6 | static + guard | T6 greps the skill; AC22 extracts the routing block |
| AC7 | static + guard | T7 greps the `ask.md` description; AC22 asserts the exact string |
| AC8 | integration | T8 adds the check and proves it fails naming file+command on a mutated surface; T9 documents AC22 in `tests/README.md` |
| AC9 | integration | T10 runs `bash tests/run.sh` and asserts exit 0 with the split, inventory, packaging, lifecycle, and instruction checks present and passing |

No criterion is manual-only. The guard's negative (mutation) verification in T8
is the same technique `tests/mutation.sh` uses; adding an AC22 case to that
opt-in script is a nice-to-have, not required by any criterion, and is listed as
a follow-up.
