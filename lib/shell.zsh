# ── shell components ──────────────────────────────────────────
# All functions set REPLY instead of echo to avoid subshell forks.

prompt_exit_code() {
  REPLY="%(?..${R}❌ %?${RESET} )"
}

prompt_dir() {
  REPLY="${C}${BOLD}%(4~|%-1~/…/%2~|%~)${RESET}"
}

prompt_context() {
  REPLY=""
  [[ -n "$SSH_CONNECTION" ]] && REPLY="${DIM}🔐 %n@%m${RESET} "
}

prompt_venv() {
  REPLY=""
  [[ -n "$VIRTUAL_ENV" ]] && REPLY="${DIM}🐍 ${VIRTUAL_ENV##*/}${RESET} "
}

typeset -g _LANG_CACHE_PWD="" _LANG_CACHE_VAL=""

prompt_lang() {
  REPLY=""

  # return cached result if still in same directory
  if [[ "$PWD" == "$_LANG_CACHE_PWD" ]]; then
    REPLY="$_LANG_CACHE_VAL"
    return
  fi
  _LANG_CACHE_PWD="$PWD"

  local lang="" ver=""

  if [[ -f package.json ]] || [[ -f .nvmrc ]]; then
    lang="node"
    ver=$(node -v 2>/dev/null) && ver="${ver#v}"
  elif [[ -f Cargo.toml ]]; then
    lang="rust"
    ver=$(cargo --version 2>/dev/null) && ver="${ver#cargo }"
  elif [[ -f pyproject.toml ]]; then
    lang="python"
    ver=$(python3 --version 2>/dev/null) && ver="${ver#Python }"
  elif [[ -f go.mod ]]; then
    lang="go"
    ver=$(go version 2>/dev/null) && ver="${ver#go version go}" && ver="${ver%% *}"
  elif [[ -f mix.exs ]]; then
    lang="elixir"
    ver=$(elixir --version 2>/dev/null | grep 'Elixir' | sed 's/.*Elixir //')
  elif [[ -f Gemfile ]]; then
    lang="ruby"
    ver=$(ruby -v 2>/dev/null) && ver="${ver#ruby }" && ver="${ver%% *}"
  fi

  if [[ -n "$lang" && -n "$ver" ]]; then
    REPLY="${DIM}${lang} ${ver}${RESET}"
  elif [[ -n "$lang" ]]; then
    REPLY="${DIM}${lang}${RESET}"
  fi

  _LANG_CACHE_VAL="$REPLY"
}

prompt_jobs() {
  REPLY="%(1j.${Y}⚙️ %j${RESET} .)"
}
