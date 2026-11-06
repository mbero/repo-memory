#!/usr/bin/env bash
# Pull a newer template version into a project that already uses it.
#
#   /path/to/template/bootstrap/sync.sh /path/to/your/project
#
# It never overwrites a file the project owns. It refreshes the structural
# files, and it reports every difference it leaves for you to merge.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"

[ -z "$TARGET" ] && { echo "usage: bootstrap/sync.sh /path/to/your/project" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"
[ "$SRC" = "$TARGET" ] && { echo "Target must differ from the template." >&2; exit 2; }

NEW_VERSION="$(cat "$SRC/.template-version" 2>/dev/null || echo unknown)"
OLD_VERSION="$(cat "$TARGET/.template-version" 2>/dev/null || echo none)"

echo "Template sync"
echo "  installed version: $OLD_VERSION"
echo "  available version: $NEW_VERSION"
echo

if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  echo "Already up to date. Nothing to do."
  exit 0
fi

# Files the template owns. Safe to refresh: they hold no project content.
REFRESH="bootstrap/check.sh bootstrap/init.sh bootstrap/sync.sh bootstrap/placeholders.yml \
.agents/README.md .agents/bindings .agents/procedures"

echo "Refreshing template-owned files:"
for item in $REFRESH; do
  if [ -e "$SRC/$item" ]; then
    mkdir -p "$(dirname "$TARGET/$item")"
    rm -rf "${TARGET:?}/$item"
    cp -R "$SRC/$item" "$TARGET/$item"
    echo "  updated  $item"
  fi
done
echo

# Files the project owns. Report, never touch.
echo "Files the project owns — review these yourself:"
CHANGED=0
while IFS= read -r rel; do
  [ -f "$TARGET/$rel" ] || { echo "  NEW in template   $rel"; CHANGED=$((CHANGED+1)); continue; }
  if ! diff -q "$SRC/$rel" "$TARGET/$rel" >/dev/null 2>&1; then
    echo "  differs           $rel"
    CHANGED=$((CHANGED+1))
  fi
done < <(cd "$SRC" && find AGENTS.md CLAUDE.md GEMINI.md .github .cursor docs profiles \
          -type f -name '*.md' -o -type f -name '*.mdc' 2>/dev/null | sort)

[ "$CHANGED" -eq 0 ] && echo "  none"
echo

echo "$NEW_VERSION" > "$TARGET/.template-version"
echo "Marked the project as version $NEW_VERSION."
echo "Read the template CHANGELOG.md for what changed, then merge the files listed above."
echo
"$TARGET/bootstrap/check.sh" || true
