# Agent Workflow For Codex

This file is the Codex-friendly entrypoint. Copy it to the root of a repository as `AGENTS.md`.

## Core Workflow

Use this workflow for non-trivial code changes:

```text
plan -> build -> review -> manual fixes -> verify
```

## How To Use In Codex

Codex may not have Cursor slash commands or custom subagents. Treat the workflow stages as explicit instructions:

- Ask for `plan` when you want an implementation plan without code.
- Ask for `build` when you want implementation.
- Ask for `review` when you want a code-review pass over the current diff.
- Ask for `verify` when you want final factual validation.
- Ask for `learn` when you want durable repository instruction improvements.

## Slash Commands (Cursor, Claude Code)

These commands exist as slash commands in Cursor and Claude Code. In Codex, treat them as named workflow steps.

| Command | Purpose | When To Use |
| --- | --- | --- |
| `/plan` | Creates an implementation plan through planner agents. | Before multi-file work or ambiguous changes. |
| `/plan-manual` | Creates the plan in the current chat. | When you want no planner subagents. |
| `/build` | Routes to exactly one builder agent and then verifies. | For implementation through a subagent. |
| `/build-manual` | Uses the same routing, but implements in the current chat. | For implementation without builder subagents. |
| `/review` | Runs correctness and design review in parallel. | After implementation. |
| `/verify` | Runs final factual validation. | At the end of every build task. |
| `/learn` | Proposes durable workflow or rule improvements. | After a session reveals repeatable guidance. |

## Agent Roles

| Agent | Role |
| --- | --- |
| `build-standard` | Routine implementation: 1-2 files, clear scope, small fixes or features. |
| `build-complex` | Multi-file implementation, new flows, public API changes, or meaningful trade-offs. |
| `build-hardcore` | Large, security-sensitive, migration-heavy, or unclear work. |
| `plan-gpt` | Structured planning: files, steps, contracts, done criteria, test plan. |
| `plan-claude` | Architectural second opinion: risks, boundaries, edge cases. |
| `review-correctness` | Bugs, types, async behavior, data boundaries, security baseline. |
| `review-design` | Architecture, readability, duplication, performance, UX consistency. |
| `verifier` | Final validation: CI, changed files, exports, security grep, dependency audit. |

If the tool does not support subagents, run these roles sequentially in the same chat. For review, use two passes: correctness first, then design.

## Operating Rules

- Keep changes narrow and tied to the user's request.
- Ask only blocking questions; if the task is clear, proceed.
- Do not add dependencies, commit, or push unless explicitly requested.
- Prefer existing project patterns over new abstractions.
- Run verification as the last step of any build task.

## Planning Rules

- Ask only blocking questions before planning.
- For broad or risky work, write a mini-spec first:
  - goal;
  - non-goals;
  - user flows and states;
  - data and boundaries;
  - acceptance criteria;
  - risks.
- The plan must include files, contracts, edge cases, risks, done criteria, test plan, and build routing.

## Build Routing

Use exactly one route:

- `build-standard`: 1-2 files, clear scope, no public API change.
- `build-complex`: 3+ files, new flow, public API change, or meaningful architecture trade-off.
- `build-hardcore`: security-sensitive, migration-heavy, large, unclear, or many edge cases.

## Review Rules

Run two review passes:

- correctness: bugs, types, async behavior, errors, data boundaries, security baseline;
- design: architecture, boundaries, readability, duplication, performance, UX consistency.

Findings must cite changed code and include a concrete fix.

## Verification Rules

- Identify changed files.
- Check public exports and import boundaries.
- Run the repository's standard validation command.
- For JS/TS changes, grep for unsafe HTML, dynamic URL schemes, secrets, and sensitive logs.
- If dependencies changed, run the package manager audit command when available.

## Model Setup

The base setup does not pin models. In Codex, model choice happens in the CLI (profiles, `config.toml`, or flags), not in this file. For Cursor and Claude Code model presets, see `MODEL_PRESETS.md`.
