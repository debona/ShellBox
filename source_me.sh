#!/bin/bash
#
## Creates some aliases
#

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
fi

SHELLTASK_LIBS="$SHELLTASK_ROOT/libs"

source "$SHELLTASK_LIBS/ui.sh"
source "$SHELLTASK_LIBS/complete.sh"

# TODO : manage multiple paths in SHELLTASK_PATH
SHELLTASK_PATH="$SHELLTASK_ROOT/tasks"


## autocompletion function called when TAB key is pressed
#
function _complete() {
	local task_name="${COMP_WORDS[0]}" # first word of the line
	local current="${COMP_WORDS[COMP_CWORD]}" # the word currently auto-completed

	local task_file="$SHELLTASK_PATH/$task_name.task.sh"

	if [ "$COMP_CWORD" -eq 1 ] # if only one word in the line
	then
		# try to autocomplete with subcommand
		COMPREPLY=( $( _list_commands $task_file | egrep "^$current" ) )
	else
		# TODO extract the completion function of the Nth param

		# if there is more than 2 words
		# try to autocomplete with files in current directory
		COMPREPLY=( $( compgen -f $current ) )
	fi
}


## Load task
#
# @param	task_file	The task file
function load_task() {
	local task_file="$1"
	local task_name=$( basename "$task_file" '.task.sh' )

	if ! [[ -r "$task_file" ]]
	then
		echo "${redb}${boldon} ✗ could not read $1:${reset}"
		return 1
	fi

	if alias "$task_name"="$SHELLTASK_ROOT/shelltask.sh $task_file"
	then
		echo "${boldon} ● ${bluef}$task_name${reset} available"

		# generate autocompletion for this command
		complete -F _complete "$task_name"
		return 0
	else
		echo "${redb}${boldon} ✗ couldn't import $1:${reset}"
		return 1
	fi
}

for task_file in `find $SHELLTASK_PATH -type f -maxdepth 1 | egrep '.sh$'`
do
	load_task "$task_file"
done

