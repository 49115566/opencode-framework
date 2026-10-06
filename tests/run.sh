#!/usr/bin/env bash
#
# Canonical entry point for the framework's committed test suite.
#
# Usage: bash tests/run.sh [repo-root]
#   repo-root defaults to the git top level, is cd'd into, and is the root every
#   check reads its live surfaces from. The optional argument lets the mutation
#   self-check (tests/mutation.sh) point the suite at a copy.
#
# Exit:  0 = every executed assertion passed (skips do not fail)
#        1 = one or more assertions failed
#        2 = setup error (not a git repo, cannot cd, cannot locate checks)
#
# The suite is read-only against the repository and never reads work/**.
# It is provider-neutral: the hosted CI wrapper is .github/workflows/ci.yml.

set -u

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || {
  echo "setup error: cannot locate the tests directory" >&2
  exit 2
}

if [ "${1:-}" != "" ]; then
  ROOT="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "setup error: not a git repository; pass a repo root" >&2
    exit 2
  }
fi
cd "$ROOT" || { echo "setup error: cannot cd to $ROOT" >&2; exit 2; }
ROOT="$(pwd)"

# shellcheck source=tests/lib.sh
. "$TESTS_DIR/lib.sh"

# Source every check in filename order, in this one process, so the counters
# accumulated by lib.sh are shared across all of them. Adding a check is adding
# a file under tests/checks/; run.sh never needs editing.
shopt -s nullglob
checks=("$TESTS_DIR"/checks/*.sh)
shopt -u nullglob
if [ "${#checks[@]}" -gt 0 ]; then
  for c in "${checks[@]}"; do
    # shellcheck source=/dev/null
    . "$c"
  done
fi

printf '\nTOTAL: %s passed, %s failed, %s skipped\n' "$pass" "$fail" "$skip"
[ "$fail" -eq 0 ]
