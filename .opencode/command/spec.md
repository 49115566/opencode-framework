---
description: "Gather requirements and write a feature spec. Usage: /spec <feature or problem description>"
agent: product
---

Run the **Requirements** phase for the following request:

$ARGUMENTS

Follow your Product agent instructions exactly. In particular:

- Read `AGENTS.md`, `docs/workflow.md`, and `docs/artifact-conventions.md` first.
- Recon the repository for domain context before asking anything. Delegate broad
  recon to the `scout` subagent.
- Ask every clarifying question that materially changes the spec in a **single
  batched round** using the question tool. Offer concrete options and mark a
  recommendation. Do not ask what the repo already answers.
- Then write `work/<NNNN-slug>/spec.md` using the `spec-writing` skill and the
  template in `docs/artifact-conventions.md`. Allocate the next `NNNN` and a
  kebab-case slug.
- Run the spec quality bar and set `status: final` (or `blocked` with a reason).

If `$ARGUMENTS` is empty, ask the user what they want to build before doing
anything else. If the request is trivial, recommend `/fix` instead of inflating a
spec.

Do not write any code and do not start design. End with the handoff block.
