# shellcheck shell=bash disable=SC2034
# Kanagawa Wave minimal theme for tmux-powerline.
# Low-saturation, paper-like palette inspired by Hokusai's Great Wave off
# Kanagawa. Tuned for heavy programmer use — grey-dominant, accent only on
# live signals (agent status / task).

if tp_patched_font_in_use; then
  TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
  TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
  TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
  TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""
else
  TMUX_POWERLINE_SEPARATOR_LEFT_BOLD="◀"
  TMUX_POWERLINE_SEPARATOR_LEFT_THIN="❮"
  TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD="▶"
  TMUX_POWERLINE_SEPARATOR_RIGHT_THIN="❯"
fi

# Kanagawa Wave palette.
#   bg (sumiInk1)    #1f1f28
#   fg (fujiWhite)   #dcd7ba
#   fg_dim (fujiGray)#727169
#   blue (crystalBlue)  #7e9cd8
#   green (autumnGreen) #76946a
#   purple (oniViolet)  #957fb8
TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:-"#1f1f28"}
TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR=${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:-"#dcd7ba"}

TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}
TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR=${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:-$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}

if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_CURRENT" ]; then
  TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
    "#[$(tp_format inverse)]"
    "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
    " #I#F "
    "$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
    " #W "
    "#[$(tp_format regular)]"
    "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
  )
fi

if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_STYLE" ]; then
  TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
    "$(tp_format regular)"
  )
fi

if [ -z "$TMUX_POWERLINE_WINDOW_STATUS_FORMAT" ]; then
  TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
    "#[$(tp_format regular)]"
    "  #I#{?window_flags,#F, } "
    "$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
    " #W "
  )
fi

# Grey-dominant status bar. Only agent_status/agent_task carry accent colour;
# everything else uses dim fujiGray to keep the bar quiet during deep work.
if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
  TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
    "tmux_session_info #7e9cd8 #1f1f28"
    "hostname #727169 #1f1f28"
  )
fi

if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
  TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
    "agent_status #76946a #1f1f28"
    "agent_task #957fb8 #1f1f28"
    "date #727169 #1f1f28"
  )
fi
