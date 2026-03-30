# Shell Environment Architecture

A single idempotent file provides every shell type (login, interactive,
non-interactive, bash, zsh) with the same environment variables.

## Why

Without a shared source of truth, environment variables get duplicated across
`.zprofile`, `.zshrc`, `.bash_profile`, and `.bashrc`. This leads to:

- **Drift**: one file adds a new PATH entry, others don't
- **Doubled PATHs**: login + interactive shells source both `.zprofile` and
  `.zshrc`, appending the same paths twice
- **Broken non-login shells**: tmux panes, VS Code terminals, and subshells
  skip `.zprofile`, missing critical exports

The solution: one file, sourced everywhere, with an idempotency guard.

## How It Works

### The Fan-In Pattern

All four shell startup files converge on a single source of truth:

```
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  ┌──────────────┐
│ zsh/.zprofile │  │  zsh/.zshrc  │  │bash/.bash_profile│  │ bash/.bashrc │
│ (login)       │  │ (interactive)│  │ (login)           │  │ (interactive)│
└──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  └──────┬───────┘
       │                 │                    │                    │
       └─────────┬───────┴────────┬───────────┘                   │
                 │                │                                │
                 ▼                ▼                                ▼
       ┌──────────────────────────────────────────────────────────────┐
       │                  shell/.env.shared.sh                        │
       │                                                              │
       │  ┌────────────────────────────────────────────────────────┐  │
       │  │  if [ -n "${DOTFILES_ENV_SHARED_LOADED:-}" ]; then     │  │
       │  │    return 0          ◀── idempotency guard             │  │
       │  │  fi                                                    │  │
       │  │  export DOTFILES_ENV_SHARED_LOADED=1                   │  │
       │  └────────────────────────────────────────────────────────┘  │
       │                                                              │
       │  Exports:                                                    │
       │    XDG_CONFIG_HOME    PATH (/opt/homebrew, /usr/local, ...)  │
       │    HOMEBREW_*         ANDROID_HOME    JAVA_HOME              │
       │    GOENV_ROOT/GOPATH  NVM_DIR         Flutter/Bun/Cargo      │
       │                                                              │
       │  Optional sources (guarded):                                 │
       │    $HOME/.local/bin/env     $HOME/.cargo/env                 │
       │                                                              │
       │  NVM fallback for non-interactive login shells:              │
       │    if ! command -v node → load nvm + nvm use --silent        │
       └──────────────────────────────────────────────────────────────┘
```

### The Idempotency Guard

The guard uses parameter expansion safe for both bash and zsh:

```bash
if [ -n "${DOTFILES_ENV_SHARED_LOADED:-}" ]; then
  return 0
fi
export DOTFILES_ENV_SHARED_LOADED=1
```

This is critical because **zsh login shells source both `.zprofile` AND
`.zshrc`**, each of which sources `.env.shared.sh`. Without the guard, PATH
would be modified twice.

### Shell Behavior Matrix

| Shell Invocation | Files Sourced | .env.shared.sh Loaded Via |
|------------------|---------------|---------------------------|
| zsh login + interactive | `.zprofile` → `.zshrc` | `.zprofile` (first), `.zshrc` (guard returns) |
| zsh non-login interactive | `.zshrc` only | `.zshrc` |
| zsh login non-interactive (`zsh -lc`) | `.zprofile` only | `.zprofile` |
| bash login + interactive | `.bash_profile` | `.bash_profile` |
| bash non-login interactive | `.bashrc` only | `.bashrc` |
| bash login non-interactive (`bash -lc`) | `.bash_profile` | `.bash_profile` |

### Sourcing Pattern

Every startup file uses the same guarded source:

```bash
[ -f "$HOME/GitHub/dotfiles/shell/.env.shared.sh" ] && \
  . "$HOME/GitHub/dotfiles/shell/.env.shared.sh"
```

The existence check (`[ -f ... ]`) prevents errors if the repo isn't cloned yet.

### Load Order (Full Interactive Zsh Login)

```
1.  zsh/.zprofile
    ├── source shell/.env.shared.sh    ◀── exports set here
    ├── source OrbStack integration
    └── append Obsidian to PATH

2.  zsh/.zshrc
    ├── source shell/.env.shared.sh    ◀── guard returns immediately
    ├── Oh My Zsh setup + plugins
    ├── NVM lazy loading (see doc 04)
    ├── FZF configuration
    └── source ~/.zshrc.local          ◀── local overrides (gitignored)
```

## Shell Startup Contract

The rules are formalized in `shell/SHELL_STARTUP_CONTRACT.md`:

1. `shell/.env.shared.sh` is the **single source of truth** for all exports
2. Must be **shell-agnostic** (POSIX-compatible, no bash-isms or zsh-isms)
3. Must be **idempotent** (safe to source multiple times)
4. Optional files must be **guarded** with `[ -f ... ] &&`
5. Each startup file has **specific responsibilities** based on shell type

## Validation

The test script `shell/test-shell-startup.sh` verifies the contract:

```
Phase 1: Guard Validation
  ✓  DOTFILES_ENV_SHARED_LOADED guard exists

Phase 2: Sourcing Chain
  ✓  zsh/.zprofile sources .env.shared.sh
  ✓  zsh/.zshrc sources .env.shared.sh
  ✓  bash/.bash_profile sources .env.shared.sh
  ✓  bash/.bashrc sources .env.shared.sh

Phase 3: Optional Env Safety
  ✓  .local and .cargo sourced only in .env.shared.sh
  ✓  Not duplicated in individual shell files

Phase 4: Idempotency
  ✓  PATH identical after double-sourcing (bash)
  ✓  PATH identical after double-sourcing (zsh)
  ✓  Critical variables present (ANDROID_HOME, JAVA_HOME, etc.)
```

Run after any change to shell startup files:

```bash
shell/test-shell-startup.sh
```

## Key Files

| File | Role |
|------|------|
| `shell/.env.shared.sh` | Single source of truth for all exports |
| `shell/SHELL_STARTUP_CONTRACT.md` | Formal rules for shell startup |
| `shell/test-shell-startup.sh` | Automated contract validation |
| `zsh/.zprofile` | Zsh login shell (sources shared env) |
| `zsh/.zshrc` | Zsh interactive shell (sources shared env) |
| `bash/.bash_profile` | Bash login shell (sources shared env) |
| `bash/.bashrc` | Bash interactive shell (sources shared env) |

## See Also

- [01-stow-deployment.md](01-stow-deployment.md) — why `shell/` is not stowed
- [03-config-override-pattern.md](03-config-override-pattern.md) — `.local` override files
- [04-nvm-lazy-loading.md](04-nvm-lazy-loading.md) — the NVM optimization in `.zshrc`
