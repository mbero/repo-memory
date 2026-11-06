---
title: Local setup
type: context
status: draft
updated: {{TODAY}}
sources: []
tags: [setup, local]
---

# Local setup — {{PROJECT_NAME}}

> Load this file when the build fails, the application does not start, or the
> IDE import breaks.

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| {{LANGUAGE_VERSION}} | | |
| | | |

## First run

```bash
# 1. clone and enter
# 2. {{BUILD_COMMAND}}
# 3. {{RUN_COMMAND}}
```

## Configuration

| Variable | Default | Purpose | Secret |
|---|---|---|---|
| | | | yes / no |

Copy the example file and fill it in. Never commit a filled secret.

## IDE setup

<!-- Import style, required plugins, annotation processing, code style file. -->

## Known local traps

> Add an entry every time you lose time to a startup problem. One trap, one
> entry. Name the **symptom**, the **cause**, and the **fix command**.

### Template for a trap

**Symptom:** <!-- the exact error message -->
**Cause:** <!-- why it happens -->
**Fix:**

```bash
# commands
```

**Verify:** <!-- how you know it worked -->

---

<!-- Common categories worth documenting when they bite you:
     - a port already in use by another process
     - credentials that drifted between the container and the application config
     - a database volume initialised with stale data
     - a bind-mount that the container created as a directory instead of a file
     - a stale build artifact that survives a rebuild
-->

## What could not be verified

<!-- -->
