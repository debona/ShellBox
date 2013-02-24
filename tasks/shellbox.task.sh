#!/bin/bash
#
# Shellbox commands
# This is the main library as it provides you information about your shellbox install and all your library.


TODOS_REGEX=".*TODO[ 	:]+(.*)"


####################################################################
###########                  COMMANDS                    ###########
####################################################################

## List all TODOs of the ShellBox project
#
function shellbox::todos() {
	echo "${bluef}${boldon}==================== Root: ====================${reset}"
	extract_todos $SHELLBOX_ROOT/*.sh

	echo "${bluef}${boldon}================== Libraries: ==================${reset}"
	for path in `echo "$SHELLBOX_DIRS" | tr ':' '\n'`
	do
		extract_todos $path/*.sh
	done
}


## The default command.
# Run the `status` command with no options.
#
function shellbox::() {
	shellbox::status
}


## Print the status of your shellbox install
# Not yet implemented
#
function shellbox::status() {
	echo "Not yet implemented."
	# TODO shellbox is it in the path
	# TODO info about library dirs
	# TODO list of all library shortcuted
}


## Print the list of all the libraries available.
#
function shellbox::libraries() {
	require "analyse.task.sh"

	for lib_name in `list_library_names`
	do
		local lib_file=$( locate_library_file "${lib_name}.task.sh" )
		local short=$( cat "$lib_file" | analyse::file_raw_doc | sed -E "s/^#[# 	]*(.*)$/\1/g" | head -n 1 )
		echo " - ${purplef}${boldon}$lib_name${reset} - $short"
	done
}


## Create a shortcut for the given libraries
# A shortcut allow you to run directly a library without prefix it with `shellbox my_library ...`
# It simply create a symlink in the `path` folder which target the `main.sh` library executer.
#
# @param	lib_name	The name of the library to shortcut. 'all' create a shortcut for all available libraries.
function shellbox::shortcut() {
	local library="$1"

	if [[ "$library" = "all" ]]
	then
		for lib_name in `list_library_names`
		do
			shortcut $lib_name
		done
	else
		for lib_name in $@
		do
			shortcut $lib_name
		done
	fi
}


## Delete a shortcut for the given libraries
# Not yet implemented.
#
function shellbox::unshortcut() {
	echo "Not yet implemented."
}


# This hack allow shellbox to get all libraries as shellbox commands
for lib_name in `list_library_names`
do
	if ! [[ "$lib_name" = 'shellbox' ]]
	then
		eval "function shellbox::$lib_name() {
			run_library_command $lib_name \"\$@\"
		}"
	fi
done


####################################################################
###########              PRIVATE FUNCTIONS               ###########
####################################################################

## Extract TODOs from a given file content or given files list
#
# @stdin	[file_content]	the content of the file to parse
# @params	[file_list]		The list of the files to analyse
function extract_todos() {
	if ! [[ -t 0 ]]
	then # if stdin is NOT a tty
		cat | egrep "$TODOS_REGEX" | sed -E "s/$TODOS_REGEX/\1/g"
	fi

	for file in "$@"
	do
		local todos=$( cat "$file" | extract_todos | sed -E "s/(.*)/	● \1/g" )
		[[ -z $todos ]] && continue # continue if no TODOs

		echo "${greenf}`basename $file`${reset}"
		echo "$todos"
	done
}


## Create a shortcut for the given library.
#
# @param	lib_name	The name of the library to shortcut.
function shortcut() {
	require 'cli.task.sh'

	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name.task.sh" )

	if ! [[ -r "$lib_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	ln -s "../main.sh" "$SHELLBOX_ROOT/path/$lib_name" &> /dev/null

	if [[ -x "$SHELLBOX_ROOT/path/$lib_name" ]]
	then
		cli::step "${boldon}${bluef}$lib_name${reset} available"
		return 0
	else
		cli::failure "couldn't shortcut $1${reset}"
		return 1
	fi
}
