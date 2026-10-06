#!/usr/bin/env bash
#
# AC12 — external pin agreement.
#
# The Playwright MCP dependency is pinned in three live surfaces: opencode.json,
# docs/customization.md, and the browser-verification skill. This check extracts
# every `@playwright/mcp@<spec>` occurrence from all three, asserts each surface
# names a pin, that the surfaces agree on exactly one distinct spec, that the
# spec is an exact `x.y.z` semver (no floating `latest`/`*`/`^`/`~` tag), and —
# when npm and the registry are reachable — that the exact version is published.
# The version value itself is read from the surfaces, so bumping the pin
# everywhere at once still passes; only a floating tag or a divergent copy fails.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL/skip lines labelled with its stable AC12 token.

echo "== AC12 external pin agreement =="

PIN_SKILL="$SKILL_DIR/browser-verification/SKILL.md"

# Emit the spec text that follows each `@playwright/mcp@` in a file, one per
# line: stop at a quote, whitespace, or comma so JSON and array literals both
# parse. A floating tag (`latest`, `*`, `^1.2.3`) is emitted verbatim so the
# exact-semver assertion below can reject it.
pin_specs_from() {
  grep -oE '@playwright/mcp@[^"[:space:],]+' "$1" 2>/dev/null \
    | sed 's|^@playwright/mcp@||'
}

cfg_specs="$(pin_specs_from "$CFG" | sort -u)"
cust_specs="$(pin_specs_from "$CUST" | sort -u)"
skill_specs="$(pin_specs_from "$PIN_SKILL" | sort -u)"

# (i) Each surface must name at least one pin, else a surface was silently
# dropped from the agreement.
if [ -n "$cfg_specs" ]; then
  ok "AC12 $CFG names a @playwright/mcp pin"
else
  bad "AC12 $CFG names no @playwright/mcp pin"
fi
if [ -n "$cust_specs" ]; then
  ok "AC12 $CUST names a @playwright/mcp pin"
else
  bad "AC12 $CUST names no @playwright/mcp pin"
fi
if [ -n "$skill_specs" ]; then
  ok "AC12 $PIN_SKILL names a @playwright/mcp pin"
else
  bad "AC12 $PIN_SKILL names no @playwright/mcp pin"
fi

# (ii) The three surfaces must agree on exactly one distinct spec.
all_specs="$( { pin_specs_from "$CFG"; pin_specs_from "$CUST"; pin_specs_from "$PIN_SKILL"; } | sort -u )"
n_specs="$(printf '%s\n' "$all_specs" | grep -c .)"

if [ "$n_specs" -eq 1 ]; then
  agreed="$(printf '%s\n' "$all_specs" | grep . | head -n1)"
  ok "AC12 all three surfaces agree on @playwright/mcp@$agreed"
elif [ "$n_specs" -eq 0 ]; then
  bad "AC12 no @playwright/mcp pin found on any surface"
else
  bad "AC12 surfaces disagree on the pin: $(printf '%s ' $all_specs)"
fi

# (iii) The agreed spec must be an exact x.y.z semver, never a floating tag.
# Run this over every distinct spec seen so a stray floating tag is named even
# when it masks a valid pin.
if [ "$n_specs" -gt 0 ]; then
  for s in $all_specs; do
    if printf '%s\n' "$s" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      ok "AC12 '$s' is an exact semver pin"
    else
      bad "AC12 '$s' is not an exact x.y.z semver pin (floating tag)"
    fi
  done
fi

# Explicit floating-token guard, so `latest`/`*`/`^`/`~` on any surface fails
# even if it appears alongside a valid exact pin.
float_hits="$(grep -nE '@playwright/mcp@(latest|\*|\^|~)' "$CFG" "$CUST" "$PIN_SKILL" 2>/dev/null)"
if [ -z "$float_hits" ]; then
  ok "AC12 no floating latest/*/^/~ pin token on any surface"
else
  bad "AC12 floating pin token found: $(printf '%s ' $float_hits)"
fi

# (iv) Best-effort: confirm the exact pinned version is published. Registry
# absence or an unreachable registry is a skip, never a failure.
if [ "$have_npm" -eq 1 ] && [ "$have_net" -eq 1 ] && [ "$n_specs" -eq 1 ]; then
  if npm view "@playwright/mcp@$agreed" version >/dev/null 2>&1; then
    ok "AC12 @playwright/mcp@$agreed is published"
  else
    bad "AC12 @playwright/mcp@$agreed is not published"
  fi
else
  skip "AC12 npm/registry unavailable; cannot confirm the pin is published"
fi
