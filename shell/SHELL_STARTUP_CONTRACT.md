# Shell Startup Contract

This document defines shell startup responsibilities for this repository.
Use it as the source of truth before changing any shell init file.

## Goals

- Shared environment variables are available in login and non-login sessions.
- Optional bootstrap files never break shell startup when missing.
- Shared bootstrap can be sourced multiple times safely.

## File Responsibilities

### `shell/.env.shared.sh`

- Single source of truth for shared exports and bootstrap.
- Must be shell-agnostic (`bash` and `zsh`).
- Must be idempotent (safe when sourced multiple times).
- Optional files (for example `~/.local/bin/env`, `~/.cargo/env`) must be guarded.

### `zsh/.zprofile`

- Login-shell initialization for zsh.
- Sources `shell/.env.shared.sh` so login zsh gets shared env.
- May include login-only integrations.

### `zsh/.zshrc`

- Interactive zsh initialization.
- Must also source `shell/.env.shared.sh` so non-login interactive zsh gets shared env.
- Should not directly source optional env scripts that are already handled by `shell/.env.shared.sh`.

### `bash/.bash_profile`

- Login-shell initialization for bash.
- Sources `shell/.env.shared.sh` so login bash gets shared env.

### `bash/.bashrc`

- Interactive non-login initialization for bash.
- Must source `shell/.env.shared.sh` so non-login bash gets shared env.
- Should not directly source optional env scripts that are already handled by `shell/.env.shared.sh`.

## Expected Behavior Matrix

| Shell invocation | Files responsible for shared env |
| --- | --- |
| zsh login interactive | `zsh/.zprofile` (+ `zsh/.zshrc`) |
| zsh non-login interactive | `zsh/.zshrc` |
| zsh login non-interactive (`zsh -lc`) | `zsh/.zprofile` |
| bash login interactive | `bash/.bash_profile` |
| bash non-login interactive | `bash/.bashrc` |
| bash login non-interactive (`bash -lc`) | `bash/.bash_profile` |

## Maintenance Rules

- Keep shared env changes in `shell/.env.shared.sh`.
- If you add new optional bootstrap files, guard them with existence checks.
- Validate with `shell/test-shell-startup.sh` after any change.
