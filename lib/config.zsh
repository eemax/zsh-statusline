# ── config loader ─────────────────────────────────────────────
# Minimal TOML reader — supports `key = value` lines only
# (booleans and quoted strings). Sections are used as prefixes.

typeset -gA STATUSLINE_CFG

_statusline_load_config() {
  local cfg_file="${STATUSLINE_DIR}/config.toml"
  [[ -f "$cfg_file" ]] || return

  local section="" key val
  while IFS= read -r line; do
    # strip comments and whitespace
    line="${line%%#*}"
    [[ -z "${line// /}" ]] && continue

    # section header
    if [[ "$line" =~ '^\[([a-z_]+)\]' ]]; then
      section="${match[1]}"
      continue
    fi

    # key = value
    if [[ "$line" =~ '^[[:space:]]*([a-z_]+)[[:space:]]*=[[:space:]]*(.+)' ]]; then
      key="${match[1]}"
      val="${match[2]}"
      # strip surrounding quotes
      val="${val%\"}"
      val="${val#\"}"
      # trim leading/trailing whitespace
      val="${val#"${val%%[! ]*}"}"
      val="${val%"${val##*[! ]}"}"
      STATUSLINE_CFG[${section}.${key}]="$val"
    fi
  done < "$cfg_file"
}

# Helper: check if a config key is enabled (defaults to true)
_statusline_enabled() {
  local val="${STATUSLINE_CFG[$1]:-true}"
  [[ "$val" == "true" ]]
}
