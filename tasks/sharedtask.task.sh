#!/bin/bash
#
#

##
#
function sharedtask_help() {
	require "analyse.task.sh"

	local cmd_list=$( analyse_extract_commands $TASK_FILE)
	echo "Available commands for this task:"
	echo "$cmd_list" | sed -E "s:(.*):	- ${boldon}${purplef}$TASK_NAME ${bluef}\1${reset}:g"
}

##
#
function sharedtask_man() {
	require "analyse.task.sh"

	analyse_task_doc "$TASK_FILE" | less -R
}
