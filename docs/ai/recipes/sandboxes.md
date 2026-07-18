# Sandboxes

Agent workflows run against **three independent sandbox layers**. They stack, they
have different owners, and confusing them wastes time — a failure in one looks like
a bug in your prompt or a broken CLI. This recipe explains each layer, how they
interact, and the symptoms that tell them apart.

| Layer                    | Owner            | Controls                                  | Turn it off with               |
| ------------------------ | ---------------- | ----------------------------------------- | ------------------------------ |
| 1. Harness sandbox       | the agent host   | shell commands the agent runs             | `dangerouslyDisableSandbox`    |
| 2. Codex sandbox         | the Codex CLI    | whether Codex may edit files              | `-s` mode (keep `read-only`)   |
| 3. Runner sandbox        | your night-runner| filesystem writes + network for CLI agents| `--settings <file>`            |

## 1. Harness sandbox (interactive)

The agent host wraps the shell commands an agent runs in its own sandbox:
filesystem writes are limited to the working directory (plus temp), and network is
limited to an allowlist. This is the right default — run commands inside it.

It blocks two common things you legitimately need:

- **Writing outside the working directory** (e.g. editing a sibling repo). Symptom:
  `Operation not permitted` on `mkdir`/write.
- **Binding a port** for a dev/preview server, and some `install` steps that hard-link.
  Symptoms are misleading: a dev server reports `Port <N> is not available` even
  though `lsof -ti:<N>` shows it free; a preview tool reports
  `EPERM: operation not permitted, uv_cwd`; `install` fails with `EPERM` on the
  link step.

When you have real evidence a command failed **because of** the harness sandbox
(the symptoms above), re-run that one command with the sandbox disabled
(`dangerouslyDisableSandbox`) and say why. Do it per-command, not globally — don't
disable it because a command failed for an unrelated reason (missing file, wrong
args, network). Never add secret paths (`~/.ssh`, `~/.aws`, credential files) to
any allowlist.

## 2. Codex sandbox (`-s read-only`)

Codex has its **own** sandbox, separate from the harness. All planning and review
calls run `codex exec ... -s read-only`: Codex can read code and run git, but
**cannot edit files**. The orchestrator collects Codex's output and writes the
artifact (plan/review) itself. See `docs/ai/agents/cli.md`.

**The trap:** when the *harness* sandbox blocks `codex exec` from starting
(symptoms: `Operation not permitted (os error 1)`,
`failed to initialize in-process app-server client`,
`WARNING: proceeding, even though we could not update PATH`), you disable the
**harness** sandbox to let it run — but you **keep `-s read-only`**. That flag is
Codex's own sandbox; dropping it lets Codex start editing files. Two different
sandboxes, only one comes off.

## 3. Runner sandbox (`sandbox.settings.json`)

When agents run **unattended** (night-runner), they run with permission prompts
bypassed, so a config file constrains what they can touch. `night-runner/sandbox.settings.json`
is the template, passed to the Claude CLI via `--settings`:

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false,
    "filesystem": {
      "allowWrite": ["./"],
      "denyRead": ["~/.ssh", "~/.aws", "~/.gnupg", "~/.config/gh"]
    },
    "network": {
      "allowedDomains": [
        "registry.npmjs.org",
        "registry.yarnpkg.com",
        "*.npmjs.com",
        "*.yarnpkg.com",
        "github.com",
        "raw.githubusercontent.com",
        "objects.githubusercontent.com",
        "codeload.github.com"
      ]
    }
  }
}
```

- **`allowWrite: ["./"]`** — writes only inside the worktree.
- **`denyRead`** — agents cannot read credential dirs even though they can read the
  repo. Extend this list; never shrink it.
- **`network.allowedDomains`** — only the package registries and source hosts the
  build needs. Add your registry/proxy; keep it tight. Note the model API host is
  reached by the CLI process, not the sandboxed child, so it need not be listed.

Codex's read-only config template is `.codex/config.toml`:

```toml
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = true
```

This is the *interactive* Codex default (workspace-write + network). For
orchestrated plan/review calls the `-s read-only` flag on each invocation
overrides it to read-only — the flag wins per call.

## Worktree gotchas (sandbox ∩ git)

The worktree recipe (`docs/ai/recipes/git-worktree.md`) has the full list; the
sandbox-specific ones:

- **`install` in a fresh worktree fails under the harness sandbox** (`EPERM` on the
  link step) — run setup with the sandbox disabled. Do **not** symlink the
  dependency dir from `main`: build tools write inside it (temp caches), and a write
  through the symlink lands in `main` and gets blocked. Use a real install.
- **git operations outside the worktree** (apply into the main checkout, rebase,
  `worktree remove`, `branch -D`) need the sandbox disabled.
- **The check command may scan sibling worktrees.** A formatter/linter with no path
  argument walks the whole tree from cwd, including other worktrees; a broken file
  in *another* worktree can fail your run. If an error points at a path under a
  different worktree, verify your own files pointwise instead of trusting the
  aggregate.

## Rule of thumb

- Command failed with a permission/port/EPERM symptom → **harness** sandbox; disable
  it for that one command.
- Need Codex to stay read-only while the harness sandbox is off → keep **`-s
  read-only`**.
- Unattended agent must not read secrets or reach arbitrary hosts → **runner**
  sandbox (`sandbox.settings.json`).
