---
name: implementation-clarify
description: Ask 1-3 blocking questions before implementation when missing answers could materially change the solution.
---

# Implementation Clarify

Use this before implementation, planning, or design-to-code work when ambiguity could send the task in the wrong direction.

## Rules

1. Ask only 1-3 blocking questions.
2. Do not repeat information already present in the prompt or open files.
3. If the task is clear, ask nothing and proceed.
4. If the user says "use defaults", "no questions", or "make reasonable assumptions", proceed with concise assumptions.

## Checklist

Use only the relevant areas:

### Product And Behavior

- What is the expected user outcome?
- What states matter: loading, empty, error, disabled, success?
- Is backward compatibility required?

### Data And Contracts

- Where does the data come from?
- What fields are optional, nullable, or versioned?
- Are migrations or existing consumers involved?

### Architecture

- Which module, layer, or package owns the change?
- Does any public API change?
- Are feature flags or rollout constraints needed?

### UI And Copy

- Is there a design, reference, or existing component to match?
- Is copy final?
- Are accessibility requirements implied by an existing primitive?

### Tests

- What level of validation is expected: unit, integration, e2e, manual, or CI only?

## Red Flags

Ask before proceeding if:

- the task touches auth, payments, permissions, personal data, or irreversible actions;
- a public API changes without compatibility guidance;
- a design is provided without required states;
- data shape is unknown and the implementation depends on it.

## Verification

- Questions are blocking, not nice-to-have.
- Questions are specific enough to change the implementation.
- The answer can be acted on immediately.
