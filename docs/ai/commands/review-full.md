# review-full

Claude orchestrates a full review of the changed diff: Codex (correctness +
optionally security) and Opus (design) in parallel, then deduplication and a
single report. Code is not edited in this command.

## Scope

1. Determine the changed files: `git diff --name-only`.
2. If the diff is empty, check the staged diff: `git diff --staged --name-only`.
3. If the staged diff is empty too, say briefly: `No changes to review`.
4. Only the changed/staged files and the nearest code paths are reviewed, not the
   whole project. If the user specified a different range (for example
   `main...HEAD`) — use it.

## Orchestrator decisions

Before launching, decide yourself and state in one line:
`Review: codex correctness[+security] effort <X> ∥ opus design`.

- **Codex effort** — by the cost of a mistake in the diff (criteria in
  `docs/ai/commands/choose-model.md`): default `high`, `max` for
  money/security/migrations, `medium` for small cosmetics.
- **Codex security pass** — run it only when there are risk signals in the
  actually added or changed parts of the diff:
  - security-sensitive domains (auth, payments, money, PII, access control);
  - user input, URL/deep link, HTML/markdown, file/media;
  - storage/localStorage/sessionStorage/cookies;
  - external APIs, browser APIs, postMessage;
  - dependencies, env/config, logging/error-tracker breadcrumbs;
  - crypto/signature/encryption/randomness;
  - the user explicitly asked for a security review.

  Do not run security if the diff only moves, deletes, or inlines existing code
  without new external surfaces, storage writes, API/browser calls, or new
  handling of user input.

## Parallel launch

Launch both reviews **at the same time**; do not wait for one to start the other:

1. **Codex correctness (+security)** — a Bash call in the background, strictly
   per `docs/ai/agents/cli.md`. In the prompt include:
   - follow `docs/ai/skills/review-correctness.md` (and
     `docs/ai/skills/review-security.md` if security is needed);
   - the same scope you determined (which diff to look at);
   - do not edit code, report only;
   - on the first line, a summary:
     `Critical: N | Required: N | Nit: N | Optional: N | FYI: N`.
2. **Opus design** — the native subagent `review-design` (Agent tool, model
   opus): follow `docs/ai/commands/review-design.md` and
   `docs/ai/skills/review-design.md`, the same scope, no edits, the same summary
   on the first line. The subagent does not write a file artifact — it returns
   the report to you.

## Deduplication

Merge both reports yourself:

- the same finding (same file, spot, gist) → one entry with source `codex+claude`;
- when one finding has different severities, do not mechanically take the higher
  one — decide yourself by reading the disputed code;
- keep unique findings with source `correctness` / `security` / `design`;
- delete speculation that does not reference a concrete diff/code path.

## Artifact

Write the merged report to `docs/ai/reviews/YYYY-MM-DD-short-task.review.md`:

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### Critical

[security vulnerabilities, data loss, broken core flow]

### Required

[bugs, regressions, missing validation]

### Nit

[small concrete fixes]

### Optional

[improvements, not required]

### FYI

[context or future tech debt]
```

For each finding, give:

- the file;
- the gist;
- the severity;
- the source: `correctness` | `security` | `design` | `codex+claude`;
- the concrete fix.

If there are no problems: `No critical problems found` and list which review
passes were run.

## Chat result

- the path to the review file;
- the summary `Critical / Required / Nit / Optional / FYI`;
- 1–3 top findings, if any;
- fixes are not made in this command — only on a separate user request.
