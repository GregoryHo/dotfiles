# Neovim Configuration

Built on kickstart.nvim with lazy.nvim for plugin management and custom
extensions for git and filesystem navigation.

## Why

Kickstart.nvim provides a well-documented, modular Neovim config that's easy to
understand and extend. Rather than using a distribution (LazyVim, NvChad), this
approach gives full control while starting from a solid, opinionated base.

## How It Works

### Plugin Architecture

```
nvim/
├── init.lua                              ◀── Entry point
│   ├── Leader: <space>
│   ├── vim.g.have_nerd_font = true
│   ├── netrw disabled (Neo-tree only)
│   └── require("lazy").setup({...})
│
├── lazy-lock.json                        ◀── Lock file (pinned versions)
│
└── lua/
    ├── kickstart/                        ◀── Base modules (from kickstart.nvim)
    │   ├── health.lua                        Health check
    │   └── plugins/
    │       ├── autopairs.lua                 Auto-close brackets
    │       ├── indent_line.lua               Indent guides
    │       ├── neo-tree.lua                  File explorer (base)
    │       ├── debug.lua                     DAP debugger
    │       ├── gitsigns.lua                  Git signs (base)
    │       └── lint.lua                      Linting
    │
    └── custom/                           ◀── Custom extensions
        └── plugins/
            ├── init.lua                      (empty — for user additions)
            ├── git.lua                       Diffview + Gitsigns overrides
            └── filesystem.lua                Neo-tree configuration
```

### Key Differences from Vim Config

| Aspect | Vim | Neovim |
|--------|-----|--------|
| Plugin manager | vim-plug | lazy.nvim |
| Leader key | `,` | `<space>` |
| LSP | CoC (Node.js-based) | Native LSP + mason.nvim |
| File explorer | (none) | Neo-tree |
| Config language | VimScript | Lua |
| Location | `~/.vimrc` | `~/.config/nvim/` |

### Custom Plugins

**git.lua** — Diffview + Gitsigns:

```lua
-- Diffview: full diff viewer
{
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>' },
    { '<leader>gD', '<cmd>DiffviewClose<cr>' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>' },
  },
}

-- Gitsigns: hunk navigation and staging
{
  'lewis6991/gitsigns.nvim',
  keys = {
    { ']h', function() gitsigns.nav_hunk('next') end },
    { '[h', function() gitsigns.nav_hunk('prev') end },
    { '<leader>hs', gitsigns.stage_hunk },
    { '<leader>hr', gitsigns.reset_hunk },
    { '<leader>hp', gitsigns.preview_hunk },
  },
}
```

**filesystem.lua** — Neo-tree:

```lua
{
  'nvim-neo-tree/neo-tree.nvim',
  keys = {
    { '<leader>e', '<cmd>Neotree toggle<cr>' },
    { '<leader>fe', '<cmd>Neotree reveal<cr>' },
  },
  opts = {
    close_if_last_window = false,
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
}
```

### Lazy Loading Strategy

lazy.nvim loads plugins on-demand using triggers:

```
Trigger Type    Example                    When It Loads
────────────    ───────                    ─────────────
cmd             cmd = { 'DiffviewOpen' }   First :DiffviewOpen
keys            keys = { '<leader>gd' }    First <space>gd press
ft              ft = { 'python' }          First Python file opened
event           event = { 'BufReadPre' }   First file read
dependencies    deps = { 'plenary.nvim' }  When dependent loads
```

### LSP Setup

Mason.nvim auto-installs language servers:

```
Mason (installer)
    │
    ▼
mason-lspconfig (bridge)
    │
    ▼
nvim-lspconfig (configuration)
    │
    ├── lua_ls (Lua)
    ├── pyright (Python)
    ├── ts_ls (TypeScript)
    └── ... (auto-detected)
```

### Tmux Integration

The `vim-tmux-navigator` plugin enables seamless navigation between Neovim and
tmux panes using `Ctrl-h/j/k/l`:

```
┌──────────────┬──────────────┐
│  Neovim      │  Tmux pane   │
│  split       │  (shell)     │
│              │              │
│  C-l ──────────────▶        │
│       ◀──────────── C-h     │
│              │              │
└──────────────┴──────────────┘
```

The same keybindings work whether you're moving between Neovim splits or
tmux panes — no need to distinguish.

## Key Files

| File | Role |
|------|------|
| `nvim/init.lua` | Entry point, base settings, plugin list |
| `nvim/lazy-lock.json` | Pinned plugin versions |
| `nvim/lua/custom/plugins/git.lua` | Diffview + Gitsigns |
| `nvim/lua/custom/plugins/filesystem.lua` | Neo-tree config |
| `nvim/lua/kickstart/plugins/` | Base kickstart modules |

## See Also

- [01-stow-deployment.md](01-stow-deployment.md) — stowed to `~/.config/nvim/`
- [06-tmux-agent-orchestration.md](06-tmux-agent-orchestration.md) — prefix+E opens scrollback in Neovim
