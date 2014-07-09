#!/bin/bash

XATTR_REVIEW_TIME="ReviewTime"

function setReviewTime() {
	xattr -w $XATTR_REVIEW_TIME "$1" "$2"
}

function readReviewTime() {
	echo $(xattr -p $XATTR_REVIEW_TIME "$1" || true)
}
