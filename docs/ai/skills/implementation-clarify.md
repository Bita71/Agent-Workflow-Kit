# Clarifications before implementation

The goal is to close ambiguities before decisions or changes are made, so you don't pick a layer, contract, scenario, or check at random.

## When to apply

Apply it if the task has a substantial ambiguity: scope, scenario, architecture, data, UI, text, tests, or done criteria.

**Red flags = a mandatory question.** If the task has at least one red flag (see below) — ask a question, even if the task seems clear. You can't take a default.

Don't apply it only if: the task is fully clear, there are no red flags, and the user wrote "no questions", "defaults are fine", "proceed with reasonable assumptions", "just the X edit".

## Rules

1. Ask as many questions as needed for a precise decision, but don't ask the unnecessary.
2. Group questions by meaning if there are several.
3. Don't duplicate information from the task, open files, or project rules.
4. Take a default without a question only when it's conventional and easily reversible (internal mechanics, implementation). A user-visible UX fork with several equally valid options — do **not** close it with a default; ask: clarifying up front is cheaper than hunting it down and reworking later. "I recorded it in a visible assumptions line" does not replace a question on such a fork.
5. If the task is clear and there are no red flags — continue the work without extra questions.

## What to clarify

### Scenario and scope

- Which user flow is the main one, and what's out of scope?
- Which states are required: loading, error, empty, disabled, success?
- Is backward compatibility needed for existing users/data?

### Architecture and boundaries

- Which layer/module owns the logic, if it doesn't follow from the code?
- Does the module's public API change?
- Should the existing contract be preserved, or can it be replaced entirely?
- Is there a feature flag or conditional rollout?

### Data and contracts

- Data source: backend, storage, URL, browser API, mock?
- DTO shape: which fields are optional / nullable?
- Are retry, idempotency, protection against race conditions or repeated actions needed?

### Security-sensitive logic

Ask if the task touches security-sensitive domains (auth, payments, money, PII, access control) or user input, but the validation boundaries and errors aren't described.

### UI and i18n

- Is there a design reference, and which states are in scope?
- Is the text final, and which i18n keys to use?
- Can existing styling tokens be used, or are new tokens needed?

### Tests and verification

- Are unit/integration/e2e needed, or is a manual check enough?
- Which done criteria count as mandatory?

## Response format

The gate result is always visible — one of two things.

If questions are needed:

```markdown
Need to clarify:

- [question]
- [question]
```

If no questions are needed — print one line, so the "don't ask" decision is explicit and verifiable:

```markdown
Clarification: no red flags → proceeding with defaults [X, Y].
```

Silently skipping the gate is not allowed: no line = the step wasn't done.

## Red flags (mandatory question, no default applies)

- Money/transactions/funds without rules for amount validation and errors.
- The public API changes, but it's unknown whether compatibility must be preserved.
- A new user flow, but no required UI states.
- External data is used as guaranteed, but the DTO shape isn't described.
- There's a design reference, but the states and the acceptable deviation from the mockup aren't specified.
- There's a race condition / retry / repeated action, but no expected behavior.
- A user-visible UX fork with several equally valid options for look or behavior that doesn't follow unambiguously from the task: exactly what to gray out/disable, whether to show text/reason, whether to reset state on reset, the placement of an element in a row, etc.

## Question quality check

- [ ] The questions genuinely help plan or implement the task more precisely.
- [ ] The questions don't repeat context that's already known.
- [ ] Scenario, data/contracts, or UI are covered only where they affect the decision.
