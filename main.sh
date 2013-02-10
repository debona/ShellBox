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

# TODO: it would be great to remove shelltask_functions file
source "$SHELLTASK_ROOT/shelltask_functions.sh"

# Disable color in shell if the outputs are not tty
initializeANSI
[[ -t 1 ]] && [[ -t 2 ]] || dropANSI


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

run_task_command "$0" "$@"
