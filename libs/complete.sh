#!/bin/bash
#
# Auto-completion library
# This library 

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_LIBS="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_LIBS="$( cd -P "$( dirname "$0" )" && pwd )"
fi

source "$SHELLTASK_LIBS/regex.sh"



## List all commands of a task file
#
# @param	task_file		the task file
function _list_commands() {
	local task_file="$1"
	local file_content=$( cat "$task_file" )
	local task_name=$( basename "$task_file" '.task.sh' )

	regex="^(function$SPACE+)?${task_name}_([^\( 	]+)$SPACE*\(.*$"

	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}




