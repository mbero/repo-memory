---
title: Data model — <Area>
type: analysis
status: draft
updated: YYYY-MM-DD
sources:
  - <path/to/schema-or-entity:LINE>
tags: []
---

# Data model — <Area>

## Entities this area owns

### <EntityName>

| Field | Type | Nullable | Meaning | Source |
|---|---|---|---|---|
| | | | | `<!-- file:line -->` |

**Volume:** <!-- row count and growth rate, with the date measured -->
**Primary key:** <!-- -->
**Indexes that matter:** <!-- -->

## Data that stays where it is

| Entity | Why it does not move | Who owns it |
|---|---|---|
| | | |

## Shared data, read only

| Entity | Owner | How this area reads it | Staleness tolerated |
|---|---|---|---|
| | | | |

## Proposed target schema

```sql
-- Only when the area moves to a new store.
```

## Migration strategy

| Step | Action | Rollback | Downtime |
|---|---|---|---|
| 1 | | | |

**Consistency during migration:** <!-- dual write, backfill, cutover, ... -->
**How you verify the data matches:** <!-- the exact query or tool -->

## What could not be verified

<!-- -->
