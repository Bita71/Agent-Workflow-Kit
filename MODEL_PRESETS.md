# Model Presets

Model IDs and account availability change over time. The only repository-owned
values live in `.agent-workflow-kit/config.conf`; this file explains the roles but
does not duplicate their values.

## Roles

| Role | Config key | Used for |
| --- | --- | --- |
| Planner | `PLANNER_MODEL` | plans and plan refinement |
| Builder | `BUILDER_MODEL` | implementation and fixes |
| Correctness reviewer | `CORRECTNESS_MODEL` | behavior review |
| Security reviewer | `SECURITY_MODEL` | risk-driven security review |
| Design reviewer | `DESIGN_MODEL` | architecture, UX, simplification, performance |

`auto` means inherit the current host/account default. Pin an ID only after
checking the current account's official model list. Never copy an ID into agent
frontmatter, TOML adapters, commands, or run templates.

## Effort

The workflow uses `low`, `medium`, `high`, and `max` as intent labels. Resolve
them through host capabilities:

- `DEFAULT_EFFORT` is the normal starting point.
- `max` means the highest supported effort justified by risk and uncertainty.
- For Codex, map `max` to `CODEX_MAX_EFFORT`; do not assume a universal CLI enum.
- A host that does not expose effort uses the selected model and prompt only.

Choose effort by the cost of a mistake and uncertainty, not by file count. Current
model discovery and recommendation format live in
`docs/ai/commands/choose-model.md`.
