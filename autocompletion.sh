#!/bin/bash
#
# Auto-completion library
# This library 


## autocompletion function called when TAB key is pressed
#
function _complete() {
	local lib_name="${COMP_WORDS[0]}" # first word of the line
	local current="${COMP_WORDS[COMP_CWORD]}" # the word currently auto-completed

	local lib_file=$( locate_library_file "$lib_name.lib.sh" )

	if [ "$COMP_CWORD" -eq 1 ] # the first parameter is the command
	then
		COMPREPLY=( $( complete_commands $lib_file | egrep "^$current" ) )
	else
		local cmd_name="${COMP_WORDS[1]}"

		# The other parameter are 
		local n=$COMP_CWORD
		let 'n = n - 1'

		local options=$(complete_option $lib_file $cmd_name $n )
		local status=$?
		[[ "$status" = "0" ]] && COMPREPLY=( $( echo "$options" | egrep "^$current" ) )

		return $status
	fi
}


## List all commands of a library file
#
# @param	lib_file		the library file
function complete_commands() {
	local lib_file="$1"
	local file_content=$( cat "$lib_file" )
	local lib_name=$( basename "$lib_file" '.lib.sh' )

	local regex="^(function[ 	]+)?${lib_name}_([^\( 	]+)[ 	]*\(.*$"

	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}

## Try to auto-complete the nth parameter of the given command
#
# @param	lib_file	the library file
# @param	cmd_name	the command name
# @param	n			the "index" of the parameter
function complete_option() {
	require "analyse.lib.sh" # this source is inside the function to avoid the analyse functions leak

	local lib_file="$1"
	local file_content=$( cat "$lib_file" )
	local lib_name=$( basename "$lib_file" '.lib.sh' )
	local cmd_name="$2"
	local n="$3"

	local n_raw_params=$( cat "$lib_file" \
		| analyse_function_raw_doc "${lib_name}_${cmd_name}" \
		| analyse_function_raw_input \
		| egrep "@params?" \
		| head -n $n )

	local comp_func=$( echo "$n_raw_params" | egrep "^@params" | sed -E "s:@params$input_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null

	comp_func=$( echo "$n_raw_params" | awk "NR==$n{print;exit}" | sed -E "s:@params?$input_comp_name:\2:g" )
	eval "$comp_func" 2> /dev/null
}


