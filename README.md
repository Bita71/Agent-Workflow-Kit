# Agent Workflow Kit

A portable operating system for agent-driven software development across Claude
Code, Codex, and Cursor. It gives you a disciplined pipeline for planning,
building, reviewing, and shipping code changes — plus an unattended night runner
for batch work.

The design principle: **one source of truth, thin adapters.** All the logic —
rules, skills, commands, agent roles — lives in `docs/ai/`. Each tool points there
through a small adapter, so there's no duplicated logic to drift.

## What's included

```text
docs/ai/            Source of truth (rules, skills, commands, agents, recipes, artifacts)
AGENTS.md           Codex adapter → docs/ai
CLAUDE.md           Claude Code adapter → docs/ai
.claude/            Claude commands + design-review subagent + settings example
.codex/             Codex config + custom subagents (toml)
.agents/skills/     Codex repo-scoped skill adapters
.cursor/            Cursor rules + commands
night-runner/       Config templates for the unattended batch runner
MODEL_PRESETS.md    Model + effort defaults (editable)
LICENSE             MIT
```

## Quick start

If the target repo already has any of these files, **merge manually** instead of
overwriting your instructions.

```bash
# Everything (recommended)
cp -R docs .claude .codex .agents .cursor night-runner \
      AGENTS.md CLAUDE.md MODEL_PRESETS.md LICENSE /path/to/your/repo/

# Or per tool — docs/ai is required in every case:
cp -R docs .claude CLAUDE.md /path/to/your/repo/                 # Claude Code
cp -R docs .codex .agents AGENTS.md /path/to/your/repo/          # Codex
cp -R docs .cursor /path/to/your/repo/                           # Cursor
```

Then customize (see [Make it yours](#make-it-yours)) — at minimum, define your
`<check>` command and fill in `docs/ai/rules/coding-rules.md`.

## The workflow

The core loop is one pattern repeated: **produce → verify → fix → repeat**. Only
the actor, the judge, and the exit condition change.

```text
clarify → plan → build → verify → review → triage → fix → done
```

- **`/symphony`** runs the whole thing under one orchestrator, with human gates and
  a resumable run file. The orchestrator never writes code itself — it delegates to
  a builder, has Codex plan and review, runs a design-review subagent, deduplicates
  findings, and loops fixes until done. See `docs/ai/commands/symphony.md`.
- Or drive the stages by hand: `/codex-plan` → `/build` → `/review-full`, fixing in
  between.

Roles are split by strength: **Codex** plans and does correctness/security review;
a **strong model** builds and does design review. The human is the conductor at the
gates.

### Model policy

Strong models only; intelligence is scaled by a `reasoning effort` knob, not by
downgrading the model. Default effort is `high`; raise it with the cost of being
wrong. Full guidance in `docs/ai/commands/choose-model.md` and `MODEL_PRESETS.md`.

## Night runner

An unattended, two-phase batch pipeline: you drop task **briefs** in a folder, a
planner turns each into a plan (you review the plans), then a builder implements +
reviews + fixes each one in its own isolated git worktree — never touching `main`.

The kit ships this as a **pattern plus config templates**, not runnable code: the
loop maps 1:1 onto the same agents, skills, and CLI calls the rest of the kit
already defines, so you wire it to your task runner of choice.

- `docs/ai/recipes/night-runner.md` — the full pattern: two phases, brief
  lifecycle, crash recovery, rate-limit handling, safety model.
- `docs/ai/recipes/night-runner-briefs.md` — how to write briefs that survive an
  agent that can't ask you questions.
- `night-runner/` — `sandbox.settings.json` and `briefs/TEMPLATE.md`.

## Sandboxes

Agent workflows stack three independent sandbox layers — the agent host's, Codex's
own read-only sandbox, and the runner's filesystem/network allowlist. Confusing
them wastes hours (a blocked write looks like a broken CLI). `docs/ai/recipes/sandboxes.md`
explains each layer, how they interact, and the symptoms that tell them apart.

## Make it yours

The kit is intentionally generic. After copying, customize:

- **`<check>`** — your standard verify command (lint + typecheck + tests). Define it
  in `CLAUDE.md` / `AGENTS.md`; it's referenced throughout as `<check>`.
- **`docs/ai/rules/coding-rules.md`** — a template: your architecture boundaries,
  types, UI/i18n, styling, and code-style conventions.
- **`docs/ai/rules/project.md`** — tighten the tool-agnostic invariants for your
  team.
- **`docs/ai/rules/testing.md`** — swap in your test runner and libraries.
- **`MODEL_PRESETS.md`** and **`.codex/config.toml`** — pin the models/effort your
  accounts use.
- **`night-runner/sandbox.settings.json`** — your registry hosts and secret paths.

## Non-goals

- Not tied to any product domain.
- No secrets, local paths, private URLs, or project-specific business rules.
- No new runtime dependencies required.

## Source

This workflow was extracted from a real production project and cleaned up for
open-source use. The `LICENSE` is MIT — replace it if you prefer another.
