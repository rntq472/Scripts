#!/usr/bin/env bash

# Script for moving the most recent file(s) or director(y/ies) in ~/Downloads to a
# specified directory. I use this when I download something through my browser and
# immediately want to store it somewhere via the command line without checking the
# exact file name.

# Examples:
# moveLatestDownload .
# moveLatestDownload ~/Foo/Bar/
# moveLatestDownload -n 3 ~/Pictures/Cats/
# moveLatestDownload -d ~/Foo/Bar/new_directory_name

# This would be a lot easier in a different scripting language since we effectively
# want to parse ls -t but I have implemented it anyway for portability.
# See https://mywiki.wooledge.org/BashFAQ/099

# Note the use of mv --backup=numbered at the end to avoid clobbering.

# Also note that if you use any torrenting software then you will need to point it
# to a different output directory as those files will always have the latest mtimes.


num_files=1
directory=false

while :; do
    case $1 in
	-h|--help)
	    printf 'Use -d for directories; otherwise files will be moved.\n'
	    printf 'Use -n to specify the number of files/directories to move. Default is 1.\n'
	    printf 'First positional argument must be the output directory.\n'
	    exit
	    ;;
	-d)
	    directory=true
	    ;;
	-n)
	    num_files=$2
	    shift
	    ;;
	-?*)
	    printf 'ERROR: Unknown option: %s\n' "$1" 1>&2
	    exit 1
            ;;
	*)
	    break
    esac
    
    shift
done

if [[ -z "$1" ]]; then
    printf 'ERROR: Must provide the output directory\n' 1>&2
    exit 1
fi

outdir=$1
shift 1

for ((i = 1; i <= $num_files; i++)); do
    
    # Find newest file/directory and move it.
    
    all_downloads=(~/Downloads/*)
    any_present=false
    
    for f in "${all_downloads[@]}"; do
	
	if ! $any_present ; then
	    if $directory ; then
		if [[ -d "$f" ]]; then
		    newest=$f
		    any_present=true
		fi
	    else
		if [[ -f "$f" ]]; then
		    newest=$f
		    any_present=true
		fi
	    fi
	fi
	
	if $directory ; then
	    if [[ -d "$f" ]]; then
		if [[ $f -nt $newest ]]; then
		    newest=$f
		fi
	    fi
	else
	    if [[ -f "$f" ]]; then
		if [[ $f -nt $newest ]]; then
		    newest=$f
		fi
	    fi
	fi
    
    done
    
    if $any_present ; then
	mv --backup=numbered "$newest" "$outdir"
    fi
    
done
