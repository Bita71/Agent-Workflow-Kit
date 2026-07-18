# choose-model

Analyze the provided context (most often an **implementation plan in a `.md`
file**) and recommend **which model** (Claude or GPT) and **what effort** to use
for the work. Do not write code, do not run anything — a recommendation only.

> The model IDs, prices, and effort tables below are editable defaults. They
> reflect a point-in-time lineup; treat them as a starting point and update them
> for your own accounts and current model generation.

## What to do

1. **Get the current model list.**
   - Claude: WebFetch the page
     `https://docs.anthropic.com/en/docs/about-claude/models/overview`.
   - GPT / Codex (if the task goes down the Codex branch): WebFetch
     `https://platform.openai.com/docs/models`.

   Take the current IDs and descriptions from them. Do not treat the lists below
   as truth — they are only a fallback in case the fetch does not work.

2. **Take the context.** If a file path is given in the message — read it.
   Otherwise use the current chat context / the user's message.

3. **Assess the task** by these criteria:
   - **Logic complexity** — trivial / routine / nontrivial architecture.
   - **Cost of a mistake** — cosmetic / an ordinary feature / money, security,
     migrations, prod incidents.
   - **Size** — a point fix / several files / a cross-module refactor.
   - **Uncertainty** — requirements are clear, or you have to guess/investigate.

4. **Give a recommendation** — briefly: model + effort + one sentence of why.

## Fallback model list (if WebFetch is unavailable)

### Claude (primary builder)

Order — from the most capable/expensive to the fastest/cheapest.

| Model     | ID                          | Price (in/out per MTok) | When to use                                                                                                                          |
| --------- | --------------------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Fable 5   | `claude-fable-5`            | $10 / $50               | The most capable. Long agentic runs (30+ min), the hardest architecture, the highest cost of a mistake. The slowest of all.         |
| Opus 4.8  | `claude-opus-4-8`           | $5 / $25                | Complex agentic code and enterprise: cross-module refactors, subtle debugging, ambiguous requirements.                              |
| Sonnet 5  | `claude-sonnet-5`           | $3 / $15 (intro $2/$10) | The best speed/intelligence balance. Routine feature work against a clear plan.                                                     |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | $1 / $5                 | The fastest, near-frontier. Mechanics: renames, boilerplate, localization, simple tests. Does not support the `effort` parameter.   |

### GPT / Codex (planning and correctness/security review)

There are no separate `-codex` IDs — Codex is a surface over the same models.

| Model   | ID        | When to use                                                                                 |
| ------- | --------- | ------------------------------------------------------------------------------------------- |
| GPT-5.5 | `gpt-5.5` | The only model for planning and correctness/security review. The tier is set by effort.     |

> Strong-only policy: we do not choose the model, we tune intelligence with
> `effort` (`low` … `max`, see below). Suffixes like `-sol` / `-terra` / `-luna`
> on `gpt-5.5` **do not exist** — the CLI answers `invalid_request_error`. The
> line is versioned: when the generation changes, check the available IDs
> (`codex exec ... -m <id>`) and update `docs/ai/agents/cli.md` together with
> this table.

### ultracode (Claude)

About subagent orchestration, **not** a separate effort level:

- **Claude — ultracode**: in Claude Code this is `xhigh` **plus** standing
  permission to run a multi-agent workflow. Not a new API effort — the same
  `xhigh` plus orchestration (agent fan-out, adversarial verify, synthesis).

`max` = "think deeper on a single task", ultracode = "split into independent
pieces and parallelize". Use it when the work genuinely breaks into independent
parts (an audit, a migration, a broad survey, N independent checks). For
sequential subtle logic they do not help — there you need `max`.

## Effort

A single reasoning-effort scale. The default everywhere is `high`.

| Effort   | When                                                                     | Models                               |
| -------- | ------------------------------------------------------------------------ | ------------------------------------ |
| `low`    | Unambiguous steps, little branching, the fix is obvious.                 | Fable 5, Opus, Sonnet 5; GPT-5.5     |
| `medium` | Ordinary development: there is logic, but risk and uncertainty are moderate. | Fable 5, Opus, Sonnet 5; GPT-5.5 |
| `high`   | Nontrivial logic, correctness matters, many edge cases. **Default.**     | Fable 5, Opus, Sonnet 5; GPT-5.5     |
| `xhigh`  | Long agentic/coding tasks (30+ min), broad exploration.                  | Fable 5, Opus 4.8, Sonnet 5; GPT-5.5 |
| `max`    | Highest cost of a mistake: money/security/migrations, subtle edge cases. | Fable 5, Opus 4.8, Sonnet 5; GPT-5.5 |

`gpt-5.5` has all five levels available (verified with a
`codex exec ... -c model_reasoning_effort=<e>` call).
The `minimal` level cannot be used through `codex exec`: the API answers
`The following tools cannot be used with reasoning.effort 'minimal': image_gen, web_search`,
and Codex enables those tools by default. This is a surface limitation, not a
model one.

**Guideline:** effort grows with the cost of a mistake and with uncertainty, not
with size. A large but mechanical task — Haiku 4.5 or `gpt-5.5` + `low/medium`.
`max` is expensive — do not make it the default; compare it with `xhigh` on the
real task. Haiku 4.5 does not accept the `effort` parameter (tune via the prompt
or model choice).
