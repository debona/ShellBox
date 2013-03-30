#!/bin/bash
#
# Auto-completion commands library.

require 'shared'


####################################################################
###########                  COMMANDS                    ###########
####################################################################


## autocompletion function called when TAB key is pressed
#
function complete::dispatch() {
	local comp_count=$1
	local lib_name="$2"   # first word of the line
	local cmd_name="$3" # it can be empty

	local dispatch_number=0
	((dispatch_number = comp_count + 2))
	local current="${!dispatch_number}" # it can be empty

	# echo "complete_commands__(comp_count=$comp_count)_(lib_name=${lib_name})_(cmd=${cmd_name})_(current=$current)_(1=$1)_(2=$2)_(3=$3)"

	if [[ $comp_count -eq 1 ]] # the user is currently completing the cmd_name
	then
		complete::commands "$lib_name" "$cmd_name"
	else
		((comp_count = comp_count - 2))

		local options=$( complete::option $lib_file $cmd_name $comp_count )
		local status=$?
		[[ "$status" = "0" ]] && echo "$options" | egrep "^$current"

		return $status
	fi
}


## List all commands of a library file
#
# @param	lib_name	the library name
# @param	current		the currently completed command
function complete::commands() {
	local lib_name="$1" # first word of the line
	local current="$2"

	list_library_commands "$lib_name" | egrep "^$current"
}

## Try to auto-complete the nth parameter of the given command
#
# @param	lib_file	the library file
# @param	cmd_name	the command name
# @param	n			the "index" of the parameter
function complete::option() {
	require 'analyse'

	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )
	local file_content=$( cat "$lib_file" )
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




####################################################################
###########              PRIVATE FUNCTIONS               ###########
####################################################################
