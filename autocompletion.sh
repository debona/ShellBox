#!/bin/bash
#
# Auto-completion library
# This library 


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

## Try to auto-complete the nth parameter of the given command
#
# @param	task_file	the task file
# @param	cmd_name	the command name
# @param	n			the "index" of the parameter
function complete_option() {
	source "$SHELLTASK_PATH/analyse.task.sh" # this source is inside the function to avoid the analyse functions leak

	local task_file="$1"
	local file_content=$( cat "$task_file" )
	local task_name=$( basename "$task_file" '.task.sh' )
	local cmd_name="$2"
	local n="$3"

	local n_raw_params=$( cat "$task_file" \
		| analyse_function_raw_doc "${task_name}_${cmd_name}" \
		| analyse_function_raw_params \
		| head -n $n )

	local comp_func=$( echo "$n_raw_params" | egrep "@params" | sed -E "s:@params$param_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null

	comp_func=$( echo "$n_raw_params" | awk "NR==$n{print;exit}" | sed -E "s:@params?$param_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null
}


