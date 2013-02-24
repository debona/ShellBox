#!/bin/bash
#
# Task executer
# This script execute task commands of a given task. It is the only script which can be execute.
# The task name is given by $0, so you must create a symlink with the name of the task which target this script.
#
# @param	command		The task command to run
# @params	options		All the task command options


####################################################################
###########                 GLOBAL VARS                  ###########
####################################################################

SHELLTASK_ROOT="$( cd -P "`dirname "$0"`/.." && pwd )"

[[ ":$SHELLTASK_DIRS:" =~ ":$SHELLTASK_ROOT/tasks:" ]] || SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks:$SHELLTASK_DIRS"


####################################################################
###########               GLOBAL FUNCTIONS               ###########
####################################################################

## Define colors.
# From http://www.intuitive.com/wicked/showscript.cgi?011-colors.sh
# Author: Dave Taylor
function enableColors()
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

## Undefine colors to write readable log files.
#
function disableColors() {
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


## Source the task file.
# This mechanism rely on the `locate_task_file` function.
# Return 1 if the file can't be sourced
#
# @param	file	The file to source but not the path (i.e. awesome_task.task.sh)
function require() {
	local file="$1"
	local fullpath=$( locate_task_file $file )

	if ! source "$fullpath"
	then
		echo "$file cannot be sourced from path:"
		echo "SHELLTASK_DIRS=$SHELLTASK_DIRS"
		return 1
	fi
}

## Find a task file across all directories present in SHELLTASK_DIRS.
# It print the path of the last task file which match.
# Return 1 if the file can't be found in SHELLTASK_DIRS
#
# @param	file	The file to locate but not the path (i.e. awesome_task.task.sh)
function locate_task_file() {
	local task_filename="$1"
	local task_dirs=$( echo $SHELLTASK_DIRS | tr ':' ' ' )
	local fullpath=$( find $task_dirs -type f -name '*.task.sh' | egrep "$task_filename$" | tail -1 )

	echo "$fullpath"
	[[ -z "$fullpath" ]] && return 1
}

## List all task name which are available in SHELLTASK_DIRS
#
function list_task_names() {
	local task_dirs=$( echo $SHELLTASK_DIRS | tr ':' ' ' )
	find $task_dirs -type f -name '*.task.sh' | xargs basename -as '.task.sh' | sort -u
}


####################################################################
###########               PRIVATE FUNCTIONS              ###########
####################################################################

## Print the command function for the given task and command.
# Return 1 if the command does not exist.
#
# @param	task_name	the task name
# @param	cmd_name	the command
function _command_function() {
	local task_name="$1"
	local cmd_name="$2"

	local cmd_function="${task_name}_${cmd_name}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	cmd_function="sharedtask_${cmd_name}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	return 1
}


## Run a task command with options.
# This is the main function of shelltask.
#
# @param	TASK_NAME	the task name
# @param	CMD_NAME	the command name
# @params	options		the options
function run_task_command() {
	# All this vars are reachable by the tasks
	TASK_NAME="$1"
	TASK_FILE=$( locate_task_file ${TASK_NAME}.task.sh )
	CMD_NAME="$2"
	shift 2

	require "sharedtask.task.sh"
	require "${TASK_NAME}.task.sh" || return 1

	if _command_function "$TASK_NAME" "$CMD_NAME" &> /dev/null
	then
		# The task command exists
		local cmd_function=$( _command_function "$TASK_NAME" "$CMD_NAME" )
		$cmd_function "$@"
	else
		# The task command does not exist
		# Display the error
		require "cli.task.sh"
		cli_failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$TASK_NAME ${redf}$CMD_NAME${reset}"
		# Run the help command on the task
		local cmd_function=$( _command_function "$TASK_NAME" "help" )
		$cmd_function
		return 1
	fi
}


####################################################################
###########              EXEC TASK COMMAND               ###########
####################################################################

enableColors
[[ -t 1 ]] && [[ -t 2 ]] || disableColors # Disable color in shell if the outputs are not tty

run_task_command `basename "$0" ".task.sh"` "$@"
