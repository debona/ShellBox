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

## Source the library file.
# This mechanism rely on the `locate_library_file` function.
# Return 1 if the file can't be sourced
#
# @param	lib_name	The name of the library to source
function require() {
	local lib_name="$1"
	local lib_file=$( locate_library_file $lib_name )
	local status=0

	if ! source "$lib_file"
	then
		status=$?
		echo "$lib_name cannot be sourced from path:"
		echo "SHELLBOXES=$SHELLBOXES"
	fi

	return $status
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

	[[ -n $fullpath ]] && echo "$fullpath" || return 1
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

	return 1
}


## Run a library command with options.
# This is the main function of shellbox.
#
# @param	lib_name	the library name
# @param	cmd_name	the command name
# @params	options		the options
function run_library_command() {
	local lib_name="$1"
	local cmd_name="$2"

	shift # can't run `shift 2` because if there is only one arg, it doesn't shift at all
	shift

	require "${lib_name}" || return 1

	if _command_function "$lib_name" "$cmd_name" &> /dev/null
	then
		# The library command exists
		local cmd_function=$( _command_function "$lib_name" "$cmd_name" )
		$cmd_function "$@"
	else
		# The library command does not exist
		# Display the error
		require 'cli'
		cli::failure "This command does not exist:"
		echo "	- ${boldon}${purplef}$lib_name ${redf}$cmd_name${reset}"
		# Run the help command on the library
		local cmd_function=$( _command_function "$lib_name" "help" )
		$cmd_function
		return 1
	fi
}


####################################################################
###########               EXEC LIB COMMAND               ###########
####################################################################

run_library_command `basename "$0" ".lib.sh"` "$@"
