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
# @param the file
function file_raw_doc() {
	task_file="$1"
	match "$task_file" "($SOL#(![^$EOL]+)?$EOL)*(($SOL#[^$EOL!]*$EOL)+)$BL" 3
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


## Extract commands from a task file
#
# @param the task file
function extract_commands() {
	task_file="$1"
	task_name="$(basename $task_file .task.sh)"

	regex="^(function$SPACE+)?${task_name}_([^\( 	]+)$SPACE*\(.*$"

	egrep "$regex" "$task_file" | sed -E "s:$regex:\2:g"
}

## Generate the file documentation
#
# @param the file
function file_doc() {
	file="$1"
	file_name=$(basename $file)

	description=$(file_raw_doc $file | sed -E "s/^#[# 	]*(.*)$/	\1/g")
	short=$(echo "$description" | head -n 1)

	echo "FILE"
	echo "	${purplef}$file_name${reset} -$short"
	echo "DESCRIPTION"
	echo "$description"
}

## Generate the task file documentation
#
# @param the task file
function task_doc() {
	task_file="$1"
	task_name=$(basename $task_file .task.sh)

	description=$(file_raw_doc $task_file | sed -E "s/^#[# 	]*(.*)$/	\1/g")
	short=$(echo "$description" | head -n 1)

	commands=$(extract_commands $task_file)

	echo "NAME"
	echo "	${purplef}$task_name${reset} -$short"

	echo "SYNOPSIS"
	# TODO : default command
	for command in $commands
	do
		# TODO : extract command params
		echo "	${purplef}$task_name${reset} ${bluef}$command${reset} options"
	done

	echo "DESCRIPTION"
	echo "$description"

	echo "COMMANDS"
	# TODO : default command
	for command in $commands
	do
		echo
		# TODO : command_doc
		echo "	${bluef}$command${reset}"
		command_raw_doc $task_file $command | sed -E "s/^#[# 	]*(.*)$/		\1/g"
	done
}

