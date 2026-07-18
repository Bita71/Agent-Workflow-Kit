# Profiles

Profiles are opt-in overlays over the neutral core. Activate them through the
comma-separated `PROFILES` value in `.agent-workflow-kit/config.conf`.

Rules:

- `core` is mandatory and loaded first.
- Load only listed profiles; an unlisted profile must not influence a task.
- Repository-specific exceptions stay in `docs/ai/rules/coding-rules.md`.
- A profile may narrow a core rule but may not weaken safety, authority, or secret
  handling.

