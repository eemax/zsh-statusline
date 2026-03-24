# ── assemble ──────────────────────────────────────────────────

build_prompt() {
  local char="${STATUSLINE_CFG[prompt.char]:-❯}"
  local sep=" ${DIM}•${RESET} "

  # ── line 1 parts ──
  local parts=()
  local ctx=""
  if _statusline_enabled "components.context"; then
    prompt_context; ctx="$REPLY"
  fi
  prompt_dir; parts+=("${ctx}${REPLY}")

  # git parts (already •-delimited internally)
  prompt_git
  [[ -n "$REPLY" ]] && parts+=("$REPLY")

  # language + runtime version
  if _statusline_enabled "components.lang"; then
    prompt_lang
    [[ -n "$REPLY" ]] && parts+=("$REPLY")
  fi

  # join line 1
  local line1="${(pj: ${DIM}•${RESET} :)parts}"

  # ── commit lines ──
  _git_commits; local commits="$REPLY"

  # ── last line ──
  local last_line=""
  if _statusline_enabled "components.venv"; then
    prompt_venv; last_line+="$REPLY"
  fi
  if _statusline_enabled "components.jobs"; then
    prompt_jobs; last_line+="$REPLY"
  fi
  if _statusline_enabled "components.exit_code"; then
    prompt_exit_code; last_line+="$REPLY"
  fi

  PROMPT="
${commits:+${commits}
}${line1}
${last_line}${M}${BOLD}${char}${RESET} "
}

precmd() { build_prompt }
