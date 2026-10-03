#!/usr/bin/env bash
# Copy the wallpapers in this repo into the user's wallpaper directory.
#
# Usage: install-scripts/install.sh [-f|--force] [DEST]
#
# DEST defaults to $WALLPAPER_DIR, then $(xdg-user-dir PICTURES)/Wallpapers,
# which is caelestia's default paths.wallpaperDir. Existing files are kept
# unless --force is given.

set -euo pipefail

usage() {
  sed -n '4,8s/^# \{0,1\}//p' "$0"
}

force=false
dest=""
while [ $# -gt 0 ]; do
  case "$1" in
  -f | --force) force=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  *) dest="$1" ;;
  esac
  shift
done

repo_dir=$(dirname "$(dirname "$(realpath "$0")")")
src="$repo_dir/wallpapers"

if [ -z "$dest" ]; then
  if [ -n "${WALLPAPER_DIR:-}" ]; then
    dest="$WALLPAPER_DIR"
  else
    pictures=$(xdg-user-dir PICTURES 2>/dev/null || true)
    # xdg-user-dir falls back to $HOME when PICTURES is unset
    if [ -z "$pictures" ] || [ "$pictures" = "$HOME" ]; then
      pictures="$HOME/Pictures"
    fi
    dest="$pictures/Wallpapers"
  fi
fi

if [ ! -d "$src" ]; then
  echo "No wallpapers found at $src" >&2
  exit 1
fi

mkdir -p "$dest"

copied=0
skipped=0
for file in "$src"/*; do
  [ -f "$file" ] || continue
  target="$dest/$(basename "$file")"
  if [ -e "$target" ] && [ "$force" = false ]; then
    skipped=$((skipped + 1))
    continue
  fi
  cp -- "$file" "$target"
  copied=$((copied + 1))
done

echo "Copied $copied wallpaper(s) to $dest ($skipped already present)."
