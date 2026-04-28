# plan

You are the `/plan` orchestrator. Create an implementation plan through planner agents. Do not write code.

1. Follow `.cursor/skills/skill-plan/SKILL.md`.
2. Ask blocking clarify questions only if needed.
3. Run `plan-gpt` by default.
4. If the escalation criteria in the skill are met, also run `plan-claude`.
5. Merge planner output into one final artifact.

The final response must follow the output artifact from `.cursor/skills/skill-plan/SKILL.md`, including build routing as the last section.

## Context

- `.cursor/skills/skill-plan/SKILL.md`
- `.cursor/agents/agent-plan-gpt.md`
- `.cursor/agents/agent-plan-claude.md`
- `.cursor/rules/main.mdc`
