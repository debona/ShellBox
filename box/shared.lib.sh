#!/bin/bash
#
# Shared commands with all libraries
# When you execute a library command, if the command is not found in the library, then the command is execute with this library (shared).
# That means shared is always required before to execute your library commands.



####################################################################
###########                  COMMANDS                    ###########
####################################################################

## Display a short help of the library or the help of the library command provided
#
# @param	[command_name]	The command name
function shared::help() {
	[[ -n $1 ]] && shared_command_help "$1" || shared_library_help
}


## Display a detailed manual of the library.
#
function shared::man() {
	require "analyse.lib.sh"

	analyse::library_doc "$LIB_FILE" | less -R
}


####################################################################
###########              PRIVATE FUNCTIONS               ###########
####################################################################

## Display a short help of the library. i.e. list of available commands with options
#
function shared_library_help() {
	require "analyse.lib.sh"

	local cmd_list=$( analyse::extract_commands $LIB_FILE)
	local file_content=$( cat $LIB_FILE )

	echo "Available commands for this library:"

	echo "$cmd_list" | while read _command # the while loop avoids to ignore blank line
	do
		echo -n "    "
		echo "$file_content" \
			| analyse::function_raw_doc "${LIB_NAME}::${_command}" \
			| analyse::function_raw_input \
			| analyse::function_synopsis "${boldon}${purplef}$LIB_NAME ${bluef}${_command}${reset}"
	done
}

## Display the help of the library command.
#
# @param	command_name	the library command name
function shared_command_help() {
	require "analyse.lib.sh"

	local cmd_list=$( analyse::extract_commands $LIB_FILE)
	local file_content=$( cat $LIB_FILE )

	if echo "$cmd_list" | egrep "^$1$" &> /dev/null
	then
		echo "$file_content" | analyse::command_doc "$LIB_NAME" "$1"
	else
		cli::failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$LIB_NAME ${redf}$1${reset}"
		return 1
	fi
}