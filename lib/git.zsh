# ── git ───────────────────────────────────────────────────────
# All functions set REPLY instead of echo to avoid subshell forks.
# Cache layer: _git_cache_init runs shared git commands once per render.

typeset -g _GIT_DIR="" _GIT_COMMON_DIR="" _GIT_HEAD_SHORT=""

_git_cache_init() {
  _GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || return 1
  _GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
  _GIT_HEAD_SHORT=$(git rev-parse --short HEAD 2>/dev/null)
}

_git_branch() {
  REPLY=$(git symbolic-ref --short HEAD 2>/dev/null) \
    || REPLY="$_GIT_HEAD_SHORT"
}

_git_worktree() {
  REPLY=""
  if [[ "$_GIT_DIR" != "$_GIT_COMMON_DIR" ]]; then
    REPLY="${M}🌲${RESET}"
  fi
}

_git_tracking() {
  REPLY=""
  local upstream
  upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [[ -z "$upstream" ]]; then
    REPLY="${DIM}local${RESET}"
  else
    local remote=${upstream%%/*}
    [[ "$remote" != "origin" ]] && REPLY="${M}📡 ${remote}${RESET}"
  fi
}

_git_ahead_behind() {
  REPLY=""
  local counts
  counts=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  [[ -z "$counts" ]] && return
  local ahead=${counts%$'\t'*}
  local behind=${counts#*$'\t'}
  local out=""
  (( ahead  > 0 )) && out+="${G}ahead ${ahead}${RESET}"
  (( ahead  > 0 && behind > 0 )) && out+="${DIM} / ${RESET}"
  (( behind > 0 )) && out+="${R}behind ${behind}${RESET}"
  REPLY="$out"
}

_git_clean_dirty() {
  REPLY=""
  local dirty=0 f_new=0 f_mod=0 f_del=0 f_ren=0 f_unt=0

  while IFS= read -r line; do
    case "$line" in
      "1 "*)
        (( dirty++ ))
        local xy=${line:2:2}
        [[ "$xy" == A* || "$xy" == *A ]] && (( f_new++ ))
        [[ "$xy" == M* || "$xy" == *M ]] && (( f_mod++ ))
        [[ "$xy" == D* || "$xy" == *D ]] && (( f_del++ ))
        ;;
      "2 "*)
        (( dirty++ ))
        (( f_ren++ ))
        ;;
      "u "*)
        (( dirty++ ))
        ;;
      "? "*)
        (( dirty++ ))
        (( f_unt++ ))
        ;;
    esac
  done < <(git status --porcelain=v2 2>/dev/null)

  if (( dirty == 0 )); then
    REPLY="${G}clean${RESET}"
  else
    local added=0 removed=0 a d
    while IFS=$'\t' read -r a d _rest; do
      [[ "$a" == "-" ]] && continue
      (( added += a, removed += d ))
    done < <(git diff HEAD --numstat 2>/dev/null)

    local out="${Y}dirty${RESET}"
    (( f_new > 0 )) && out+=" ${G}new${DIM}(${RESET}${G}${f_new}${RESET}${DIM})${RESET}"
    (( f_mod > 0 )) && out+=" ${Y}m${DIM}(${RESET}${Y}${f_mod}${RESET}${DIM})${RESET}"
    (( f_unt > 0 )) && out+=" ${C}u${DIM}(${RESET}${C}${f_unt}${RESET}${DIM})${RESET}"
    if (( f_del > 0 || f_ren > 0 )); then
      out+=" ${R}d${DIM}/${RESET}${Y}r${DIM}(${RESET}"
      out+="${R}${f_del}${RESET}${DIM}/${RESET}${Y}${f_ren}${RESET}"
      out+="${DIM})${RESET}"
    fi
    if (( added > 0 || removed > 0 )); then
      out+=" ${DIM}diff(${RESET}"
      (( added   > 0 )) && out+="${G}+${added}${RESET}"
      (( added   > 0 && removed > 0 )) && out+="${DIM}/${RESET}"
      (( removed > 0 )) && out+="${R}-${removed}${RESET}"
      out+="${DIM})${RESET}"
    fi
    REPLY="$out"
  fi
}

# ── main git block ────────────────────────────────────────────

prompt_git() {
  REPLY=""
  _git_cache_init || return
  _statusline_enabled "components.git" || return

  local branch="" worktree="" tracking="" ahead_behind="" clean_dirty=""

  if _statusline_enabled "git.branch"; then
    _git_branch; branch="$REPLY"
  fi
  if _statusline_enabled "git.worktree"; then
    _git_worktree; worktree="$REPLY"
  fi
  if _statusline_enabled "git.tracking"; then
    _git_tracking; tracking="$REPLY"
  fi
  if _statusline_enabled "git.ahead_behind"; then
    _git_ahead_behind; ahead_behind="$REPLY"
  fi
  if _statusline_enabled "git.clean_dirty"; then
    _git_clean_dirty; clean_dirty="$REPLY"
  fi

  local sep=" ${DIM}•${RESET} "
  # combine branch + tracking into one section (no dot separator)
  local branch_section="${M}${branch}${RESET}"
  [[ -n "$tracking" ]] && branch_section+=" ${tracking}"
  [[ -n "$worktree" ]] && branch_section+=" ${worktree}"

  local parts=()
  [[ -n "$branch"       ]] && parts+=("${branch_section}")
  [[ -n "$ahead_behind" ]] && parts+=("${ahead_behind}")
  [[ -n "$clean_dirty"  ]] && parts+=("${clean_dirty}")

  REPLY="${(pj: ${DIM}•${RESET} :)parts}"
}

_git_commits() {
  REPLY=""
  [[ -z "$_GIT_DIR" ]] && return
  _statusline_enabled "components.git" || return

  local count=${STATUSLINE_CFG[git.commit_count]:-3}
  local trunc=${STATUSLINE_CFG[git.commit_truncate]:-30}
  (( count == 0 )) && return

  local now=$EPOCHSECONDS
  local hash ts msg age diff display_msg rest over
  local lines=""

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

    lines+="${DIM}${hash} ${display_msg} ${age}${RESET}
"
  done < <(git log --format="%h %ct %s" -"${count}" --reverse 2>/dev/null)

  # remove trailing newline
  REPLY="${lines%$'\n'}"
}
