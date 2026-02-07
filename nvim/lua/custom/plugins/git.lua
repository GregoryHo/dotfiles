return {
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewFileHistory',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iffview Open' },
      { '<leader>gD', '<cmd>DiffviewClose<CR>', desc = '[G]it [D]iffview Close' },
      { '<leader>gH', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it File [H]istory' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    keys = {
      {
        ']h',
        function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            require('gitsigns').nav_hunk 'next'
          end
        end,
        desc = 'Git Next Hunk',
      },
      {
        '[h',
        function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            require('gitsigns').nav_hunk 'prev'
          end
        end,
        desc = 'Git Prev Hunk',
      },
      {
        '<leader>hs',
        function()
          require('gitsigns').stage_hunk()
        end,
        desc = 'Git Hunk Stage',
      },
      {
        '<leader>hr',
        function()
          require('gitsigns').reset_hunk()
        end,
        desc = 'Git Hunk Reset',
      },
      {
        '<leader>hp',
        function()
          require('gitsigns').preview_hunk()
        end,
        desc = 'Git Hunk Preview',
      },
    },
  },
}
