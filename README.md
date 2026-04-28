# Agent Workflow Kit

A portable setup for agent-driven software development in Cursor, Claude Code, and Codex.

It provides a small operating system for planning, building, reviewing, and verifying code changes.

## What Is Included

- `.cursor/` - Cursor agents, commands, skills, and rules.
- `.claude/` - Claude Code agents, commands, skills, and rules.
- `AGENTS.md` - Codex-compatible repository instructions and workflow map.
- `CLAUDE.md` - Short entrypoint for Claude Code that points into `.claude/`.
- `MODEL_PRESETS.md` - per-tool model options and balanced defaults.
- `LICENSE` - MIT license.

## Quick Start

The package includes an MIT license. Replace `LICENSE` if you prefer another open-source license.

If the target repository already has `.cursor`, `.claude`, `AGENTS.md`, or `CLAUDE.md`, merge files manually instead of overwriting existing instructions.

### Cursor

```bash
cp -R .cursor AGENTS.md MODEL_PRESETS.md /path/to/your/repo/
```

Open the repository in Cursor and use the slash commands:

```text
/plan -> /build -> /review -> manual fixes -> /verify
```

### Claude Code

```bash
cp -R .claude CLAUDE.md MODEL_PRESETS.md /path/to/your/repo/
```

Open the repository with Claude Code. It reads `CLAUDE.md` and discovers agents, commands, and skills in `.claude/`.

### Codex

```bash
cp AGENTS.md MODEL_PRESETS.md /path/to/your/repo/
```

Codex reads `AGENTS.md` as repository instructions.

### All Tools

```bash
cp -R .cursor .claude AGENTS.md CLAUDE.md MODEL_PRESETS.md LICENSE /path/to/your/repo/
```

## Recommended Flow

```text
plan -> build -> review -> manual fixes -> verify
```

- `plan` before multi-file or ambiguous work.
- `build` for implementation.
- `review` after implementation, using correctness and design lenses.
- `verify` as the final factual validation step.
- `learn` after a useful session to propose durable rule or workflow improvements.

## Model Defaults

Base `.cursor/agents` and `.claude/agents` do not pin models. This is the safest default because model IDs differ across tools and accounts.

Optional presets for Cursor and Claude Code (balanced, GPT-only, Claude-heavy, opus-heavy) are documented in `MODEL_PRESETS.md`.

## How The Workflow Works

1. Clarify only blocking ambiguity.
2. Route the task by complexity: standard, complex, or hardcore.
3. Use exactly one builder per build task.
4. Review with two independent passes: correctness and design.
5. Verify facts: changed files, exports, import boundaries, security grep, dependency audit, and the repository's standard check.

## Repository Assumptions

This setup is intentionally generic. After copying, customize:

- architecture boundaries;
- test commands;
- lint or typecheck commands;
- UI and accessibility conventions;
- import rules;
- documentation requirements.

Targets to customize per tool:

- Cursor: `.cursor/rules/main.mdc`;
- Claude Code: `CLAUDE.md` and `.claude/rules/*`;
- Codex: `AGENTS.md`.

## Non-Goals

- Not tied to any specific product domain.
- No secrets, local paths, private URLs, or project-specific business rules.
- No new dependencies required.

## Source

This workflow was extracted from a real production project and cleaned up for open-source use.
