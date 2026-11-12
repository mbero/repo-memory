# Changelog

All notable changes to this template. A project installs a version and can pull
a later one with `bootstrap/sync.sh`.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] — 2026-11-12

Initial public release.

### Added

- `AGENTS.md` as the single canonical instruction file for every agent.
- Optional stub files for GitHub Copilot, Claude Code, Cursor, and Gemini CLI.
- `.agents/procedures/` — six tool-neutral procedures in plain Markdown.
- `.agents/bindings/` — per-tool wrappers that `init.sh` installs on request.
- `docs/` — one folder per question type, with mandatory YAML frontmatter.
- `docs/INDEX.md` — a generated index that an agent reads before the code.
- `docs/context/domain.md` — business rules, each marked confirmed or inferred.
- `docs/decisions/` — Architecture Decision Records with a template and ADR-0001.
- `bootstrap/init.sh` — detects the project facts and installs file by file.
- `bootstrap/check.sh` — verifies placeholders, frontmatter, source paths,
  stale drafts, and the index.
- `bootstrap/sync.sh` — pulls a newer template version into a project.
- `profiles/` — optional rule sets for Kafka, monolith extraction, Obsidian,
  and Jira.
- A GitHub Actions workflow that runs the knowledge-base check.
- MIT license.
