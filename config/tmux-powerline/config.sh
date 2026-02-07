# tmux-powerline config tracked in dotfiles.

# Global behavior.
export TMUX_POWERLINE_PATCHED_FONT_IN_USE="true"
export TMUX_POWERLINE_THEME="tokyonight_storm_minimal"
export TMUX_POWERLINE_DIR_USER_THEMES="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline/themes"
export TMUX_POWERLINE_STATUS_INTERVAL="5"
export TMUX_POWERLINE_STATUS_JUSTIFICATION="left"
export TMUX_POWERLINE_STATUS_LEFT_LENGTH="60"
export TMUX_POWERLINE_STATUS_RIGHT_LENGTH="60"

# Minimal but useful segments.
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="#S"
export TMUX_POWERLINE_SEG_HOSTNAME_FORMAT="short"
export TMUX_POWERLINE_SEG_DATE_FORMAT="%Y-%m-%d"
export TMUX_POWERLINE_SEG_TIME_FORMAT="%H:%M"
