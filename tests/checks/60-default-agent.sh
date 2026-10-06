#!/usr/bin/env bash
#
# AC11 — default-agent agreement.
#
# opencode.json's `default_agent` is the authority. This check asserts that
# README.md's Agents table marks exactly that agent as the default, that
# docs/customization.md names the same value, that the agent's file exists, that
# the agent is not disabled in opencode.json's `agent` map, and — when the
# opencode CLI is present — that `opencode debug agent <name>` resolves; the
# resolution probe is skipped, never failed, when the CLI is absent.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL/skip lines labelled with its stable AC11 token.

echo "== AC11 default-agent agreement =="

# --- authority: opencode.json `default_agent` --------------------------------
cfg_default_agent() {
  awk '
    match($0, /"default_agent"[[:space:]]*:[[:space:]]*"[^"]*"/) {
      s = substr($0, RSTART, RLENGTH)
      sub(/.*"[[:space:]]*:[[:space:]]*"/, "", s)
      sub(/"$/, "", s)
      print s
      exit
    }
  ' "$CFG"
}

cfg_agent="$(cfg_default_agent)"
if [ -n "$cfg_agent" ]; then
  ok "AC11 $CFG declares default_agent '$cfg_agent'"
else
  bad "AC11 $CFG declares no default_agent"
fi

# --- README: the Agents-table row marked "(default)" -------------------------
# The README Mode cell carries the default marker; the agent name is read from
# the same row, so moving the marker to another agent fails the check.
readme_default_agent() {
  awk '
    $0 == "## Agents" { insec = 1; next }
    insec && /^## / { insec = 0 }
    !insec { next }
    /^\|/ {
      n = split($0, a, "|")
      if (n < 4) next
      name = a[2]; mode = a[3]
      gsub(/`/, "", name); gsub(/^[ \t]+|[ \t]+$/, "", name)
      gsub(/^[ \t]+|[ \t]+$/, "", mode)
      if (name != "" && name != "Agent" && name !~ /^-+$/ && tolower(mode) ~ /default/) print name
    }
  ' "$README"
}

readme_agent="$(readme_default_agent)"
readme_count="$(printf '%s\n' "$readme_agent" | grep -c .)"
if [ "$readme_count" -eq 1 ] && [ "$readme_agent" = "$cfg_agent" ]; then
  ok "AC11 $README marks '$readme_agent' as the default agent"
elif [ "$readme_count" -eq 0 ]; then
  bad "AC11 $README does not mark any agent as the default"
elif [ "$readme_count" -gt 1 ]; then
  bad "AC11 $README marks multiple agents as default: $(printf '%s ' $readme_agent)"
else
  bad "AC11 $README marks '$readme_agent' as default but $CFG declares '$cfg_agent'"
fi

# --- docs/customization.md: names the default agent --------------------------
# Take the first backticked token following the phrase "default agent" on any
# line of the surface; the Config table row mentions the phrase without a value
# and is skipped because it has no backticked token after it.
named_default_agent_in() {
  awk '
    {
      i = index(tolower($0), "default agent")
      if (i == 0) next
      rest = substr($0, i + length("default agent"))
      if (match(rest, /`[^`]+`/)) {
        print substr(rest, RSTART + 1, RLENGTH - 2)
        exit
      }
    }
  ' "$1"
}

cust_agent="$(named_default_agent_in "$CUST")"
if [ -z "$cust_agent" ]; then
  bad "AC11 $CUST does not name the default agent"
elif [ "$cust_agent" = "$cfg_agent" ]; then
  ok "AC11 $CUST names '$cust_agent' as the default agent"
else
  bad "AC11 $CUST names '$cust_agent' as default but $CFG declares '$cfg_agent'"
fi

# --- the named agent exists and is enabled -----------------------------------
if [ -f "$AGENT_DIR/$cfg_agent.md" ]; then
  ok "AC11 default agent file $AGENT_DIR/$cfg_agent.md exists"
else
  bad "AC11 default agent '$cfg_agent' has no $AGENT_DIR/$cfg_agent.md"
fi

# opencode.json's top-level `agent` map disables four built-in agents; the
# default agent must not be one of them. The map is parsed by its known shape
# (a 2-space-indented object whose entries are 4-space-indented objects).
agent_disabled_in_cfg() {
  awk -v name="$1" '
    /^  "agent"[[:space:]]*:[[:space:]]*\{/ { inmap = 1; next }
    inmap && /^  \}/ { inmap = 0 }
    !inmap { next }
    $0 ~ ("\"" name "\"[[:space:]]*:[[:space:]]*\\{") { inentry = 1; next }
    inentry && /"disable"[[:space:]]*:[[:space:]]*true/ { print "yes"; exit }
    inentry && /^    \}/ { inentry = 0 }
  ' "$CFG"
}

if [ "$(agent_disabled_in_cfg "$cfg_agent")" = "yes" ]; then
  bad "AC11 default agent '$cfg_agent' is disabled in $CFG's agent map"
else
  ok "AC11 default agent '$cfg_agent' is not disabled in $CFG"
fi

# --- live resolution (optional tool) -----------------------------------------
if [ "$have_opencode" -eq 1 ]; then
  if opencode debug agent "$cfg_agent" >/dev/null 2>&1; then
    ok "AC11 opencode debug agent '$cfg_agent' resolves"
  else
    bad "AC11 opencode debug agent '$cfg_agent' did not resolve"
  fi
else
  skip "AC11 opencode CLI absent; cannot confirm '$cfg_agent' resolves"
fi
