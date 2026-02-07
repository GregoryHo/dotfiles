return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle left<CR>', desc = '[E]xplorer Toggle' },
      { '<leader>fe', '<cmd>Neotree reveal<CR>', desc = '[F]ile [E]xplorer Reveal' },
    },
    opts = {
      -- Keep Neo-tree open even when it is the last window so closing an editor
      -- split doesn't unexpectedly exit Neovim.
      close_if_last_window = false,
      popup_border_style = 'rounded',
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_default',
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
