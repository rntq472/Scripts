#!/usr/bin/env bash

# Motivating use case: When I copy photos off my phone I frequently can't remember
# how far back in time I need to go (since I don't always delete the photos immediately
# after copying them). Therefore I want to know what is the most recent photo in the
# collection on my hard drive but I can't simply copy-paste and skip duplicates because
# on my hard drive the photos have already been filed amongst various directories
# (Holidays, Pets, etc). As a solution this script finds the latest date-taken amongst
# the EXIF data of a (nested) directory of photos.

# This would be much easier in a different scripting language since it might be helpful
# to sort the entire collection of dates and return more than one.

# imagemagick is required


shopt -s globstar

if [[ -z "$1" ]]; then
    printf 'ERROR: Must provide the base directory\n' 1>&2
    exit 1
fi

base_dir=$1
shift 1

all_files=("$base_dir"/**/*)

foo () {
    identify -format '%[EXIF:DateTimeOriginal*]' "${1}"
}

newest_ts=$(foo "${all_files[0]}")
newest_fn="${all_files[0]}"

for f in "${all_files[@]}"; do
    
    if [[ -d "$f" ]]; then
	continue
    fi
    
    file_type=$(file --mime-type -b "$f")
    
    case $file_type in
	"image/png" | "image/jpeg") ;;
	*) continue ;;
    esac
    
    ts=$(foo "$f")
    
    if [[ "$ts" > "$newest_ts" ]]; then
	newest_ts="$ts"
	newest_fn="$f"
    fi

done

if [[ -z "$newest_ts" ]]; then
    printf 'ERROR: No images with EXIF data\n' 1>&2
    exit 1
fi

echo "$newest_fn" "$newest_ts"
