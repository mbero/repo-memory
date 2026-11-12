#!/usr/bin/env bash
# Pull a newer template version into a project that already uses it.
#
#   /path/to/template/bootstrap/sync.sh /path/to/your/project
#
# It refreshes the files the template owns: the check script, the procedures,
# and the tool bindings that the project installed. It never deletes a file and
# never changes a file the project owns. It reports those for a manual merge.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

[ -n "$TARGET" ] || { echo "usage: bootstrap/sync.sh /path/to/your/project" >&2; exit 2; }
[ -d "$TARGET" ] || { echo "No such directory: $TARGET" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$SRC" != "$TARGET" ] || { echo "Target must differ from the template." >&2; exit 2; }
[ -f "$TARGET/AGENTS.md" ] || { echo "No AGENTS.md in $TARGET. Run bootstrap/init.sh first." >&2; exit 2; }

NEW_VERSION="$(cat "$SRC/.template-version" 2>/dev/null || echo unknown)"
OLD_VERSION="$(cat "$TARGET/.template-version" 2>/dev/null || echo none)"

echo "Template sync"
echo "  installed version: $OLD_VERSION"
echo "  available version: $NEW_VERSION"
echo

refresh() { # refresh SOURCE-RELATIVE TARGET-RELATIVE
  [ -f "$SRC/$1" ] || return 0
  if [ -f "$TARGET/$2" ] && cmp -s "$SRC/$1" "$TARGET/$2"; then return 0; fi
  mkdir -p "$(dirname "$TARGET/$2")"
  cp "$SRC/$1" "$TARGET/$2"
  echo "  updated  $2"
  UPDATED=$((UPDATED+1))
}

# Files the template owns. They hold no project content and no placeholder.
echo "Refreshing template-owned files:"
UPDATED=0
refresh bootstrap/check.sh bootstrap/check.sh
refresh .agents/README.md .agents/README.md
for f in "$SRC"/.agents/procedures/*.md; do
  refresh ".agents/procedures/$(basename "$f")" ".agents/procedures/$(basename "$f")"
done
# A binding folder in the project means the project installed that tool.
if [ -d "$TARGET/.github/prompts" ]; then
  for f in "$SRC"/.agents/bindings/copilot/*.prompt.md; do
    refresh ".agents/bindings/copilot/$(basename "$f")" ".github/prompts/$(basename "$f")"
  done
fi
if [ -d "$TARGET/.claude/commands" ]; then
  for f in "$SRC"/.agents/bindings/claude-code/*.md; do
    [ "$(basename "$f")" = "README.md" ] && continue
    refresh ".agents/bindings/claude-code/$(basename "$f")" ".claude/commands/$(basename "$f")"
  done
fi
if [ -f "$TARGET/.cursor/rules/10-procedures.mdc" ]; then
  refresh .agents/bindings/cursor/10-procedures.mdc .cursor/rules/10-procedures.mdc
fi
[ "$UPDATED" -eq 0 ] && echo "  none"
echo

# Files the project owns. Report, never touch.
# A template file with a placeholder always differs from the filled copy, so
# the report compares only the files that hold no placeholder.
echo "Files the project owns — review these yourself:"
CHANGED=0
while IFS= read -r rel; do
  case "$rel" in docs/analysis/*) [ -d "$TARGET/docs/analysis" ] || continue ;; esac
  if [ ! -f "$TARGET/$rel" ]; then
    echo "  NEW in template   $rel"
    CHANGED=$((CHANGED+1))
  elif ! grep -q '{{[A-Z_]*}}' "$SRC/$rel" && ! cmp -s "$SRC/$rel" "$TARGET/$rel"; then
    echo "  differs           $rel"
    CHANGED=$((CHANGED+1))
  fi
done < <(cd "$SRC" && find docs -type f -name '*.md' | sort)
[ "$CHANGED" -eq 0 ] && echo "  none"
echo

echo "$NEW_VERSION" > "$TARGET/.template-version"
echo "Marked the project as version $NEW_VERSION."
echo "Read CHANGELOG.md in the template, then merge the files listed above."
echo
"$TARGET/bootstrap/check.sh" || true
