#!/bin/bash
#
# Auto-completion library
# This library 


source "$SHELLTASK_PATH/regex.task.sh"


## List all commands of a task file
#
# @param	task_file		the task file
function complete_commands() {
	local task_file="$1"
	local file_content=$( cat "$task_file" )
	local task_name=$( basename "$task_file" '.task.sh' )

	regex="^(function$SPACE+)?${task_name}_([^\( 	]+)$SPACE*\(.*$"

	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}




