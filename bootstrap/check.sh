#!/usr/bin/env bash
# Knowledge base health check.
# Run from the project root:  bootstrap/check.sh
# Exit 0 = healthy, 1 = at least one problem found.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAIL=0
WARN=0

red()  { printf '\033[31m%s\033[0m\n' "$*"; }
yel()  { printf '\033[33m%s\033[0m\n' "$*"; }
grn()  { printf '\033[32m%s\033[0m\n' "$*"; }

fail() { red "FAIL  $*"; FAIL=$((FAIL+1)); }
warn() { yel "WARN  $*"; WARN=$((WARN+1)); }

# Files the checks ignore: the installer itself, template skeletons, and VCS data.
is_excluded() {
  case "$1" in
    ./.git/*|./bootstrap/*|*/_template/*|*/_template.md) return 0 ;;
    *) return 1 ;;
  esac
}

md_files() {
  find . -type f -name '*.md' -not -path './.git/*' | sort
}

to_epoch() {
  # Accepts YYYY-MM-DD. Works on both BSD (macOS) and GNU date.
  date -j -f "%Y-%m-%d" "$1" "+%s" 2>/dev/null || date -d "$1" "+%s" 2>/dev/null
}

echo "Knowledge base check — $ROOT"
echo

# ---------------------------------------------------------------- 1. placeholders
if [ -f .template-source ]; then
  echo "[1/5] Unfilled placeholders — skipped (this is the template repository)"
else
echo "[1/5] Unfilled placeholders"
while IFS= read -r f; do
  is_excluded "$f" && continue
  hits=$(grep -oE '\{\{[A-Z_]+\}\}' "$f" 2>/dev/null | sort -u | tr '\n' ' ')
  [ -n "$hits" ] && fail "$f — $hits"
done < <(find . -type f \( -name '*.md' -o -name '*.yml' -o -name '*.mdc' \) -not -path './.git/*')
fi

# ---------------------------------------------------------------- 2. absolute paths
echo "[2/5] Absolute machine paths"
while IFS= read -r f; do
  is_excluded "$f" && continue
  if grep -nE '(/Users/[A-Za-z0-9._-]+/|/home/[A-Za-z0-9._-]+/|[A-Z]:\\Users\\)' "$f" >/dev/null 2>&1; then
    line=$(grep -nE '(/Users/[A-Za-z0-9._-]+/|/home/[A-Za-z0-9._-]+/|[A-Z]:\\Users\\)' "$f" | head -1)
    fail "$f:$line"
  fi
done < <(md_files)

# ---------------------------------------------------------------- 3. frontmatter
echo "[3/5] Frontmatter in docs/"
VALID_TYPES="context decision knowledge lesson todo published analysis"
while IFS= read -r f; do
  case "$f" in ./docs/*) ;; *) continue ;; esac
  [ "$(head -1 "$f")" = "---" ] || { fail "$f — no frontmatter block"; continue; }
  fm=$(sed -n '2,/^---$/p' "$f")
  for key in title type status updated sources; do
    echo "$fm" | grep -qE "^${key}:" || fail "$f — frontmatter misses '${key}'"
  done
  t=$(echo "$fm" | grep -E '^type:' | head -1 | sed 's/^type:[[:space:]]*//')
  case " $VALID_TYPES " in *" $t "*) ;; *) fail "$f — unknown type '$t'" ;; esac
  s=$(echo "$fm" | grep -E '^status:' | head -1 | sed 's/^status:[[:space:]]*//')
  case "$s" in draft|current|superseded) ;; *) fail "$f — unknown status '$s'" ;; esac
done < <(md_files)

# ---------------------------------------------------------------- 4. stale drafts
echo "[4/5] Stale drafts (status: draft, older than 90 days)"
NOW=$(date "+%s")
while IFS= read -r f; do
  case "$f" in ./docs/*) ;; *) continue ;; esac
  is_excluded "$f" && continue
  fm=$(sed -n '2,/^---$/p' "$f")
  echo "$fm" | grep -qE '^status:[[:space:]]*draft' || continue
  d=$(echo "$fm" | grep -E '^updated:' | head -1 | sed 's/^updated:[[:space:]]*//' | tr -d '"')
  ep=$(to_epoch "$d") || continue
  [ -z "${ep:-}" ] && continue
  age=$(( (NOW - ep) / 86400 ))
  [ "$age" -gt 90 ] && warn "$f — draft for $age days"
done < <(md_files)

# ---------------------------------------------------------------- 5. ADR index
echo "[5/5] ADR index"
if [ -f docs/decisions/README.md ]; then
  for adr in docs/decisions/[0-9][0-9][0-9][0-9]-*.md; do
    [ -e "$adr" ] || continue
    base=$(basename "$adr")
    grep -q "$base" docs/decisions/README.md || fail "docs/decisions/README.md — no index row for $base"
  done
fi

echo
if [ "$FAIL" -gt 0 ]; then
  red "$FAIL problem(s), $WARN warning(s)."
  exit 1
fi
grn "Healthy. $WARN warning(s)."
exit 0
