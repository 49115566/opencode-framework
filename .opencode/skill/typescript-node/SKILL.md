---
name: typescript-node
description: "TypeScript and Node.js conventions and tooling. Use when writing, testing, or reviewing TypeScript or JavaScript: pnpm/npm/yarn, vitest/jest, eslint/biome, prettier, tsc, tsconfig, ESM vs CJS."
---

# TypeScript / Node conventions

The repository's own config overrides everything below. Read `tsconfig.json`,
the linter config, and the `package.json` scripts before writing code. These are
defaults for when the repo is silent.

## Match the existing style

- Mirror import style, module system (ESM vs CJS), and file naming of neighbors.
- Match the formatter's output rather than hand-formatting. Run the formatter if
  one is configured.
- Reuse existing utilities and types. Search before creating a new helper.
- Prefer the repository's error-handling pattern (thrown errors, `Result` types,
  etc.) over inventing one.

## TypeScript

- Prefer precise types over `any`. If `any` is unavoidable, narrow it immediately
  and say why.
- Use `unknown` for untrusted input and narrow with type guards.
- Model invalid states out of existence with discriminated unions where practical.
- Avoid non-null assertions (`!`) on values that can legitimately be absent.
- Keep functions small and pure where possible; isolate side effects.
- Do not silence the compiler with `@ts-ignore` or `as` casts to make checks pass;
  fix the type or explain the unavoidable assertion.

## Node

- Handle promise rejections; never leave an unhandled async path.
- Validate external input at the boundary (env, HTTP, files) before trusting it.
- Do not log secrets or full request bodies.
- Prefer the standard library and already-installed dependencies.

## Verification

- Typecheck with the project's command (`tsc --noEmit` or a script) after changes.
- Run the focused tests for the touched area, then the full suite when feasible.
- Confirm the lint command is clean for changed files.

## Common pitfalls

- Editing emitted output under `dist/` or `build/` instead of source.
- Adding a dependency when the repo already has an equivalent.
- Assuming ESM/CJS — check `package.json` `"type"` and tsconfig `module`.
