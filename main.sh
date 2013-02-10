#!/bin/bash
#
# Task executer
# PARAMETERS
#  $1 => the task file to load
# [$2 => the task command to call]
# [$+ => task sub-command options]

# TODO: follow the link and get the absolute path
SHELLTASK_ROOT="$( cd -P "`dirname "$0"`/.." && pwd )"

# TODO: Ensure that SHELLTASK_DIRS includes $SHELLTASK_ROOT/tasks
[[ -z $SHELLTASK_DIRS ]] && SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks"


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



## Print the command function for the given task
# return 1 if the command does not exist.
#
function command_function() {
	local cmd_function="${TASK_NAME}_${CMD_NAME}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	cmd_function="sharedtask_${CMD_NAME}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	return 1
}

function run_task_command() {
	# All this vars are reachable by the task functions
	TASK_NAME=$( basename "$1" ".task.sh" )
	TASK_FILE=$( locate_taskfile ${TASK_NAME}.task.sh )
	CMD_NAME="$2"
	shift 2

	require "sharedtask.task.sh"
	require "${TASK_NAME}.task.sh" || return 1

	# TODO: remove this line and add it to task file whch require it
	require "cli.task.sh"

	if command_function &> /dev/null
	then
		local cmd_function=$( command_function )
		$cmd_function "$@"
	else
		require "cli.task.sh"
		cli_failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$TASK_NAME ${redf}$CMD_NAME${reset}"
		CMD_NAME="help"
		local cmd_function=$( command_function )
		$cmd_function
	fi
}


# Disable color in shell if the outputs are not tty
initializeANSI
[[ -t 1 ]] && [[ -t 2 ]] || dropANSI

run_task_command "$0" "$@"
