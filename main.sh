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

[[ ":$SHELLBOXES:" =~ ":$SHELLBOX_ROOT/box:" ]] || SHELLBOXES="$SHELLBOX_ROOT/box:$SHELLBOXES"


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
# @param	lib_name	The name of the library to source
function require() {
	local lib_name="$1"
	local fullpath=$( locate_library_file $lib_name )

	if ! source "$fullpath"
	then
		echo "$lib_name cannot be sourced from path:"
		echo "SHELLBOXES=$SHELLBOXES"
		return 1
	fi
}

## Include all the commands available in the given library
# This mechanism rely on the `require` and the `list_library_commands` functions.
# Return 1 if the file can't be required
#
# @param	lib_name	The name of the library to include
function include() {
	local lib_name="$1"
	require "$lib_name" || return 1

	local _commands=$( list_library_commands $lib_name )
	for _command in $_commands
	do
		if ! type "${LIB_NAME}::${_command}" &> /dev/null
		then
			eval "function ${LIB_NAME}::${_command}() {
				${lib_name}::${_command} \"\$@\"
			}"
		fi
	done
}

## Find a library file across all directories present in SHELLBOXES.
# It print the path of the last library file which match.
# Return 1 if the file can't be found in SHELLBOXES
#
# @param	lib_name	The name of the library to locate
function locate_library_file() {
	local lib_name="$1"
	local library_dirs=$( echo $SHELLBOXES | tr ':' ' ' )
	local fullpath=$( find $library_dirs -type f -name "${lib_name}.lib.sh" | tail -1 )

	echo "$fullpath"
	[[ -z "$fullpath" ]] && return 1
}

## List all library name which are available in SHELLBOXES
#
function list_library_names() {
	local library_dirs=$( echo $SHELLBOXES | tr ':' ' ' )
	find $library_dirs -type f -name '*.lib.sh' -exec basename {} '.lib.sh' \; | sort -u
}

## List all commands available in the given library
#
# @param	lib_name	The name of the library
function list_library_commands() {
	local lib_name="$1"

	local reg="^${lib_name}::"
	local declared_func
	if [[ -n "$BASH" ]]
	then
		declared_func=$( require "$lib_name" && typeset -F | sed 's/declare -f //g' ) # the require is inside the fork to avoid to leak all the functions
	else
		declared_func=$( require "$lib_name" && functions | grep ' \(\) {' | sed 's/ \(\) \{//g' )
	fi
	echo "$declared_func" | egrep "$reg" | sed -E "s/$reg//g"
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
	LIB_NAME="$1" # TODO: refactor the name of these var with something like: SELF_NAME, etc
	LIB_FILE=$( locate_library_file ${LIB_NAME} )
	CMD_NAME="$2"
	shift # can't run `shift 2` because if there is only one arg, it fails
	shift

	require 'shared'
	require "${LIB_NAME}" || return 1

	if _command_function "$LIB_NAME" "$CMD_NAME" &> /dev/null
	then
		# The library command exists
		local cmd_function=$( _command_function "$LIB_NAME" "$CMD_NAME" )
		$cmd_function "$@"
	else
		# The library command does not exist
		# Display the error
		require 'cli'
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

run_library_command `basename "$0" ".lib.sh"` "$@"
