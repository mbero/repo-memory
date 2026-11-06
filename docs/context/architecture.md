---
title: Architecture
type: context
status: draft
updated: {{TODAY}}
sources: []
tags: [architecture]
---

# Architecture — {{PROJECT_NAME}}

> Record a **choice** in `docs/decisions/`, not here. This file describes the
> result, not the reasoning.

## Style

<!-- One paragraph: layered, hexagonal, event-driven, modular monolith, ... -->

## Boundaries

| Boundary | What crosses it | Contract | Where it is defined |
|---|---|---|---|
| `<!-- name -->` | <!-- data --> | REST / event / SQL | `<!-- file -->` |

## Layers

| Layer | Package | May depend on | Must never depend on |
|---|---|---|---|
| | | | |

## Primary data flow

```text
<!-- ASCII or Mermaid. Show the request from entry point to persistence. -->
```

## Persistence

| Store | What it holds | Owner | Migration tool |
|---|---|---|---|
| | | | |

## Cross-cutting concerns

| Concern | How it is handled | Where |
|---|---|---|
| Error handling | | |
| Logging | | |
| Tracing / correlation id | | |
| Authentication | | |
| Configuration | | |
| Feature flags | | |

## Known architectural debt

| # | Debt | Impact | Recorded in |
|---|---|---|---|
| 1 | | | `docs/todo/...` |

## What could not be verified

<!-- -->
