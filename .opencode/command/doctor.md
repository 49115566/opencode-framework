---
description: "Read-only diagnostic for framework drift — inventory, counts, permissions, and ignore rules. Usage: /doctor"
agent: doctor
---

Produce a **consistency diagnostic**. This is read-only: do not edit any file
and do not run any command that writes.

Follow your Doctor agent instructions exactly. In particular:

- Resolve the repository root once with `git rev-parse --show-toplevel` and build
  every path from it, so the run works from any working directory.
- Run the nine checks and report every finding in the
  `[CODE] <source-of-truth> <-> <stale location>: <detail>` format:
  - Agent inventory — `AGENT-UNDOCUMENTED`, `AGENT-PHANTOM`.
  - Command inventory — `COMMAND-UNDOCUMENTED`, `COMMAND-PHANTOM` (the `ask`
    agent intentionally has no command; not a finding).
  - Skill inventory — `SKILL-UNDOCUMENTED`, `SKILL-PHANTOM`.
  - Counts — `COUNT-MISMATCH` against the README layout comments.
  - Permission work pattern — `PERMISSION-WORK-PATTERN` (both `work/**` and
    `**/work/**` are required).
  - Permission table — `PERMISSION-TABLE-MISMATCH` against the README Agents
    table.
  - Ignore rules — `IGNORE-MISSING` (`.playwright-mcp/`, `scratch/`).
  - Temp path — `TEMP-PATH-OUTSIDE-WORKSPACE` (no system temp directory use).
  - Skill name — `SKILL-NAME-MISMATCH` against each skill directory name.
- Compare names and integers after normalising whitespace and table alignment,
  so formatting differences never produce false positives.
- If there are no findings, print exactly:
  `No findings — repository is consistent.`
  then the checked counts (agents, commands, skills). Otherwise print every
  finding first, then the summary.
- Do not fix drift or treat intentional absences (such as `ask` having no
  command, or the deferred backlog) as findings.

End with the handoff block. Do not commit, push, or open a PR.
