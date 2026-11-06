---
title: Dependencies — <Area>
type: analysis
status: draft
updated: YYYY-MM-DD
sources:
  - <path/to/file.ext:LINE>
tags: []
---

# Dependencies — <Area>

## Inbound — who calls this area

| Caller | Entry point | Protocol | Frequency | Breaks if changed |
|---|---|---|---|---|
| | `<!-- class or endpoint -->` | | | yes / no |

## Outbound — what this area calls

| Target | How | Protocol | Failure mode | Timeout / retry |
|---|---|---|---|---|
| | `<!-- class or client -->` | | | |

## Shared data dependencies

| Store / table | Read | Write | Other writers |
|---|---|---|---|
| | yes/no | yes/no | |

> A second writer to the same table is the hardest dependency to remove. List
> every one you find.

## Events and messages

| Direction | Channel / topic | Payload | Producer | Consumers |
|---|---|---|---|---|
| in / out | | | | |

## Flow diagram

```text
<!-- ASCII or Mermaid. Show the area in the middle, inbound left, outbound right. -->
```

## Implications for a separate service

| Dependency | Problem if the area moves out | Possible resolution |
|---|---|---|
| | | |

## What could not be verified

<!-- -->
