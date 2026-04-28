---
description: Create an implementation plan through planner subagents
---

Orchestrate planning. Do not write code.

1. Follow `.claude/skills/skill-plan/SKILL.md`.
2. Ask blocking clarify questions only if needed.
3. Invoke the `plan-gpt` subagent by default.
4. If the escalation criteria in the skill are met, also invoke the `plan-claude` subagent.
5. Merge planner output into one final artifact.

The final response must follow the output artifact in `.claude/skills/skill-plan/SKILL.md`, including build routing as the last section.
