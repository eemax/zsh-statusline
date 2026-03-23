# statusline

A modular zsh prompt with rich git integration.

## Features

- **Directory** — smart truncation for deep paths
- **Git** — branch, worktree, tracking remote, ahead/behind, file status, diff stats, commit hash & age
- **Environment** — Python venv, Node version, background jobs, last exit code, SSH context
- **Configurable** — toggle any component via `config.toml`

## Example

```
~/projects/api 🪾 feature/auth ahead 3 / behind 1 ✨ 🔖 b9d4e2 ⏱️  20m ago
❯
```

```
~/projects/api 🪾 feature/auth 🔒 local staged:1 modified:3 untracked:2 (+87/-12) 🔖 c1a2b3 ⏱️  2h ago
❯
```

## Install

```zsh
git clone <repo-url> ~/statusline
cd ~/statusline && ./install.zsh
```

Or manually add to `~/.zshrc`:

```zsh
source ~/statusline/statusline.zsh
```

## Uninstall

```zsh
cd ~/statusline && ./uninstall.zsh
```

## Configuration

Edit `config.toml` to toggle components:

```toml
[prompt]
char = "❯"            # prompt character

[components]
git       = true
venv      = true
node      = true
jobs      = true
exit_code = true
context   = true       # SSH user@host

[git]
branch       = true
worktree     = true
tracking     = true
ahead_behind = true
file_status  = true
diff_lines   = true
hash_time    = true
```

Changes take effect in new shell sessions (or after `source ~/.zshrc`).

## Structure

```
statusline/
├── statusline.zsh      # entry point
├── config.toml         # user configuration
├── lib/
│   ├── config.zsh      # config loader
│   ├── palette.zsh     # color definitions
│   ├── shell.zsh       # shell components
│   ├── git.zsh         # git integration
│   └── prompt.zsh      # prompt assembly
├── install.zsh         # installer
└── uninstall.zsh       # uninstaller
```

## License

MIT
