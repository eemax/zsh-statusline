# ── assemble ──────────────────────────────────────────────────

build_prompt() {
  local ctx="" line2=""
  local char="${STATUSLINE_CFG[prompt.char]:-❯}"

  _statusline_enabled "components.context"   && ctx="$(prompt_context)"
  _statusline_enabled "components.venv"      && line2+="$(prompt_venv)"
  _statusline_enabled "components.node"      && line2+="$(prompt_node)"
  _statusline_enabled "components.jobs"      && line2+="$(prompt_jobs)"
  _statusline_enabled "components.exit_code" && line2+="$(prompt_exit_code)"

  PROMPT="
${ctx}$(prompt_dir) $(prompt_git)
${line2}${G}${char}${RESET} "
}

precmd() { build_prompt }
