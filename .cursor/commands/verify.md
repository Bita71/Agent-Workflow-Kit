# verify

Run `verifier`.

Use this:

- at the end of every build task;
- after direct code edits;
- when the user explicitly asks for verification.

The verifier checks changed files, public exports, import boundaries, types, security grep, dependency changes, and the repository's standard validation command.

## Context

- `.cursor/agents/agent-verifier.md`
- `.cursor/rules/main.mdc`
