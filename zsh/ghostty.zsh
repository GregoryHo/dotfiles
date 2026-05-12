# ==============================================================================
# Ghostty-specific layer (active only when TERM_PROGRAM=ghostty, i.e. bare
# Ghostty session). tmux overrides TERM_PROGRAM to "tmux" inside its sessions,
# so this layer is naturally inactive in tmux and the tmux-centric tools
# (tsa/tla/dot_agent_pane_rows) keep their original semantics.
# Note: gating on $TERM is unreliable because zsh/.zshrc forces
# TERM=xterm-256color before this file is sourced; TERM_PROGRAM is untouched.
# ==============================================================================
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  autoload -U add-zsh-hook
  zmodload zsh/datetime 2>/dev/null

  # --- Command-finished 通知 (OSC 9 → macOS notification) ---
  # > 10s 的命令才發,避免快命令洗版。exit 0 → ✔,非 0 → ✘。
  # 單一 precmd hook 同時負責「算時長 + 通知」,避免兩個 hook 排隊時
  # 前者把 $? 蓋成 0(zsh precmd 依註冊順序執行,每個 hook 結束都會更新 $?)。
  _dot_ghostty_time_start() { _DOT_CMD_START=$EPOCHSECONDS }
  _dot_ghostty_precmd() {
    local exit_code=$?
    local duration=$(( EPOCHSECONDS - ${_DOT_CMD_START:-$EPOCHSECONDS} ))
    if (( duration > 10 )); then
      local label="✔"
      (( exit_code != 0 )) && label="✘"
      printf '\033]9;%s command finished (%ds)\033\\' "$label" "$duration"
    fi
    unset _DOT_CMD_START
  }
  add-zsh-hook preexec _dot_ghostty_time_start
  add-zsh-hook precmd  _dot_ghostty_precmd

  # --- Agent picker (替代 Ghostty 環境下的 tsa 語意) ---
  # tmux 的 tsa 是「切到 agent 所在 pane」;Ghostty 沒有切 pane 的概念,
  # 改列 agent PID + 即時資源,選中後回傳 PID 供接手腳本使用。
  dot_agent_picker_ghostty() {
    local pid_line
    pid_line=$(pgrep -af 'claude|codex|gemini' 2>/dev/null \
      | fzf --prompt='agent> ' --height=40% --border \
            --preview='ps -o pid,%cpu,%mem,etime,command -p {1}' \
            --preview-window='down:3:wrap') || return 1
    echo "$pid_line" | awk '{print $1}'
  }

  # 在 Ghostty 環境覆蓋 tsa;tmux session 內 $TERM 不是 xterm-ghostty,不受影響。
  alias tsa='dot_agent_picker_ghostty'
fi
