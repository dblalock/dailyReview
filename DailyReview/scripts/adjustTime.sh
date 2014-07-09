#!/bin/bash

source ./reviewTimeAccessors.sh
source ./timeFuncs.sh

# ================================================================
# Functions
# ================================================================

function usage() {
	echo "Usage: adjustedTime amount file"
	echo "Echoes a string representation of the current time plus the specified amount"
	echo "Options:"
	echo "hour, day, 2days, week, month"
}

# ================================================================
# Main
# ================================================================

# validate input - two args, second is an existing file
if [[ $# != 2 ]]; then
	usage
	exit 1
fi
if [[ ! -f "$2" ]]; then
	echo "ERROR: no file: "$2""
	exit 2
fi

# print appropriate output
if [[ "$1" = "hour" ]]; then
	setReviewTime "$(nextHour)" "$2"
elif [[ "$1" = "day" ]]; then
	setReviewTime "$(nextDay)" "$2"
elif [[ "$1" = "2days" ]]; then
	setReviewTime "$(twoDays)" "$2"
elif [[ "$1" = "week" ]]; then
	setReviewTime "$(nextWeek)" "$2"
elif [[ "$1" = "month" ]]; then
	setReviewTime "$(nextMonth)" "$2"
else
	echo "ERROR: invalid argument given"
	usage
	exit 3
fi
