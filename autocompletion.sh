#!/bin/bash
#
# Auto-completion library
# This library 


## autocompletion function called when TAB key is pressed
#
function _complete() {
	local task_name="${COMP_WORDS[0]}" # first word of the line
	local current="${COMP_WORDS[COMP_CWORD]}" # the word currently auto-completed

	local task_file=$( locate_task_file "$task_name.task.sh" )

	if [ "$COMP_CWORD" -eq 1 ] # the first parameter is the command
	then
		COMPREPLY=( $( complete_commands $task_file | egrep "^$current" ) )
	else
		local cmd_name="${COMP_WORDS[1]}"

		# The other parameter are 
		local n=$COMP_CWORD
		let 'n = n - 1'

		local options=$(complete_option $task_file $cmd_name $n )
		local status=$?
		[[ "$status" = "0" ]] && COMPREPLY=( $( echo "$options" | egrep "^$current" ) )

		return $status
	fi
}


## List all commands of a task file
#
# @param	task_file		the task file
function complete_commands() {
	local task_file="$1"
	local file_content=$( cat "$task_file" )
	local task_name=$( basename "$task_file" '.task.sh' )

	local regex="^(function[ 	]+)?${task_name}_([^\( 	]+)[ 	]*\(.*$"

	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}

## Try to auto-complete the nth parameter of the given command
#
# @param	task_file	the task file
# @param	cmd_name	the command name
# @param	n			the "index" of the parameter
function complete_option() {
	require "analyse.task.sh" # this source is inside the function to avoid the analyse functions leak

	local task_file="$1"
	local file_content=$( cat "$task_file" )
	local task_name=$( basename "$task_file" '.task.sh' )
	local cmd_name="$2"
	local n="$3"

	local n_raw_params=$( cat "$task_file" \
		| analyse_function_raw_doc "${task_name}_${cmd_name}" \
		| analyse_function_raw_input \
		| egrep "@params?" \
		| head -n $n )

	local comp_func=$( echo "$n_raw_params" | egrep "^@params" | sed -E "s:@params$input_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null

	comp_func=$( echo "$n_raw_params" | awk "NR==$n{print;exit}" | sed -E "s:@params?$input_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null
}


