#!/usr/bin/env shellbox
#
# Shellbox commands
# This is the main library as it provides you information about your shellbox install and all your library.


require 'shared'

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


## Display a short help of the library or the help of the library command provided
#
# @param {list_library_commands shellbox}	[command_name]	The command name
function shellbox::help() {
	if [[ -z $1 ]]
	then
		shared::help 'shellbox'
	elif locate_library_file "$1" &> /dev/null
	then
		shared::help "$@"
	else
		shared::help 'shellbox' "$@"
	fi
}


## Display a detailed manual of the library.
#
function shellbox::man() {
	[[ -n $1 ]] && shared::man "$1" || shared::man 'shellbox'
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


## Sample library
#
# @params {complete::sublibrary $@}	options		sample library options
function shellbox::sample() {
	run_library_command "sample" "$@"
}

# This hack allow shellbox to get all libraries as shellbox commands
for lib_name in `list_library_names`
do
	if ! [[ "$lib_name" = 'shellbox' ]] || type "shellbox::${lib_name}" &> /dev/null
	then
		eval "function shellbox::${lib_name}() {
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
