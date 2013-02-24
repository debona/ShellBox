#!/bin/bash
#
# Library command executer
# This script execute library commands of a given library. It is the only script which can be execute.
# The library name is given by $0, so you must create a symlink with the name of the library which target this script.
#
# @param	command		The library command to run
# @params	options		All the library command options


####################################################################
###########                 GLOBAL VARS                  ###########
####################################################################

SHELLBOX_ROOT="$( cd -P "`dirname "$0"`/.." && pwd )"

[[ ":$SHELLBOX_DIRS:" =~ ":$SHELLBOX_ROOT/tasks:" ]] || SHELLBOX_DIRS="$SHELLBOX_ROOT/tasks:$SHELLBOX_DIRS"


####################################################################
###########               GLOBAL FUNCTIONS               ###########
####################################################################

## Define colors.
# From http://www.intuitive.com/wicked/showscript.cgi?011-colors.sh
# Author: Dave Taylor
function enableColors()
{
	esc=""

	blackf="${esc}[30m";	redf="${esc}[31m";		greenf="${esc}[32m";
	yellowf="${esc}[33m";	bluef="${esc}[34m";		purplef="${esc}[35m";
	cyanf="${esc}[36m";		whitef="${esc}[37m";

	blackb="${esc}[40m";	redb="${esc}[41m";		greenb="${esc}[42m";
	yellowb="${esc}[43m";	blueb="${esc}[44m";		purpleb="${esc}[45m";
	cyanb="${esc}[46m";		whiteb="${esc}[47m";

	boldon="${esc}[1m";		boldoff="${esc}[22m";
	italicson="${esc}[3m";	italicsoff="${esc}[23m";
	ulon="${esc}[4m";		uloff="${esc}[24m";
	invon="${esc}[7m";		invoff="${esc}[27m";

	reset="${esc}[0m";
}

## Undefine colors to write readable log files.
#
function disableColors() {
	unset esc

	unset blackf;		unset redf;		unset greenf;
	unset yellowf;		unset bluef;	unset purplef;
	unset cyanf;		unset whitef;

	unset blackb;		unset redb;		unset greenb;
	unset yellowb;		unset blueb;	unset purpleb;
	unset cyanb;		unset whiteb;

	unset boldon;		unset boldoff;
	unset italicson;	unset italicsoff;
	unset ulon;			unset uloff;
	unset invon;		 unset invoff;

	unset reset;
}


## Source the library file.
# This mechanism rely on the `locate_library_file` function.
# Return 1 if the file can't be sourced
#
# @param	file	The file to source but not the path (i.e. awesome_library.task.sh)
function require() {
	local file="$1"
	local fullpath=$( locate_library_file $file )

	if ! source "$fullpath"
	then
		echo "$file cannot be sourced from path:"
		echo "SHELLBOX_DIRS=$SHELLBOX_DIRS"
		return 1
	fi
}

## Find a library file across all directories present in SHELLBOX_DIRS.
# It print the path of the last library file which match.
# Return 1 if the file can't be found in SHELLBOX_DIRS
#
# @param	file	The file to locate but not the path (i.e. awesome_library.task.sh)
function locate_library_file() {
	local library_filename="$1"
	local library_dirs=$( echo $SHELLBOX_DIRS | tr ':' ' ' )
	local fullpath=$( find $library_dirs -type f -name '*.task.sh' | egrep "$library_filename$" | tail -1 )

	echo "$fullpath"
	[[ -z "$fullpath" ]] && return 1
}

## List all library name which are available in SHELLBOX_DIRS
#
function list_library_names() {
	local library_dirs=$( echo $SHELLBOX_DIRS | tr ':' ' ' )
	find $library_dirs -type f -name '*.task.sh' -exec basename {} '.task.sh' \; | sort -u
}


####################################################################
###########               PRIVATE FUNCTIONS              ###########
####################################################################

## Print the command function for the given library and command.
# Return 1 if the command does not exist.
#
# @param	library_name	the library name
# @param	cmd_name	the command
function _command_function() {
	local library_name="$1"
	local cmd_name="$2"

	local cmd_function="${library_name}::${cmd_name}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	cmd_function="shared::${cmd_name}"
	if type $cmd_function &> /dev/null
	then
		echo $cmd_function
		return
	fi

	return 1
}


## Run a library command with options.
# This is the main function of shellbox.
#
# @param	LIB_NAME	the library name
# @param	CMD_NAME	the command name
# @params	options		the options
function run_library_command() {
	# All this vars are reachable by the librarys
	LIB_NAME="$1"
	LIB_FILE=$( locate_library_file ${LIB_NAME}.task.sh )
	CMD_NAME="$2"
	shift # can't run `shift 2` because if there is only one arg, it fails
	shift

	require "shared.task.sh"
	require "${LIB_NAME}.task.sh" || return 1

	if _command_function "$LIB_NAME" "$CMD_NAME" &> /dev/null
	then
		# The library command exists
		local cmd_function=$( _command_function "$LIB_NAME" "$CMD_NAME" )
		$cmd_function "$@"
	else
		# The library command does not exist
		# Display the error
		require "cli.task.sh"
		cli::failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$LIB_NAME ${redf}$CMD_NAME${reset}"
		# Run the help command on the library
		local cmd_function=$( _command_function "$LIB_NAME" "help" )
		$cmd_function
		return 1
	fi
}


####################################################################
###########               EXEC LIB COMMAND               ###########
####################################################################

enableColors
[[ -t 1 ]] && [[ -t 2 ]] || disableColors # Disable color in shell if the outputs are not tty

run_library_command `basename "$0" ".task.sh"` "$@"
