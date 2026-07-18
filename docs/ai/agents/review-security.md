# Review Security

Read `docs/ai/skills/review-security.md` and perform the security review strictly by it.

Context: run only when the `codex review` orchestrator passes a security-sensitive diff or the user explicitly asks for a security review. If no file list is passed, determine the changed files via `git diff --name-only`.
