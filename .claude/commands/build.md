---
description: Route implementation to one builder subagent, then verify
---

Route the task. Do not implement code yourself.

1. Follow `.claude/skills/skill-build/SKILL.md`.
2. Ask blocking clarify questions only if needed.
3. Invoke exactly one subagent: `build-standard`, `build-complex`, or `build-hardcore`.
4. Wait for the builder result.
5. Invoke the `verifier` subagent as the final step.
