# NVM Lazy Loading

Node.js tools are available instantly on shell startup without paying the cost
of sourcing the full `nvm.sh` (~3500 lines, 80+ function definitions).

## Why

NVM's `nvm.sh` is expensive to source — it adds measurable latency to every
new shell. But you need `node`, `npm`, and globally-installed tools (like
`mgrep`) available immediately. The solution: eagerly resolve the default
Node.js PATH at startup, but defer loading the full `nvm` function until
someone actually types `nvm`.

## How It Works

### Three-Phase Strategy

```
Phase 1: Shell Startup              Phase 2: First `nvm` Call         Phase 3: Directory Change
(instant, no nvm.sh)                (one-time cost)                   (automatic)

┌─────────────────────────┐         ┌────────────────────────┐        ┌────────────────────────┐
│ Read alias/default       │         │ nvm() {                │        │ load-nvmrc() {         │
│   → "22" or "22.12.0"   │         │   unset -f nvm         │        │   if [[ -f .nvmrc ]]   │
│                          │         │   . nvm.sh --no-use    │        │     nvm use            │
│ Resolve to full path:    │         │   nvm "$@"             │        │   fi                   │
│   ~/.nvm/versions/node/  │         │ }                      │        │ }                      │
│   v22.12.0/bin           │         │                        │        │ add-zsh-hook chpwd     │
│                          │         │ ◀── stub replaces      │        │   load-nvmrc           │
│ Prepend to PATH          │         │     itself with real    │        │                        │
│ Set NVM_BIN, MANPATH     │         │     nvm on first call   │        │ ◀── auto-switches      │
│ hash -r                  │         │                        │        │     node version per    │
│                          │         │                        │        │     project .nvmrc      │
│ ◀── node/npm/npx ready   │         │                        │        │                        │
│     nvm.sh NOT sourced   │         │                        │        │                        │
└─────────────────────────┘         └────────────────────────┘        └────────────────────────┘
```

### Phase 1: Eager PATH Resolution (zsh/.zshrc)

Instead of sourcing `nvm.sh` to get node on PATH, the startup code reads the
default version alias and resolves it to a filesystem path directly:

```bash
# Read the default version alias (e.g., "22" or "22.12.0")
_nvm_ver="$(< "$NVM_DIR/alias/default")"
_nvm_ver="${_nvm_ver#v}"                    # Strip leading 'v'

# Try exact match first
_nvm_path="$NVM_DIR/versions/node/v${_nvm_ver}"

if [[ ! -d "$_nvm_path" ]]; then
  # Partial version → glob match (e.g., "22" → "v22.12.0")
  _nvm_path="${NVM_DIR}/versions/node/v${_nvm_ver}"*
  _nvm_path=( $_nvm_path )                 # Expand glob
  _nvm_path="${_nvm_path[-1]}"              # Take highest match
fi

if [[ -d "$_nvm_path" ]]; then
  export PATH="${_nvm_path}/bin:${PATH}"
  export NVM_BIN="${_nvm_path}/bin"
  export MANPATH="${_nvm_path}/share/man:${MANPATH:-}"
  hash -r                                  # Flush command cache
fi

unset _nvm_ver _nvm_path                   # Clean up temp vars
```

**Result**: `node`, `npm`, `npx`, and all globally-installed packages are
immediately available. The full `nvm.sh` has not been sourced.

### Phase 2: Stub Function

The `nvm` command is defined as a self-replacing stub:

```bash
nvm() {
  unset -f nvm                    # Remove the stub
  [ -s "$NVM_DIR/nvm.sh" ] && \
    \. "$NVM_DIR/nvm.sh" --no-use # Load real nvm (skip auto-use)
  nvm "$@"                        # Call real nvm with original args
}
```

The `--no-use` flag is important: it prevents nvm from running `nvm use default`
on load, since Phase 1 already set up the correct PATH.

### Phase 3: Automatic Version Switching

A `chpwd` hook detects `.nvmrc` files when changing directories:

```bash
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && \
       [ "$(nvm version)" != "$(nvm version default)" ]; then
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
```

**Note**: First `cd` into a project with `.nvmrc` triggers Phase 2 (nvm.sh
load), then switches versions. Subsequent switches are instant.

### Persistent Global Packages

`nvm-default-packages` is manually symlinked to `~/.nvm/default-packages`
(not stow-managed, since the target is inside `~/.nvm/`):

```
nvm-default-packages  ── ln -s ──▶  ~/.nvm/default-packages
```

NVM reads this file on every `nvm install` and auto-installs the listed
packages. This ensures tools like `mgrep`, `prettier`, etc. survive Node
version changes.

### Oh My Zsh Integration

The Oh My Zsh `nvm`, `node`, and `npm` plugins are **intentionally disabled**:

```bash
plugins=(git docker kubectl ... tmux react-native zsh-syntax-highlighting)
#        ^^^ no nvm, node, or npm plugins
```

These plugins would interfere with the custom lazy loading by eagerly sourcing
`nvm.sh`.

## Performance Impact

```
Without lazy loading:  nvm.sh sourced at startup → ~200-400ms added
With lazy loading:     PATH resolved from alias  → ~5ms added
                       Full nvm available on first `nvm` call
```

## Key Files

| File | Role |
|------|------|
| `zsh/.zshrc` (lines 236-260) | Eager PATH resolution + stub function |
| `zsh/.zshrc` (lines 270-300) | `load-nvmrc` chpwd hook |
| `nvm-default-packages` | Persistent global npm packages |
| `shell/.env.shared.sh` (lines 55-62) | NVM fallback for non-interactive shells |

## See Also

- [02-shell-environment.md](02-shell-environment.md) — where NVM_DIR is exported
- [01-stow-deployment.md](01-stow-deployment.md) — how `nvm-default-packages` is deployed
