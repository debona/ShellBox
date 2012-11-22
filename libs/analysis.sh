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

# TODO : Standardize libraries (i.e. function names...)
# TODO : Extract documentation from libraries

# TODO : generecize for library documentation usage



## Extracts the file raw documentation
# The raw documentation means comment lines right after /bin/bash.
#
# @stdin	file_content	the file to analyse
function file_raw_doc() {
	local file_content
	[[ -t 0 ]] || file_content=$( cat )

	bin_bash_line="($SOL#(![^$EOL]+)?$EOL)" # match `#!/bin/bash` line or empty line

	echo "$file_content" | match "${bin_bash_line}*(${comment_line}+)$BL" 3
}


## Extracts the function raw documentation
# The raw documentation means these comment lines (just above the function).
#
# @stdin	file_content	the file to analyse
# @param	function_name	the function name
function function_raw_doc() {
	local file_content
	[[ -t 0 ]] || file_content=$( cat )

	function_name="$1"

	special_comment_line="($SOL##[^$EOL]*$EOL)" # match a special comment line like `## special comment`

	echo "$file_content" | match "(${special_comment_line}${comment_line}*)($BL)*$SOL$SPACE*(function$SPACE)?$SPACE*${function_name}$SPACE*\(" 1
}


## Extracts commands from a task file
#
# @stdin [file_content] the file to analyse
# @param file_or_name the task file to analyse, or its name if the file is piped in
function extract_commands() {
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

	regex="^(function$SPACE+)?${task_name}_([^\( 	]+)$SPACE*\(.*$"

	echo "$file_content" | egrep "$regex" | sed -E "s:$regex:\2:g"
}


## Extracts function parameters from a raw function documentation
# Format: @param(s)? {completion_function} name description of the parameter
#
# @stdin	command_raw_doc	the function raw documentation
function function_raw_params() {
	local command_raw_doc
	[[ -t 0 ]] || command_raw_doc=$( cat )

	regex="#$SPACE*(@param(s)?$SPACE+.*)$"

	echo "$command_raw_doc" | egrep "$regex" | sed -E "s:$regex:\1:g"
}


## Generates the synopsis of a function from raw function parameters
# Format: param1 param2*
# Star * marks variable arity
#
# @stdin	function_raw_params	the raw function parameters
function function_synopsis() {
	local function_raw_params
	[[ -t 0 ]] || function_raw_params=$( cat )

	comp_func="\{[^\}]*\}" # match the completion function
	param="[^ 	]+" # match the first word after @param

	regex="($SPACE+${comp_func})?$SPACE+(${param}).*$"

	params=$(echo "$function_raw_params" \
		| sed -E "s:@param$regex: \2:g" \
		| sed -E "s:@params$regex: \2${yellowf}*${reset}${boldon}:g" \
		| tr -d '\n')

	echo "${boldon}$params${reset}"
}


## Generate the task file documentation
#
# @stdin the file to analyse
# @param cmd_name the command name
function command_doc() {
	local task_file="$1"
	local file_content=$( cat "$1" )

	local task_name="$(basename $task_file .task.sh)"
	local cmd_name="$2"
	local function_name="${task_name}_${cmd_name}"

	local raw_doc=$( echo "$file_content" | function_raw_doc "$function_name")

	echo -n "${boldon}${purplef}$task_name ${bluef}$cmd_name${reset}"
	echo "$raw_doc" | function_raw_params | function_synopsis

	comp_func="\{[^\}]*\}" # match the completion function
	param="[^ 	]+" # match the first word after @param

	regex="($SPACE+${comp_func})?$SPACE+(${param})$SPACE*(.*)$"

	echo "$raw_doc" | function_raw_params "$task_file" "$cmd_name" \
		| sed -E "s/@param$regex/	${boldon}\2${reset} : \3$/g" \
		| sed -E "s/@params$regex/	${boldon}\2${yellowf}*${reset} : \3/g"

	echo "$raw_doc" \
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

	local file_content=$( cat "$task_file" )

	description=$(echo "$file_content" \
		| file_raw_doc \
		| sed -E "s/^#[# 	]*(.*)$/	\1/g")
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
		local raw_doc=$(echo "$file_content" | function_raw_doc "${task_name}_${command}")
		echo -n "	${boldon}${purplef}$task_name ${bluef}$command${reset}"
		echo "$raw_doc" \
			| function_raw_params \
			| function_synopsis
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

