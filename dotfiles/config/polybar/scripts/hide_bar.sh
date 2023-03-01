#!/usr/bin/env bash

#	Simple script to hide/unhide polybar
#   Author: z0mbi3
#	url: https://github.com/gh0stzk


function hide() {
		polybar-msg cmd hide | bspc config top_padding 5
}

function unhide() {
	polybar-msg cmd show | bspc config top_padding 60
}

case $1 in
	-h | --hide | hide)
		hide
		exit;;
	-u | --unhide | unhide)
		unhide
		exit;;
		*) # Invalid option
		echo "Error: Invalid option"
		exit;;
esac
