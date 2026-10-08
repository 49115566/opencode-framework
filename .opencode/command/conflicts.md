---
description: "Read-only report of declared conflicts among the unshipped committed plans under work/. Usage: /conflicts [item-ref]"
agent: status
---

Produce a **declared-conflict report**. This is read-only: do not edit any file.

Follow your Status agent instructions exactly. In particular:

- Run the read-only declared-conflict check defined in `docs/workflow.md` →
  `## Declared-conflict check`; reference that authority and do not restate its
  algorithm here.
- With no argument, report every declared conflict, unresolved declaration, and
  parent/item declaration discrepancy across the whole `work/` tree.
- With an item-ref, report only the findings that involve that item and name each
  counterpart.
- Use the shipped finding-line grammar
  `- [<CODE>] (<class>) <offender canonical reference(s)> — <detail>` and the
  shipped `(a)`–`(d)` class labels; add no new class, code, or policy. The same
  findings appear in the `/status` report.
- The check is advisory, offline, local-only, and read-only: it reads committed
  `work/` state and the local repository for target resolution, performs no fetch,
  remote read, merge, or dry-run merge, takes no lock, modifies no file, adds no
  readiness edge, and blocks no phase.

If `work/` has no unshipped plan with a declaration, report no findings and do not
error. Do not start or run any phase. End with the handoff block.
