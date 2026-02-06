# dotfiles
Personal setting

## Shell Environment Maintenance

- Shared environment exports live in `shell/.env.shared.sh` only.
- `zsh/.zprofile` and `zsh/.zshrc` both source `shell/.env.shared.sh` to cover login and non-login zsh sessions.
- `bash/.bash_profile` and `bash/.bashrc` both source `shell/.env.shared.sh` to cover login and non-login bash sessions.
- Optional bootstrap files (for example `~/.local/bin/env`, `~/.cargo/env`) must always be guarded with existence checks.
- `shell/.env.shared.sh` must remain idempotent (`DOTFILES_ENV_SHARED_LOADED`) because it can be sourced multiple times in one session.

### Verification

Run:

```bash
shell/test-shell-startup.sh
```

This script checks shared-env sourcing paths, optional-file guards, and idempotent behavior.
