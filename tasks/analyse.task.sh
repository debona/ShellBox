#!/bin/bash
#
# Tasks analysis
# The main purpose of this task file is to provide needed functions to build up the tasks documentation.
# It source the regex task file.

# TODO : Allow bold in documentation
# TODO : Use column instead of tabs to handle correctly the broken line
# TODO : Support @stdin
# TODO : Support @stdout, and error code ?

source "$SHELLTASK_PATH/regex.task.sh"

# Some common pattern used for analysis:

comment_line="($SOL#[^$EOL!]*$EOL)" # group 1 match a comment line
bin_bash_line="($SOL#(![^$EOL]+)?$EOL)" # group 1 match the `#!/bin/*` and empty comment line, group 2 is wasted
special_comment_line="($SOL##[^$EOL]*$EOL)" # group 1 match the trigger comment line which begin by double #

param_regex="#$SPACE*(@param(s)?$SPACE+.*)$" # group 1 match a parameter declaration line, group 2 is wasted
comp_func="\{[^\}]*\}" # match the completion function in a parameter declaration line
param_comp_name="($SPACE+${comp_func})?$SPACE+([^ 	]+)$SPACE*(.*)$" # group 1 match the completion function, group 2 match the parameter name, group 3 match the parameter details


## Extracts the file raw documentation
# The raw documentation means comment lines right after /bin/bash.
#
# @stdin	file_content	the file to analyse
function analyse_file_raw_doc() {
	local file_content
	[[ -t 0 ]] || file_content=$( cat )

	echo "$file_content" | regex_match "${bin_bash_line}*(${comment_line}+)$BL" 3
}


## Extracts the function raw documentation
# The raw documentation means these comment lines (just above the function).
#
# @stdin	file_content	the file to analyse
# @param	function_name	the function name
function analyse_function_raw_doc() {
	local function_name="$1"
	local file_content
	[[ -t 0 ]] || file_content=$( cat )

	echo "$file_content" | regex_match "(${special_comment_line}${comment_line}*)($BL)*$SOL$SPACE*(function$SPACE)?$SPACE*${function_name}$SPACE*\(" 1
}


## Extracts commands from a task file
#
# @stdin [file_content] the file to analyse
# @param file_or_name the task file to analyse, or its name if the file is piped in
function analyse_extract_commands() {
	local file_content
	local task_name

	if [[ -t 0 ]]
	then
		file_content=$( cat "$1" )
		task_name="$(basename "$1" .task.sh)"
	else
		file_content=$( cat )
		task_name="$1"
	fi

	local regex="^(function$SPACE+)?${task_name}_([^\( 	]+)$SPACE*\(.*$"
	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}


## Extracts function parameters from a raw function documentation
# Format: @param(s)? {completion_function} name description of the parameter
#
# @stdin	command_raw_doc	the function raw documentation
function analyse_function_raw_params() {
	local command_raw_doc
	[[ -t 0 ]] || command_raw_doc=$( cat )

	echo "$command_raw_doc" | egrep "$param_regex" | sed -E "s:$param_regex:\1:g"
}


## Generates the synopsis of a function from raw function parameters
# Format: param1 param2*
# Star * marks variable arity
#
# @stdin	analyse_function_raw_params	the raw function parameters
function analyse_function_synopsis() {
	local analyse_function_raw_params
	[[ -t 0 ]] || analyse_function_raw_params=$( cat )

	local params=$(echo "$analyse_function_raw_params" \
		| sed -E "s:@param$param_comp_name: \2:g" \
		| sed -E "s:@params$param_comp_name: \2${yellowf}*${reset}${boldon}:g" \
		| tr -d '\n')

	echo "${boldon}$params${reset}"
}


## Generate the task file documentation
#
# @stdin the file to analyse
# @param	cmd_name	the command name
function analyse_command_doc() {
	local task_file="$1"
	local file_content=$( cat "$1" )

	local task_name="$(basename $task_file .task.sh)"
	local cmd_name="$2"
	local function_name="${task_name}_${cmd_name}"

	local raw_doc=$( echo "$file_content" | analyse_function_raw_doc "$function_name")

	echo -n "${boldon}${purplef}$task_name ${bluef}$cmd_name${reset}"
	echo "$raw_doc" | analyse_function_raw_params | analyse_function_synopsis

	echo "$raw_doc" | analyse_function_raw_params "$task_file" "$cmd_name" \
		| sed -E "s/@param$param_comp_name/	${boldon}\2${reset} : \3/g" \
		| sed -E "s/@params$param_comp_name/	${boldon}\2${yellowf}*${reset} : \3/g"

	echo "$raw_doc" \
		| sed -E "/#$SPACE*@param(s)?/d" \
		| sed -E "s/^#[# 	]*(.*)$/	\1/g" \
		| sed "/^$SPACE*$/d"
}


## Generate the file documentation
#
# @param	task_file	the file
function analyse_file_doc() {
	local file="$1"
	local file_name=$(basename $file)

	local description=$(analyse_file_raw_doc $file | sed -E "s/^#[# 	]*(.*)$/	\1/g")
	local short=$(echo "$description" | head -n 1)

	echo "FILE"
	echo "	${purplef}$file_name${reset} -$short"
	echo "DESCRIPTION"
	echo "$description"
}


## Generate the task file documentation
#
# @param	task_file	the task file
function analyse_task_doc() {
	local task_file="$1"
	local task_name=$(basename $task_file .task.sh)

	local file_content=$( cat "$task_file" )

	local description=$(echo "$file_content" \
		| analyse_file_raw_doc \
		| sed -E "s/^#[# 	]*(.*)$/	\1/g")
	local short=$(echo "$description" | head -n 1)

	local commands=$(analyse_extract_commands $task_file)

	echo
	echo "${boldon}NAME${reset}"
	echo "	${purplef}${boldon}$task_name${reset} -$short"

	echo
	echo "${boldon}SYNOPSIS${reset}"
	# TODO : default command
	for command in $commands
	do
		local raw_doc=$(echo "$file_content" | analyse_function_raw_doc "${task_name}_${command}")
		echo -n "	${boldon}${purplef}$task_name ${bluef}$command${reset}"
		echo "$raw_doc" \
			| analyse_function_raw_params \
			| analyse_function_synopsis
	done

	echo
	echo "${boldon}DESCRIPTION${reset}"
	echo "$description"

	echo
	echo "${boldon}COMMANDS${reset}"
	# TODO : default command
	for command in $commands
	do
		analyse_command_doc "$task_file" "$command" | sed -E "s:(.*):	\1:g"
		echo
	done
}

