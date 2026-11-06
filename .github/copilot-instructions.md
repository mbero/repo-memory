# Copilot instructions

**Read [`../AGENTS.md`](../AGENTS.md) first.** It is the canonical instruction
file for this repository. This file repeats only the rules that Copilot must see
inline, because Copilot gives this path a higher precedence than `AGENTS.md`.

## Non-negotiable

1. Never commit, push, or create a branch without an explicit request.
2. Never state a fact you did not verify. Cite `file:line`, a config key, or the exact log line.
3. Never invent a path, a class name, or a configuration key. Read it first.
4. Write documentation in {{DOC_LANGUAGE}}.
5. Use repository-relative paths, never an absolute path of one machine.

## Before you answer a technical question

1. List the files in `docs/knowledge/`, `docs/decisions/`, and `docs/context/`.
2. Read the matching document and use it as the primary source.
3. Explore the code only when no document answers the question.

## Path-specific rules

- `docs/**` — see [`instructions/docs.instructions.md`](instructions/docs.instructions.md)
- source code — see [`instructions/code.instructions.md`](instructions/code.instructions.md)
