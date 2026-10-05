---
feature: 0003-framework-quality-hardening/0002-readiness-ship-state
phase: tasks
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Tasks — Readiness semantics and shipped-state detection

Ordered, dependency-aware. One task ≈ one focused commit. `docs/workflow.md` is
the single authority; every other surface references it.

- [x] **T1** — Make `docs/workflow.md` the sole authoritative readiness definition and key shipped state on `ship.md` presence. [AC1, AC2, AC3, AC4, AC8]
      In the `satisfied()` block (`docs/workflow.md:87-107`) delete the
      `if a PR is detected for the child` line and change the `ship.md` branch
      comment to `# shipped; presence is the sole shipped signal`. Rewrite the
      prose at `:103-106` so that: a `review.md` verdict of `approve` satisfies a
      dependency **even if unshipped**; `ship.md` presence is the sole shipped
      signal, takes precedence over a `request-changes` verdict, and is keyed on
      presence not contents; a `request-changes` verdict and missing `review.md`
      are not satisfied. In the derived-state table (`:233-245`) add
      `| \`ship.md\` present | shipped |` **above** the `request-changes` row,
      change the approve row to
      `` | `review.md` verdict `approve`, no `ship.md` | ship | ``, and remove
      every "PR" reference. Update the Ship phase Artifact line (`:225`) to
      include `ship.md` as the recorded signal.
      Verify: `rg -n "PR is detected|PR detected|or a PR detected" docs/workflow.md` prints nothing; `rg -c "satisfied\(dep_local_id\):" docs/workflow.md` prints `1`; `rg -n "even if unshipped|presence is the sole shipped signal|no .ship.md.|^\| .ship.md. present" docs/workflow.md` shows the new text and the `ship.md` row line number is lower than the `request-changes` row.

- [x] **T2** — Make the status agent defer to the authority, remove the contradiction, and drop the detected-PR step. [AC1, AC2, AC3, AC6]
      In `.opencode/agent/status.md` replace the `<readiness_algorithm>` block
      (`:100-124`) with a short `<readiness>` note that names
      `docs/workflow.md` → "Dependencies and readiness" as the authority, forbids
      restating the branch sequence, and states that shipped state is the
      presence of `ship.md`. Delete the contradictory bullet at `:119-122`.
      Remove the "Optionally, the current git branch per item, to infer shipped
      state" input at `:63-64`, and change `:75` "for `ship.md` or a detected PR"
      to "for `ship.md`". Keep the operating principle at `:43` ("Readiness is
      derived live, never stored") and the rule at `:183` ("Never write or
      refresh a readiness value") verbatim. Leave the bash allowlist unchanged
      (still no `gh`).
      Verify: `rg -n "satisfied\(dep_local_id\)|PR detected|detected PR|PR is detected" .opencode/agent/status.md` prints nothing; `rg -n "Dependencies and readiness" .opencode/agent/status.md` hits; `rg -n "derived live, never stored|Never write or refresh a readiness value" .opencode/agent/status.md` hits both; `rg -n '"gh ' .opencode/agent/status.md` prints nothing.

- [x] **T3** — Make the `/status` command defer to the authority. [AC1, AC2, AC3, AC6]
      In `.opencode/command/status.md` change `:11` to name only `ship.md` (drop
      "or detected PR"). Replace the restated algorithm at `:17-22` with a
      reference to `docs/workflow.md` → "Dependencies and readiness" plus the
      settled one-line semantics (approve satisfies even when unshipped;
      `ship.md` presence satisfies), and state that the branch sequence is not to
      be restated here.
      Verify: `rg -n "PR detected|detected PR|or detected" .opencode/command/status.md` prints nothing; `rg -n "Dependencies and readiness" .opencode/command/status.md` hits; `rg -c "satisfied\(dep_local_id\):" .opencode/command/status.md` prints `0`.

- [x] **T4** — Grant the shipper write access to `work/`, make recording `ship.md` required, and reconcile the permission docs. [AC4, AC5, AC7]
      In `.opencode/agent/shipper.md` change the frontmatter from `edit: deny` to
      the artifact-writer object with `"*": deny`, `"work/**": allow`, and
      `"**/work/**": allow`; leave the `bash` block unchanged. Rewrite process
      step 6 (`:89-90`) so writing `work/<item-ref>/ship.md` is required, not
      optional, recording the branch, commit subjects, and PR URL (or "not
      created"), and note it must be written even when `gh` is unavailable
      because its presence is the shipped signal. In `.opencode/command/ship.md`
      change the final bullet (`:24-25`) from "Optionally write" to a required
      write. In `README.md` change the `shipper` Agents-table row (`:173`) from
      "none" to `` `work/**` + `**/work/**` ``. In `docs/artifact-conventions.md`
      (`:397`) retitle the `ship.md` section as the shipped-state record and add
      one clause that its presence is the shipped signal defined in
      `docs/workflow.md` → "Dependencies and readiness".
      Verify: `rg -n '"work/\*\*": allow|"\*\*/work/\*\*": allow' .opencode/agent/shipper.md` shows both patterns; `rg -n 'shipper.*work/\*\*' README.md` hits; `rg -n "ship\.md" .opencode/command/ship.md .opencode/agent/shipper.md` shows the required write.

- [x] **T5** — Update the existing verification suite and add the readiness-agreement assertion. [AC1, AC2, AC3, AC4, AC5, AC8, AC9, AC10] [depends: T1, T2, T3, T4]
      In `work/0002-agentic-roadmaps/verify-tests.sh`:
      (a) At `:76-84`, assert the algorithm tokens against `$WF` only (drop the
      `$AGENT_DIR/status.md` algorithm-token loop) and replace the old
      `'Only a \`review.md\` verdict of \`approve\`'` line with
      `need "$AGENT_DIR/status.md" 'Dependencies and readiness'` and
      `need "$CMD_DIR/status.md" 'Dependencies and readiness'`.
      (b) At `:133`, replace the row tokens
      `` '`review.md` verdict `approve`, no branch/PR recorded' `` and
      `` '`ship.md` present with PR URL' `` with
      `` '`review.md` verdict `approve`, no `ship.md`' `` and
      `` '`ship.md` present' ``.
      (c) Replace the detected-PR block at `:219-222` with assertions that
      `$WF` contains `child_dir/ship.md exists` and
      `presence is the sole shipped signal`, and that the derived-state
      `ship.md present` row maps to `shipped`.
      (d) Replace the blanket "no agent permission block changed vs HEAD"
      assertion at `:233-240` with content assertions: `shipper.md` frontmatter
      grants both `work/**` patterns, and the read-only agents `status`, `doctor`,
      `ask`, and `scout` still do not grant `work/**`.
      (e) Add a new `== AC9: one authoritative readiness definition ==` block that
      (i) collects the candidate files
      `"$WF" "$AGENT_DIR/status.md" "$CMD_DIR/status.md" "$AGENT_DIR/product.md" "$CONV"`,
      counts those containing `satisfied(dep_local_id):`, and requires the value
      to be exactly `workflow.md`; (ii) requires each of status agent, `/status`
      command, and product agent to contain `Dependencies and readiness`;
      (iii) requires `$WF` to contain `even if unshipped`; (iv) fails if
      `grep -rniE 'PR is detected|PR detected|detected PR'` matches any of the
      candidate files or `README.md`; and (v) fails if
      `grep -rniE 'approved-but-unshipped.*not satisfied|not satisfied.*approved-but-unshipped'`
      matches any of `$WF`, `$AGENT_DIR`, or `$CMD_DIR`. Never scan `work/`
      historical artifacts.
      Verify: `bash work/0002-agentic-roadmaps/verify-tests.sh` exits `0` and
      prints `TOTAL: <n> passed, 0 failed`; the `== AC9 ==` block shows only `ok`
      lines.

- [x] **T6** — Confirm behavior and permission-drift consistency end to end. [AC6, AC7] [depends: T4, T5]
      Run `/doctor` and confirm it prints `No findings — repository is consistent.`
      (or, at minimum, no `PERMISSION-TABLE-MISMATCH` and no
      `PERMISSION-WORK-PATTERN` finding for `shipper`). Run
      `/status 0003-framework-quality-hardening` and confirm
      `0001-state-model` is reported ready via its `approve` verdict even though
      it is unshipped, and that the run completes with no `gh`/network command.
      If the CLI is available, run `opencode debug agent shipper` and confirm the
      resolved `edit` permission lists both `work/**` forms.
      Verify: observable `/doctor` output (no shipper permission finding) and
      `/status` output (parent reports `0001-state-model` ready).
