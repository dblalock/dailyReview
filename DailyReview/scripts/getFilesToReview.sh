#!/bin/bash

# includes
source ./timeFuncs.sh
source ./reviewTimeAccessors.sh

# ================================================================
# Constants
# ================================================================

# mdfind output separated by newlines, not whitespace
IFS='
'

TO_REVIEW_FILE='filesToReview.txt'
DIRS_TO_SEARCH_FILE='dirsToSearch.txt'

TYPES_TO_REVIEW[0]="presentation"
TYPES_TO_REVIEW[1]="document"
TYPES_TO_REVIEW[2]="pdf"

# ================================================================
# Functions
# ================================================================

function getReviewTime() {
	reviewTime=$(readReviewTime "$1")	# attr might not be present
	if [ -z "$reviewTime" ]; then
		reviewTime=$( now )
		setReviewTime "$reviewTime "$1"
		# xattr -w $XATTR_REVIEW_TIME "$reviewTime" "$1" "
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

# get all the files to review
for dir in "${dirsToSearch[@]}"; do
	for kind in "${TYPES_TO_REVIEW[@]}"; do

		files=( $(mdfind -onlyin "$dir" kind:"$kind") )	#wrapping parens init an array
		for file in "${files[@]}"; do
			storeReviewItem "$file"
		done
	done
done

# restore normal file separators
unset IFS
