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

_git_file_status() {
  local staged=0 modified=0 deleted=0 untracked=0 conflicted=0 renamed=0

  while IFS= read -r line; do
    case "$line" in
      "1 "*)
        local x=${line:2:1} y=${line:3:1}
        [[ "$x" != "." ]] && case "$x" in
          A|M|D) (( staged++ ));;
          R)     (( renamed++ ));;
        esac
        [[ "$y" != "." ]] && case "$y" in
          M) (( modified++ ));;
          D) (( deleted++  ));;
        esac
        ;;
      "2 "*) (( staged++ ));;
      "u "*) (( conflicted++ ));;
      "? "*) (( untracked++  ));;
    esac
  done < <(git status --porcelain=v2 2>/dev/null)

  local out="" any=0

  (( staged     > 0 )) && { out+="${G}staged:${staged}${RESET} ";               any=1; }
  (( renamed    > 0 )) && { out+="${C}renamed:${renamed}${RESET} ";             any=1; }
  (( modified   > 0 )) && { out+="${Y}modified:${modified}${RESET} ";           any=1; }
  (( deleted    > 0 )) && { out+="${R}deleted:${deleted}${RESET} ";             any=1; }
  (( untracked  > 0 )) && { out+="${DIM}untracked:${untracked}${RESET} ";       any=1; }
  (( conflicted > 0 )) && { out+="${R}${BOLD}conflict:${conflicted}${RESET} ";  any=1; }

  (( any == 0 )) && out="✨"

  echo "${out% }"
}

_git_diff_lines() {
  local added removed
  read -r added removed < <(git diff --numstat 2>/dev/null \
    | awk '{a+=$1; d+=$2} END {print a+0, d+0}')
  (( added == 0 && removed == 0 )) && return
  local out="${DIM}(${RESET}"
  (( added   > 0 )) && out+="${G}+${added}${RESET}"
  (( added   > 0 && removed > 0 )) && out+="${DIM}/${RESET}"
  (( removed > 0 )) && out+="${R}-${removed}${RESET}"
  out+="${DIM})${RESET}"
  echo "$out"
}

# ── main git block ────────────────────────────────────────────

prompt_git() {
  _git_repo || return
  _statusline_enabled "components.git" || return

  local branch worktree tracking ahead_behind hash_time files diff

  _statusline_enabled "git.branch"       && branch=$(_git_branch)
  _statusline_enabled "git.worktree"     && worktree=$(_git_worktree)
  _statusline_enabled "git.tracking"     && tracking=$(_git_tracking)
  _statusline_enabled "git.ahead_behind" && ahead_behind=$(_git_ahead_behind)
  _statusline_enabled "git.hash_time"    && hash_time=$(_git_hash_and_time)
  _statusline_enabled "git.file_status"  && files=$(_git_file_status)
  _statusline_enabled "git.diff_lines"   && diff=$(_git_diff_lines)

  local out="${M}${BOLD}🪾 ${branch}${RESET}"
  [[ -n "$worktree"     ]] && out+=" ${worktree}"
  [[ -n "$tracking"     ]] && out+=" ${tracking}"
  [[ -n "$ahead_behind" ]] && out+=" ${ahead_behind}"
  [[ -n "$files"        ]] && out+=" ${files}"
  [[ -n "$diff"         ]] && out+=" ${diff}"
  [[ -n "$hash_time"    ]] && out+=" ${hash_time}"

  echo "$out"
}
