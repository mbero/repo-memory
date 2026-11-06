---
title: Business rules — <Area>
type: analysis
status: draft
updated: YYYY-MM-DD
sources:
  - <path/to/file.ext:LINE>
tags: []
---

# Business rules — <Area>

> Implementation-agnostic. A reader must be able to reimplement this area on a
> different stack using only this file. Name no class here.

## Domain context

<!-- What this area is responsible for, in business terms. Two paragraphs. -->

## Actors

| Actor | What they do in this area |
|---|---|
| | |

## Rules

| ID | Rule | Source | Confidence |
|---|---|---|---|
| BR-001 | <!-- one sentence, in the active voice --> | `<!-- file:line -->` | confirmed / inferred |
| BR-002 | | | |

> **Confidence matters.** `inferred` means you read the code and guessed the
> intent. A business owner must confirm it.

## Use cases

### UC-001 — <name>

**Trigger:** <!-- -->
**Actor:** <!-- -->
**Preconditions:** <!-- -->

**Main flow:**

1. <!-- -->
2. <!-- -->

**Alternative flows:**

- <!-- -->

**Postconditions:** <!-- -->
**Rules applied:** BR-001, BR-00x

## Validation and constraints

| ID | Constraint | Enforced where | What happens on violation |
|---|---|---|---|
| VC-001 | | `<!-- file:line -->` | |

## Open business questions

| # | Question | Who can answer | Blocks |
|---|---|---|---|
| 1 | | | BR-00x |
