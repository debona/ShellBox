#!/bin/bash
#
#


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
function shelltask_todos() {
	echo "${bluef}${boldon}==================== Root: ====================${reset}"
	extract_todos $SHELLTASK_ROOT/*.sh

	echo "${bluef}${boldon}==================== Tasks: ====================${reset}"
	for path in `echo "$SHELLTASK_DIRS" | tr ':' '\n'`
	do
		extract_todos $path/*.sh
	done
}


##
#
#
function shelltask_() {
	shelltask_status
}


##
#
#
function shelltask_status() {
	echo
	# TODO shelltask is it in the path
	# TODO info about task dirs
	# TODO list of all task shortcuted
}


##
#
#
function shelltask_tasks() {
	require "analyse.task.sh"

	for task_file in `list_taskfiles`
	do
		local task_name=$( basename "$task_file" ".task.sh" )
		local short=$( cat "$task_file" | analyse_file_raw_doc | sed -E "s/^#[# 	]*(.*)$/\1/g" | head -n 1 )
		echo " - ${purplef}${boldon}$task_name${reset} - $short"
	done
}


## Create a shortcut for the given task
#
# @param	task_name	name of the task to shortcut
function shortcut() {
	local task_name="$1"
	local task_file=$( locate_taskfile "$task_name.task.sh" )

	if ! [[ -r "$task_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	ln -s "$SHELLTASK_ROOT/main.sh" "$SHELLTASK_ROOT/path/$task_name" &> /dev/null

	if [[ -x "$SHELLTASK_ROOT/path/$task_name" ]]
	then
		echo "${boldon} ● ${bluef}$task_name${reset} available"
		return 0
	else
		echo "${redb}${boldon} ✗ couldn't import $1:${reset}"
		return 1
	fi
}


## Create a shortcut for the given tasks
#
# @params	task_names	name of the tasks to shortcut
function shelltask_shortcut() {
	local task="$1"

	if [[ "$task" = "all" ]]
	then
		for task_file in `list_taskfiles`
		do
			shortcut `basename $task_file ".task.sh"`
		done
	else
		for task_name in $@
		do
			shortcut $task_name
		done
	fi
}


##
#
#
function shelltask_unshortcut() {
echo
}


for task_file in `list_taskfiles`
do
	local task_name=$( basename "$task_file" ".task.sh" )
	if ! [[ "$task_name" = 'shelltask' ]]
	then
		eval "function shelltask_$task_name() {
			run_task_command $task_name \"\$@\"
		}"
	fi
done
