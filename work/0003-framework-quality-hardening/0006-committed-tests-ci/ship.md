---
feature: 0003-framework-quality-hardening/0006-committed-tests-ci
phase: ship
status: final
created: 2026-10-06
updated: 2026-10-06
parent: 0003-framework-quality-hardening
---

# Ship record — Committed test harness and CI

- Branch: `feat/0003-framework-quality-hardening-0006-committed-tests-ci`
- PR: https://github.com/49115566/opencode-framework/pull/10
- Commits:
  - `f186d65` test(tests): add canonical framework test harness and entry point
  - `9fd7b16` docs: document instruction set, default agent, and maintainer-only tests
  - `b4339f7` test(checks): assert readiness and dependency semantics agree (AC6)
  - `8b2eb04` test(checks): assert lifecycle and derived-state agreement (AC7)
  - `685f3a2` test(checks): assert documented permissions match declarations (AC8)
  - `35ec6c5` test(checks): assert inventory counts match disk (AC9)
  - `948267a` test(checks): assert always-loaded instruction set agreement (AC10)
  - `4d1176a` test(checks): assert default-agent agreement (AC11)
  - `3ca0c7e` test(checks): assert external MCP pin agreement (AC12)
  - `e96c348` test(checks): assert roadmap cycle rule with a committed fixture (AC13)
  - `893a344` ci: run the canonical test suite on push and pull request (AC4, AC5)
  - `6499514` test(tests): add opt-in mutation self-check (AC2, AC14, AC15)
  - `b13e70e` docs(work): add committed-tests-ci work-item artifacts

Shipped from `main` at `18fe4b9`. Review verdict `approve`; no override was
needed. The canonical suite (`bash tests/run.sh`) was recorded passing in
`verify.md` (160 passed, 0 failed, 0 skipped) but could not be re-executed in the
ship session (read-only bash guard); CI runs it on this branch.
