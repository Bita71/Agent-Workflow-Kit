# Agent Workflow Kit

A portable operating system for agent-driven software development across Claude
Code, Codex, and Cursor. It gives you a disciplined pipeline for planning,
building, reviewing, and shipping code changes, plus a documented unattended
night-runner pattern for batch work.

The design principle: **one source of truth, thin adapters.** All the logic —
rules, skills, commands, agent roles — lives in `docs/ai/`. Each tool points there
through a small adapter, so there's no duplicated logic to drift.

## What's included

```text
docs/ai/            Source of truth (rules, skills, commands, agents, recipes, artifacts)
.agent-workflow-kit/ One project config + nested kit license
AGENTS.md           Codex adapter → docs/ai
CLAUDE.md           Claude Code adapter → docs/ai
.claude/            Claude commands + build/design agents + settings example
.codex/             Codex config + custom subagents (toml)
.agents/skills/     Codex repo-scoped skill adapters
.cursor/            Cursor rules + commands + native agents
night-runner/       Config templates for the unattended batch runner
MODEL_PRESETS.md    Model-role and effort policy
scripts/            Dry-run installer + validator
LICENSE             MIT
```

## Quick start

Prerequisites: Git and a POSIX/Bash environment (Git Bash or WSL on Windows), plus
the CLIs for the host adapters you select. Details: `docs/ai/setup.md`.

Preview installation into an existing repository:

```bash
scripts/install.sh /path/to/your/repo \
  --components core,claude,codex,cursor \
  --check-command 'your verify command'
```

Dry-run is the default. The installer never overwrites a different file and aborts
before writing if it finds a conflict. Apply the reviewed plan with the same
arguments plus `--apply`, then run:

```bash
/path/to/your/repo/scripts/agent-workflow-kit-validate.sh
```

Use `--components all` to include the optional night-runner templates; that mode
also requires the `--runner-plan`, `--runner-exec`, and `--runner-clean` options.
See `docs/ai/setup.md`. The kit's license is installed under
`.agent-workflow-kit/LICENSE`; the target project's root `LICENSE` is never
replaced.

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

Model roles, preferred overrides, and effort live only in
`.agent-workflow-kit/config.conf`. The source config preserves the kit owner's
editable preferences; a target project may use `auto` to inherit its host/account
default. Never duplicate pins across adapters. Guidance:
`docs/ai/commands/choose-model.md` and `MODEL_PRESETS.md`.

## Night runner

An unattended, two-phase batch pipeline: you drop task **briefs** in a folder, a
planner turns each into a plan (you review the plans), then a builder implements +
reviews + fixes each one in its own isolated git worktree - never touching the
resolved `BASE_REF` checkout.

The kit ships this as a **pattern plus config templates**, not runnable code. The
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

The installer creates one config. Customize it and the local overlay:

- **`.agent-workflow-kit/config.conf`** — `CHECK_COMMAND`, `BASE_REF`, active
  profiles, selected tools, model roles, effort, shell, and ecosystem.
- **`docs/ai/rules/coding-rules.md`** — project overlay: architecture boundaries,
  toolchain, contracts, domain constraints, and code-style conventions.
- **`docs/ai/profiles/`** — activate only applicable stack/domain overlays.
- **`docs/ai/rules/project.md`** — tighten the tool-agnostic invariants for your
  team.
- **`docs/ai/rules/testing.md`** — swap in your test runner and libraries.
- **`RUNNER_*` in config** — optional runner commands and sandbox domains; the
  installer renders `night-runner/sandbox.settings.json` from them.

## Portability contract

- Neutral core with opt-in stack/domain profiles.
- No secrets, private URLs, personal paths, or project-specific business rules in
  the distributed tracked files.
- No application runtime dependency; Git/Bash/POSIX/selected agent CLIs are workflow
  prerequisites.

## Source

This workflow was derived from production patterns and generalized for reuse. The
kit is MIT-licensed. Installation preserves that notice without modifying the
target project's root license.
