# Model Presets

Model names change over time and differ across tools and accounts. Treat every
value here as an **editable default**. The authoritative, self-updating guidance
lives in `docs/ai/commands/choose-model.md` (it fetches current model lists) — this
file is the quick reference.

## Policy: strong-only + effort

This kit does **not** route work across weak/strong models. It uses one strong
model per role and scales intelligence with a `reasoning effort` knob. A large but
mechanical task is a strong model at low effort — not a weaker model. Pick the
model by role, the effort by the **cost of being wrong** and the uncertainty, not
by task size.

| Role                    | Default model | Notes                                            |
| ----------------------- | ------------- | ------------------------------------------------ |
| Builder / design review | `opus`        | Implementation and design review (Claude).       |
| Planner / correctness   | `gpt-5.5`     | Planning and correctness/security review (Codex).|
| Hardest, long runs      | `fable`       | Reserve for the most complex, long agentic work. |
| Fast mechanical work    | `haiku`       | Renames, boilerplate; does not take `effort`.    |

Model IDs (editable): `claude-opus-4-8`, `claude-sonnet-5`, `claude-fable-5`,
`claude-haiku-4-5-20251001`, `gpt-5.5`. Versioned lines change over time — verify
current IDs and update `docs/ai/commands/choose-model.md` when a generation flips.

## Effort scale

Single scale, default `high` everywhere.

| Effort   | When                                                                  |
| -------- | --------------------------------------------------------------------- |
| `low`    | Unambiguous steps, few branches, the edit is obvious.                 |
| `medium` | Ordinary work: real logic, but moderate risk and uncertainty.        |
| `high`   | Non-trivial logic, correctness matters, many edge cases. **Default.** |
| `xhigh`  | Long agentic/coding runs (30+ min), broad exploration.               |
| `max`    | Highest cost of error: security, money, migrations, subtle edges.    |

`max` is expensive — don't make it the default; compare it against `xhigh` on a
real task. `minimal` is not usable through `codex exec` (the CLI's default tools
reject it). See `docs/ai/agents/cli.md` for the Codex effort details.

## Per-tool notes

- **Claude Code** — the `review-design` subagent pins `model: opus` in its
  frontmatter (`.claude/agents/review-design.md`). Everything else runs on the
  session model; scale with effort. Change the pin if your account differs.
- **Codex** — model and effort are set on the CLI (`.codex/config.toml`, profiles,
  or `-m` / `-c model_reasoning_effort=` flags), and per-subagent in
  `.codex/agents/*.toml`. Not read from `AGENTS.md`.
- **Cursor** — Cursor uses full model slugs. If you want to pin a model per
  command, do it in the Cursor UI; the kit's `.cursor` adapters don't hardcode
  models so the setup stays portable across accounts.

## ultracode (Claude)

Not a separate effort level — it's `xhigh` **plus** standing permission to run
multi-agent workflows (fan-out, adversarial verify, synthesis). Use it when the
work genuinely splits into independent parts (audit, migration, broad sweep, N
independent checks). For sequential, subtle logic, use `max` instead. Details in
`docs/ai/commands/choose-model.md`.
