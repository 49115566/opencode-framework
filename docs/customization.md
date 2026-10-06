# Customization

How to extend or change this framework. All components are plain files under
`.opencode/`; there is nothing to compile.

## Where things live

| Component | Path                                    | Notes                                            |
| --------- | --------------------------------------- | ------------------------------------------------ |
| Agents    | `.opencode/agent/<name>.md`             | Frontmatter + prompt body.                       |
| Commands  | `.opencode/command/<name>.md`           | Frontmatter + prompt template with `$ARGUMENTS`. |
| Skills    | `.opencode/skill/<name>/SKILL.md`       | Folder name must equal the skill `name`.         |
| Config    | `opencode.json`                         | Models, default agent, permissions, instructions, MCP.|

opencode discovers these automatically. No registration is required.

`opencode.json` also sets the default agent (`product`), the agent opencode
selects at startup when none is given; every other agent is chosen explicitly or
by a command's `agent:` field.

## Always-loaded instructions

`opencode.json` lists three files under `instructions`:

```json
"instructions": [
  "AGENTS.md",
  "docs/workflow.md",
  "docs/artifact-conventions.md"
]
```

Every request loads all three, so their combined size is a token tax paid on
every turn. The set is deliberate, not accidental:

| File                            | Purpose                                                                                             | Approx. per-request cost |
| ------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------ |
| `AGENTS.md`                     | The workflow contract every agent needs: lifecycle, artifact contract, guardrails, project profile. | ~1.9k tokens (~7.5 KB)   |
| `docs/workflow.md`              | Authoritative lifecycle: phase entry/exit criteria, derived state, routing.                         | ~4.1k tokens (~16.6 KB)  |
| `docs/artifact-conventions.md`  | Exact frontmatter and templates for every artifact.                                                 | ~3.3k tokens (~13.2 KB)  |
| **Total per request**           |                                                                                                     | **~9.3k tokens (~37 KB)**|

Costs are approximate, estimated from each file's current size at roughly 4
bytes per token; refresh this table whenever a listed file changes. These three
are exactly the files the adoption quickstart copies (`README.md` → Quickstart),
so every listed path exists in a freshly adopted repository.

## Editing an agent

1. Open `.opencode/agent/<name>.md`.
2. Keep the existing frontmatter keys valid. Allowed keys: `description`, `mode`
   (`primary` | `subagent` | `all`), `model`, `variant`, `temperature`,
   `top_p`, `steps`, `permission`, `tools`, `disable`, `hidden`, `color`.
   Unknown keys are ignored or routed into `options`.
3. The Markdown body is the system prompt. Do not add a `prompt:` key to the
   frontmatter — the body already is the prompt.

After editing, run:

```
opencode debug agent <name>
```

to confirm the resolved configuration.

## Adding an agent

Create `.opencode/agent/<name>.md`:

```markdown
---
description: One line; shown in the agent picker and used for delegation.
mode: subagent
permission:
  edit: deny
---

<system prompt>
```

Use `mode: primary` for agents the user selects directly (also usable from a
command's `agent:` field). Use `mode: subagent` for agents invoked via the task
tool by a primary agent.

## Adding a command

Create `.opencode/command/<name>.md`:

```markdown
---
description: One line shown in the command list.
agent: builder
---

<Prompt run when the command is invoked. Use $ARGUMENTS for the full input,
and $1, $2, ... for positional arguments.>
```

The command body becomes the user message; the `agent` runs it.

## Adding a skill

Create `.opencode/skill/<name>/SKILL.md`:

```markdown
---
name: <name>
description: What it does AND when to use it, with trigger keywords. Skills
  without a description are not surfaced.
---

<instructions, examples, references>
```

The folder name must match `name`. Skills are matched by their description, so
front-load literal triggers (`test`, `lint`, `pyproject.toml`). Keep each skill
focused on one job.

## Changing models

`opencode.json` sets a default `model`; agents inherit it unless they set their
own `model`. To specialize, add `model: provider/model-id` to an agent's
frontmatter.

The shipped default is `deepseek/deepseek-flash`. It is vision-capable and the
strongest model the framework ships, and every agent inherits it: no agent
declares a `model:` override. `/visual` and `/reviewer` therefore need no
per-agent model override — `/visual` can already analyze screenshots on the
default. To move the whole framework to another model, change the global `model`
(and `small_model`, which tracks it); add a per-agent `model:` only when one
agent genuinely needs a different one.

## Permissions

`opencode.json` sets global permission defaults. Agents override them per key.
Permission objects are evaluated last-match-wins, so list broad patterns first
and narrow ones last:

```yaml
permission:
  bash:
    "*": ask
    "git diff*": allow
```

`edit` governs every file mutation: it covers **create, write, and patch**.
There is no separate `write` key, and none is needed — an agent that can `edit`
a path can create a new file there as well as update one that already exists.

Permission checks see tool paths in two forms: relative to the repository root
(for example `work/<item-ref>/spec.md`) and absolute (for example
`/repo/work/<item-ref>/spec.md`). One pattern matches only one form, so
artifact-writing agents must declare **both** `work/**` and `**/work/**`:

```yaml
permission:
  edit:
    "*": deny
    "work/**": allow
    "**/work/**": allow
```

Read-only agents set `edit: deny` with no `work/` allow, making the intent
explicit even though the catch-all already denies.

Confirm the resolved result for any agent before relying on it:

```
opencode debug agent <name>
```

These blocks restrict opencode's own file tools; they are not a sandbox for
`bash`. opencode matches bash rules by command prefix, so an allowlist cannot
prevent shell redirection (`ls > file`) or output-to-file flags (`tree -o file`,
`git diff --output=file`). Agents with broad bash access (`bootstrap`, `scout`,
`tester`, `visual`) can still modify files through shell commands even when their
`edit` permission is restricted. `scout`'s broad access is a deliberate, accepted
residual: it is the reconnaissance subagent and needs the full shell to explore
unfamiliar repositories. If you need a hard boundary, run opencode in a
sandboxed filesystem rather than relying on these permission blocks.

## MCP servers

Optional integrations live under `mcp:` in `opencode.json`. An enabled MCP
server contributes its tool schemas to every request, so the framework ships the
Playwright browser server **disabled by default**:

```json
"mcp": {
  "playwright": {
    "type": "local",
    "command": ["npx", "-y", "@playwright/mcp@0.0.83", "--headless", "--isolated"],
    "enabled": false
  }
}
```

`/bootstrap` offers to enable it when it detects a user-facing frontend. A
disabled server costs nothing at runtime; `command` must be an array of strings;
`type` is required. Restart opencode after toggling. Use `--headless` to avoid
focus stealing and `--isolated` to avoid a persistent profile; add
`--storage-state <file>` only for flows that need authentication.

The Playwright server is pinned to one exact version so every clone resolves the
same tooling. To move to a new version, **bump the pin**: edit the `@x.y.z`
literal in `opencode.json` and mirror it in the snippet above and in the
`browser-verification` skill's copied example — never restore a floating tag
such as `@latest`. The pin is a deliberate, reviewable change, and bumping it is
the sanctioned way to upgrade.

## Validation loop

After any change:

```
opencode debug config     # confirm config parses
opencode debug agent      # list agents; or `opencode debug agent <name>`
opencode debug skill      # list skills and their descriptions
```

Then **restart opencode** — config is loaded once at startup and is not
hot-reloaded.
