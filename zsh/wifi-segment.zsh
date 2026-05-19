# Custom Powerlevel10k wifi segment.
#
# Currently UNUSED. The synchronous osascript+CoreWLAN call takes ~315ms per
# prompt redraw, which is unacceptable in the hot path. Re-enable by:
#   1. Wrapping `zsh_wifi_signal` in a zsh-async worker (zsh-async required), or
#   2. Adding a background timer that writes the result to a cache file and
#      having the segment cat the cache.
# When ready, uncomment the line in zsh/.p10k.zsh and ensure POWERLEVEL9K_CUSTOM_*
# vars below are defined.
#
# macOS 26 removed the `airport` CLI; this uses CoreWLAN via osascript (no sudo).

POWERLEVEL9K_CUSTOM_WIFI_SIGNAL="zsh_wifi_signal"
POWERLEVEL9K_CUSTOM_WIFI_SIGNAL_BACKGROUND="clear"

zsh_wifi_signal() {
  local info=$(/usr/bin/osascript <<'AS' 2>/dev/null
use framework "CoreWLAN"
set i to (current application's CWWiFiClient's sharedWiFiClient()'s interface())
set p to (i's powerOn()) as text
set r to (i's transmitRate()) as text
return p & "|" & r
AS
)
  local power=${info%%|*}
  local speed=${info##*|}
  speed=${speed%.*}

  if [ "$power" != "true" ]; then
    echo -n "%F{007}Wifi Off"
  else
    local signColor='%F{green}'
    [[ $speed -lt 50 ]] && signColor='%F{red}'
    echo -n "%F{007}${speed} Mbps ${signColor}%f"
  fi
}
