# choose-model

Recommend a configured model role and effort for the supplied task or artifact.
Do not edit code or configuration.

## Process

1. Read `.agent-workflow-kit/config.conf` and `MODEL_PRESETS.md`.
2. Identify the role: planner, builder, correctness reviewer, security reviewer,
   or design reviewer.
3. If its config value is `auto` or the user asks for a current recommendation,
   fetch the official model lists for the applicable hosts:
   - Claude: `https://docs.anthropic.com/en/docs/about-claude/models/overview`
   - OpenAI: `https://platform.openai.com/docs/models`
4. Assess logic complexity, cost of error, breadth, uncertainty, tool use, and
   expected run duration.
5. Recommend one current model for the role (or keep the configured pin) and one
   workflow effort label: `low`, `medium`, `high`, or `max`.
6. Resolve host syntax through `docs/ai/agents/cli.md`. For Codex `max`, pass the
   current `CODEX_MAX_EFFORT` value rather than assuming `max` is accepted.

Do not maintain fallback model IDs or prices in this command. If current model
discovery fails and the config is `auto`, report that the role remains inherited
instead of inventing an ID.

## Output

```text
Role: <role>
Model: <configured/current ID or auto>
Effort: <low|medium|high|max> -> <host value if different>
Why: <one concise risk/complexity reason>
Config change: <none or the single key the user may choose to update>
```
