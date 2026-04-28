# Model Presets

Model names change over time and differ across tools. Treat the values below as editable defaults.

The base `.cursor/agents` and `.claude/agents` do not pin models. This is the safest copy-ready default because model IDs vary across accounts and tool versions.

If you want to pin models, edit the agent frontmatter directly.

## Cursor

Cursor uses full model slugs.

### Balanced (Cursor)

| Agent | Model |
| --- | --- |
| `build-standard` | `gpt-5.5-high` |
| `build-complex` | `claude-opus-4-7-thinking-high` |
| `build-hardcore` | `claude-opus-4-7-thinking-high` |
| `plan-gpt` | `gpt-5.5-high` |
| `plan-claude` | `claude-opus-4-7-thinking-high` |
| `review-correctness` | `gpt-5.5-high` |
| `review-design` | `claude-opus-4-7-thinking-high` |
| `verifier` | `gpt-5.5-high` |

Example frontmatter in `.cursor/agents/*.md`:

```yaml
---
name: build-standard
model: gpt-5.5-high
description: Standard builder for routine tasks.
---
```

### GPT-Only (Cursor)

Set every Cursor agent to:

```yaml
model: gpt-5.5-high
```

### Claude-Heavy (Cursor)

Set every Cursor agent to:

```yaml
model: claude-opus-4-7-thinking-high
```

Keep `verifier` on `gpt-5.5-high` unless your repository verification requires long-context reasoning.

## Claude Code

Claude Code uses short aliases: `haiku`, `sonnet`, `opus`. Pick the strongest model you are willing to run for each role.

### Balanced (Claude Code)

| Agent | Model |
| --- | --- |
| `build-standard` | `sonnet` |
| `build-complex` | `opus` |
| `build-hardcore` | `opus` |
| `plan-gpt` | `sonnet` |
| `plan-claude` | `opus` |
| `review-correctness` | `sonnet` |
| `review-design` | `opus` |
| `verifier` | `sonnet` |

Example frontmatter in `.claude/agents/*.md`:

```yaml
---
name: build-standard
description: Standard builder for routine tasks.
model: sonnet
tools: Read, Edit, Write, Bash, Grep, Glob
---
```

Note: `plan-gpt` keeps the name for workflow consistency across tools. In Claude Code it runs on Claude models; the "gpt" name only marks the role (structured planner) vs. `plan-claude` (architecture escalator).

### Opus-Heavy (Claude Code)

Set every Claude Code agent to `opus` for maximum quality.

## Codex

Codex does not read `model:` from `AGENTS.md`. Model selection happens in the Codex CLI (profiles, `config.toml`, or CLI flags). See `AGENTS.md` for Codex-facing workflow instructions.
