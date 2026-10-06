#!/usr/bin/env bash
#
# AC8 — documented-vs-declared permission agreement.
#
# Each agent declares its `edit` and `bash` capability in the frontmatter of
# .opencode/agent/<name>.md. The README's Agents table restates those
# capabilities in prose. This check derives a fixed class for each declaration
# and a fixed class for each documented cell, and fails when they disagree,
# naming the agent and both classes.
#
# The class mapping is intentionally coarse (see tests/README.md): it compares
# capability *classes*, not exact pattern lists, so a genuinely new allow pattern
# inside the same class passes while a relocated capability fails.
#
# Reads only live surfaces (never work/**); sourced by tests/run.sh, so it must
# not call exit. Prints ok/FAIL lines labelled with its stable AC8 token.

echo "== AC8 permission agreement (declaration vs README) =="

# --- declaration class from frontmatter --------------------------------------
# Prints one of: any | tests+work | config+work | work | none
edit_class() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function unq(s)  { gsub(/"/, "", s); return s }
    /^---[ \t]*$/ { if (infm) { infm = 0; inperm = 0; cap = 0 } else { infm = 1 }; next }
    !infm { next }
    /^permission:[ \t]*$/ { inperm = 1; next }
    inperm && /^[^ ]/ { inperm = 0; cap = 0 }
    inperm && /^  edit:/ {
      v = $0; sub(/^  edit:/, "", v); v = trim(v)
      if (v != "") { scalar = v; cap = 0 } else { cap = 1 }
      next
    }
    inperm && cap {
      if ($0 ~ /^  [^ ]/) { cap = 0; next }
      if ($0 ~ /^    /) {
        line = $0
        i = index(line, ":")
        k = unq(trim(substr(line, 1, i - 1)))
        val = unq(trim(substr(line, i + 1)))
        if (k == "*") { if (val == "allow") star_allow = 1 }
        else if (val == "allow") {
          has_any_allow = 1
          if (k == "work/**" || k == "**/work/**") haswork = 1
          if (k ~ /test|spec|e2e|cypress|playwright|integration/) hastest = 1
          if (k == "AGENTS.md" || k == "**/AGENTS.md" || k == "opencode.json" || k == "**/opencode.json" || k == ".gitignore" || k == "**/.gitignore") hasconfig = 1
        }
      }
    }
    END {
      if (scalar == "allow" || star_allow) { print "any"; exit }
      if (scalar == "deny") { print "none"; exit }
      if (!has_any_allow) { print "none"; exit }
      if (haswork && hastest) print "tests+work"
      else if (haswork && hasconfig) print "config+work"
      else if (haswork) print "work"
      else print "none"
    }
  ' "$1"
}

# Prints one of: allow | git-gh | read-only | none
bash_class() {
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function unq(s)  { gsub(/"/, "", s); return s }
    /^---[ \t]*$/ { if (infm) { infm = 0; inperm = 0; cap = 0 } else { infm = 1 }; next }
    !infm { next }
    /^permission:[ \t]*$/ { inperm = 1; next }
    inperm && /^[^ ]/ { inperm = 0; cap = 0 }
    inperm && /^  bash:/ {
      v = $0; sub(/^  bash:/, "", v); v = trim(v)
      if (v != "") { scalar = v; cap = 0 } else { cap = 1 }
      next
    }
    inperm && cap {
      if ($0 ~ /^  [^ ]/) { cap = 0; next }
      if ($0 ~ /^    /) {
        line = $0
        i = index(line, ":")
        k = unq(trim(substr(line, 1, i - 1)))
        val = unq(trim(substr(line, i + 1)))
        if (k == "*") { if (val == "allow") star_allow = 1 }
        else if (val == "allow") {
          has_any_allow = 1
          if (k ~ /^git (add|commit|checkout|switch|push|merge|rebase|reset|restore|tag|rm|mv|stash|cherry-pick)([ *]|$)/) gitwrite = 1
          if (k ~ /^gh /) gitwrite = 1
        }
      }
    }
    END {
      if (scalar == "allow" || star_allow) { print "allow"; exit }
      if (scalar == "deny") { print "none"; exit }
      if (!has_any_allow) { print "none"; exit }
      if (gitwrite) print "git-gh"; else print "read-only"
    }
  ' "$1"
}

# --- documented class from the README Agents table --------------------------
readme_agent_row() {
  # $1 = agent name; prints "<mode>|<edit cell>|<bash cell>" or nothing.
  awk -v name="$1" '
    /^\|/ {
      n = split($0, a, "|")
      if (n < 5) next
      agent = a[2]; gsub(/^[ \t]+|[ \t]+$/, "", agent); gsub(/`/, "", agent)
      if (agent == name) {
        mode = a[3]; edit = a[4]; bash = a[5]
        gsub(/^[ \t]+|[ \t]+$/, "", mode)
        gsub(/^[ \t]+|[ \t]+$/, "", edit)
        gsub(/^[ \t]+|[ \t]+$/, "", bash)
        print mode "|" edit "|" bash
        exit
      }
    }
  ' "$README"
}

readme_agent_names() {
  # Agent names from the `## Agents` table only (not the command/skill tables).
  awk '
    /^## Agents[ \t]*$/ { ina = 1; next }
    ina && /^## / { ina = 0 }
    !ina { next }
    /^\|/ {
      n = split($0, a, "|")
      if (n < 5) next
      name = a[2]; gsub(/^[ \t]+|[ \t]+$/, "", name); gsub(/`/, "", name)
      if (name == "" || name == "Agent" || name ~ /^-+$/) next
      print name
    }
  ' "$README"
}

readme_edit_class() {
  cell="$1"
  [ "$cell" = "none" ] && { echo none; return; }
  case "$cell" in
    *"any source"*) echo any; return ;;
  esac
  case "$cell" in
    *'work/**'*)
      case "$cell" in
        *test*)   echo tests+work;  return ;;
        *config*) echo config+work; return ;;
      esac
      echo work; return ;;
  esac
  echo "unknown"
}

readme_bash_class() {
  cell="$1"
  case "$cell" in
    none)  echo none;  return ;;
    allow) echo allow; return ;;
    read-only*) echo read-only; return ;;
    *'git/gh'*) echo git-gh; return ;;
  esac
  echo "unknown"
}

# Mode cell may carry a parenthetical, e.g. "primary (default)"; the declared
# frontmatter value is the bare mode.
readme_mode() { printf '%s' "$1" | awk '{ print $1 }'; }

# --- compare every agent on disk to its README row --------------------------
mismatches=0
for name in $(agent_names); do
  f="$AGENT_DIR/$name.md"
  [ -f "$f" ] || continue

  dec_mode="$(fm "$f" | awk -F': *' '/^mode:/ { print $2; exit }')"
  dec_edit="$(edit_class "$f")"
  dec_bash="$(bash_class "$f")"

  row="$(readme_agent_row "$name")"
  if [ -z "$row" ]; then
    bad "AC8 $name: declared in frontmatter but absent from README Agents table"
    mismatches=$((mismatches+1))
    continue
  fi

  doc_mode="$(readme_mode "${row%%|*}")"
  rest="${row#*|}"
  doc_edit="$(readme_edit_class "${rest%%|*}")"
  doc_bash="$(readme_bash_class "${rest#*|}")"

  if [ "$dec_mode" = "$doc_mode" ] && [ "$dec_edit" = "$doc_edit" ] && [ "$dec_bash" = "$doc_bash" ]; then
    ok "AC8 $name: mode=$dec_mode edit=$dec_edit bash=$dec_bash"
  else
    bad "AC8 $name disagrees (declared mode=$dec_mode edit=$dec_edit bash=$dec_bash vs README mode=$doc_mode edit=$doc_edit bash=$doc_bash)"
    mismatches=$((mismatches+1))
  fi
done

# Every README Agents-table row must resolve to an on-disk agent (the reverse
# direction; the full inventory membership is AC9's job, but a stale permission
# row here would otherwise let AC8 pass vacuously).
readme_agents=0
for agent in $(readme_agent_names); do
  readme_agents=$((readme_agents+1))
  if [ ! -f "$AGENT_DIR/$agent.md" ]; then
    bad "AC8 README Agents row '$agent' has no .opencode/agent/$agent.md"
    mismatches=$((mismatches+1))
  fi
done

if [ "$readme_agents" -gt 0 ] && [ "$mismatches" -eq 0 ]; then
  ok "AC8 all $readme_agents documented agents agree with their declarations"
fi
