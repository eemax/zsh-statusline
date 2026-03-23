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

prompt_lang() {
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

  [[ -z "$lang" ]] && return

  if [[ -n "$ver" ]]; then
    echo "${DIM}${lang} ${ver}${RESET}"
  else
    echo "${DIM}${lang}${RESET}"
  fi
}

prompt_jobs() {
  echo "%(1j.${Y}⚙️ %j${RESET} .)"
}
