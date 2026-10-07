---
feature: 0004-adoption-template-split/0002-bootstrap-quickstart-rework
phase: tasks
status: final
created: 2026-10-06
updated: 2026-10-07
parent: 0004-adoption-template-split
notes: "Ordered by dependency. T1 is the first change and closes the quickstart leak window; T8 is the AC7/AC8 gate. No task adds or edits tests/checks/** (child 0003 owns committed split guards). Each task runs bash tests/run.sh for its touched scope; the final gate runs it plus the opt-in mutation self-check. Note: T6's inline awk verify over-matches the bash map's allow lines; AC3 is instead confirmed by opencode debug agent bootstrap resolving template/** and **/template/** to deny after all edit allows."
---

# Tasks — Bootstrap and quickstart rework

Ordered, dependency-aware. One task ≈ one focused commit. Each Verify step is a
command or an observable check; a task is complete only when it passes.

- [x] **T1** — In `README.md`, replace the single root-source copy line
      (`README.md:49`) in the first ```bash block with three per-file copies:
      `cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md`,
      `cp "$FRAMEWORK/template/opencode.json" ./opencode.json`, and
      `cp "$FRAMEWORK/template/.gitignore" ./.gitignore`. Leave the merge
      advisory (`README.md:83-84`) and the rest of the block unchanged; add no
      migration or deletion step. [AC1] [AC2] [AC9]
      Verify: `grep -q 'cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md' README.md && grep -q 'cp "$FRAMEWORK/template/opencode.json" ./opencode.json' README.md && grep -q 'cp "$FRAMEWORK/template/.gitignore" ./.gitignore' README.md && ! grep -q 'cp "$FRAMEWORK/AGENTS.md"' README.md && grep -q 'merge rather than overwrite' README.md && rm -rf scratch/qscheck && mkdir -p scratch/qscheck/.opencode scratch/qscheck/docs scratch/qscheck/work && (cd scratch/qscheck && FRAMEWORK="$OLDPWD" && cp -r "$FRAMEWORK/.opencode/agent" "$FRAMEWORK/.opencode/command" "$FRAMEWORK/.opencode/skill" .opencode/ && cp "$FRAMEWORK/template/AGENTS.md" ./AGENTS.md && cp "$FRAMEWORK/template/opencode.json" ./opencode.json && cp "$FRAMEWORK/template/.gitignore" ./.gitignore && cp "$FRAMEWORK"/docs/*.md docs/) && grep -q '_e\.g\. pnpm' scratch/qscheck/AGENTS.md && diff -q scratch/qscheck/opencode.json template/opencode.json && diff -q scratch/qscheck/.gitignore template/.gitignore && [ ! -e scratch/qscheck/template ] && bash tests/run.sh` → exit 0.
- [x] **T2** — In `README.md`, reconcile the Quickstart copy-set prose
      (`README.md:54-91`): state that `AGENTS.md`, `opencode.json`, and
      `.gitignore` are copied from their `template/` adopter-pristine sources,
      that the framework repository's own root copies are maintainer-bootstrapped
      and never copied, and that `.opencode/{agent,command,skill}` and `docs/*.md`
      are shared verbatim. Add no claim that an adopter receives a root copy and
      no packaging-file claim. [AC5] [AC6] [depends: T1]
      Verify: `grep -q 'template/AGENTS.md' README.md && grep -q 'template/opencode.json' README.md && grep -q 'template/.gitignore' README.md && grep -qi 'shared verbatim' README.md && bash tests/run.sh` → exit 0, with the `AC19`/`AC20` lines labelled `ok`.
- [x] **T3** — In `docs/customization.md`, rewrite the stale sentence at
      `docs/customization.md:64-67` so it no longer claims the always-loaded set
      is "exactly the files the adoption quickstart copies": state that the first
      is copied from `template/AGENTS.md` and the other two arrive via the
      `docs/*.md` copy, so every listed path exists in a freshly adopted
      repository. Keep the existing split-contract section
      (`docs/customization.md:21-40`) and its shared-verbatim statement; keep the
      wording framework-repository organisation, not adopter instruction.
      [AC5] [AC6]
      Verify: `grep -q 'template/AGENTS.md' docs/customization.md && grep -q 'template/opencode.json' docs/customization.md && grep -q 'template/.gitignore' docs/customization.md && grep -qi 'shared verbatim' docs/customization.md && ! grep -q 'exactly the files the adoption quickstart copies' docs/customization.md && bash tests/run.sh` → exit 0.
- [x] **T4** — In `tests/README.md`, update the copy-set enumeration
      (`tests/README.md:5-11`) to name the `template/` adopter-pristine sources
      for `AGENTS.md`, `opencode.json`, and `.gitignore`, distinguish the
      framework-repo/maintainer-only files, and state that
      `.opencode/{agent,command,skill}` and `docs/*.md` are shared verbatim. The
      parenthetical that contains `.opencode/` must still end with the exact
      literal `` `docs/*.md`) `` so the mutation self-check's AC19 mutation
      (`tests/mutation.sh:263`) still applies; keep packaging filenames off any
      line that also contains "copy set". [AC5] [AC6]
      Verify: `grep -q 'template/AGENTS.md' tests/README.md && grep -q 'template/opencode.json' tests/README.md && grep -q 'template/.gitignore' tests/README.md && grep -qi 'shared verbatim' tests/README.md && grep -qF '`docs/*.md`)' tests/README.md && bash tests/run.sh && bash tests/mutation.sh` → both exit 0; mutation output shows `mutation AC19 caught and named`.
- [x] **T5** — In `CONTRIBUTING.md`, update the maintainer-only paragraph
      (`CONTRIBUTING.md:121-133`) to name the `template/` adopter-pristine
      sources for `AGENTS.md`, `opencode.json`, and `.gitignore`, distinguish the
      framework repository's own copies, and state that
      `.opencode/{agent,command,skill}` and `docs/*.md` are shared verbatim. Add
      no claim that an adopter receives a root copy. [AC5] [AC6]
      Verify: `grep -q 'template/AGENTS.md' CONTRIBUTING.md && grep -q 'template/opencode.json' CONTRIBUTING.md && grep -q 'template/.gitignore' CONTRIBUTING.md && grep -qi 'shared verbatim' CONTRIBUTING.md && bash tests/run.sh` → exit 0.
- [x] **T6** — In `.opencode/agent/bootstrap.md`, add the hard guard to
      `permission.edit` by appending `"template/**": deny` and
      `"**/template/**": deny` **after every `allow` rule** in the map, and
      rework the body so the `<mission>`, `<operating_principles>`, `<process>`
      (confirm-context and apply steps), `<rules>`, and `<quality_bar>` state
      that `/bootstrap` fills the adopter's own root `AGENTS.md`,
      `opencode.json`, and `.gitignore` — the copies an adopter received from the
      framework's adopter-pristine sources — and must never modify the framework
      repository's sources under `template/`. [AC3] [AC4]
      Verify: `grep -q 'template/' .opencode/agent/bootstrap.md && grep -qi 'never modify' .opencode/agent/bootstrap.md && awk '/^    "template\/\*\*": deny/ {t=NR} /^    "\*\*\/template\/\*\*": deny/ {a=NR} /^    ".*": allow/ {l=NR} END { exit !(t>l && a>l) }' .opencode/agent/bootstrap.md && bash tests/run.sh` → exit 0; when the `opencode` CLI is available, `opencode debug agent bootstrap` shows `template/**` resolved to deny and root `AGENTS.md` to allow. Verify failing; human checked.
- [x] **T7** — In `.opencode/command/bootstrap.md`, update the body so the command
      instruction states that `/bootstrap` fills the adopter's own root
      `AGENTS.md`, `opencode.json`, and `.gitignore` (the copies received from the
      framework's adopter-pristine sources) and must never modify the framework
      repository's sources under `template/`. [AC4] [depends: T6]
      Verify: `grep -qi 'adopter' .opencode/command/bootstrap.md && grep -q 'template/' .opencode/command/bootstrap.md && grep -qi 'never' .opencode/command/bootstrap.md && bash tests/run.sh` → exit 0.
- [x] **T8** — Run the full committed suite and the opt-in mutation self-check on
      the completed change; fix any regression in `tests/checks/90-packaging.sh`,
      `40-inventory.sh`, `50-instructions.sh`, or `30-permissions.sh` without
      editing `tests/checks/**`. [AC7] [AC8] [depends: T1, T2, T3, T4, T5, T6, T7]
      Verify: `bash tests/run.sh` → exit 0 (`TOTAL: … 0 failed`); `bash tests/mutation.sh` → exit 0 (`MUTATION TOTAL: … 0 failed`).
