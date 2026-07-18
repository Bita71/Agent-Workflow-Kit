# Commit Message

Return only the commit message in English — no comments, explanations, or diff.

Use Conventional Commits:

```text
<type>(<scope>): <subject>
```

If no scope is needed:

```text
<type>: <subject>
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
`build`, `ci`, `chore`, `revert`.

Rules:

- Pick the type by the meaning of the change.
- Add a scope only when it genuinely helps.
- Keep the subject short and to the point, in lower case.
- No period at the end of the subject.
- Use the imperative mood.
- If one line is enough, do not add a body.
- If a body is needed, separate it with a blank line.
- Do not repeat the subject in the body; write only useful context.
- For breaking changes use `!`: `feat!: ...` or `feat(api)!: ...`.
- For breaking changes add `BREAKING CHANGE: ...` in the body or footer.
