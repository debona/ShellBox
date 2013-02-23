#!/bin/bash
#
# Provides commands shared with all tasks
# When you execute a task command, if the command is not found in the task, then the command is execute with this task (sharedtask).
# That means sharedtask is always required before to execute your task commands.


## Display a short help of the task. i.e. list of available commands
#
function sharedtask_help() {
	# TODO should take command as $1
	# TODO should take task as $1 and command as $2
	require "analyse.task.sh"

	local cmd_list=$( analyse_extract_commands $TASK_FILE)
	echo "Available commands for this task:"
	echo "$cmd_list" | sed -E "s:(.*):	- ${boldon}${purplef}$TASK_NAME ${bluef}\1${reset}:g"
}


## Display a detailed manual of the task.
#
function sharedtask_man() {
	# TODO should take command as $1
	# TODO should take task as $1 and command as $2
	require "analyse.task.sh"

	analyse_task_doc "$TASK_FILE" | less -R
}
