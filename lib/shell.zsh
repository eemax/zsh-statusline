# ── shell components ──────────────────────────────────────────

prompt_exit_code() {
  echo "%(?..${R}❌ %?${RESET} )"
}

prompt_dir() {
  echo "${C}${BOLD}%(4~|%-1~/…/%2~|%~)${RESET}"
}

prompt_context() {
  [[ -n "$SSH_CONNECTION" ]] && echo "${DIM}🔐 %n@%m${RESET} "
}

prompt_venv() {
  [[ -n "$VIRTUAL_ENV" ]] && echo "${DIM}🐍 $(basename $VIRTUAL_ENV)${RESET} "
}

prompt_node() {
  if [[ -f package.json ]] || [[ -f .nvmrc ]]; then
    local ver
    ver=$(node -v 2>/dev/null) && echo "${DIM}⬡ ${ver#v}${RESET} "
  fi
}

prompt_jobs() {
  echo "%(1j.${Y}⚙️ %j${RESET} .)"
}
