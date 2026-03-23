# ── statusline ────────────────────────────────────────────────
# Modular zsh prompt with git integration
# Source this file from your .zshrc

setopt PROMPT_SUBST
autoload -U colors && colors

# Resolve the directory this script lives in
STATUSLINE_DIR="${0:A:h}"

source "${STATUSLINE_DIR}/lib/config.zsh"
source "${STATUSLINE_DIR}/lib/palette.zsh"
source "${STATUSLINE_DIR}/lib/shell.zsh"
source "${STATUSLINE_DIR}/lib/git.zsh"
source "${STATUSLINE_DIR}/lib/prompt.zsh"

# Load user config
_statusline_load_config
