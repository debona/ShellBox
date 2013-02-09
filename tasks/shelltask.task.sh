#!/bin/bash
#
#

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

	local task_dirs=$( echo $SHELLTASK_DIRS | tr -s ':' ' ' )
	for task_file in `find $task_dirs -type f -name '*.task.sh'`
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

	ln -s "shelltask" "$SHELLTASK_ROOT/path/$task_name" &> /dev/null

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
		local task_dirs=$( echo $SHELLTASK_DIRS | tr -s ':' ' ' )
		for task_file in `find $task_dirs -type f -name '*.task.sh'`
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
