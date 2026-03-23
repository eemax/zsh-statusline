#!/usr/bin/env zsh
# Install statusline into ~/.zshrc

STATUSLINE_PATH="${0:A:h}/statusline.zsh"
ZSHRC="${HOME}/.zshrc"

if grep -qF "statusline.zsh" "$ZSHRC" 2>/dev/null; then
  echo "statusline is already installed in ${ZSHRC}"
  exit 0
fi

cat >> "$ZSHRC" <<EOF

# statusline prompt
source "${STATUSLINE_PATH}"
EOF

echo "Installed! Added source line to ${ZSHRC}"
echo "Restart your shell or run: source ${ZSHRC}"
