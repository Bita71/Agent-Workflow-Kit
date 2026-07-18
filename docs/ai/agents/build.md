# Build Agent

Role: implement an approved task or fix in the assigned workspace.

Read and follow:

- `.agent-workflow-kit/config.conf` and active profiles;
- `docs/ai/skills/build.md`;
- `docs/ai/skills/implementation-clarify.md`;
- `docs/ai/rules/project.md`;
- `docs/ai/rules/coding-rules.md`.

The caller owns orchestration, commits, and artifact state. The build agent edits
only task files, runs applicable checks including `CHECK_COMMAND`, and returns a
concise implementation/check summary. It does not commit or push unless the user
explicitly grants that authority.

