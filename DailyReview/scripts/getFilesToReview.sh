#!/bin/bash

# includes
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/reviewTimeAccessors.sh
source ${DIR}/timeFuncs.sh

# ================================================================
# Constants
# ================================================================

TO_REVIEW_FILE="${DIR}/filesToReview.txt"
DIRS_TO_SEARCH_FILE="${DIR}/dirsToSearch.txt"

TYPES_TO_REVIEW[0]="presentation"
TYPES_TO_REVIEW[1]="document"
TYPES_TO_REVIEW[2]="pdf"
TYPES_TO_REVIEW[3]="web"

# echo "actually calling this script"

# ================================================================
# Functions
# ================================================================

function getReviewTime() {
	reviewTime=$(readReviewTime "$1")	# attr might not be present
	if [ -z "$reviewTime" ]; then
		reviewTime=$(now)
		setReviewTime "$reviewTime" "$1"
		# xattr -w $XATTR_REVIEW_TIME "$reviewTime" "$1" "
	fi
	echo "$reviewTime"
}

function storeReviewItem() {
	# xattr -d $XATTR_REVIEW_TIME "$1" uncomment and comment below to reset times
	reviewTime=$(getReviewTime "$1")
	currentTime=$(now)
	if [[ "$reviewTime" < "$currentTime" ]]; then
		echo "$1" # >> $TO_REVIEW_FILE;
		# echo "$1" >> $TO_REVIEW_FILE;
	fi
}

# ================================================================
# Main
# ================================================================

# get the directories to search
dirsToSearch=( $(cat $DIRS_TO_SEARCH_FILE) )

# find/mdfind output separated by newlines, not whitespace
IFS='
'

# echo dirsToSearch: $dirsToSearch
# get symlinks in dirs to search, since mdfind ignores them
allDirsToSearch=( "${dirsToSearch[@]}" )
# for dir in in "${dirsToSearch[@]}"; do
# 	# ignore files and directories containing *.*
# 	symlinks=( $(find "$dir" -type l \( ! -iname "*.*" \) ) )
# 	allDirsToSearch+=("${symlinks[@]}")
# done
# echo dirs with links: "${allDirsToSearch[@]}"

# get all the files to review; note that there may be duplicates
for dir in "${allDirsToSearch[@]}"; do
	for kind in "${TYPES_TO_REVIEW[@]}"; do

		files=( $(mdfind -onlyin "$dir" kind:"$kind") )	#wrapping parens init an array
		for file in "${files[@]}"; do
			storeReviewItem "$file"
		done
	done
done

# restore normal file separators
unset IFS
