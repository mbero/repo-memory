---
title: Development conventions
type: context
status: draft
updated: {{TODAY}}
sources: []
tags: [conventions, code]
---

# Development conventions — {{PROJECT_NAME}}

> Load this file before you write or modify any code in this repository.

## Naming

| Element | Rule | Example |
|---|---|---|
| Package | | `{{PACKAGE_ROOT}}.<area>` |
| Class | | |
| Interface | | |
| Test class | | |
| Database table | | |
| Configuration key | | |

## Package structure

```text
{{PACKAGE_ROOT}}
├── <!-- area -->
│   ├── <!-- layer -->
```

**Rule:** group by feature first, by layer second. A reader must find a feature
in one directory.

## Layering

| Layer | May call | Must not call |
|---|---|---|
| | | |

## Code style

- One public type per file.
- No fully qualified class name in a method body. Import it.
- A comment explains **why**, never **what**. Keep it under five lines.
- Public API gets documentation. Private code does not.
- Match the formatting of the surrounding file. Run `{{LINT_COMMAND}}`.

## Tests

| Test type | Framework | Naming | Runs with |
|---|---|---|---|
| Unit | | | `{{TEST_UNIT_COMMAND}}` |
| Integration | | | `{{TEST_INTEGRATION_COMMAND}}` |

**Rules:**

- Every new unit of observable behaviour gets a test. HTTP endpoints, filters,
  repositories, and exception handlers always qualify.
- A pure data holder does not need a test.
- A test name states the behaviour, not the method name.
- An integration test must run on a clean machine. It may not depend on your
  local configuration.

## Error handling

- <!-- Which exception types does this project define? -->
- <!-- What does the API return for a client error, a server error, a timeout? -->
- <!-- What gets logged, and at which level? -->

Review error handling **before** you hand a change over. See
`.agents/procedures/pre-commit-review.md`.

## Commits and branches

| Item | Rule |
|---|---|
| Branch name | `<!-- e.g. feat/<ticket>-<slug> -->` |
| Commit subject | `<!-- e.g. type: short imperative subject -->` |
| Ticket reference | `<!-- required or not; where it goes -->` |

**The agent never commits, pushes, or creates a branch without an explicit request.**

## Code review checklist

- [ ] The change does what the ticket asks, and nothing more.
- [ ] Error paths are handled and tested.
- [ ] No secret, token, or absolute machine path in the diff.
- [ ] New behaviour has a test.
- [ ] Public API changes are documented.
- [ ] `{{LINT_COMMAND}}` and `{{TEST_UNIT_COMMAND}}` pass.
- [ ] A decision worth remembering became an ADR.

## Common traps in this codebase

<!-- Add one entry each time you lose time to something non-obvious.
     Name the symptom, the cause, and the fix. -->
