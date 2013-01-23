#!/bin/bash
#
# Tasks analysis
# The main purpose of this task file is to provide needed functions to build up the tasks documentation.
# It source the regex task file.

# TODO : Allow bold in documentation

require "regex.task.sh"

# common patterns used for analysis:

comment_line="($SOL#[^$EOL!]*$EOL)" # group 1 catches a comment line
bin_bash_line="($SOL#(![^$EOL]+)?$EOL)" # group 1 catches the `#!/bin/*` and empty comment line, group 2 is wasted
special_comment_line="($SOL##[^$EOL]*$EOL)" # group 1 catches the trigger comment line which begin by double #

input_regex="#$SPACE*(@(stdin|params?)$SPACE+.*)$" # group 1 catches a parameter declaration line, group 2 is wasted as it catches the type of input
comp_func="\{([^\}]*)\}" # catches the completion function in a parameter declaration line
input_comp_name="($SPACE+${comp_func})?$SPACE+([^ 	]+)$SPACE*(.*)$" # group 1 is wasted, group 2 catches the completion function, group 3 catches the input name, group 4 catches the input details

tab="      " # Typical offset in man pages


## Format a text by prepending a prefix to each lines that fit the console screen width.
# Text must be provided by parameters or through standard input
#
# @stdin	[text]	the text to format
# @param	prefix	prefix to prepend to each lines
# @params	[text]	the text to format
function format() {
	local prefix="$1"
	shift
	local text
	[[ -t 0 ]] && text="$@" || text=$( cat )

	local console_width=$(tput cols)
	local columns=${#prefix}
	let "columns = console_width - columns"
	# TODO : Find a better way to fold lines. (do not count escaped chars)
	echo "$text" | fold -s -w $columns | sed -E "s/^(.*)$/$prefix\1/g"
}


## Extracts the file raw documentation
# The raw documentation means comment lines right after /bin/bash.
#
# @stdin	[file_content]	[the content file to analyse]
# @param	[file]			the file to analyse
function analyse_file_raw_doc() {
	local file_content
	[[ -t 0 ]] && file_content=$(cat $1) || file_content=$( cat )

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
# @stdin	[file_content]	the file to analyse
# @param	file_or_name	the task file to analyse, or its name if the file is piped in
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


## Extracts function inputs (standard input and parameters) from a raw function documentation
# Expected format:
# ● @stdin                             the_name  The description
# ● @param(s)?  {completion_function}  the_name  The description
#
# @stdin	command_raw_doc	the function raw documentation
function analyse_function_raw_input() {
	local command_raw_doc
	[[ -t 0 ]] || command_raw_doc=$( cat )

	echo "$command_raw_doc" | egrep "$input_regex" | sed -E "s:$input_regex:\1:g"
}


## Generates the synopsis of a function from raw function parameters
# Output: function_name param1 param2*
# Star * marks variable arity
#
# @stdin	function_raw_input	the raw function parameters
# @param	function_name		the function name to display
function analyse_function_synopsis() {
	local function_raw_input
	[[ -t 0 ]] || function_raw_input=$( cat )
	local function_name="$1"

	local params=$(echo "$function_raw_input" \
		| egrep "^@params?" \
		| sed -E "s:@param$input_comp_name: \3:g" \
		| sed -E "s:@params$input_comp_name: \3${yellowf}*${reset}${boldon}:g" \
		| tr -d '\n')
	local stdin=$(echo "$function_raw_input" \
		| egrep "^@stdin" \
		| sed -E "s:@stdin$input_comp_name: < ${greenf}\3:g" \
		| tr -d '\n')

	echo "$function_name${boldon}$params$stdin${reset}"
}


## Generate the task command documentation
#
# @stdin	[file_content]	the file to analyse
# @param	file_or_name	the task file to analyse, or its name if the file is piped in
# @param	cmd_name		the command name
function analyse_command_doc() {
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

	local cmd_name="$2"
	local function_name="${task_name}_${cmd_name}"

	local raw_doc=$( echo "$file_content" | analyse_function_raw_doc "$function_name")
	local raw_params_doc=$(echo "$raw_doc" | analyse_function_raw_input)

	echo "$raw_params_doc" | analyse_function_synopsis "${boldon}${purplef}$task_name ${bluef}$cmd_name${reset}"

	echo "$raw_doc" \
		| egrep -v "$input_regex" \
		| sed -E "s/^#[# 	]*(.*)$/\1/g" \
		| sed "/^$SPACE*$/d"
	echo -n "$raw_params_doc" \
		| egrep "^@stdin" \
		| sed -E "s/@stdin$input_comp_name/ < ${greenf}${boldon}\3${reset} : \4/g"
	echo -n "$raw_params_doc" \
		| egrep "^@params?" \
		| sed -E "s/@param$input_comp_name/ - ${boldon}\3${reset} : \4/g" \
		| sed -E "s/@params$input_comp_name/ - ${boldon}\3${yellowf}*${reset} : \4/g"
}


## Generate the file documentation
#
# @param	file	the file
function analyse_file_doc() {
	local file="$1"
	local file_name=$(basename $file)

	local description=$(analyse_file_raw_doc $file | sed -E "s/^#[# 	]*(.*)$/\1/g")
	local short=$(echo "$description" | head -n 1)

	echo "FILE"
	echo "${purplef}$file_name${reset} - $short" | format "${tab}"
	echo "DESCRIPTION"
	echo "$description" | format "${tab}"

	# TODO : Handle parameters like a command
	#	synopsis
	#	input output
	#	parameters
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
		| sed -E "s/^#[# 	]*(.*)$/\1/g")
	local short=$(echo "$description" | head -n 1)

	local commands=$(analyse_extract_commands $task_file)

	echo
	echo "${boldon}NAME${reset}"
	echo "${purplef}${boldon}$task_name${reset} - $short" | format "${tab}"

	echo
	echo "${boldon}SYNOPSIS${reset}"
	# TODO : default command
	for _command in $commands
	do
		echo "$file_content" \
			| analyse_function_raw_doc "${task_name}_${_command}" \
			| analyse_function_raw_input \
			| analyse_function_synopsis "${boldon}${purplef}$task_name ${bluef}${_command}${reset}" \
			| format "${tab}"
	done

	echo
	echo "${boldon}DESCRIPTION${reset}"
	echo "$description" | format "${tab}"

	echo
	echo "${boldon}COMMANDS${reset}"
	# TODO : default command
	for _command in $commands
	do
		echo "$file_content" | analyse_command_doc "$task_name" "${_command}" | format "${tab}"
		echo
	done
}

