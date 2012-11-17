#!/bin/bash
#
# Task analysis library

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_LIBS="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_LIBS="$( cd -P "$( dirname "$0" )" && pwd )"
fi

source "$SHELLTASK_LIBS/regex.sh"


## Extract the file raw documentation
# Raw documentation means concerned comment lines
#
# @param the task file
function file_raw_doc() {
	task_file="$1"
	match "$task_file" "(($SOL#[^$EOL]*$EOL)+)$BL" 1
}


## Extract the command raw documentation
# Raw documentation means concerned comment lines
#
# @param the task file
# @param the command name
function command_raw_doc() {
	task_file="$1"
	task_name="$(basename $task_file .task.sh)"
	cmd_name="$2"
	function_name=$"${task_name}_${cmd_name}"

	match "$task_file" "(($SOL#[^$EOL]*$EOL)+)$SOL($EOL$SOL)*$SPACE*(function$SPACE)?$SPACE*${function_name}$SPACE*\(" 1
}

