#!/bin/bash
#
# Shared commands with all libraries
# When you execute a library command, if the command is not found in the library, then the command is execute with this library (shared).
# That means shared is always required before to execute your library commands.


## Display a short help of the library. i.e. list of available commands
#
function shared::help() {
	# TODO should take command as $1
	# TODO should take library as $1 and command as $2
	require "analyse.task.sh"

	local cmd_list=$( analyse::extract_commands $LIB_FILE)
	echo "Available commands for this library:"
	echo "$cmd_list" | sed -E "s:(.*):	- ${boldon}${purplef}$LIB_NAME ${bluef}\1${reset}:g"
}


## Display a detailed manual of the library.
#
function shared::man() {
	# TODO should take command as $1
	# TODO should take library as $1 and command as $2
	require "analyse.task.sh"

	analyse::library_doc "$LIB_FILE" | less -R
}
