---
name: test-strategy
description: Use when writing, reviewing, or planning tests, mapping acceptance criteria to test cases, choosing test levels, or deciding what to mock. Triggers during /test and /plan test-strategy work.
---

# Test strategy

Good tests fail when behavior is wrong and pass when it is right, and they keep
doing so as the implementation changes. Optimize for that, not for coverage
numbers.

## Test what the spec promises

Each acceptance criterion needs at least one test that would fail if the
criterion were unmet. Start from the criteria, not from the code. Covering code
that no criterion requires is optional; missing a criterion is not.

## The levels

- **Unit** — one function or module in isolation. Fast, numerous. For pure logic,
  parsing, calculations, edge cases.
- **Integration** — several real components together (service + database, route +
  handler). For contracts between modules.
- **End-to-end** — the real system through its public surface. Few, slow, and
  high-value. For the critical user journeys.
- **Manual** — when automation is impractical. Record exact steps and the reason
  it is manual in `verify.md`.

Prefer the lowest level that can catch the failure. Do not push everything to
e2e.

## Write behavior, not implementation

- Assert on observable behavior and outputs, not private internals or call
  sequences, unless the interaction *is* the contract.
- Name tests after the behavior: `returns_empty_list_when_no_results`, not
  `test_search_2`.
- Arrange–Act–Assert with a single logical assertion per test.
- Tests must be deterministic and independent: no reliance on execution order,
  wall-clock time, or shared mutable state.

## Mocking

- Mock at the boundary you do not own: network, clock, filesystem, randomness.
- Prefer real collaborators when they are fast and deterministic.
- Do not mock the thing under test, or you test the mock.
- A test that only asserts a mock was called proves the code called a function,
  not that it did the right thing.

## Before claiming tests pass

- Run the project's test command and read the output, not just the exit code.
- Confirm the new test fails without the change (or would have).
- Report counts and any skips, and never skip or weaken a test to get green.
