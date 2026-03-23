# ── assemble ──────────────────────────────────────────────────

build_prompt() {
  local char="${STATUSLINE_CFG[prompt.char]:-❯}"
  local sep=" ${DIM}•${RESET} "

  # ── line 1 parts ──
  local parts=()
  local ctx=""
  _statusline_enabled "components.context" && ctx="$(prompt_context)"
  # dir (with context prefix if SSH)
  parts+=("${ctx}$(prompt_dir)")

  # git parts (already •-delimited internally)
  local git_out=""
  git_out="$(prompt_git)"
  [[ -n "$git_out" ]] && parts+=("${git_out}")

  # language + runtime version
  local lang=""
  _statusline_enabled "components.lang" && lang="$(prompt_lang)"
  [[ -n "$lang" ]] && parts+=("${lang}")

  # join line 1
  local line1=""
  for (( i=1; i<=${#parts[@]}; i++ )); do
    (( i > 1 )) && line1+="${sep}"
    line1+="${parts[$i]}"
  done

  # ── commit lines ──
  local commits=""
  commits="$(_git_commits)"

  # ── last line ──
  local last_line=""
  _statusline_enabled "components.venv"      && last_line+="$(prompt_venv)"
  _statusline_enabled "components.jobs"      && last_line+="$(prompt_jobs)"
  _statusline_enabled "components.exit_code" && last_line+="$(prompt_exit_code)"

  PROMPT="
${commits:+${commits}
}${line1}
${last_line}${char} "
}

precmd() { build_prompt }
