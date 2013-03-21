#!/bin/bash
#
# Shared commands with all libraries


####################################################################
###########                  COMMANDS                    ###########
####################################################################

## Display a short help of the library or the help of the library command provided
#
# @param	lib_name	The library name
# @param	[cmd_name]	The command name
function shared::help() {
	local lib_name="$1"
	local cmd_name="$2"

	[[ -n $cmd_name ]] && shared:-command_help "$lib_name" "$cmd_name" || shared:-library_help "$lib_name"
}


## Display a detailed manual of the library.
#
# @param	lib_name	The library name
function shared::man() {
	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )

	require 'analyse'
	analyse::library_doc "$lib_file" | less -R
}


####################################################################
###########              PRIVATE FUNCTIONS               ###########
####################################################################

## Display a short help of the library. i.e. list of available commands with options
#
# @param	lib_name	The library name
function shared:-library_help() {
	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )

	require 'analyse'

	local cmd_list=$( analyse::extract_commands $lib_file)
	local file_content=$( cat $lib_file )

	echo "Available commands for this library:"

	echo "$cmd_list" | while read _command # the while loop avoids to ignore blank line
	do
		echo -n "    "
		echo "$file_content" \
			| analyse::function_raw_doc "${lib_name}::${_command}" \
			| analyse::function_raw_input \
			| analyse::function_synopsis "${boldon}${purplef}$lib_name ${bluef}${_command}${reset}"
	done
}

## Display the help of the library command.
#
# @param	lib_name	The library name
# @param	cmd_name	the library command name
function shared:-command_help() {
	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )
	local cmd_name="$2"

	require 'analyse'

	local cmd_list=$( analyse::extract_commands $lib_file)
	local file_content=$( cat $lib_file )

	if echo "$cmd_list" | egrep "^${cmd_name}$" &> /dev/null
	then
		echo "$file_content" | analyse::command_doc "$lib_name" "$cmd_name"
	else
		cli::failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$lib_name ${redf}$cmd_name${reset}"
		return 1
	fi
}