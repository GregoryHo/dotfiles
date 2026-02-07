# Neovim 使用手冊（tmux + worktree）

這份文件對應 `/Users/gregho/GitHub/dotfiles/nvim`。

## 1. 你目前裝了什麼（重點）

### 核心
- `lazy.nvim`: 插件管理
- `which-key.nvim`: 顯示快捷鍵提示
- `vim-tmux-navigator`: tmux pane 與 nvim split 共用方向鍵

### 編輯/語言
- `nvim-lspconfig`, `mason.nvim`, `blink.cmp`
- `conform.nvim`: 格式化
- `nvim-treesitter`: 語法高亮/語法樹

### 檔案與搜尋
- `neo-tree.nvim`: 檔案樹（主流程）
- `telescope.nvim`: 模糊搜尋

### Git
- `gitsigns.nvim`: 行內 hunk 操作
- `diffview.nvim`: diff panel

### UI
- `tabby.nvim`: 上方 tabline（只在多 tab 顯示）

## 2. 三個核心概念：tab / window / buffer

- `buffer`: 檔案內容（例如 `foo.ts`）
- `window`: 畫面分割（`split`）
- `tab`(tabpage): 一組 windows 的工作上下文

建議：
- 同一個任務用 `window` 分割
- 不同任務上下文用 `tab`

常用 tab 指令：
- `:tabnew` 開新 tab
- `:tabclose` 關目前 tab
- `gt` 下一個 tab
- `gT` 上一個 tab
- `3gt` 跳到第 3 個 tab

## 3. 每日工作流（建議）

1. 在 repo 開啟 nvim：
   - `nvim /Users/gregho/GitHub/dotfiles`
2. 用 `<leader>e` 打開 Neo-tree 選檔
3. 用 `<leader>fe` 定位目前檔案
4. 修改後用 `<leader>gd` 打開 Diffview 看整體差異
5. 在單檔內用 gitsigns：
   - `]h` / `[h` 跳 hunk
   - `<leader>hp` 預覽 hunk
   - `<leader>hs` stage hunk
   - `<leader>hr` reset hunk
6. 用 `<leader>gH` 查看目前檔案歷史

## 4. 目前快捷鍵（你這次調整重點）

### Tab 管理
- `<leader>ta`: 新增 tab
- `<leader>tq`: 關閉 tab
- `<leader>to`: 只留目前 tab
- `<leader>tn`: 下一個 tab
- `<leader>tp`: 上一個 tab

### 檔案樹
- `<leader>e`: Neo-tree toggle
- `<leader>fe`: Neo-tree reveal current file

### Git / Diff
- `<leader>gd`: DiffviewOpen
- `<leader>gD`: DiffviewClose
- `<leader>gH`: DiffviewFileHistory %
- `]h`, `[h`, `<leader>hp`, `<leader>hs`, `<leader>hr`

## 5. 故障排除

1. 看健康檢查：`:checkhealth`
2. 看插件狀態：`:Lazy`
3. 看 LSP 安裝：`:Mason`
4. 如果 `DiffviewOpen` 不存在：先 `:Lazy sync` 再重啟
5. 如果你看到 netrw 清單：確認不是舊 session，重開 nvim 測試
6. 若出現 `Cannot close because an unnamed buffer is modified`：
   先按 `Enter`，再用 `:bd!` 丟棄未命名暫存 buffer，最後用 `<leader>e` 或 `:Neotree focus`

## 6. tmux + Agent（Hybrid）

### 主要規則
- `大寫`：切到/建立專用 window（長任務主流程）
- `小寫`：開 popup（臨時查詢）

### 快捷鍵
- `<prefix> + A`：`agent-claude` window（Claude 主力）
- `<prefix> + a`：Claude popup
- `<prefix> + O`：`agent-codex` window
- `<prefix> + o`：Codex popup
- `<prefix> + G`：`agent-gemini` window
- `<prefix> + g`：Gemini popup
- `<prefix> + L`：`git` window（Lazygit）
- `<prefix> + l`：Lazygit popup
- `<prefix> + R` 然後 `A/O/G`：resume（`aar/aor/agr`）

### 空間拓撲（建議）
- 1 個 worktree 對應 1 個 tmux session
- 預設 windows：`editor`、`agent-claude`、`test`、`logs`
- `agent-codex`、`agent-gemini`、`git` 採 lazy create（按 `O/G/L` 才建立）
- pane 只做短暫輔助，不作多 agent 長駐

### nvim 與 lazygit 分工（tmux-only）
- `nvim`：編輯、Diffview、gitsigns（主流程）
- `lazygit`：commit 編排、rebase/cherry-pick（僅透過 tmux `L/l` 進入）
