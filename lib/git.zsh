# ── git ───────────────────────────────────────────────────────

_git_repo() {
  git rev-parse --git-dir &>/dev/null
}

_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null \
    || git rev-parse --short HEAD 2>/dev/null
}

_git_worktree() {
  local git_dir common_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ "$git_dir" != "$common_dir" ]]; then
    local name
    name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    echo "${DIM}🌲 ${name}${RESET}"
  fi
}

_git_tracking() {
  local upstream
  upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [[ -z "$upstream" ]]; then
    echo "${Y}🔒 local${RESET}"
  else
    local remote=${upstream%%/*}
    [[ "$remote" != "origin" ]] && echo "${M}📡 ${remote}${RESET}"
  fi
}

_git_ahead_behind() {
  local counts
  counts=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  [[ -z "$counts" ]] && return
  local ahead=${counts%$'\t'*}
  local behind=${counts#*$'\t'}
  local out=""
  (( ahead  > 0 )) && out+="${G}ahead ${ahead}${RESET}"
  (( ahead  > 0 && behind > 0 )) && out+="${DIM} / ${RESET}"
  (( behind > 0 )) && out+="${R}behind ${behind}${RESET}"
  echo "$out"
}

_git_hash_and_time() {
  local hash t now diff age
  hash=$(git rev-parse --short HEAD 2>/dev/null) || return
  t=$(git log -1 --format="%ct" 2>/dev/null)
  now=$(date +%s)
  diff=$(( now - t ))
  if   (( diff < 3600   )); then age="$((diff / 60))m ago"
  elif (( diff < 86400  )); then age="$((diff / 3600))h ago"
  elif (( diff < 604800 )); then age="$((diff / 86400))d ago"
  else                           age="$((diff / 604800))w ago"
  fi
  echo "${DIM}🔖 ${hash} ⏱️  ${age}${RESET}"
}

_git_clean_dirty() {
  local dirty=0

  while IFS= read -r line; do
    case "$line" in
      "1 "*|"2 "*|"u "*|"? "*) (( dirty++ ));;
    esac
  done < <(git status --porcelain=v2 2>/dev/null)

  if (( dirty == 0 )); then
    echo "${G}clean${RESET}"
  else
    local added removed
    read -r added removed < <(git diff --numstat 2>/dev/null \
      | awk '{a+=$1; d+=$2} END {print a+0, d+0}')
    # include staged diff too
    local sa sr
    read -r sa sr < <(git diff --cached --numstat 2>/dev/null \
      | awk '{a+=$1; d+=$2} END {print a+0, d+0}')
    (( added += sa ))
    (( removed += sr ))

    local out="${Y}dirty${RESET}"
    if (( added > 0 || removed > 0 )); then
      out+=" ${DIM}(${RESET}"
      (( added   > 0 )) && out+="${G}+${added}${RESET}"
      (( added   > 0 && removed > 0 )) && out+="${DIM}/${RESET}"
      (( removed > 0 )) && out+="${R}-${removed}${RESET}"
      out+="${DIM})${RESET}"
    fi
    echo "$out"
  fi
}

# ── main git block ────────────────────────────────────────────

prompt_git() {
  _git_repo || return
  _statusline_enabled "components.git" || return

  local branch worktree tracking ahead_behind clean_dirty

  _statusline_enabled "git.branch"       && branch=$(_git_branch)
  _statusline_enabled "git.worktree"     && worktree=$(_git_worktree)
  _statusline_enabled "git.tracking"     && tracking=$(_git_tracking)
  _statusline_enabled "git.ahead_behind" && ahead_behind=$(_git_ahead_behind)
  _statusline_enabled "git.clean_dirty"  && clean_dirty=$(_git_clean_dirty)

  local sep=" ${DIM}•${RESET} "
  local parts=()
  [[ -n "$branch"       ]] && parts+=("${M}${BOLD}${branch}${RESET}")
  [[ -n "$worktree"     ]] && parts+=("${worktree}")
  [[ -n "$tracking"     ]] && parts+=("${tracking}")
  [[ -n "$ahead_behind" ]] && parts+=("${ahead_behind}")
  [[ -n "$clean_dirty"  ]] && parts+=("${clean_dirty}")

  local out=""
  for (( i=1; i<=${#parts[@]}; i++ )); do
    (( i > 1 )) && out+="${sep}"
    out+="${parts[$i]}"
  done
  echo "$out"
}

_git_commits() {
  _git_repo || return
  _statusline_enabled "components.git" || return

  local count=${STATUSLINE_CFG[git.commit_count]:-3}
  local trunc=${STATUSLINE_CFG[git.commit_truncate]:-30}
  (( count == 0 )) && return

  local now hash ts msg age diff display_msg rest over
  now=$(date +%s)

  while IFS= read -r line; do
    hash=${line%% *}
    rest=${line#* }
    ts=${rest%% *}
    msg=${rest#* }

    diff=$(( now - ts ))
    if   (( diff < 3600   )); then age="$((diff / 60))m ago"
    elif (( diff < 86400  )); then age="$((diff / 3600))h ago"
    elif (( diff < 604800 )); then age="$((diff / 86400))d ago"
    else                           age="$((diff / 604800))w ago"
    fi

    if (( ${#msg} > trunc )); then
      over=$(( ${#msg} - trunc ))
      display_msg="[${msg:0:$trunc}...+${over} chars]"
    else
      display_msg="[${msg}]"
    fi

    echo "${DIM}${hash} ${display_msg} ${age}${RESET}"
  done < <(git log --format="%h %ct %s" -"${count}" --reverse 2>/dev/null)
}
