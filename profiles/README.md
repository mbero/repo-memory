# Profiles

A profile is an **optional rule set** for one technology or one way of working.
Enabling a profile adds a link to section 9 of `AGENTS.md`. The agent reads the
profile only when it works on that subject.

## Why profiles exist

The always-loaded instruction file is a running cost. Copilot and Cursor inline
it into every request. A Kafka rule you read while renaming a variable is waste.

So the core stays small, and a profile carries the specialised rules.

## Available profiles

| Profile | Enable when |
|---|---|
| [`kafka.md`](kafka.md) | The project consumes or publishes Kafka topics |
| [`monolith-extraction.md`](monolith-extraction.md) | The project extracts areas out of a monolith |
| [`spring-boot.md`](spring-boot.md) | The project is a Spring Boot service |
| [`frontend.md`](frontend.md) | The project contains a web frontend |
| [`obsidian.md`](obsidian.md) | The team browses `docs/` in Obsidian |
| [`jira.md`](jira.md) | The team uses Jira, and the agent writes ticket text |

## Enabling

`bootstrap/init.sh` asks which profiles to enable. It records them in
`.agents/manifest.yml` and writes the links between the `PROFILES` markers in
`AGENTS.md`.

To enable one later:

1. Add its name to `profiles:` in `.agents/manifest.yml`.
2. Add a link to it inside the `<!-- PROFILES:START -->` block in `AGENTS.md`.

## Writing a new profile

- One subject per file.
- Rules only. No project facts — those belong in `docs/context/`.
- State the trigger in the first line: *"Read this when you ..."*.
- Keep it under 80 lines. A long profile is a document, not a rule set.
