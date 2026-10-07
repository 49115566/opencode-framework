---
feature: 0004-adoption-template-split/0005-surface-consistency-sweep
phase: tasks
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
---

# Tasks — Command signature and prompt-surface sweep

Ordered, dependency-aware. Exact target strings, rendering/escaping rules, and
the guard contract are fixed in `design.md` → "Approach" and "Interfaces and data
model"; no task requires a further design decision. One task ≈ one focused
commit.

- [x] **T1** — Repair the two incomplete command usage strings: in
      `.opencode/command/spec.md` line 2, make the `Usage:` string
      `/spec <feature or problem description | item-ref>`; in
      `.opencode/command/ship.md` line 2, make it
      `/ship [item-ref] | /ship fix [short description]`. Change nothing else in
      either file. [AC1]
      Verify: `grep -F 'Usage: /spec <feature or problem description | item-ref>' .opencode/command/spec.md` and `grep -F 'Usage: /ship [item-ref] | /ship fix [short description]' .opencode/command/ship.md` both match, and `bash tests/run.sh` exits 0.

- [x] **T2** — Apply the canonical registry to the root `AGENTS.md`: replace the
      six lifecycle-table Command cells (lines 35–40) with the canonical
      signatures (escaping the `/spec` cell's `|` as `\|`) and replace `/fix <bug>` and `/visual [url|slug]` in the `Supporting commands:` list (lines 46–48). Leave the Project profile, guardrail XML, footnote, and working-agreement prose untouched. [AC2] [depends: T1]
      Verify: `bash tests/run.sh` exits 0; the six Command cells read `/spec <feature or problem description \| item-ref>`, `/plan <item-ref>`, `/build [item-ref or task-id]`, `/test [item-ref]`, `/review [item-ref]`, `/ship [item-ref]`, the supporting list reads `/fix <bug description>` and `/visual [url or item-ref]`, and none of `/plan <feature>`, `/build [task-id]`, `/fix <bug>`, or `/visual [url|slug]` remains.

- [x] **T3** — Apply the same two edits to `template/AGENTS.md` (lifecycle table
      lines 35–40; supporting list lines 46–48), mirroring T2 exactly. Do not
      touch the `## Project profile` section (lines 11–27). [AC3] [depends: T1]
      Verify: `bash tests/run.sh` exits 0 (in particular
      `tests/checks/95-split-guard.sh` still reports the placeholder Project
      profile); `git diff -- template/AGENTS.md` shows changed lines only within
      lines 35–48.

- [x] **T4** — Apply the canonical registry to `docs/workflow.md`: replace the
      command in the six phase headings at lines 139, 153, 170, 184, 204, 217
      (`/spec <feature>`, `/plan <feature>`, `/build [task-id]`, `/test`,
      `/review`, `/ship`) and the `/visual [url or slug]` routing bullet at line
      306. Leave all other mentions (Next lines, the `/fix <bug>` routing bullet,
      the fix-track prose) untouched. [AC4] [depends: T1]
      Verify: `bash tests/run.sh` exits 0; the six headings state the canonical
      signatures and the bullet reads `/visual [url or item-ref]`.

- [x] **T5** — Apply the canonical registry to `README.md`: replace the Commands
      table cells at lines 194–201 (`/spec`, `/build`, `/visual`, `/fix`; escape
      the `/spec` cell's `|` as `\|`) and the lifecycle-mermaid command labels at
      lines 139–151 (`/spec` entity-escaped as `&lt;…&gt;`, plus `/build`,
      `/test`, `/review`, `/ship`, `/visual`). Leave the quickstart bash block,
      copy-set prose, Agents/Skills tables, and Layout untouched. [AC5]
      [depends: T1]
      Verify: `bash tests/run.sh` exits 0; the Commands table and mermaid labels
      state the canonical signatures (decoding `\|` and `&lt;`/`&gt;`), no
      `/build [task]`, `/visual [url]`, or `/fix <bug>` remains, and
      `tests/checks/40-inventory.sh` and `tests/checks/90-packaging.sh` stay
      green.

- [x] **T6** — Apply the canonical registry to the "Which command now?" fenced
      block in `.opencode/skill/workflow-lifecycle/SKILL.md` (lines 31–43):
      `/spec <feature>` → canonical; `/build <item-ref>` (both occurrences) →
      `[item-ref or task-id]`; bare `/test`, `/review`, `/ship` → canonical with
      `[item-ref]`; `/visual [url or item-ref]` already canonical. Leave `/ship
      fix` and the rules prose untouched. [AC6] [depends: T1]
      Verify: `bash tests/run.sh` exits 0; every route target in the block equals
      the canonical signature for its command, with no stale form remaining.

- [x] **T7** — Replace `.opencode/agent/ask.md` line 2's description with exactly
      `Q&A agent. Answers whatever the user has on their mind with plain, thorough explanations. Read-only.`,
      changing no other line. [AC7]
      Verify: `grep -F 'description: Q&A agent. Answers whatever the user has on their mind with plain, thorough explanations. Read-only.' .opencode/agent/ask.md` matches and the string `Ultra-Basic Read-Only Agent.` no longer appears.

- [x] **T8** — Add `tests/checks/96-signature-sweep.sh` implementing the AC22
      guard exactly as specified in `design.md` → "Guard mechanics" and
      "Interfaces and data model": the `canonical_signature` registry, the nine
      designated-position extractors, normalization (`\|`, `&lt;`, `&gt;`),
      signature-vs-invocation classification, the per-surface required sets, the
      usage-string checks for `spec.md`/`ship.md`, and the `ask.md` description
      assertion. Follow the suite conventions (`AC22` labels in `ok`/`bad`
      output, no `exit`, banner `== AC22 signature agreement ==`).
      [AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` exits 0 and prints `AC22` `ok` lines for every
      in-scope surface; then confirm sensitivity by temporarily changing the
      `/build` cell in `README.md` to `/build [task]`, re-running
      `bash tests/run.sh`, and confirming it exits non-zero with a message naming
      both `README.md` and `/build`; restore the file and confirm exit 0 again.

- [x] **T9** — Document the new check in `tests/README.md`: add
      `tests/checks/96-signature-sweep.sh` to the Checks table with its area
      ("command signature agreement across the in-scope surfaces plus the `ask`
      agent description; suite token `AC22`"), and add the short AC22 mapping
      paragraph in the style of the existing `90-packaging.sh` and
      `95-split-guard.sh` notes. [AC8] [depends: T8]
      Verify: `grep -F '96-signature-sweep.sh' tests/README.md` and
      `grep -F 'AC22' tests/README.md` both match, and `bash tests/run.sh` exits 0.

- [x] **T10** — Run the whole committed suite on the finished change and confirm
      nothing regressed. [AC9] [depends: T8, T9]
      Verify: `bash tests/run.sh` exits 0, and its output includes the split
      guard, inventory, packaging, lifecycle, instruction, and new AC22
      assertions with no `FAIL` line.
