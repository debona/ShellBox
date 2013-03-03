#!/bin/bash
#
# Shellbox commands
# This is the main library as it provides you information about your shellbox install and all your library.


include 'shared'

TODOS_REGEX=".*TODO[ 	:]+(.*)"


####################################################################
###########                  COMMANDS                    ###########
####################################################################

## The default command.
# Run the `status` command with no options.
#
function shellbox::() {
	shellbox::status
}


## List all TODOs of the ShellBox project
#
function shellbox::todos() {
	echo "${bluef}${boldon}==================== Root: ====================${reset}"
	extract_todos $SHELLBOX_ROOT/*.sh

	echo "${bluef}${boldon}================== Libraries: ==================${reset}"
	for path in `echo "$SHELLBOXES" | tr ':' '\n'`
	do
		extract_todos $path/*.sh
	done
}


## Print the status of your shellbox install
# Not yet implemented
#
function shellbox::status() {
	require 'cli'

	if which shellbox &> /dev/null
	then
		cli::step "shellbox is available in your PATH"
	else
		cli::warning "shellbox is NOT available in your PATH"
	fi

	shellbox::libraries

	cli::step "Library shortcuts"
	for lib_name in `list_library_names`
	do
		if [[ -x "$SHELLBOX_ROOT/bin/$lib_name" ]]
		then
			echo "   - ${purplef}${boldon}$lib_name${greenf} shortcuted${reset}"
		else
			echo "   - ${purplef}${boldon}$lib_name${redf} NOT shortcuted${reset}"
		fi
	done
}


## Print the list of all the libraries available.
#
function shellbox::libraries() {
	require 'analyse'
	require 'cli'

	cli::step "Available libraries:"
	for lib_name in `list_library_names`
	do
		local lib_file=$( locate_library_file "${lib_name}" )
		local short=$( cat "$lib_file" | analyse::file_raw_doc | sed -E "s/^#[# 	]*(.*)$/\1/g" | head -n 1 )
		echo "   - ${purplef}${boldon}$lib_name${reset} - $short"
	done
}


## Create a shortcut for the given libraries
# A shortcut allow you to run directly a library without prefix it with `shellbox my_library ...`
# It simply create a symlink in the `bin` folder which target the `main.sh` library executer.
#
# @params	lib_names	The names of the libraries to shortcut. 'all' create a shortcut for all available libraries.
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
# It simply delete the symlink in the `bin` folder which match the given library name.
#
# @params	lib_names	The names of the libraries to unshortcut.
function shellbox::unshortcut() {
	local library="$1"

	for lib_name in $@
	do
		unshortcut $lib_name
	done
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
# @param	lib_name	The name of the library to shortcut
function shortcut() {
	require 'cli'

	local lib_name="$1"
	local lib_file=$( locate_library_file "$lib_name" )

	if ! [[ -r "$lib_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	ln -s "../main.sh" "$SHELLBOX_ROOT/bin/$lib_name" &> /dev/null

	if [[ -x "$SHELLBOX_ROOT/bin/$lib_name" ]]
	then
		cli::step "${boldon}${bluef}$lib_name${reset} available"
		return 0
	else
		cli::failure "couldn't shortcut $lib_name${reset}"
		return 1
	fi
}

## Delete a shortcut for the given library.
#
# @param	lib_name	The name of the library to unshortcut
function unshortcut() {
	require 'cli'

	local lib_name="$1"
	local shortcut="$SHELLBOX_ROOT/bin/$lib_name"

	if [[ "$lib_name" = 'shellbox' ]]
	then
		cli::failure "Couldn't unshortcut $lib_name"
		echo "   To delete this shortcut manually, run the following command:"
		echo " > rm \"$shortcut\""
		return 1
	fi

	rm -f "$shortcut" &> /dev/null

	if [[ -e $shortcut ]]
	then
		cli::failure "Couldn't unshortcut $lib_name:"
		rm -f "$shortcut"
	else
		cli::step "${boldon}${bluef}$lib_name${reset} no more available"
	fi
}
