#!/bin/bash
#
# Task executer
# PARAMETERS
#  $1 => the task file to load
# [$2 => the task command to call]
# [$+ => task sub-command options]

# All this vars are reachable by the task functions
SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
TASK_FILE="$1"
TASK_NAME=$( basename "$TASK_FILE" '.task.sh' )
CMD_NAME="$2"


if [[ -z $SHELLTASK_DIRS ]]
then
	SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks"
fi

shift 2 # Remove $TASK_NAME and $CMD_NAME from parameters list

source "$SHELLTASK_ROOT/shelltask_functions.sh"

require "cli.task.sh"
require "regex.task.sh"

initializeANSI
[[ -t 1 ]] || dropANSI
[[ -t 2 ]] || dropANSI

function shellscript() {
	if [[ ! -r "$TASK_FILE" ]]
	then
		cli_failure "Can't read the file:" $TASK_FILE
		return 1
	fi

	if ! source $TASK_FILE 2> /dev/null
	then
		cli_failure "Can't load" "$TASK_FILE:"
		source $TASK_FILE
		return 1
	fi

	local cmd_function="${TASK_NAME}_${CMD_NAME}"

	if [[ "$CMD_NAME" = "help" ]]
	then
		require "analyse.task.sh"
		analyse_task_doc $TASK_FILE | less -R

	elif type $cmd_function &> /dev/null # if cmd_function can be called (i.e. is a function)
	then
		$cmd_function "$@"

	else # Otherwise, print repo help
		cli_failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$TASK_NAME ${redf}$CMD_NAME${reset}"

		local cmd_list=$($0 "$SHELLTASK_DIRS/analyse.task.sh" extract_commands $TASK_FILE)
		echo "Available commands for this task:"
		echo "$cmd_list" | sed -E "s:(.*):	- ${boldon}${purplef}$TASK_NAME ${bluef}\1${reset}:g"
	fi

}

shellscript "$@"
