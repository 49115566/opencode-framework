---
feature: 0003-framework-quality-hardening/0003-readonly-permissions
phase: design
status: final
created: 2026-10-05
updated: 2026-10-05
parent: 0003-framework-quality-hardening
---

# Design — Read-only agent permissions and enforcement claims

## Summary

Harden the six read-only agents (`product`, `architect`, `roadmap`, `status`,
`reviewer`, `doctor`) by removing the two bash tokens that can write or execute
arbitrary commands (`find*`, `rg*`), add one identical read-only guard bullet to
each prompt, and rewrite the README and customization guide so the file-tool
guarantee is stated separately from the best-effort bash restriction. Broaden
`tester`'s file-tool allowlist to five common test layouts in both path forms.
No runtime code, lifecycle phase, artifact format, routing rule, or global
permission default changes.

## Approach

The change has five parts, all in prompt/config/documentation files. All five
are independent except that the permission edit and the prompt guard for the
same six agents land together.

### 1. Remove the write/execute tokens from the six read-only agents (AC1, AC2)

Each of the six agents' bash allowlists keeps its leading catch-all `"*": deny`
and drops the `"rg*"` and `"find*"` lines. The exact before → after for the
shared tail is:

```yaml
# before (product / architect / roadmap / doctor)
    "ls*": allow
    "cat*": allow
    "rg*": allow      # removed: `rg --pre <cmd>` executes an arbitrary program
    "find*": allow    # removed: `find -delete` / `find -exec` write or execute
    "tree*": allow

# after
    "ls*": allow
    "cat*": allow
    "tree*": allow
```

`status` and `reviewer` have the same tail without `tree*`; they drop the same
two lines. Every remaining entry is a command whose canonical use only reads
repository state (`ls`, `cat`, `tree`, and read-only git subcommands). `cat`'s
redirection hazard and `tree -o` remain, but they are covered by the prompt
guard (part 2) and the documentation (parts 3–4), because opencode's prefix
rules cannot express an argument-level block — see "Residual risk" below.

### 2. Add a canonical read-only guard to each of the six prompts (AC3, AC4)

Append one bullet, with identical wording, to the end of the `<rules>` section of
each of the six agents. `<rules>` exists in all six (`product.md:99`,
`architect.md:93`, `roadmap.md:124`, `status.md:159`, `reviewer.md:92`,
`doctor.md:177`). The canonical text:

```markdown
- **Read-only guard.** Your bash allowlist is a best-effort guard, not a
  sandbox: opencode matches bash rules by command prefix and cannot stop shell
  redirection or output-to-file flags. Never use bash to create, write, move, or
  delete a file, and never use it to execute an arbitrary program. Use the Read,
  Grep, and Glob tools for inspection instead of shell commands.
```

Recon confirmed that **no** prompt body among the six currently instructs the
agent to run `rg` or `find` through bash (the only literal occurrences are the
permission lines being removed), so this bullet is additive: it satisfies the
"directs it to the file-search tools" half of AC3 and supplies AC4's explicit
prohibition.

### 3. Correct the README's enforcement claims (AC5, AC6, AC7)

1. **Guardrail prose (`README.md:23-24`).** Replace "Reviewers and product agents
   cannot touch source." with "Reviewers and product agents cannot create,
   modify, or delete source through the file tools; their bash access is an
   inspection allowlist, not a sandbox (see Permissions)."
2. **Agents table (`README.md:166-179`).** Change the six `read-only allowlist`
   cells to `read-only, best-effort †`, leaving `builder`/`tester`/`visual`/
   `bootstrap` as `allow`, `scout` as `allow`, `shipper` as `git/gh allowlist`,
   `scribe`/`ask` as `none`. Directly under the table add a footnote:

   > † The "Can run bash" column is a best-effort allowlist, not a sandbox.
   > opencode matches bash rules by command prefix and cannot prevent shell
   > redirection or output-to-file flags. See
   > [`docs/customization.md`](docs/customization.md) for the full permission
   > model.

3. **Enforcement paragraph (`README.md:181-188`).** Keep the enforced-`edit`
   facts, then add that bash rules match a command prefix and are best-effort,
   cannot prevent redirection or output flags, and that broad-bash agents can
   still modify files through the shell.

### 4. Expand the customization caveat (AC8)

Replace the existing caveat (`docs/customization.md:133-136`) with a paragraph
that (a) keeps "these blocks are not a sandbox for bash", (b) explains the
prefix-match limitation and names shell redirection and output-to-file flags,
(c) lists every broad-bash agent — `bootstrap`, `scout`, `tester`, `visual` — as
able to modify files through the shell, (d) names `scout`'s broad access as a
deliberate, accepted residual because it is the reconnaissance subagent, and
(e) points readers needing a hard boundary at a sandboxed filesystem. It must
not list `ask`, which is already `none`/`none`.

### 5. Broaden the tester's file-tool allowlist (AC9)

Insert after the existing `"**/__tests__/**": allow` line
(`.opencode/agent/tester.md:14`):

```yaml
    "e2e/**": allow
    "**/e2e/**": allow
    "spec/**": allow
    "**/spec/**": allow
    "integration/**": allow
    "**/integration/**": allow
    "cypress/**": allow
    "**/cypress/**": allow
    "playwright/**": allow
    "**/playwright/**": allow
```

Both the relative and repository-absolute forms are required for the same reason
the work grants list both (`docs/customization.md:111-122`). The tester's bash
stays `allow`; this is an intent/consistency improvement, not a new boundary, and
the docs must not call the tester sandboxed.

### Residual risk (accepted, not designed around)

opencode evaluates bash permissions by command prefix, so shell redirection
(`ls > f`), `tree -o f`, and `git diff --output=f` remain possible for any agent
whose token is allowed. The spec explicitly scopes this out (non-goal 1); the
design addresses it with the guard bullet (part 2) plus honest documentation
(parts 3–4) rather than an unattainable rule. `ask` is untouched (already denies
`edit` and `bash`); `scout`'s broad bash is deliberately kept and documented.

## Alternatives considered

- **Documentation-only correction (no permission change).** Pros: smallest diff,
  zero risk of breaking an agent workflow. Cons: leaves `find -delete`/`-exec`
  and `rg --pre` in place, so the framework still ships write/execute-capable
  "read-only" agents and the prior review's m1 remains unfixed. Rejected because
  it fails the primary goal.
- **Maximal allowlist reduction (keep only read-only git + `ls`).** Pros: closest
  possible to a true inspection allowlist. Cons: forces every prompt that
  mentions `cat`/`tree` searching to be rewritten, gains little because shell
  redirection is unpreventable regardless, and degrades doctor/reviewer recon
  for no enforceable boundary. Rejected as gratuitous.
- **Generate the shared allowlist from one source.** Pros: no drift across the
  six blocks. Cons: there is no build step or runtime in this prompt-only
  framework, so it would introduce a generator, a generation step, and a
  "regenerate" failure mode that the repo cannot run in CI today; sibling
  `0006` owns committed tests/CI. Rejected as new scope and a new dependency.
- **Keep this item's bash-search tokens but only soften the README.** Rejected:
  the spec's user decision was "harden + correct wording"; softening alone leaves
  the over-claim's root cause.

Chosen: remove `find`/`rg`, add the guard, correct the claims, broaden the
tester allowlist.

## Interfaces and data model

There is no data model; the interfaces are the agent frontmatter permission maps
and the documentation surfaces.

**Agent frontmatter — `permission.bash` (six files).** Remove exactly two keys
each; order and catch-all unchanged.

| File | Removed keys | Remaining allowed keys |
| ---- | ------------ | ---------------------- |
| `.opencode/agent/product.md` | `"rg*"`, `"find*"` | git log/diff/show, ls, cat, tree |
| `.opencode/agent/architect.md` | `"rg*"`, `"find*"` | git log/diff/show, ls, cat, tree |
| `.opencode/agent/roadmap.md` | `"rg*"`, `"find*"` | git log/diff/show, ls, cat, tree |
| `.opencode/agent/doctor.md` | `"rg*"`, `"find*"` | git rev-parse/status/diff/check-ignore, ls, cat, tree |
| `.opencode/agent/status.md` | `"rg*"`, `"find*"` | git status/log/show/diff/branch, ls, cat |
| `.opencode/agent/reviewer.md` | `"rg*"`, `"find*"` | git diff/log/show/status/merge-base/rev-parse/blame, ls, cat |

**Agent prompt body (six files).** One new `<rules>` bullet, canonical text above.

**Agent frontmatter — `permission.edit` (one file).**
`.opencode/agent/tester.md` gains the ten path patterns listed in part 5, both
forms for each of `e2e/`, `spec/`, `integration/`, `cypress/`, `playwright/`.

**Documentation surfaces.**
- `README.md`: guardrail bullet (`:23-24`), six table cells (`:166,167,168,172,175,179`),
  a new footnote after `:179`, and the enforcement paragraph (`:181-188`).
- `docs/customization.md`: the caveat paragraph (`:133-136`).

**Backward compatibility.** No runtime, schema, or public API changes.
`opencode.json`, `docs/workflow.md`, `docs/artifact-conventions.md`, all
lifecycle tables, and all other agents/commands/skills are untouched. The one
behavioral change — read-only agents can no longer call `rg`/`find` through bash
— is intended, and the Grep/Glob/Read tools they already have cover inspection.
`/doctor`'s `PERMISSION-TABLE-MISMATCH` check compares the *capability*
(read-only bash vs broad/bash vs none) rather than literal cell text, so
relabeling the cells to `read-only, best-effort †` keeps it semantically valid;
no `doctor.md` change is required.

## Affected areas

- `.opencode/agent/product.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/architect.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/roadmap.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/status.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/reviewer.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/doctor.md` — bash allowlist, `<rules>` guard.
- `.opencode/agent/tester.md` — `permission.edit` additions only.
- `README.md` — guardrail bullet, Agents table cells + footnote, Permissions paragraph.
- `docs/customization.md` — permission caveat paragraph.

Explicitly unchanged: `opencode.json`, `docs/workflow.md`,
`docs/artifact-conventions.md`, `AGENTS.md`, `.opencode/command/**`,
`.opencode/skill/**`, all other agents (`builder`, `shipper`, `scribe`, `scout`,
`visual`, `bootstrap`, `ask`).

## Risks and mitigations

- **An agent workflow relied on bash `rg`/`find`.** Likelihood: low / Impact:
  low. Recon found no prompt among the six instructing bash search; the guard
  bullet directs to Grep/Glob/Read, which every agent already has. Mitigation:
  T6 runs `/doctor` and the existing static suites.
- **The README table and the on-disk blocks drift, tripping `/doctor`.** Likelihood:
  medium / Impact: medium. Mitigation: edit table and blocks in the same item and
  keep the read-only classification explicit; T6 requires
  `No findings — repository is consistent.`
- **The guard bullet's wording diverges across the six files.** Likelihood:
  medium / Impact: low. Mitigation: one canonical paragraph, copied verbatim;
  T2 verifies all six carry the same phrase.
- **A reader still reads "read-only" as a hard boundary.** Likelihood: low /
  Impact: medium. Mitigation: README and customization both say best-effort /
  not a sandbox, and AC4's guard forbids writes even where redirection is
  possible.
- **The tester's new globs match an unintended directory.** Likelihood: low /
  Impact: low. Mitigation: the added directories are conventional test roots;
  the pattern is exact-name (`e2e/**`, `spec/**`, `integration/**`, `cypress/**`,
  `playwright/**`) with no wildcards in the directory component.

## Test strategy

Prompt/config-only work: verification is static shell assertions over the files
plus a real `/doctor` run, matching the repository's existing pattern
(`work/0002-agentic-roadmaps/verify-tests.sh`,
`work/0003-.../0002-readiness-ship-state/verify-tests.sh`).

| Criterion | Verification | Level |
| --------- | ------------ | ----- |
| AC1 | `rg '"find\*"\|"rg\*"'` over the six agents returns nothing; each still shows the leading `"*": deny` | static shell |
| AC2 | Manual read of the six remaining allowlists; every entry is an inspection/git-read command | static shell + manual |
| AC3 | `rg -n 'bash.*(rg\|find)\|(rg\|find).*bash'` over the six bodies shows no bash-search instruction; the guard bullet names Grep/Glob/Read | static shell |
| AC4 | `rg -c 'Read-only guard'` and `rg 'not a sandbox'` match in all six | static shell |
| AC5 | `rg -n 'cannot touch source' README.md` returns nothing; the replaced sentence mentions file tools | static shell |
| AC6 | `rg -n 'read-only allowlist' README.md` returns nothing; `read-only, best-effort` and the customization link appear | static shell |
| AC7 | The Permissions paragraph contains `best-effort`, `command prefix`/`prefix`, and `redirection` | static shell |
| AC8 | `rg -n 'bootstrap.*scout.*tester.*visual'` matches the caveat; it names `scout` as a deliberate residual and says "not a sandbox" | static shell |
| AC9 | `rg -n '"(e2e\|spec\|integration\|cypress\|playwright)/\*\*"'` and the `**/…` forms each match | static shell |
| AC10 | `opencode run --agent doctor "run the consistency diagnostic"` prints `No findings — repository is consistent.`; both existing `verify-tests.sh` suites still pass | manual/tool + static shell |
| AC11 | `git diff --name-only` shows only the nine expected files plus `work/`; `opencode.json`, `docs/workflow.md`, `docs/artifact-conventions.md` absent from the diff | static shell |
