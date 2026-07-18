# Model Presets

Model IDs and account availability change over time. The editable preferred values
live only in `.agent-workflow-kit/config.conf`; this file preserves the selection
policy without duplicating those IDs.

## Preferred roles

| Role | Config key | Use |
| --- | --- | --- |
| Planner | `PLANNER_MODEL` | plans and plan refinement |
| Builder | `BUILDER_MODEL` | implementation and fixes |
| Correctness reviewer | `CORRECTNESS_MODEL` | behavior review |
| Security reviewer | `SECURITY_MODEL` | risk-driven security review |
| Design reviewer | `DESIGN_MODEL` | architecture, UX and performance |
| Balanced override | `BALANCED_MODEL` | routine work where latency/cost matters |
| Long-run override | `LONG_RUN_MODEL` | hardest broad or long agentic work |
| Mechanical override | `MECHANICAL_MODEL` | renames, boilerplate and simple repetition |

The source config intentionally preserves the kit owner's preferred defaults.
An installed project may replace any value with `auto` to inherit its host/account
default. Never copy a concrete ID into agent frontmatter, TOML adapters, commands,
or run templates.

## Selection policy

- Keep the five primary roles on strong models. Scale ordinary work with effort
  before changing the role model.
- Use `BALANCED_MODEL` when a task is clear and routine but still requires real
  implementation judgment.
- Use `LONG_RUN_MODEL` only when breadth, ambiguity, or sustained tool use makes it
  materially better than the normal builder.
- Use `MECHANICAL_MODEL` only for low-risk, easily verified repetition. Do not use
  it for subtle correctness, security, migrations, or ambiguous requirements.
- Model choice follows the role and failure cost; effort follows uncertainty and
  depth. File count alone determines neither.

## Effort scale

| Effort | Use |
| --- | --- |
| `low` | Unambiguous mechanics with a cheap verification path |
| `medium` | Ordinary logic with moderate branching or risk |
| `high` | Non-trivial behavior, several edge cases, correctness matters |
| `xhigh` | Long exploration or agentic coding when the host supports it |
| `max` | Highest cost of error: security, value, migrations, subtle state |

`DEFAULT_EFFORT` is the normal starting point. `max` is a workflow intent, not a
universal CLI enum; Codex resolves it through `CODEX_MAX_EFFORT`.

Multi-agent fan-out is an execution mode, not another effort level. Use it only
when the user/host permits delegation and the work genuinely splits into
independent investigations or implementations. Sequential subtle logic usually
benefits more from higher effort on one agent.

Current model discovery and recommendation format live in
`docs/ai/commands/choose-model.md`.
