# Changelog

All notable changes to this template. A project installs a version and can pull
a later one with `bootstrap/sync.sh`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] — 2026-11-06

First public, vendor-neutral release.

### Added

- `AGENTS.md` as the single canonical instruction file for every agent.
- Stub files for Claude Code, GitHub Copilot, Cursor, and Gemini CLI.
- `.agents/procedures/` — five tool-neutral procedures in plain Markdown.
- `.agents/bindings/` — optional per-tool wrappers.
- `docs/decisions/` — Architecture Decision Records with a template and ADR-0001.
- `docs/context/glossary.md` — one definition per domain term.
- Mandatory YAML frontmatter on every document under `docs/`.
- `{{PLACEHOLDER}}` tokens that a script fills and a check verifies.
- `bootstrap/init.sh`, `bootstrap/sync.sh`, `bootstrap/check.sh`.
- `profiles/` — optional add-ons for Kafka, monolith extraction, Spring Boot,
  frontend work, Obsidian, and Jira.
- A GitHub Actions workflow that runs the knowledge-base check.
- MIT license.

### Changed

- `docs/agents/` split into `docs/context/` (project facts) and
  `docs/sessions/` (handoff log).
- `docs/qa/` renamed to `docs/knowledge/`.
- `docs/confluence/` renamed to `docs/published/`. The template no longer names
  a specific wiki product.
- `AGENTS.md` cut from 408 to about 150 lines. Knowledge moved into `docs/`.
  Copilot and Cursor inline the instruction file on every request, so size is a
  running cost.
- Obsidian wikilinks became an opt-in profile. Standard Markdown links are the default.
- Kafka rules and monolith-extraction goals moved from `AGENTS.md` into `profiles/`.

### Removed

- All references to one specific employer, product line, and ticket system.
- All absolute machine paths.
- The dependency on tool-specific skills in the core template.
