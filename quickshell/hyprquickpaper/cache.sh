#!/usr/bin/env bash


CONFIG="$1/config.json"



wallpaper_path=$(jq -r '.wallpaper_path' "$CONFIG")
cache_path=$(jq -r '.cache_path' "$CONFIG")
cache_batch_size=$(jq -r '.cache_batch_size' "$CONFIG")

# config.json stores paths with a leading "~" so they stay portable. Bash only
# expands a tilde written literally in the source, never one that arrives inside
# a variable, so expand it here or mkdir would create a directory named "~".
wallpaper_path="${wallpaper_path/#\~/$HOME}"
cache_path="${cache_path/#\~/$HOME}"

# ImageMagick 7 installs "magick", ImageMagick 6 installs "convert", and which
# one you get depends on the distro: Debian sid ships 7, Ubuntu 24.04 still
# ships 6. Pick whichever exists instead of assuming one.
if command -v magick >/dev/null 2>&1; then
    magick_cmd=(magick)
elif command -v convert >/dev/null 2>&1; then
    magick_cmd=(convert)
else
    echo "Error: ImageMagick not found (needs 'magick' or 'convert')." >&2
    exit 1
fi

mkdir -p "$cache_path"

echo "Wallpaper path: $wallpaper_path"
echo "Cache path: $cache_path"

find "$wallpaper_path" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" \
\) | while read -r img; do

    filename=$(basename "$img")
    out="$cache_path/$filename"

    if [[ -f "$out" ]]; then
        continue
    fi

    echo "Generating thumbnail for $filename"


    "${magick_cmd[@]}" "$img" -thumbnail x500 -strip -quality 85 "$out" &

    # Only limit jobs if batch_size > 0
    if (( cache_batch_size > 0 )); then
        while (( $(jobs -rp | wc -l) >= cache_batch_size )); do
            wait -n
        done
    fi

done

wait

echo "Thumbnail generation complete."
