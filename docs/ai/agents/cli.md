# Agent CLI Calls

Canonical invocation shapes for orchestrators and runners. Read model/effort
values from `.agent-workflow-kit/config.conf`; never duplicate concrete IDs here.

## Codex

Planning and review calls run read-only:

```bash
codex exec "<prompt>" \
  -s read-only \
  -C <absolute-path-to-repo-root> \
  -c model_reasoning_effort=<resolved-effort> \
  -o <outfile>
```

- Use the model key for the role. If it is `auto`, omit `-m`; otherwise add
  `-m <configured-model>`.
- Resolve ordinary effort from the requested workflow label. Resolve `max` to
  `CODEX_MAX_EFFORT`; if the CLI rejects a configured value, report the config
  mismatch rather than guessing.
- Keep `-s read-only`. The caller writes plans/reviews from returned Markdown.
- `<outfile>` is a temporary file outside the repository. Delete it after reading;
  if it is empty, use stdout, and treat an empty successful response as failure.
- Put long prompts in a temporary file rather than hand-escaping them.
- Background calls must not inherit interactive stdin; connect stdin to
  `/dev/null` in the POSIX runner.
- Long calls may take tens of minutes. Use an appropriate timeout and surface rate
  limits instead of silently switching roles/models.

## Native host agents

Claude Code and Cursor use their tracked `build` and `review-design` agents when
the workflow calls for native implementation or design review. The adapters read
the same config and active profiles. Review agents return text to the caller; they
do not write artifacts.

## Claude CLI for external runners

When a runner cannot use native agents:

```bash
claude -p "<prompt>" \
  --output-format text \
  --permission-mode auto \
  --settings <sandbox.settings.json>
```

- If the configured role model is not `auto`, add
  `--model <configured-model>`.
- For review mode, add `--disallowedTools "Edit Write NotebookEdit"`.
- Build/fix mode may edit only inside the runner sandbox.
- Sandbox and POSIX prerequisites are documented in
  `docs/ai/recipes/sandboxes.md` and `docs/ai/setup.md`.
