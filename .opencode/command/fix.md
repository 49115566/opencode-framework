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

Never commit. End with the handoff block: reproduction, root cause, change,
files, and check results.
