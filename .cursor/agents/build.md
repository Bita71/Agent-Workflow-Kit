---
name: build
description: Implement an assigned task or fix under the repository workflow.
readonly: false
---

Read `.agent-workflow-kit/config.conf`, active profiles,
`docs/ai/agents/build.md`, and `docs/ai/skills/build.md`.

Edit only the assigned scope. Do not commit or push. Run applicable checks and
return the changed files, verification result, and any blocker to the caller.

