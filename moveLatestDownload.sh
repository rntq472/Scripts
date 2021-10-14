#!/bin/bash

# Script for moving the most recent file(s) or director(y/ies) in ~/Downloads to a
# specified directory.

# Note that if you use any torrenting software then you will need to point it to a
# different directory as those files will always have the latest mtimes.

# This would be a lot easier in a different scripting language since we effectively
# want to parse ls -t but I have implemented it anyway for portability.
# See https://mywiki.wooledge.org/BashFAQ/099

# TODO:
# Check when to use [ and [[. https://mywiki.wooledge.org/BashFAQ/031
# Check if it can be sh instead of bash.
# Check which things exactly need quoting. newest=$f


if [ -z "$1" ]; then
    echo "First argument must be the output directory."
    echo "Use -d for directories; otherwise files will be moved."
    echo "Use -n to specify the number of files/directories to move. Default is 1."
    echo "For example: moveLatestDownload.sh . -n 3"
    exit 1
fi

outdir=$1
shift 1

NUMFILES=1
directory=false

while getopts "dn:" option
do
    case "${option}"
    in
      d) directory=true;;
      n) NUMFILES=${OPTARG};;
      *) echo "Invalid option" && exit 1;;
   esac
done

for ((i = 1; i <= $NUMFILES; i++)); do
    
    # Find newest file/directory and move it.

    all_downloads=(~/Downloads/*)
    any_present=false
    
    for f in "${all_downloads[@]}"; do
	
	if ! $any_present ; then
	    if $directory ; then
		if [ -d "$f" ]; then
		    newest=$f
		    any_present=true
		fi
	    else
		if [ -f "$f" ]; then
		    newest=$f
		    any_present=true
		fi
	    fi
	fi
	
	if $directory ; then
	    if [ -d "$f" ]; then
		if [[ $f -nt $newest ]]; then
		    newest=$f
		fi
	    fi
	else
	    if [ -f "$f" ]; then
		if [[ $f -nt $newest ]]; then
		    newest=$f
		fi
	    fi
	fi
    
    done
    
    if $any_present ; then
	mv "$newest" $outdir
    fi
    
done
