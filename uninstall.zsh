#!/usr/bin/env zsh
# Remove statusline from ~/.zshrc

ZSHRC="${HOME}/.zshrc"

if ! grep -qF "statusline.zsh" "$ZSHRC" 2>/dev/null; then
  echo "statusline is not installed in ${ZSHRC}"
  exit 0
fi

# Remove the comment line and the source line
sed -i '' '/# statusline prompt/d' "$ZSHRC"
sed -i '' '/statusline\.zsh/d' "$ZSHRC"

echo "Removed statusline from ${ZSHRC}"
echo "Restart your shell or run: source ${ZSHRC}"
