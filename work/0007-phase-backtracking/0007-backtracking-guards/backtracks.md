---
feature: 0007-phase-backtracking/0007-backtracking-guards
record: backtracks
created: 2026-10-09
updated: 2026-10-09
---

## Finding 1 — 2026-10-09

- detecting phase: `/build`
- target phase: `/plan`
- affected: `design.md`, `tasks.md`
- evidence: `design.md:213` (mutation self-check table, row 4) specifies the
  `challenge-loop` mutation as "change
  `items/9110-challenge-mixed/challenges.md` a Response header `## Response 2` →
  `## Ack 2`", but that fixture contains no `## Response 2`. Its challenge
  entries are `## Challenge 1` + `## Response 1`, `## Challenge 2` +
  `## Withdrawal 2`, and `## Challenge 3` + `## Response 3` + `## Reversal 3`
  (`tests/fixtures/backtracking/items/9110-challenge-mixed/challenges.md:19,36,50,58`;
  `tests/checks/87-backtrack-guards.sh:450-462` pins exactly this expected
  block). Reproducing the mutation as written is a no-op — `replace_first` finds
  no literal and the file is unchanged — so the suite exits 0 and
  `tests/mutation.sh` reports mutation 4 "not caught", failing the `T5` `Verify:`
  step (`bash tests/mutation.sh` → exit 0 with eight `AC24` "caught and named"
  lines). The fixture cannot be changed to add `## Response 2`: `Withdrawal 2` is
  what supplies the fourth entry kind that AC4 requires, and a second entry on
  Challenge 2 would flip it from `withdrawn` to `resolved`, contradicting the
  pinned expected block. The defect is therefore in the design's mutation anchor,
  not in the fixture or the guard. `design.md` §4 (`:80`) and §5 (`:213`) are
  mutually inconsistent.
- status: open

Recorded by the `/build` phase while selecting `T5`; the `design.md` and
`tasks.md` artifacts owned by the architect were not edited. The task remains
unchecked. The sanctioned route is `/plan <item-ref>` to correct the §5 mutation
anchor (for example to the existing `## Response 1`/`## Response 3` header, or to
`## Withdrawal 2`) so the mutation remains a meaningful, independently reachable
`AC24 challenge-loop` trip.

## Resolution 1 — 2026-10-09

- resolves: Finding 1
- revision: corrected the `challenge-loop` mutation anchor in `design.md` §5. The
  row referenced a nonexistent `## Response 2`; it now changes the fixture's sole
  `## Reversal 3` header to `## Ack 3`, which drops the `Reversal` entry and trips
  `AC24 challenge-loop` without collaterally changing `derived-state` (Challenge 3
  still carries `Response 3`, so it stays `resolved` and `9110` still derives
  `build`). `tasks.md` T5 already adds the eight mutations "from design §5" and
  needed no edit. Nothing was stale-marked on this item: `design.md`/`tasks.md`
  are the found-against target artifacts and are revised, not marked, and
  `verify.md`/`review.md` do not exist.

## Finding 2 — 2026-10-09

- detecting phase: `/build`
- target phase: `/plan`
- affected: `design.md`, `tasks.md`
- evidence: `design.md:211` (§5 mutation table, row 2) specifies the
  `record-status` mutation as "change
  `items/9107-resolved/backtracks.md` `- resolves: Finding 1` → `- resolves:
  Finding 9`", expected to trip `AC24 record-status`. But the analyzer
  `tests/checks/87-backtrack-guards.sh:130-154` (`fixture_backtrack_status`)
  keys resolution matching on the `## Resolution <n>` **header number**, never
  on the `- resolves: Finding <n>` **body field**: it reads the body only in
  `contract-pins`. Changing the body field is therefore a silent no-op for
  `record-status` — the expected block
  (`design.md:253-261`, `9107-resolved|1|resolved|1`) still matches and the
  suite exits 0. Reproduced: `bash tests/mutation.sh` reports
  `FAIL mutation AC24 not caught (broke a resolution's finding number): suite
  exited 0` (all seven other AC24 mutations are caught and named), so the T5
  `Verify:` step (`bash tests/mutation.sh` → exit 0) cannot pass. The design is
  internally inconsistent — §4 (`:121-126`) defines the effective status by a
  matching `Resolution <n>` header, while §5 mutation 2 (`:211`) expects a
  body-field change to trip it; the `- resolves:` literal is separately pinned
  by `contract-pins` (mutation 8). The defect is in the §5 anchor, not the
  fixture: the fixture's resolution genuinely resolves Finding 1, and the
  analyzer is faithful to the authority. Nothing was stale-marked on this item
  because `design.md`/`tasks.md` are the found-against target artifacts
  (revised, not marked) and `verify.md`/`review.md` do not exist.
- status: open

Recorded by the `/build` phase while completing `T5`; the `design.md` and
`tasks.md` artifacts owned by the architect were not edited. The task remains
unchecked. The sanctioned route is `/plan 0007-phase-backtracking/0007-backtracking-guards`
to correct the §5 `record-status` anchor so it makes 9107's resolution no longer
match its finding and trips only `AC24 record-status` — for example rename the
`## Resolution 1` header to `## Resolution 9` in
`tests/fixtures/backtracking/items/9107-resolved/backtracks.md` (then Finding 1
is `open` while the expected block is `resolved`); the `- resolves:` body field
change cannot work because the analyzer does not consume it. A revision that
instead strengthens the analyzer to consume the body field would need to say so
  in §4; the two must agree.

## Resolution 2 — 2026-10-09

- resolves: Finding 2
- revision: corrected the `record-status` mutation anchor in `design.md` §5. The
  row changed the `- resolves: Finding 1` **body field**, but
  `fixture_backtrack_status` (`tests/checks/87-backtrack-guards.sh:130-154`)
  matches a finding to a resolution by the `## Resolution <n>` **header number**
  and never consumes the body field, so the mutation was a silent no-op. The
  anchor now renames the resolution header `## Resolution 1` → `## Resolution 9`,
  leaving Finding 1 unmatched (`9107-resolved|1|open|1`) against the expected
  `9107-resolved|1|resolved|1`, which trips only `AC24 record-status` (the
  `- resolves:` body field remains pinned separately by the `contract-pins`
  mutation). `design.md` §4 now names the header-number matching key explicitly
  so §4 and §5 agree. `tasks.md` T5 already adds the eight mutations "from design
  §5" and needed no edit. Nothing was stale-marked on this item:
  `design.md`/`tasks.md` are the found-against target artifacts and are revised,
  not marked, and `verify.md`/`review.md` do not exist.
