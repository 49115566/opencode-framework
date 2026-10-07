---
description: "Adopt the framework into this repository — detect the stack, fill AGENTS.md, and tailor skills. Usage: /bootstrap"
agent: bootstrap
---

**Bootstrap** the opencode-framework into this repository. This is a one-time
setup; do not begin any feature work.

Follow your Bootstrap agent instructions exactly. In particular:

- Confirm the framework files (`AGENTS.md`, `opencode.json`, `.opencode/`) are
  present, and whether the Project profile is already filled. The root
  `AGENTS.md`, `opencode.json`, and `.gitignore` are the adopter's own copies —
  the ones `/bootstrap` fills, received from the framework's adopter-pristine
  sources under `template/`. Never modify the framework repository's `template/`
  sources.
- Run the `project-discovery` skill and detect the real install / test / lint /
  typecheck / format / build commands from the repository's own files. Detect
  whether the project has a user-facing frontend.
- Confirm everything with the user in **one batched round**: the command table,
  which stack skills to keep, and whether to enable the Playwright MCP for
  visual QA.
- Fill the **Project profile** in the adopter's own root `AGENTS.md`, remove only
  the approved stack skill directories, set `mcp.playwright.enabled` per the
  user's choice, and ensure `work/` exists and the adopter's own `.gitignore`
  does not ignore it, so artifacts are committed working state while `scratch/`
  and tooling output stay ignored. Write only to the adopter's own root files;
  never modify the framework repository's adopter-pristine sources under
  `template/`.
- Verify with `opencode debug config` and report.

Never delete anything without confirmation and never remove a process skill.
End with the handoff block and remind the user to restart opencode.
