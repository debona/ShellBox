#!/bin/bash
#
# function library for shelltask developers



# Part of [MSGShellUtils](github.com/MattiSG/MSGShellUtils)
# From http://www.intuitive.com/wicked/showscript.cgi?011-colors.sh
# Author: Dave Taylor
# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after 
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.
#
# Example:
#	echo "$redf Error!$reset"
#	echo "$greenf$boldon Finished!$reset"
function initializeANSI()
{
	esc=""
	
	blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
	yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
	cyanf="${esc}[36m";    whitef="${esc}[37m"
	
	blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
	yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
	cyanb="${esc}[46m";    whiteb="${esc}[47m"
	
	boldon="${esc}[1m";    boldoff="${esc}[22m"
	italicson="${esc}[3m"; italicsoff="${esc}[23m"
	ulon="${esc}[4m";      uloff="${esc}[24m"
	invon="${esc}[7m";     invoff="${esc}[27m"
	
	reset="${esc}[0m"
}

## Drop ANSI colors to write readable log files.
#
function dropANSI() {
	esc=""
	
	blackf="";   redf="";    greenf=""
	yellowf=""   bluef="";   purplef=""
	cyanf="";    whitef=""
	
	blackb="";   redb="";    greenb=""
	yellowb=""   blueb="";   purpleb=""
	cyanb="";    whiteb=""
	
	boldon="";    boldoff=""
	italicson=""; italicsoff=""
	ulon="";      uloff=""
	invon="";     invoff=""
	
	reset=""
}


## Define the global if not defined
#
# @param the name of the global
# @param the value
function global_default() {
	global=$(printenv | egrep "^$1=")
	if [[ "$global" = "" ]]
	then
		export "$1=$2"
	fi
}


## Print command before run it
# Allow to do: 'verbose command option && verbose something else'
#
#* all parameters are interpreted as command and its options
function verbose() {
	step "$@"

	# exec the line
	if "$@"
	then
		success "$@"
		return 0
	else
		status=$? # remember the exit status
		failure "$@"
		return $status
	fi
}
