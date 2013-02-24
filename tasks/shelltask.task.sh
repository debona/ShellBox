#!/bin/bash
#
# Shelltask commands
# This is the main task as it provides you information about your shelltask install and all your task.


TODOS_REGEX=".*TODO[ 	:]+(.*)"


####################################################################
###########                  COMMANDS                    ###########
####################################################################

## List all TODOs of the ShellTask project
#
function shelltask::todos() {
	echo "${bluef}${boldon}==================== Root: ====================${reset}"
	extract_todos $SHELLTASK_ROOT/*.sh

	echo "${bluef}${boldon}==================== Tasks: ====================${reset}"
	for path in `echo "$SHELLTASK_DIRS" | tr ':' '\n'`
	do
		extract_todos $path/*.sh
	done
}


## The default command.
# Run the `status` command with no options.
#
function shelltask::() {
	shelltask::status
}


## Print the status of your shelltask install
# Not yet implemented
#
function shelltask::status() {
	echo "Not yet implemented."
	# TODO shelltask is it in the path
	# TODO info about task dirs
	# TODO list of all task shortcuted
}


## Print the list of all the tasks available.
#
function shelltask::tasks() {
	require "analyse.task.sh"

	for task_name in `list_task_names`
	do
		local task_file=$( locate_task_file "${task_name}.task.sh" )
		local short=$( cat "$task_file" | analyse::file_raw_doc | sed -E "s/^#[# 	]*(.*)$/\1/g" | head -n 1 )
		echo " - ${purplef}${boldon}$task_name${reset} - $short"
	done
}


## Create a shortcut for the given tasks
# A shortcut allow you to run directly a task without prefix it with `shelltask my_task ...`
# It simply create a symlink in the `path` folder which target the `main.sh` task executer.
#
# @param	task_name	The name of the task to shortcut. 'all' create a shortcut for all available tasks.
function shelltask::shortcut() {
	local task="$1"

	if [[ "$task" = "all" ]]
	then
		for task_name in `list_task_names`
		do
			shortcut $task_name
		done
	else
		for task_name in $@
		do
			shortcut $task_name
		done
	fi
}


## Delete a shortcut for the given tasks
# Not yet implemented.
#
function shelltask::unshortcut() {
	echo "Not yet implemented."
}


# This hack allow shelltask to get all tasks as shelltask commands
for task_name in `list_task_names`
do
	if ! [[ "$task_name" = 'shelltask' ]]
	then
		eval "function shelltask::$task_name() {
			run_task_command $task_name \"\$@\"
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


## Create a shortcut for the given task.
#
# @param	task_name	The name of the task to shortcut.
function shortcut() {
	require 'cli.task.sh'

	local task_name="$1"
	local task_file=$( locate_task_file "$task_name.task.sh" )

	if ! [[ -r "$task_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	ln -s "../main.sh" "$SHELLTASK_ROOT/path/$task_name" &> /dev/null

	if [[ -x "$SHELLTASK_ROOT/path/$task_name" ]]
	then
		cli::step "${boldon}${bluef}$task_name${reset} available"
		return 0
	else
		cli::failure "couldn't shortcut $1${reset}"
		return 1
	fi
}
