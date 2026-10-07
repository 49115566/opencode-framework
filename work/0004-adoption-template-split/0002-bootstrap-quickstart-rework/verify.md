---
feature: 0004-adoption-template-split/0002-bootstrap-quickstart-rework
phase: test
status: final
created: 2026-10-07
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "AC1-AC6 and AC9 are verified by reproducible ad-hoc checks, not new committed tests: the spec's non-goals reserve committed split-guard tests for child 0003 and forbid changing tests/checks/**. AC7/AC8 are covered by the committed suite and the opt-in mutation self-check."
---

# Verification — Bootstrap and quickstart rework

## Commands run

| Command | Result | Notes |
| ------- | ------ | ----- |
| `bash tests/run.sh` | PASS | `TOTAL: 182 passed, 0 failed, 0 skipped`; exit 0. Baseline and post-change identical. |
| `bash tests/mutation.sh` | PASS | `MUTATION TOTAL: 25 checked passed, 0 failed`; includes `mutation AC19 caught and named`; exit 0. |
| `opencode debug agent bootstrap` (edit rules inspected via inline `python3 -c`) | PASS | Resolved `edit` rules list the two `template` denies **after every allow** (see AC3). |
| Ad-hoc split/quickstart verification script (`/tmp/opencode/verify-0002.sh`) | PASS | `AD-HOC VERIFY TOTAL: 54 passed, 0 failed`; exit 0. Reproduced below; not committed (see Gaps). |

### Ad-hoc check commands (AC1–AC6, AC9)

Run from the repository root. `flat <file>` prints `tr '\n' ' ' < <file>`; it
normalizes line-wrapped prose and markdown emphasis before matching.

```bash
# AC1 — quickstart sources template/, never root
grep -qF 'cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md' README.md
grep -qF 'cp "$FRAMEWORK/template/opencode.json" ./opencode.json' README.md
grep -qF 'cp "$FRAMEWORK/template/.gitignore" ./.gitignore' README.md
! grep -qE 'cp .*"\$FRAMEWORK/(AGENTS\.md|opencode\.json|\.gitignore)"' README.md

# AC2 — run the documented quickstart in an empty project
QS=/tmp/opencode/qscheck-ac2; rm -rf "$QS"; mkdir -p "$QS"
( cd "$QS" && FRAMEWORK="$(git -C /home/craig-truitt/Code/opencode-framework rev-parse --show-toplevel)" && \
  mkdir -p .opencode && \
  cp -r "$FRAMEWORK/.opencode/agent" "$FRAMEWORK/.opencode/command" "$FRAMEWORK/.opencode/skill" .opencode/ && \
  rm -f .opencode/agent/doctor.md .opencode/command/doctor.md && \
  cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md && \
  cp "$FRAMEWORK/template/opencode.json" ./opencode.json && \
  cp "$FRAMEWORK/template/.gitignore" ./.gitignore && \
  mkdir -p docs && cp "$FRAMEWORK"/docs/*.md docs/ && \
  mkdir -p work && touch work/.gitkeep )
grep -q '_e\.g\.' "$QS/AGENTS.md"                 # placeholder profile present
! diff -q AGENTS.md "$QS/AGENTS.md"               # differs from maintainer copy
diff -q template/opencode.json "$QS/opencode.json"
diff -q template/.gitignore "$QS/.gitignore"
[ ! -e "$QS/template" ]                           # no template/ directory

# AC3 — resolved bootstrap edit permission ordering
opencode debug agent bootstrap | python3 - <<'PY'
import json,sys
d=json.load(sys.stdin)
pats=[(e["action"],e["pattern"]) for e in d["permission"] if e.get("permission")=="edit"]
assert pats[-2]==("deny","template/**") and pats[-1]==("deny","**/template/**")
assert not any(a=="allow" for a,_ in pats[-2:])
PY

# AC4 — bootstrap agent + command ownership and never-modify
flat .opencode/agent/bootstrap.md | grep -qi 'this repository.s own root copies'
flat .opencode/agent/bootstrap.md | grep -qi "adopter received from the framework.s adopter-pristine sources"
flat .opencode/agent/bootstrap.md | grep -qiE "never (modify|edit) the framework repository.s"
grep -qi "adopter.s own copies" .opencode/command/bootstrap.md
flat .opencode/command/bootstrap.md | grep -qi "never modify the framework repository.s"

# AC5/AC6 — each copy-set surface names template/ sources, framework copies, shared verbatim
for f in README.md docs/customization.md tests/README.md CONTRIBUTING.md; do
  grep -qF 'template/AGENTS.md' "$f"
  grep -qF 'template/opencode.json' "$f"
  grep -qF 'template/.gitignore' "$f"
  grep -qi 'shared verbatim' "$f"
  grep -qF '.opencode/{agent,command,skill}' "$f"
  grep -qF 'docs/*.md' "$f"
  grep -qiE 'framework repository.s own|maintainer-bootstrapped' "$f"
done
flat README.md | tr -d '*' | grep -qi 'maintainer-bootstrapped and are never copied'
flat tests/README.md | grep -qi 'maintainer-bootstrapped and are never copied'
flat CONTRIBUTING.md | grep -qi 'maintainer-bootstrapped and are never copied'
flat docs/customization.md | grep -qi 'must never be copied into an adopted repository'
! grep -rqE 'cp .*\$FRAMEWORK/(AGENTS\.md|opencode\.json|\.gitignore)' \
    README.md docs/customization.md tests/README.md CONTRIBUTING.md

# AC9 — merge advisory retained; no migration/deletion step added
grep -qF 'merge rather than overwrite' README.md
diff <(git show HEAD:README.md | sed -n '/^## Quickstart/,/^## The lifecycle/p' | grep -E 'rm |mv |migrat') \
     <(sed -n '/^## Quickstart/,/^## The lifecycle/p' README.md | grep -E 'rm |mv |migrat')
```

All 54 checks passed.

## Acceptance coverage

| Criterion | Test(s) | Result |
| --------- | ------- | ------ |
| AC1 — quickstart copies each of the three from `template/`, none from root | ad-hoc: AC1 grep block (`README.md:49-51`); `tests/checks/90-packaging.sh` AC19 (no copy command names a packaging file) | PASS |
| AC2 — documented quickstart in an empty project yields placeholder `AGENTS.md`, pristine `opencode.json`/`.gitignore`, no `template/` | ad-hoc: AC2 quickstart run in `/tmp/opencode/qscheck-ac2`; 7 assertions | PASS |
| AC3 — resolved bootstrap edit permissions deny `template/`, allow adopter root files | `opencode debug agent bootstrap` ordered list (denies last); `docs/customization.md:161-172` last-match-wins | PASS |
| AC4 — bootstrap agent and command state adopter-copy ownership and never-modify | ad-hoc: AC4 checks over `.opencode/agent/bootstrap.md` (`:38,56-57,79,96,113,129,142`) and `.opencode/command/bootstrap.md` (`:11-17`) | PASS |
| AC5 — all four copy-set surfaces name `template/` sources, framework copies, shared-verbatim | ad-hoc: AC5 loop over `README.md:60-70`, `docs/customization.md:21-40,64-69`, `tests/README.md:5-15`, `CONTRIBUTING.md:122-136` | PASS |
| AC6 — no copy-set surface claims an adopter receives a root copy | ad-hoc: AC6 block; broad scan found no root-source `cp` or root-copy claim | PASS |
| AC7 — `bash tests/run.sh` exits 0 | `bash tests/run.sh` | PASS (182/0/0) |
| AC8 — `bash tests/mutation.sh` reports zero failed mutations | `bash tests/mutation.sh` | PASS (25/0); AC19 mutation caught |
| AC9 — merge advisory retained; no migration/deletion step added | ad-hoc: AC9 checks; `README.md:97-98`; quickstart `rm`/`mv` set byte-identical to `HEAD` | PASS |

### Edge cases

| Edge case | Evidence | Result |
| --------- | -------- | ------ |
| Placeholder fidelity — adopter gets placeholder profile, not maintainer's | `template/AGENTS.md:11-24` all `_..._` placeholders; run copy `grep '_e\.g\.'` PASS and `diff` vs root differs | PASS |
| Byte-identical pristine pair still sourced from `template/` | `README.md:50-51` names `template/opencode.json` and `template/.gitignore`; both currently byte-identical to root | PASS |
| Already-adopted repositories — re-run adds no `template/`, merges | AC9 `rm`/`mv` set unchanged vs `HEAD`; `README.md:97-98` merge advisory; no `template/` created (AC2) | PASS |
| Framework-repo self-run — guard blocks `template/`, bootstrapped-repo behavior preserved | AC3 denies; `.opencode/agent/bootstrap.md:80-82` retains "looks bootstrapped … ask" | PASS |
| Context mismatch — wording truthful where no `template/` exists | `.opencode/agent/bootstrap.md:56-58,113,142` and command name `template/` only as the framework repository's location | PASS |
| Verbatim-copied docs — `docs/customization.md` reads as framework organisation | `docs/customization.md:26,39,71` frame `template/` as the framework repository's, not adopter instruction | PASS |
| Copy globs — `docs/*.md` cannot reach `template/`, no step captures both copies | `README.md:52` globs only `docs/*.md`; `$QS/docs/template` absent; no root-source `cp` | PASS |
| Missing/renamed pristine source fails loudly | `cp` of absent `template/DOES-NOT-EXIST` exits non-zero; no maintainer fallback | PASS |
| Guard over-reach — adopter root files remain editable | AC3 resolved list keeps `AGENTS.md`, `**/AGENTS.md`, `opencode.json`, `**/opencode.json`, `.gitignore`, `**/.gitignore` as allows before the denies | PASS |

## Gaps and residual risk

- **No new committed test was added.** The spec's non-goals ("Adding committed
  split-guard tests — child `0003`") and its dependencies ("`tests/checks/**` is
  owned by child `0003` and must not be changed here") forbid committing
  split-guard tests in this item. AC1–AC6/AC9 are therefore verified by the
  reproducible ad-hoc checks above, recorded here rather than committed. Child
  `0003-split-guard-tests` is the correct owner to promote these into the
  committed suite.
- **AC3 trusts opencode's documented last-match-wins evaluation.** The tool
  inspection shows the two `template` denies strictly after every allow, and
  `docs/customization.md:161-172` documents last-match-wins, but no live edit was
  attempted (it would need a model turn and could mutate a sandbox). If opencode
  ever changed permission evaluation to first-match-wins, `template/**` would
  fall through to the earlier `**/AGENTS.md`/`**/opencode.json`/`**/.gitignore`
  allows. Mitigated by the trailing order and by child `0003`'s committed guard.
- **`docs/customization.md` is copied verbatim to adopters** (`README.md:52`) and
  now mentions the framework repository's `template/` path, which adopters do not
  have. Wording was reviewed to read as framework organisation rather than an
  adopter instruction (edge-case row above); this is a wording risk, not a
  behavior defect.
- **`bash` access is unrestricted for the bootstrap agent**, so the `edit` guard
  is not a sandbox (`docs/customization.md:200-208`). A maintainer could still
  alter `template/` via shell redirection. This is documented, pre-existing
  framework behavior and out of scope here.
- **Mutation self-check is opt-in** and not part of `bash tests/run.sh`; AC8 was
  verified by running it explicitly.
