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

	local param_number=0
	((param_number = comp_count + 2))
	local current="${!param_number}" # it can be empty

	if [[ $comp_count -eq 1 ]] # the user is currently completing the cmd_name (parameter #2)
	then
		complete::commands "$lib_name" "$cmd_name"
	else # comp_count >= 2
		local option_number=0
		((option_number = comp_count - 1))

		complete::option "$lib_name" "$cmd_name" "$option_number" $current
	fi
}


## List all commands of a library file
#
# @param	lib_name	the library name
# @param	current		the currently completed command
function complete::commands() {
	local lib_name="$1"
	local current="$2"

	list_library_commands "$lib_name" | egrep "^$current"
}

## Try to auto-complete the nth parameter of the given command
#
# @param	lib_file		the library file
# @param	cmd_name		the command name
# @param	option_number	the number the option to complete
# @param	current			the currently completed option
function complete::option() {
	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )
	local cmd_name="$2"
	local n="$3"
	local current="$4"

	require 'analyse'
	{
		local n_raw_params=$( cat "$lib_file" \
			| analyse::function_raw_doc "${lib_name}::${cmd_name}" \
			| analyse::function_raw_input \
			| egrep "@params?" \
			| head -n $n )

		local comp_func=$( echo "$n_raw_params" | egrep "^@params" | sed -E "s:@params$input_comp_name:\2:g" )
		eval "$comp_func"

		comp_func=$( echo "$n_raw_params" | awk "NR==$n{print;exit}" | sed -E "s:@params?$input_comp_name:\2:g" )
		eval "$comp_func"
	} 2> /dev/null | egrep "^$current"
}

