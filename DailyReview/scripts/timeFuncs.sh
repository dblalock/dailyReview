#!/bin/bash

DATE_FMT_STR="+\"%Y-%m-%d %H:%M:%S %z\""
DATE_FMT_STR_EARLY_MORNING="+\"%Y-%m-%d 05:%M:%S %z\" "	# 5AM
DATE_EARLY_MORNING_HR_ADJ="-v -4H"	# adjust in case reviewing after midnight

# ================================================================
# Functions
# ================================================================

function now() {
	echo $(date $DATE_FMT_STR)
}

function nextHour() {
	echo $(date -v +1H "$DATE_FMT_STR")
}

function nextDay() {
	echo $(date -v +1d $DATE_EARLY_MORNING_HR_ADJ "$DATE_FMT_STR_EARLY_MORNING")
}

function twoDays() {
	echo $(date -v +2d $DATE_EARLY_MORNING_HR_ADJ "$DATE_FMT_STR_EARLY_MORNING")
}

function nextWeek() {
	echo $(date -v +7d $DATE_EARLY_MORNING_HR_ADJ "$DATE_FMT_STR_EARLY_MORNING")
}

function nextMonth() {
	echo $(date -v +1m $DATE_EARLY_MORNING_HR_ADJ "$DATE_FMT_STR_EARLY_MORNING")
}
