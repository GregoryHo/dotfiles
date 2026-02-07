# Lazygit Profile (tmux + nvim)

This directory contains the tracked lazygit profile used by this dotfiles repo.

## Files

- `config.yml`: functional configuration (tracked)
- `state.yml`: runtime state baseline used for symlink compatibility

## Active Decisions

1. tmux-first workflow; no nvim plugin integration.
2. Required + recommended safety/perf options are enabled.
3. Tokyonight Storm uses a minimal theme override.
4. `customCommands` are intentionally not enabled for now.

## Required/Recommended Keys

- `os.editPreset: nvim`
- `git.disableForcePushing: true`
- `git.autoFetch: true`
- `git.autoRefresh: true`
- `git.fetchAll: true`
- `notARepository: quit`
- `disableStartupPopups: true`
- `promptToReturnFromSubprocess: true`

## Nerd Font

- `gui.showFileIcons: true`
- `gui.nerdFontsVersion: "3"`

## Tokyonight Storm (Minimal)

`gui.theme` overrides exactly these keys:

- `activeBorderColor: ["#7aa2f7", "bold"]`
- `inactiveBorderColor: ["#414868"]`
- `searchingActiveBorderColor: ["#7dcfff", "bold"]`
- `optionsTextColor: ["#bb9af7"]`
- `selectedLineBgColor: ["#2f334d"]`
- `inactiveViewSelectedLineBgColor: ["default"]`
- `unstagedChangesColor: ["#f7768e"]`
- `defaultFgColor: ["#c0caf5"]`

## Symlink Targets (macOS)

- `~/Library/Application Support/lazygit/config.yml` -> `config/lazygit/config.yml`
- `~/Library/Application Support/lazygit/state.yml` -> `config/lazygit/state.yml`
