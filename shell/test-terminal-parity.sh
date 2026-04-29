#!/usr/bin/env bash
set -euo pipefail

# Compare key visual parity between alacritty and ghostty configs.
# Covers: font family/size, primary fg/bg, 16-color palette.
# Exits 0 when all match, 1 on any diff, 2 if a config file is missing.
#
# Overridable paths (useful for dry-running against dotfiles copies):
#   ALACRITTY_CONFIG  default: ~/.config/alacritty/alacritty.toml
#   GHOSTTY_CONFIG    default: ~/.config/ghostty/config

ALACRITTY_CONFIG="${ALACRITTY_CONFIG:-$HOME/.config/alacritty/alacritty.toml}"
GHOSTTY_CONFIG="${GHOSTTY_CONFIG:-$HOME/.config/ghostty/config}"

if [[ ! -f "$ALACRITTY_CONFIG" ]]; then
  echo "Alacritty config not found: $ALACRITTY_CONFIG" >&2
  exit 2
fi
if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
  echo "Ghostty config not found: $GHOSTTY_CONFIG" >&2
  exit 2
fi

normalize_hex() {
  printf '%s' "$1" | tr -d '"#' | tr '[:upper:]' '[:lower:]'
}

normalize_num() {
  awk -v v="$1" 'BEGIN { if (v+0 == v) printf "%g", v; else print v }'
}

# Extract `key = value` from a specific [section] in alacritty's TOML.
alac_get() {
  local file="$1" section="$2" key="$3"
  awk -v section="[$section]" -v key="$key" '
    /^\[/ { in_section = ($0 == section) ? 1 : 0; next }
    in_section && $1 == key {
      sub(/^[^=]*=[[:space:]]*/, "")
      gsub(/"/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      print
      exit
    }
  ' "$file"
}

# Extract `key = value` from Ghostty ini-like config (skips `# ...` comment lines).
ghostty_get() {
  local file="$1" key="$2"
  awk -v key="$key" '
    /^[[:space:]]*#/ { next }
    {
      if (match($0, "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*")) {
        val = substr($0, RLENGTH + 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        gsub(/"/, "", val)
        print val
        exit
      }
    }
  ' "$file"
}

# Extract palette[N] from Ghostty `palette = N=#HEX` lines.
ghostty_palette() {
  local file="$1" idx="$2"
  awk -v idx="$idx" '
    /^[[:space:]]*#/ { next }
    {
      if (match($0, "^[[:space:]]*palette[[:space:]]*=[[:space:]]*" idx "[[:space:]]*=[[:space:]]*")) {
        val = substr($0, RLENGTH + 1)
        gsub(/[[:space:]#]/, "", val)
        print tolower(val)
        exit
      }
    }
  ' "$file"
}

FAILED=0
check() {
  local label="$1" a="$2" b="$3"
  if [[ "$a" == "$b" ]]; then
    printf '  [OK]   %-22s %s\n' "$label" "$a"
  else
    printf '  [DIFF] %-22s alacritty=%q  ghostty=%q\n' "$label" "$a" "$b" >&2
    FAILED=1
  fi
}

printf '1) Font parity...\n'
a_family=$(alac_get "$ALACRITTY_CONFIG" 'font.normal' 'family')
g_family=$(ghostty_get "$GHOSTTY_CONFIG" 'font-family')
check "font-family" "$a_family" "$g_family"

a_size=$(normalize_num "$(alac_get "$ALACRITTY_CONFIG" 'font' 'size')")
g_size=$(normalize_num "$(ghostty_get "$GHOSTTY_CONFIG" 'font-size')")
check "font-size" "$a_size" "$g_size"

printf '2) Primary colors...\n'
a_bg=$(normalize_hex "$(alac_get "$ALACRITTY_CONFIG" 'colors.primary' 'background')")
g_bg=$(normalize_hex "$(ghostty_get "$GHOSTTY_CONFIG" 'background')")
check "background" "$a_bg" "$g_bg"

a_fg=$(normalize_hex "$(alac_get "$ALACRITTY_CONFIG" 'colors.primary' 'foreground')")
g_fg=$(normalize_hex "$(ghostty_get "$GHOSTTY_CONFIG" 'foreground')")
check "foreground" "$a_fg" "$g_fg"

printf '3) 16-color palette...\n'
KEYS=(black red green yellow blue magenta cyan white)
for i in "${!KEYS[@]}"; do
  k="${KEYS[$i]}"
  a_col=$(normalize_hex "$(alac_get "$ALACRITTY_CONFIG" 'colors.normal' "$k")")
  g_col=$(normalize_hex "$(ghostty_palette "$GHOSTTY_CONFIG" "$i")")
  check "normal.$k [$i]" "$a_col" "$g_col"
done
for i in "${!KEYS[@]}"; do
  k="${KEYS[$i]}"
  idx=$((i + 8))
  a_col=$(normalize_hex "$(alac_get "$ALACRITTY_CONFIG" 'colors.bright' "$k")")
  g_col=$(normalize_hex "$(ghostty_palette "$GHOSTTY_CONFIG" "$idx")")
  check "bright.$k [$idx]" "$a_col" "$g_col"
done

if (( FAILED )); then
  echo "Terminal parity check FAILED" >&2
  exit 1
fi
echo "Terminal parity check passed."
