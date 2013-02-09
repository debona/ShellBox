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

	blackf="${esc}[30m";	redf="${esc}[31m";		greenf="${esc}[32m";
	yellowf="${esc}[33m";	bluef="${esc}[34m";		purplef="${esc}[35m";
	cyanf="${esc}[36m";		whitef="${esc}[37m";

	blackb="${esc}[40m";	redb="${esc}[41m";		greenb="${esc}[42m";
	yellowb="${esc}[43m";	blueb="${esc}[44m";		purpleb="${esc}[45m";
	cyanb="${esc}[46m";		whiteb="${esc}[47m";

	boldon="${esc}[1m";		boldoff="${esc}[22m";
	italicson="${esc}[3m";	italicsoff="${esc}[23m";
	ulon="${esc}[4m";		uloff="${esc}[24m";
	invon="${esc}[7m";		invoff="${esc}[27m";

	reset="${esc}[0m";
}

## Drop ANSI colors to write readable log files.
#
function dropANSI() {
	unset esc

	unset blackf;		unset redf;		unset greenf;
	unset yellowf;		unset bluef;	unset purplef;
	unset cyanf;		unset whitef;

	unset blackb;		unset redb;		unset greenb;
	unset yellowb;		unset blueb;	unset purpleb;
	unset cyanb;		unset whiteb;

	unset boldon;		unset boldoff;
	unset italicson;	unset italicsoff;
	unset ulon;			unset uloff;
	unset invon;		 unset invoff;

	unset reset;
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


## Try to source a file across all directories present in SHELLTASK_DIRS.
# This mechanism rely on the `locate_taskfile`.
# Return 1 if the file can't be sourced
#
# @param	file	The file to source
function require() {
	local file="$1"
	local fullpath=$( locate_taskfile $file )

	if ! source "$fullpath"
	then
		echo "$file cannot be sourced from path:"
		echo "SHELLTASK_DIRS=$SHELLTASK_DIRS"
		return 1
	fi
}

## Find a task file across all directories present in SHELLTASK_DIRS.
# It print the path of the last task file which match.
# Return 1 if the file can't be found
#
# @param	file	The file to source
function locate_taskfile() {
	local task_filename="$1"

	# TODO: Create a private function which return all reachable task files
	local task_dirs=$( echo $SHELLTASK_DIRS | tr -s ':' ' ' )
	local fullpath=$( find $task_dirs -type f -name "$task_filename" | tail -1 )

	echo "$fullpath"
	[[ -z "$fullpath" ]] && return 1
}
