---
description: "Lightweight bug fix — reproduce, fix, test, report. Usage: /fix <bug description>"
agent: builder
---

Apply a **lightweight fix** (no spec or design) for:

$ARGUMENTS

Enter your lightweight fix mode. In order:

1. **Reproduce first.** Create a failing test or an exact reproduction. If you
   cannot reproduce the bug, stop and ask for precise steps, inputs, and expected
   behavior — do not guess-fix.
2. **Find the root cause** before editing. State it in one sentence.
3. **Make the smallest change** that fixes the cause. Do not add features,
   refactor, or reformat unrelated code.
4. **Add a regression test** that fails without the fix and passes with it.
5. **Run** the test command, lint, and typecheck for the touched scope.

If the "fix" turns out to require new behavior or a broad change, stop and
recommend `/spec` instead.

Never commit, push, or open a PR. End with the handoff block, which carries the
reproduction, root cause, change, files, and check results. When every check
passed and the defect was reproduced, name the sanctioned landing path as the
next action — the user explicitly requests `/ship fix` and the shipper performs
the git writes:

```
Done: <fix summary>; files changed (<paths>).
Checks: <test> → PASS; <lint> → PASS; <typecheck> → PASS.
Root cause: <one sentence>
Reproduction: <failing regression test or exact repro>
Next: /ship fix
Blockers: none
```

When the defect could not be reproduced or any check failed, do not present a
landing path: omit `Next: /ship fix`, report the failure as the blocker, and
stop. Do not commit, push, or open a PR yourself — only the shipper does, and
only on the user's explicit request.
