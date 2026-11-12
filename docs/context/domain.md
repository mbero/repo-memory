---
title: Business domain
type: context
status: draft
updated: {{TODAY}}
sources: []
tags: [domain, business]
---

# Business domain — {{PROJECT_NAME}}

> The business truth of the project, in business words. Name no class here.
> A reader who never saw the code must understand this file.

## What the business needs from this project

<!-- Two or three sentences. Who gets value, and what stops when the project stops? -->

## Actors

| Actor | Goal | How the actor reaches the project |
|---|---|---|
| `<!-- role or system -->` | <!-- what the actor wants --> | <!-- screen, API, file, event --> |

## Business processes

| Process | Trigger | Outcome | Detail |
|---|---|---|---|
| `<!-- name -->` | <!-- what starts it --> | <!-- what is true at the end --> | `<!-- docs/knowledge/... -->` |

## Business rules

| ID | Rule | Confidence | Source | Confirmed by |
|---|---|---|---|---|
| BR-001 | <!-- one sentence, active voice --> | confirmed / inferred | `<!-- file:line or document -->` | <!-- person or role, date --> |

> **`inferred`** means an agent read the rule out of the code. A business owner
> did not confirm it. Change it to `confirmed` only when a person confirms it.

## Constraints from outside the code

| Constraint | Origin | Effect on the project |
|---|---|---|
| <!-- legal, contractual, operational --> | <!-- who set it --> | <!-- what it forbids or forces --> |

## Open business questions

| # | Question | Who can answer | Blocks |
|---|---|---|---|
| 1 | | | |

## What could not be verified

<!-- Name every rule above that rests on a guess, and why. -->
