---
feature: 0013-simultaneous-work-recursion/0003-recursive-conflicts
phase: test
status: final
created: 2026-10-13
updated: 2026-10-13
parent: 0013-simultaneous-work-recursion
---

# Verification — Recursive `conflicts-with` at every level

## Scope and verification approach

This item is **docs-only**: it generalizes the declared-conflict model from its
two-segment cap to arbitrary depth by editing exactly two authority documents —
`docs/workflow.md` ("Declared conflicts (`conflicts-with`)" and
"Declared-conflict check") and `docs/artifact-conventions.md` (the manifest
`conflicts-with` bullet). There is no executable implementation.

The spec's resolved verification approach (spec `## Open questions` →
"Verification approach") is **authority inspection plus the committed suite**:
recursion is verified by reading the named authority sections and by the existing
suite staying green. Committed recursive fixtures/guards are an explicit
**non-goal**, deferred to Roadmap 5, and AC15 requires
`tests/checks/85-conflict-guards.sh` and `tests/fixtures/declared-conflicts/` to
stay byte-unchanged. Accordingly the tester **added no committed test**: doing so
would violate the spec's non-goal and the resolved verification decision. Instead
54 inline authority-inspection assertions were executed against the live
documents (recorded below) as a reproducible, uncommitted inspection aid. No
production file was modified by the tester.

No `challenges.md` exists for this item, so there was **no open challenge to
adjudicate** before ordinary forward work.

**Note on the prior review finding.** The prior `review.md` raised **M1**
(`docs/workflow.md:293` read "one or more nested", contradicting the `*`). The
current working-tree text reads "optionally followed by nested `/<MMMM-slug>`
segments" — i.e. the contradicting phrase is gone. This is confirmed directly by
assertion `AC17-prose-consistency` (the corrected phrase is present) and
`AC17-no-narrowing` (the phrase "one or more nested" is absent). No verification
defect remains.

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 495 passed, 0 failed, 0 skipped`; exit 0 — full committed suite (baseline run and re-run identical) |
| `FRAMEWORK_TEST_AREAS=85-conflict-guards bash tests/run.sh` | PASS | `TOTAL: 49 passed, 0 failed, 0 skipped`; exit 0 — the declared-conflict guard area |
| `git diff --quiet -- tests/checks/85-conflict-guards.sh tests/fixtures/declared-conflicts/` | PASS | exit 0 — guard and fixture byte-unchanged (AC15) |
| `git diff --name-only` / `git status --porcelain` | PASS | tracked modifications: only `docs/artifact-conventions.md`, `docs/workflow.md`, `work/.../tasks.md`; `verify.md`/`review.md` untracked |
| inline authority-inspection assertions (54 assertions; see matrix) | PASS | `INSPECTION TOTAL: 54 passed, 0 failed`; extracts the named sections and asserts each AC's required statement and the absence of the superseded forms |

The full suite was run twice (before and after the inspection); the result was
identical (`495 passed, 0 failed, 0 skipped`, exit 0), so it is deterministic and
the passing result is attributable to the builder's docs edits. The only
working-tree changes are those docs edits plus `tasks.md` check boxes.

## Acceptance coverage

Every acceptance criterion is covered by a passing authority-inspection assertion
(the table names the asserted statement) and/or the committed suite. All text in
the right-hand column matches the live documents verbatim.

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — arbitrary-depth references well-formed | AI: grammar `SiblingOrItemRef ::= [0-9]{4}-[a-z0-9-]+( /[0-9]{4}-[a-z0-9-]+ )*`; "nesting to arbitrary depth — resolving to `work/<ref>/`"; old `)?` form absent. A `*` (zero-or-more) admits depth 3+ with no cap | PASS |
| AC2 — discriminator recognizes arbitrary depth | AI: `^[0-9]{4}-[a-z0-9-]+(/[0-9]{4}-[a-z0-9-]+)*$`; old `)?$` form absent. Committed guard `cell-resolution` proves the one- and two-segment boundary still classifies | PASS |
| AC3 — compared set recurses | AI: "walks the committed tree recursively and considers every **unshipped entity** at **any depth**"; "the child is **also** a decomposition whose rows are recursed the same way — to arbitrary depth"; "legacy `roadmap.md` alias" | PASS |
| AC4 — entity kinds at depth | AI: "one entity per `Children` row, even when the child directory holds only `.gitkeep`"; "one entity per top-level item directory that is not a decomposing node and has a `spec.md`" | PASS |
| AC5 — bare-token precedence = immediate parent then root | AI: "declaring entity's immediate parent's `Children` table first, then `work/<token>/` at the repository root"; no-parent root-only fallback; old "sibling row in the same table first" absent. Committed guard `a bare MMMM-slug resolves to its sibling row first` | PASS |
| AC6 — multi-segment references root-relative | AI: "A reference containing `/` is **root-relative** and is never resolved against a sibling table". Committed guard resolves the two-segment token `9001-roadmap-a/0004-shipped` from the fixture root | PASS |
| AC7 — cross-level naming permitted; distinct resolutions distinct | AI: "may name an ancestor, a descendant, or an item in a different subtree"; "Equal trimmed tokens that resolve to *different* items … are **not** the same target". Committed guard `cross-manifest equal token is not a shared target` | PASS |
| AC8 — `own ∪ cell` union at depth | AI: "The child's declared set is `own ∪ cell`, at every depth". Committed guard drift-union assertions include both own and parent sets | PASS |
| AC9 — `DRIFT-FACT` at depth | AI: findings table "An entity's own declaration and its immediate parent's cell disagree"; "A one-sided record is the union and is not a discrepancy". Committed guard `declaration drift matches the expected block` | PASS |
| AC10 — pair predicate between any two unshipped entities | AI: "evaluated between any two **unshipped entities at any depth**"; "is still a counterpart under this clause"; "Each unordered pair is reported **once**". Committed guard `pair-predicate` block | PASS |
| AC11 — shipped handling unchanged | AI: "A **shipped** entity still **resolves** as a target but is not a counterpart"; child "is **excluded** as a counterpart"; no `reopened`/`recalled` handling in the check section. Committed guard `shipped item is excluded as a counterpart` | PASS |
| AC12 — malformed/unresolved at depth reported | AI: "both are unresolved self-references"; "a list may not repeat a target after trimming"; "never dropped or auto-repaired". Committed guard `malformed/unresolved declarations match the expected block` | PASS |
| AC13 — no new vocabulary | AI: section states the finding-line grammar, `TEXTUAL-CONFLICT`/`DANGLING-DEP`/`DRIFT-FACT`, classes `(a)`/`(b)`/`(d)`; `(e)`, `DECLARED-`, `PLAN-`, `CONFLICT-` absent from the whole of `docs/workflow.md`. Committed guard `reporting-vocabulary` (11 assertions) | PASS |
| AC14 — advisory, read-only, no readiness effect | AI: "advisory, offline, local, and read-only"; "adds no readiness edge, reorders no child, and changes no"; "it takes no lock; and it modifies no file" | PASS |
| AC15 — backward compatibility + green suite; guard/fixture unchanged | `bash tests/run.sh` → `495 passed, 0 failed, 0 skipped` exit 0; `git diff --quiet` on guard + fixture → exit 0; committed guard resolves the two-segment token `9001-roadmap-a/0004-shipped` exactly as before | PASS |
| AC16 — empty compared set is a no-op | AI: "reports no findings and does not error". Committed guard `empty compared set … yields no findings` and `all-shipped compared set yields no findings` | PASS |
| AC17 — authority states the recursive contract | AI: `docs/workflow.md` states the arbitrary-depth grammar/discriminator, recursive compared set, immediate-parent-then-root precedence, `own ∪ cell` at depth, and `DRIFT-FACT` at depth (AC1–AC9 assertions); `docs/artifact-conventions.md` states "The recursive grammar is … references nest to arbitrary depth (`NNNN-slug(/MMMM-slug)*`) …" and references `docs/workflow.md`; "deferred to the successor" and "preserved unchanged" absent | PASS |

### Edge cases

Every listed edge case is stated in the authority and covered by the same
inspection. None has a committed executable analogue (see "Gaps and residual
risk"); this is the spec's resolved, docs-only verification approach.

| Edge case | Where stated (assertion) | Result |
| --------- | ------------------------ | ------ |
| Depth boundary (depth 3 and deeper, no cap) | grammar `*`, discriminator `*`, "nesting to arbitrary depth" (`EDGE-depth`) | PASS |
| Same bare token, different parents → different items | "Equal trimmed tokens that resolve to *different* items … are **not** the same target"; immediate-parent resolution (`AC7-distinct-targets`, `AC5-precedence`) | PASS |
| Sibling vs root-name collision → sibling wins | "declaring entity's immediate parent's `Children` table first, then `work/<token>/`" (`AC5-precedence`) | PASS |
| Multi-segment first segment equal to a sibling id → root-relative | "A reference containing `/` is **root-relative** … never resolved against a sibling table" (`AC6-root-relative`) | PASS |
| Self-reference (own local id / own full canonical reference) unresolved | "both are unresolved self-references" (`AC12-self-ref`) | PASS |
| One-sided declaration is the union, not drift | "A one-sided record is the union and is not a discrepancy" (`AC9-one-sided`) | PASS |
| Pure container vs hybrid | "never an entity itself as a container; it is a"; child's `own` from its `design.md` (`EDGE-container`, `EDGE-hybrid-own`) | PASS |
| `.gitkeep`-only child is an entity | "even when the child directory holds only `.gitkeep`" (`AC4-child-entity`) | PASS |
| Legacy `roadmap.md` alias at depth | "(`manifest.md`, or the legacy `roadmap.md` alias)" recursed identically (`AC3-legacy-alias`) | PASS |
| Shipped vs recalled | shipped "still **resolves** … but is not a counterpart"; check section introduces no `reopened`/`recalled` handling (`AC11-*`) | PASS |
| Empty comparison (no declarations / all shipped) | "reports no findings and does not error" (`AC16-empty`) + committed guard | PASS |

## Gaps and residual risk

- **No committed recursive guard (known, spec-sanctioned).** The generalized
  recursion at depth ≥ 3 (AC1–AC10, AC12) has no committed executable test: the
  two-segment `tests/checks/85-conflict-guards.sh` remains byte-unchanged and pins
  only the one- and two-segment cases plus the reporting vocabulary. This is the
  spec's explicit non-goal — committed recursive fixtures/guards are deferred to
  **Roadmap 5** — so the recursion is verified by authority inspection only. The
  one- and two-segment behaviours are still proven executably by the committed
  fixture/guard (49 assertions, all green), including the two-segment reference
  `9001-roadmap-a/0004-shipped`.
- **Live enforcement points are not CI-executable.** A real `/conflicts`,
  `/status`, or `/build`-gate run emitting the recursive findings is prompt
  behavior with no committed checker; it remains a documented manual check, as it
  already was for the two-level model. No live run was performed.
- **Tester added no production or committed-test changes.** The 54 authority
  assertions were executed inline (bash here-doc) and are not committed; the only
  tracked changes remain the builder's docs edits and `tasks.md` check boxes. No
  test was weakened, skipped, or deleted.
- **No defect found.** The implementation satisfies every acceptance criterion and
  edge case as stated in the spec. In particular, the prior `review.md` M1
  ("one or more nested") is resolved in the current working tree ("optionally
  followed by nested"), confirmed by assertions `AC17-prose-consistency` and
  `AC17-no-narrowing`; the classification question does not arise.

## Verdict

Verification **passes** — all 17 acceptance criteria and every listed edge case
are covered by a passing authority inspection and/or the committed suite; the
suite is green (`495/0/0`) and the guard/fixture are byte-unchanged. The only
residual is the spec-sanctioned absence of a committed recursive guard, deferred
to Roadmap 5.
