---
feature: 0004-adoption-template-split/0003-split-guard-tests
phase: review
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Static review; could not execute the suite or mutation self-check under the read-only Bash allowlist. Baseline residuals are bounded and documented; no Blocker or Major found."
---

# Review — Committed split guards

## Verdict

**approve** — the new `AC21` agreement area statically asserts the split's five
observable properties, the change is scoped to `tests/**`, the mutation targets
the block copy command, and no acceptance criterion is unmet; the findings below
are bounded coverage gaps, not correctness or security defects.

## Method and base

The work is **uncommitted** on `main`; the tracked diff is only `tests/README.md`
and `tests/mutation.sh`, plus the new untracked `tests/checks/95-split-guard.sh`
(and this item's artifacts under `work/`). Commands used:

```sh
git merge-base HEAD origin/main      # 5c715a0a3a34c24db8a485725e745885dab9ca79 (== HEAD)
git status                           # branch main, up to date with origin/main
git diff -- tests/README.md tests/mutation.sh
git diff --stat
```

Because `HEAD == origin/main`, the review range is the working tree:
`git diff` for the two modified files and direct reads of the new file. The
uncommitted/untracked state is expected for `/review` (nothing is committed until
`/ship`).

**Execution limitation.** The read-only Bash allowlist permits only
`git`/`ls`/`cat`; `bash tests/run.sh` and `bash tests/mutation.sh` are denied, so
the suite was **not** re-run here. Correctness was judged by reading the check
against the live surfaces it asserts, plus the recorded `verify.md` evidence.

## Acceptance criteria

| Criterion | Status | Evidence |
| --------- | ------ | -------- |
| AC1 — suite exits 0 with the new guards and every existing agreement green | **met** | Change is `tests/**`-only and additive: new check file sourced by the existing `tests/checks/*.sh` glob (`tests/run.sh:38-49`), no runner/lib edit. Baseline `AC4` scan was re-derived by reading all four surfaces; the only filename+root+copy-verb lines are negated or lack a verb (`README.md:63-64`, `docs/customization.md:32-34`, `tests/README.md:91`). `verify.md:17-19` records `209 passed, 0 failed`. |
| AC2 — quickstart sources each of the three from `template/<file>`, never a root copy, whole-dir copy rejected, missing block/source fails naming the file | **met** | `95-split-guard.sh:146-207`. Parser trace on `README.md:44-54` yields `template/AGENTS.md→./AGENTS.md`, `…opencode.json`, `….gitignore`; `root_offender` at `:183`, whole-dir at `:162-170`, missing source `:174-176`, missing block `:156-158`. Mutation re-points the first occurrence — confirmed to be the block line `README.md:49`. |
| AC3 — `template/AGENTS.md` presents the unfilled placeholder Project profile; filled/missing fails naming the file | **met** | `95-split-guard.sh:225-284`. All ten labels (`:233-242`) match `template/AGENTS.md:15-24`; values match `_*_` (`:265-268`); only `template/AGENTS.md` is read. |
| AC4 — copy-set surfaces never claim an adopter receives a root copy; a reintroduced claim fails naming the surface | **met** | `95-split-guard.sh:370-432`. Positive anchor (`:395-404`) prevents a vacuous pass; line/clause-scoped wrong-claim scan (`:408-431`). Baseline clean per the re-derived scan above. `M1`/`N1` note bounded scan weaknesses. |
| AC5 — quickstart and `docs/customization.md` contract name the same `template/<file>` source; divergence fails naming the file | **met** | `95-split-guard.sh:209-223` + `contract_sources` (`:130-144`). Contract rows `docs/customization.md:32-34` parse to `template/<file>`; `N3` notes a parse-scope robustness point. |
| AC6 — a `template/` edit resolves deny while the adopter's root files stay allowed; removing/weakening fails naming `bootstrap` | **met** | `95-split-guard.sh:286-368`. Ordered last-match resolution; five deny samples and four allow samples. Traced `.opencode/agent/bootstrap.md:6-16`: all five deny, all four allow. Removal of `template/**` (E14) and reorder of `**/AGENTS.md` (E15) both flip a sample to allow → caught. `M2` notes a narrowing gap. |
| AC7 — `tests/README.md` documents the area without displacing `AC18`–`AC20` | **met** | Diff is additive: Checks row (`tests/README.md:80`) and `AC21` mapping paragraph (`:87-97`); `AC18`–`AC20` text retained (`:79,82-85`). |
| AC8 — one mutation for the new area, caught and named, 0 failed, clean/forced-absent runs pass | **met** | `tests/mutation.sh:277-284`; expected substring matches the exact `bad` text emitted at `95-split-guard.sh:196`; header area list updated (`:15`). |

## Findings

### Blockers

- None.

### Major

- None.

### Minor

- **[M1] AC4 wrong-claim scan is substring-based and can both miss and false-positive** — `tests/checks/95-split-guard.sh:384-420`
  `NEG_RE='never|not|no |…'` matches inside `cannot`, `notable`, `annotation`; `COPY_VERB_RE` matches `get` inside `together`/`target` and `given` inside a verb; and the scan requires a literal `root`/`maintainer` marker in the same clause, so a reintroduced claim phrased without that word is not caught. AC4 asks the suite to fail on a surface that "claims or implies" a root copy, so these are genuine (if bounded) coverage gaps. It does not break the baseline — the four surfaces were re-derived and are clean — and `verify.md:91-96` documents part of the trade-off.
  Recommendation: anchor the alternations on word boundaries (e.g. `(^|[^[:alnum:]_])(never|not|no|outside|excluding|neither)([^[:alnum:]_]|$)`), match `cop(y|ies|ied)`/`receiv(e|es|ed)` explicitly instead of the broad `get`/`give` substrings, and either document that a root marker is required or add a second detection for a filename named with a copy verb and no `template/` source on the line.

- **[M2] The `bootstrap` guard cannot catch narrowing `template/**` to a single level, contrary to design §6** — `tests/checks/95-split-guard.sh:326-339,348-358`
  `resolve_edit` uses POSIX `case`, where `*` spans `/`. So `template/*` matches `template/sub/AGENTS.md`, and the sample intended to catch the narrowing (`design.md:162-164`) passes even after the deny is narrowed. Under a matcher where `*` does not cross `/` — suggested by the project's own `*` vs `**` distinction and the `work/**` + `**/work/**` pairing (`docs/customization.md:178-181`) — a narrowed deny would allow nested `template/` edits while the suite stays green. Practical exposure is low today: the three protected files are direct children and remain denied by `template/*`.
  Recommendation: when the `opencode` CLI is available, confirm the matcher's `*` semantics (`opencode debug agent bootstrap`) and mirror it, or add a sample that distinguishes recursive from single-level matching; at minimum correct the design/comment claim that the sample catches the narrowing.

### Nits

- **[N1] `verify.md` reports "28 ok lines" for the `AC21` block; the check emits 27** — `work/0004-adoption-template-split/0003-split-guard-tests/verify.md:17`
  Counting executed `ok` calls: 3 (quickstart) + 1 (whole-dir) + 3 (contract) + 3 (profile) + 5 (deny) + 4 (allow) + 4 (surface anchor) + 4 (surface scan) = 27. Cosmetic evidence accuracy only.
  Recommendation: correct the count or re-derive it.

- **[N2] `quickstart_pairs` is a deliberately bounded recognizer** — `tests/checks/95-split-guard.sh:52-123`
  It reads only the first ```` ```bash ```` block and recognizes same-line literal/loop `cp` with double-quote handling; `&&`-chained copies, a renamed framework variable, or a multi-line `for` would false-fail. This is documented (`design.md:70-72`, `verify.md:98-101`) and fails closed (a required pair is reported missing), so it is acceptable.
  Recommendation: none required; if future quickstart prose churns, consider a note in `tests/README.md` that the guard recognizes the documented forms only.

- **[N3] `contract_sources` scans every `|` table row whose first cell is one of the three files** — `tests/checks/95-split-guard.sh:130-144`
  It takes the first `` `template/…` `` token in the second cell. Today the always-loaded-instructions row for `AGENTS.md` (`docs/customization.md:59`) has no such token, so it is skipped and the result is correct; a future token there would be misread as the split contract.
  Recommendation: scope the parse to the "Adopter-pristine sources and framework copies" table, or require the row to also carry a `root`/`maintainer` cell.

## Scope, security, and conventions

- **Scope:** exactly the designed surface — `tests/checks/95-split-guard.sh` (new),
  `tests/README.md`, `tests/mutation.sh`. `git status --short` shows no other
  tracked change and no non-`tests/` production surface touched. No scope creep,
  no reformatting, no dependency or CI change.
- **Security/secrets:** the guard is read-only and static; no `work/**` read (only
  the comment at `:31`), no secret handling, no eval of untrusted input (`case`
  patterns come from the repo's own agent frontmatter). Deny-by-default and the
  `template/` guard are asserted, not weakened.
- **Conventions:** one file = one area token (`AC21`, next free per `design.md:8`);
  reuses `lib.sh` `ok`/`bad` and path constants; Bash 3.2-compatible (no
  associative arrays/`mapfile`); mutation helpers reused unchanged; docs updated
  additively.
- **Performance:** negligible — a handful of small static files, no loops over
  large data.

## Not reviewed

- **Execution of `bash tests/run.sh` / `bash tests/mutation.sh`.** Blocked by the
  read-only Bash allowlist; AC1/AC8 rest on the recorded `verify.md` results plus
  a static re-derivation of the baseline checks. A maintainer run on a writable
  shell would close this out.
- **`visual.md`** — not applicable; this item has no user-facing UI.
- **`opencode`'s real permission matcher** — unavailable here; relevant only to
  `M2`.
