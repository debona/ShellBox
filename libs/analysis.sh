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
# @param task_file the task file
# @param cmd_name the command name
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


## Extract command parameters
# Format: @param(s)? {completion_function} name description of the parameter
#
# @param {file} task_file the task file
# @param cmd_name the command name
function command_raw_params() {
	task_file="$1"
	cmd_name="$2"

	regex="#$SPACE*(@param(s)?$SPACE+.*)$"

	command_raw_doc "$task_file" "$cmd_name" | egrep "$regex" | sed -E "s:$regex:\1:g"
}


## Extract command parameter names as single line
# Format: param1 param2*
# Star * marks variable arity
#
# @param {file} task_file the task file
# @param cmd_name the command name
function command_params_line() {
	task_file="$1"
	cmd_name="$2"

	comp_func="\{[^\}]*\}" # match the completion function
	param="[^ 	]+" # match the first word after @param

	regex="($SPACE+${comp_func})?$SPACE+(${param}).*$"

	command_raw_params "$task_file" "$cmd_name" \
		| sed -E "s:@param$regex: \2:g" \
		| sed -E "s:@params$regex: \2${yellowf}*${reset}:g" \
		| tr -d '\n'
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

	echo
	echo "NAME"
	echo "	${purplef}$task_name${reset} -$short"

	echo
	echo "SYNOPSIS"
	# TODO : default command
	for command in $commands
	do
		params=$(command_params_line "$task_file" "$command")
		echo "	${purplef}$task_name${reset} ${bluef}$command${reset}$params"
	done

	echo
	echo "DESCRIPTION"
	echo "$description"

	echo
	echo "COMMANDS"
	# TODO : default command
	for command in $commands
	do
		echo
		# TODO : command_doc
		params=$(command_params_line "$task_file" "$command")
		echo "	${purplef}$task_name${reset} ${bluef}$command${reset}$params"
		command_raw_doc "$task_file" "$command" | sed -E "s/^#[# 	]*(.*)$/		\1/g"
		command_raw_params "$task_file" "$command"
	done
}

