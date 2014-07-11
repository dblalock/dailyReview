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
EXTS_TO_REVIEW_FILE="${DIR}/extsToReview.txt"

# find/mdfind output separated by newlines, not whitespace
IFS='
'

# ================================================================
# Functions
# ================================================================

function getReviewTime() {
	reviewTime=$(readReviewTime "$1")	# attr might not be present
	if [ -z "$reviewTime" ]; then
		reviewTime=$(now)
		setReviewTime "$reviewTime" "$1"
	fi
	echo "$reviewTime"
}

function storeReviewItem() {
	# xattr -d $XATTR_REVIEW_TIME "$1" uncomment and comment below to reset times
	reviewTime=$(getReviewTime "$1")
	currentTime=$(now)
	if [[ "$reviewTime" < "$currentTime" ]]; then
		echo "$1" >> $TO_REVIEW_FILE;
	fi
}

# ================================================================
# Main
# ================================================================

# clear the files to review from previous runs
(rm $TO_REVIEW_FILE) || true

# get the directories to search
dirsToSearch=( $(cat $DIRS_TO_SEARCH_FILE) )

# get file extensions to review
EXTS_TO_REVIEW=( $(cat $EXTS_TO_REVIEW_FILE) )

# get all the files to review; note that there may be duplicates
for dir in "${dirsToSearch[@]}"; do
	for ext in "${EXTS_TO_REVIEW[@]}"; do

		files=( $(find -L "$dir" -type f \( -iname "*.${ext}" ! -iname ".*" \) ) )
		for file in "${files[@]}"; do
			storeReviewItem "$file"
		done
	done
done

# restore normal file separators
unset IFS
