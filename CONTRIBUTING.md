# Contributing

Thanks for improving opencode-framework. This guide covers how to propose a
change, how to run the committed test suite, the commit and branch conventions,
and the manual release model. The framework's own development process is
documented in [`docs/workflow.md`](docs/workflow.md); how to extend its agents,
commands, skills, and config is in
[`docs/customization.md`](docs/customization.md).

## Proposing a change

1. Open an issue describing the problem or the behavior you want, so the design
   can be discussed before code is written.
2. Fork the repository and create a branch off `main` (see
   [Branch conventions](#branch-conventions)).
3. Make the smallest change that satisfies the requirement. Follow the
   conventions of the surrounding files — they, not memory, define the style.
4. Run the committed test suite (below) and make sure it passes.
5. Open a pull request against `main`. Describe the change, link the issue, and
   include the command output that proves the change works.

For a change that is itself a framework feature, the repository uses the
lifecycle in [`docs/workflow.md`](docs/workflow.md): spec it, design it, build
it, test it, review it, ship it. Small, self-contained changes can follow the
lighter `/fix` path.

## Running the committed tests

The canonical, provider-neutral suite is the repository's agreement check: it
asserts that the docs, configuration, prompts, and on-disk files agree. Run it
from the repository root:

```sh
bash tests/run.sh
```

It exits `0` when every executed assertion passes, `1` when one fails, and `2`
on a setup error. A check whose only missing prerequisite is an optional tool
(the `opencode` CLI, `python3`, `npm`, or the npm registry) reports `skip` and
does not fail the run, so a minimal environment (bash + git only) still exits
`0`. See [`tests/README.md`](tests/README.md) for the canonical command, the
exit contract, and the per-area check inventory.

Adding a check is adding a file under `tests/checks/`; the runner needs no edit.
The opt-in mutation self-check (`bash tests/mutation.sh`) is maintainer tooling
and is not part of `run.sh`.

## Commit conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <imperative subject>
```

- Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `style`, `build`,
  `ci`, `chore`, `revert`.
- Use the imperative mood, lower-case, no trailing period: "add token refresh",
  not "added" or "adds".
- One logical change per commit. If the subject needs "and", split the commit.
- A breaking change adds `!` after the type/scope and a `BREAKING CHANGE:`
  footer.

Example: `test(checks): assert version and changelog agree`

## Branch conventions

Branch names are `<type>/<short-description>`, where `<type>` matches the commit
type and `<short-description>` is a short kebab-case handle:

- `feat/0001-add-dark-mode` — a work item, named by its canonical reference.
- `feat/0002-agentic-roadmaps-0001-roadmap-model` — a nested roadmap child, with
  the reference's `/` replaced by `-`.
- `fix/login-timeout` — a fix with no work item.
- `docs/update-readme` — a documentation-only change.

Never commit secrets, credentials, generated artifacts, or `.env` files. Never
amend or force-push a commit that has already been pushed.

## Release model

Releases are cut **manually** by a maintainer. There is no tag-triggered CI
release workflow: GitHub Actions runs the test suite, but tagging and publishing
are always deliberate human actions. `VERSION` at the repository root is the
**single source of truth** for the framework version; `CHANGELOG.md` must agree
with it.

To cut a release:

1. **Classify the change** as a SemVer increment: **MAJOR** for incompatible
   changes, **MINOR** for backward-compatible functionality, **PATCH** for
   backward-compatible fixes.
2. **Edit `VERSION`** to the new `MAJOR.MINOR.PATCH` string (no leading `v`, no
   other content). A pre-release uses SemVer pre-release syntax, for example
   `1.0.0-rc.1`.
3. **Update `CHANGELOG.md`**: move the `Unreleased` entries into a new dated
   section `## [x.y.z] - YYYY-MM-DD`, grouped under the Keep a Changelog
   categories, and leave `Unreleased` in place and empty. The newest released
   section's version must equal `VERSION`.
4. **Commit** the changes (`chore(release): vX.Y.Z` or similar).
5. **Create an annotated tag** on that commit:

   ```sh
   git tag -a v1.0.0 -m "opencode-framework v1.0.0"
   ```

6. **Push the commit and the tag**:

   ```sh
   git push origin main
   git push origin v1.0.0
   ```

7. **Publish a GitHub Release** for the tag, using the changelog section as its
   notes. Mark the Release as a pre-release when the version is a pre-release
   (for example `1.0.0-rc.1`).

If the release is wrong, fix it forward: publish a new version rather than
moving a tag that has been pushed.

## Packaging files are maintainer-only

`LICENSE`, `CONTRIBUTING.md`, `CHANGELOG.md`, and `VERSION` belong to the
framework repository itself. They are **maintainer-only** and are deliberately
outside the adopter copy set, so the adoption quickstart never copies them into a
downstream repository. An adopter keeps its own license, contribution guide,
changelog, and version.

The copy set itself splits by source. The three bootstrap-mutable files an
adopter receives — `AGENTS.md`, `opencode.json`, and `.gitignore` — come from the
framework's **adopter-pristine sources** (`template/AGENTS.md`,
`template/opencode.json`, and `template/.gitignore`) and are copied to their
destination names; the framework repository's own root copies of those three are
maintainer-bootstrapped and are never copied. The rest of the set —
`.opencode/{agent,command,skill}` and `docs/*.md` — has a single source and is
**shared verbatim** between the framework repository and adopters.

Because this change adds no files to the copied set, **already-adopted
repositories need no action**: re-running the quickstart copies nothing new into
them, and any existing `LICENSE`, `CONTRIBUTING.md`, or `CHANGELOG.md` they
already have is neither overwritten nor conflicted with.
