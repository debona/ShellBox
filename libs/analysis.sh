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

# Some common pattern used for analysis

comment_line="($SOL#[^$EOL!]*$EOL)" # match a comment line



## Extract the file raw documentation
# Raw documentation means concerned comment lines
#
# @param the file
function file_raw_doc() {
	task_file="$1"

	bin_bash_line="($SOL#(![^$EOL]+)?$EOL)" # match `#!/bin/bash` line or empty line

	match "$task_file" "${bin_bash_line}*(${comment_line}+)$BL" 3
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

	special_comment_line="($SOL##[^$EOL]*$EOL)" # match a special comment line like `## special comment`

	match "$task_file" "(${special_comment_line}${comment_line}*)($BL)*$SOL$SPACE*(function$SPACE)?$SPACE*${function_name}$SPACE*\(" 1
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
	task_name="$(basename $task_file .task.sh)"
	cmd_name="$2"

	comp_func="\{[^\}]*\}" # match the completion function
	param="[^ 	]+" # match the first word after @param

	regex="($SPACE+${comp_func})?$SPACE+(${param}).*$"

	params=$(command_raw_params "$task_file" "$cmd_name" \
		| sed -E "s:@param$regex: \2:g" \
		| sed -E "s:@params$regex: \2${yellowf}*${reset}${boldon}:g" \
		| tr -d '\n')

	echo "${boldon}${purplef}$task_name ${bluef}$cmd_name${reset}${boldon}$params${reset}"
}


## Generate the task file documentation
#
# @param the task file
function command_doc() {
	task_file="$1"
	task_name="$(basename $task_file .task.sh)"
	cmd_name="$2"

	command_params_line "$task_file" "$cmd_name"

	comp_func="\{[^\}]*\}" # match the completion function
	param="[^ 	]+" # match the first word after @param

	regex="($SPACE+${comp_func})?$SPACE+(${param})$SPACE*(.*)$"

	command_raw_params "$task_file" "$cmd_name" \
		| sed -E "s/@param$regex/	${boldon}\2${reset} : \3$/g" \
		| sed -E "s/@params$regex/	${boldon}\2${yellowf}*${reset} : \3/g"

	command_raw_doc "$task_file" "$cmd_name" \
		| sed -E "/#$SPACE*@param(s)?/d" \
		| sed -E "s/^#[# 	]*(.*)$/	\1/g" \
		| sed "/^$SPACE*$/d"
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
	echo "${boldon}NAME${reset}"
	echo "	${purplef}${boldon}$task_name${reset} -$short"

	echo
	echo "${boldon}SYNOPSIS${reset}"
	# TODO : default command
	for command in $commands
	do
		command_params_line "$task_file" "$command" | sed -E "s:(.*):	\1:g"
	done

	echo
	echo "${boldon}DESCRIPTION${reset}"
	echo "$description"

	echo
	echo "${boldon}COMMANDS${reset}"
	# TODO : default command
	for command in $commands
	do
		command_doc "$task_file" "$command" | sed -E "s:(.*):	\1:g"
		echo
	done
}

