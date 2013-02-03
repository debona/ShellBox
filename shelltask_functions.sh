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
	local file="$1"
	local fullpath

	local oldIFS=$IFS
	IFS=":"
	for path in $SHELLTASK_DIRS
	do
		[[ -r "$path/$file" ]] && fullpath="$path/$file"
	done
	IFS=$oldIFS

	echo "$fullpath"
	[[ -z "$fullpath" ]] && return 1
}

## Load task
#
# @param	task_file	The task file
function load_task() {
	local task_file="$1"
	local task_name=$( basename "$task_file" '.task.sh' )

	if ! [[ -r "$task_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	ln -s "shelltask" "$SHELLTASK_ROOT/path/$task_name" &> /dev/null

	if [[ -x "$SHELLTASK_ROOT/path/$task_name" ]]
	then
		echo "${boldon} ● ${bluef}$task_name${reset} available"

		# generate autocompletion for this command
		complete -o default -F _complete "$task_name"
		return 0
	else
		echo "${redb}${boldon} ✗ couldn't import $1:${reset}"
		return 1
	fi
}
