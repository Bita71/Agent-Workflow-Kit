# Web TypeScript Profile

Activate only for a TypeScript web application.

## Language and boundaries

- Do not add `any`, unsafe casts, or non-null assertions without a concrete
  guarantee. Preserve typed transport/domain contracts across boundaries.
- Treat browser, URL, storage, backend, and user-provided data as untrusted.
- In React, check effect dependencies, state updates during render, stale
  closures, cleanup, list keys, and unnecessary rerenders.

## UI and text

- For changed user-facing flows, cover applicable loading, error, empty,
  disabled, and success states.
- Route user-facing text through the project's i18n layer when one exists.
- Reuse the project's components and styling tokens; do not invent parallel UI
  primitives or hardcoded design values.
- Presentational components should have the repository's normal visual-state
  coverage when that tooling exists.

## Testing

- Follow the repository's TypeScript test naming and placement conventions.
- Use fake timers for time-dependent logic and restore them in teardown.
- Test parsing, mapping, validation, and async state transitions at their narrowest
  stable boundary.
- Use component/e2e tooling for visual behavior when unit tests cannot prove it.

## Security and verification

For changed `.ts`, `.tsx`, `.js`, or `.jsx` files, use these only as discovery
queries; inspect every hit before reporting it:

```bash
rg -n 'dangerouslySetInnerHTML|innerHTML|eval\(|new Function\(|document\.write|javascript:' <changed-files>
rg -n 'apiKey|secretKey|privateKey|password|token' --case-sensitive <changed-files>
rg -n 'localStorage|sessionStorage|postMessage|window\.open|location\.href' <changed-files>
rg -n 'console\.(log|debug|warn|error)' <changed-files>
```

