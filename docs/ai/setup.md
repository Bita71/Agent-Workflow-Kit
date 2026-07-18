# Setup

The kit is portable only after one repository-level configuration is created and
validated. All adapters read `.agent-workflow-kit/config.conf`; do not duplicate
these values in `AGENTS.md`, `CLAUDE.md`, Cursor rules, or agent definitions.

## Prerequisites

- Git for diff, review, worktree, and apply workflows.
- Bash/POSIX userland for the installer, validator, worktree recipes, and the
  optional night runner. On Windows, use Git Bash or WSL. PowerShell is not
  currently supported.
- The CLI for every selected host integration (Claude Code, Codex, Cursor) and an
  authenticated account with access to the models you configure.
- `awk`, `sed`, `grep`, `find`, `cmp`, `cp`, `mkdir`, and `mktemp`.

The kit adds no application runtime dependency. The tools above are operational
dependencies of the workflow itself.

## Install

From a checkout of Agent Workflow Kit, preview an installation first:

```bash
scripts/install.sh /path/to/target \
  --components core,claude,codex,cursor \
  --check-command 'your verify command'
```

The default is dry-run. It prints every create/skip/conflict action and writes
nothing. Apply only after the preview is clean:

```bash
scripts/install.sh /path/to/target \
  --components core,claude,codex,cursor \
  --check-command 'your verify command' \
  --apply
```

The installer never overwrites a different file. Any conflict aborts the apply
before the first write. The kit license is installed at
`.agent-workflow-kit/LICENSE`, never over the target repository's root license.

## Configure

Edit `.agent-workflow-kit/config.conf` in the target repository:

- `CHECK_COMMAND` — the complete lint/typecheck/test command. `none` is valid only
  for a documentation-only repository.
- `BASE_REF` — `auto` or the ref used for task diffs and integration.
- `PROFILES` — always `core`, plus applicable profiles from
  `docs/ai/profiles/`.
- `TOOLS` — installed host adapters: `claude`, `codex`, `cursor`.
- `SHELL_FAMILY` — currently `bash-posix`; other values fail validation.
- `DEPENDENCY_ECOSYSTEM` — `auto` or the package ecosystem used by dependency
  audits.
- `RUNNER_*` — optional runner plan/execute/clean commands and its sandbox network
  allowlist. They stay `none` unless the runner component is enabled.
- `*_MODEL` — the source config preserves editable preferred defaults; use `auto`
  to inherit the target account default or replace a pin with one current ID.
- `BALANCED_MODEL`, `LONG_RUN_MODEL`, `MECHANICAL_MODEL` — optional overrides for
  clear routine work, hardest long-running work, and low-risk repetition.
- `DEFAULT_EFFORT` and `CODEX_MAX_EFFORT` — host-supported effort values.

Model IDs are intentionally absent from the shared docs. Pin them once in this
file after checking what the current account exposes.

## Validate

```bash
scripts/agent-workflow-kit-validate.sh
```

Run it after setup and whenever rules, profiles, commands, or adapters change.
For a public release, also run `--release`; it prints Git authors/remotes and
requires an explicit manual anonymity review because rewriting history or remotes
is intentionally outside the validator.

## Profiles

`core` contains only stack-neutral workflow invariants. Profiles add conditional
language, framework, domain, or infrastructure rules. Agents must read only the
profiles listed in `PROFILES`.

Available templates:

- `core` — always active.
- `web-typescript` — TypeScript/browser/UI/i18n/testing and JS security checks.

Project-specific rules still belong in `docs/ai/rules/coding-rules.md`. That file
must stay concise and must not copy an entire profile.

When installing the optional runner component, resolve its commands explicitly:

```bash
scripts/install.sh /path/to/target \
  --components core,runner \
  --check-command 'your verify command' \
  --runner-plan 'your runner plan command' \
  --runner-exec 'your runner execute command' \
  --runner-clean 'your runner clean command' \
  --runner-domains 'registry.example.org,source.example.org' \
  --apply
```

The installer renders `night-runner/sandbox.settings.json` from
`--runner-domains`; `none` creates an offline-by-default allowlist.
