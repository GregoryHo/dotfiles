# Safety Defaults

Defensive configuration choices that prevent accidental data loss, force
pushes, and unsigned commits.

## Why

Dotfiles run unattended. A misconfigured alias or missing guard can silently
destroy work. These safety defaults act as guardrails — they make the dangerous
path require explicit intent.

## Inventory

```
┌──────────────────────┬─────────────────────────┬──────────────────────────────┐
│ What                 │ Where                   │ Why                          │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Force push disabled  │ config/lazygit/         │ Prevents rewriting shared    │
│                      │   config.yml            │ history via lazygit UI       │
│                      │   disableForcePushing:  │                              │
│                      │   true                  │                              │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Interactive rm       │ zsh/.zshrc.local        │ Confirmation before every    │
│                      │   alias rm='rm -i'      │ delete — safety net for      │
│                      │                         │ muscle memory                │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Commit signing       │ git/.gitconfig-github   │ All commits cryptographically│
│                      │   gpgsign = true        │ signed with SSH key          │
│                      │   format = ssh          │                              │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Idempotent shell env │ shell/.env.shared.sh    │ Guards against doubled PATH  │
│                      │   DOTFILES_ENV_SHARED_  │ entries from multiple        │
│                      │   LOADED guard          │ sourcing                     │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Guarded optional     │ shell/.env.shared.sh    │ Missing .local or .cargo     │
│ sources              │ zsh/.zshrc              │ files don't break shell      │
│                      │   [ -f ... ] && . ...   │ startup                      │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ GVM disabled         │ zsh/.zshrc              │ Caused cd slowdown —         │
│                      │   (commented out)        │ intentionally removed        │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Shell startup tests  │ shell/                  │ Validates contract after     │
│                      │   test-shell-startup.sh │ every change                 │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Lazygit quit on      │ config/lazygit/         │ Don't leave lazygit running  │
│ non-repo             │   config.yml            │ in non-git directories       │
│                      │   notARepository: quit  │                              │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Tmux auto-start      │ zsh/.zshrc              │ Every terminal joins tmux —  │
│                      │   ZSH_TMUX_AUTOSTART=   │ sessions survive terminal    │
│                      │   true                  │ close                        │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Agent process        │ zsh/.zshrc.local        │ Quick-ask REPL kills all     │
│ cleanup              │   trap cleanup EXIT     │ background agent processes   │
│                      │                         │ on exit                      │
├──────────────────────┼─────────────────────────┼──────────────────────────────┤
│ Scrollback cleanup   │ tmux/.tmux.conf.local   │ Temp files auto-deleted      │
│                      │   trap "rm -f ..." EXIT │ after Neovim scrollback      │
│                      │                         │ viewer closes                │
└──────────────────────┴─────────────────────────┴──────────────────────────────┘
```

### Defense-in-Depth Model

```
Layer 1: Prevention          Layer 2: Detection           Layer 3: Recovery
─────────────────            ──────────────────           ────────────────

Force push disabled          Shell startup tests          tmux-resurrect
  in lazygit                   validate contract            saves sessions

Interactive rm -i            Agent status segment         tmux-continuum
  confirms deletes             shows what's running         auto-restore

Guarded optional             Agent dashboard              Git reflog
  sources [ -f ]               live monitoring               (always available)

Idempotency guard            Commit signing               Worktree isolation
  prevents PATH dupes          verification                  limits blast radius
```

### Patterns to Note

**Fail-safe over fail-silent**: `rm -i` asks rather than silently deleting.
Guarded sources print nothing rather than erroring. The shell test script
exits non-zero on failure.

**Explicit opt-in for danger**: Force push requires the git CLI (lazygit blocks
it). Removing the idempotency guard requires editing the source file.

**Process cleanup via traps**: Both quick-ask REPL and scrollback viewer use
`trap ... EXIT` to ensure no orphan processes or temp files survive.

## Key Files

| File | Role |
|------|------|
| `config/lazygit/config.yml` | Force push disabled, quit-on-non-repo |
| `zsh/.zshrc.local` | Interactive rm, process cleanup traps |
| `git/.gitconfig-github` | Commit signing enforcement |
| `shell/.env.shared.sh` | Idempotency guard, guarded sources |
| `shell/test-shell-startup.sh` | Contract validation |
| `tmux/.tmux.conf.local` | Scrollback temp file cleanup |

## See Also

- [02-shell-environment.md](02-shell-environment.md) — idempotency and guard patterns
- [07-quick-ask-repl.md](07-quick-ask-repl.md) — process cleanup trap
- [10-git-identity.md](10-git-identity.md) — commit signing details
