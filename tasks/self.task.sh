#!/bin/bash
#
# Tools for ShellTask project's developers
# self reference the ShellTask project.



TODOS_REGEX=".*TODO[ 	:]+(.*)"

## Extract TODOs from a given file content or given files list
#
# @stdin	[file_content]	the content of the file to parse
# @params	[file_list]		The list of the files to analyse
function extract_todos() {

	if ! [[ -t 0 ]]
	then # if stdin is a tty
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

## List all TODOs of the ShellTask project
function self_todos() {
	echo "${bluef}${boldon}==================== Root: ====================${reset}"
	extract_todos $SHELLTASK_ROOT/*.sh

	echo "${bluef}${boldon}==================== Libraries: ===============${reset}"
	extract_todos $SHELLTASK_LIBS/*.sh

	echo "${bluef}${boldon}==================== Tasks: ====================${reset}"
	extract_todos $SHELLTASK_TASKS/*.sh
}

