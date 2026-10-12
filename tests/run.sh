#!/usr/bin/env bash
#
# Canonical entry point for the framework's committed test suite.
#
# Usage: bash tests/run.sh [repo-root]
#   repo-root defaults to the git top level, is cd'd into, and is the root every
#   check reads its live surfaces from. The optional argument lets the mutation
#   self-check (tests/mutation.sh) point the suite at a copy.
#
# FRAMEWORK_TEST_AREAS selects a subset: a comma- or whitespace-separated list of
# area selectors (a tests/checks/*.sh stem, e.g. 10-readiness). Unset means the
# unchanged full run. Set-but-empty (or whitespace-only), an unknown selector, or
# an ambiguous prefix is a setup error (exit 2) and sources no check.
#
# Exit:  0 = every executed assertion passed (skips do not fail)
#        1 = one or more assertions failed
#        2 = setup error (not a git repo, cannot cd, cannot locate checks,
#            bad FRAMEWORK_TEST_AREAS)
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

# FRAMEWORK_TEST_AREAS: unset => the unchanged full run; set => resolve the
# selector list to area names, dedupe, and keep the selected checks in filename
# order. Any resolution failure exits 2 before a check is sourced.
chosen=()
if [ "${FRAMEWORK_TEST_AREAS+set}" = "set" ]; then
  area_names=""
  if [ "${#checks[@]}" -gt 0 ]; then
    for c in "${checks[@]}"; do
      area_names="${area_names}$(area_name_of "$c")
"
    done
  fi
  # Normalize commas to spaces; word splitting then handles comma/whitespace and
  # drops empty tokens. `set -f` keeps a selector's glob characters literal.
  tokens="$(printf '%s' "$FRAMEWORK_TEST_AREAS" | tr ',' ' ')"
  selected=()
  saw_token=0
  set -f
  for tok in $tokens; do
    saw_token=1
    resolved="$(resolve_area_selector "$tok" "$area_names")"
    rc=$?
    case "$rc" in
      0)
        dup=0
        if [ "${#selected[@]}" -gt 0 ]; then
          for s in "${selected[@]}"; do
            [ "$s" = "$resolved" ] && { dup=1; break; }
          done
        fi
        [ "$dup" -eq 1 ] || selected[${#selected[@]}]="$resolved"
        ;;
      4)
        printf 'setup error: ambiguous area selector %s matches: %s\n' \
          "'$tok'" "$(printf '%s ' $resolved)" >&2
        set +f
        exit 2
        ;;
      *)
        echo "setup error: unknown area selector '$tok'" >&2
        set +f
        exit 2
        ;;
    esac
  done
  set +f
  if [ "$saw_token" -eq 0 ]; then
    echo "setup error: FRAMEWORK_TEST_AREAS names no area (empty selection)" >&2
    exit 2
  fi
  for c in ${checks[@]+"${checks[@]}"}; do
    if [ "${#selected[@]}" -gt 0 ]; then
      area="$(area_name_of "$c")"
      for s in "${selected[@]}"; do
        if [ "$area" = "$s" ]; then
          chosen[${#chosen[@]}]="$c"
          break
        fi
      done
    fi
  done
elif [ "${#checks[@]}" -gt 0 ]; then
  chosen=("${checks[@]}")
fi

# Probe only the optional tools the selected checks actually reference, so a
# subset (or a full run) never pays for probes it does not use. Must run before
# the checks are sourced, because they read the have_* variables.
if [ "${#chosen[@]}" -gt 0 ]; then
  probe_needed_by "${chosen[@]}"
fi

if [ "${#chosen[@]}" -gt 0 ]; then
  for c in "${chosen[@]}"; do
    # shellcheck source=/dev/null
    . "$c"
  done
fi

printf '\nTOTAL: %s passed, %s failed, %s skipped\n' "$pass" "$fail" "$skip"
[ "$fail" -eq 0 ]
