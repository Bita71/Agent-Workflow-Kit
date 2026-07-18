# Agent CLI Calls

Source of truth for the console calls to Codex and Claude made from orchestrating
commands (`/codex-plan`, `/review-full`) and scripts. Don't invent flags or
syntax — take the forms from here. The battle-tested reference is the
night-runner reference implementation (see `docs/ai/recipes/night-runner.md`):
if this file and the runner diverge, check against the runner and update this
file.

The model IDs below (`gpt-5.5`, `opus`, `sonnet`) are current editable defaults.
Model names change over time; adjust them for your setup.

## Codex

The only call form is `codex exec` in a read-only sandbox:

```bash
codex exec "<prompt>" \
  -m gpt-5.5 \
  -s read-only \
  -C <absolute-path-to-repo-root> \
  -c model_reasoning_effort=<effort> \
  -o <outfile>
```

Rules:

- **The model is always `gpt-5.5`** — a strong-only policy, where intelligence is
  regulated by effort. It has no suffixes like `-sol` / `-terra` / `-luna`: the
  CLI answers `invalid_request_error`.
- **`-s read-only`** — Codex doesn't edit files (git commands and reading code
  still work). The orchestrator picks up the result from `<outfile>` and writes
  the artifact itself into `docs/ai/plans/` or `docs/ai/reviews/`.
- **`<outfile>`** — a temporary file outside the repo (scratchpad / `$TMPDIR`).
  Delete it after reading. If the outfile is empty, take stdout; an empty
  response on a successful exit code is a failure, not "clean" — repeat the call.
- **effort**: the CLI accepts only `none` | `minimal` | `low` | `medium` |
  `high` | `xhigh`. The `max` from `docs/ai/commands/choose-model.md` is an
  abstraction: for Codex substitute `xhigh`, not `max` (the CLI answers
  `unknown variant`). `high` is battle-tested; if the CLI rejects a value, fall
  back to `high` — don't guess at the syntax.
- **A long prompt** goes into a temporary file, substituted as `"$(cat <file>)"`,
  rather than escaped by hand.
- **Timeout**: plan and review calls run for tens of minutes. Launch them in the
  background and wait for completion; don't kill them on a short timeout.
  - **Always append `< /dev/null`** to a background call. Otherwise `codex exec`
    keeps stdin open, hangs on `Reading additional input from stdin...`, and
    never processes the prompt — it looks like "still thinking" when it's
    actually stuck. Symptom: the output contains only the line about stdin and no
    `OpenAI Codex ...` banner.
- **Harness sandbox**: `codex exec` won't start from inside it. Symptoms —
  `Operation not permitted (os error 1)`,
  `failed to initialize in-process app-server client`,
  `WARNING: proceeding, even though we could not update PATH`. This is neither a
  Codex failure nor a prompt problem: rerun the same call with the harness
  sandbox disabled (`dangerouslyDisableSandbox`). **`-s read-only` stays** — that
  is Codex's own, separate sandbox, and you must not remove it, or Codex will
  start editing files.
- **Rate limit / failure**: in an interactive session, don't silently degrade to
  another model — tell the user and ask whether to wait or continue without
  Codex.

## Claude

Inside a Claude Code session **no CLI is needed** — use the native subagent
(Agent tool). For a review subagent, forbid edits via the prompt: "report only,
don't change files".

The CLI form is only needed by external scripts / runners (reference — the
night-runner reference implementation):

```bash
claude -p "<prompt>" \
  --model opus \
  --output-format text \
  --permission-mode auto \
  --settings <sandbox.settings.json> \
  --disallowedTools "Edit Write NotebookEdit"   # review mode only
```

- `--disallowedTools "Edit Write NotebookEdit"` — a hard edit ban for review
  runs; for build/fix runs the flag is removed.
- `--settings` points to sandbox settings
  (`night-runner/sandbox.settings.json`): write only to the working directory,
  denyRead on secrets, network by allowlist.
- Don't use `--permission-mode plan`: Opus mistakes it for planning mode and
  calls ExitPlanMode instead of returning a report.
