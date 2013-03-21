#!/bin/bash
#
# Regex matching functions libraries.
# All the regex commands rely on "line markers". When a file is read, the start and end of line are marked.
# Why marking start and end of line?
# Because the =~ bash operator don't care about start and end of line patterns: ^ and $
#
# The markers:
# All End of Line are replaced with $EOL exported var.
# All Start of Line are replaced with $SOL exported var.
# In case of conflict with these markers, they can be overridden by exporting $SOL or $EOL in environment vars.
#
# Other exported shortcuts:
# The empty line: $EL ("$SOL$EOL" by default)
# The whitespace: $SPACE ("[ 	]" by default)
# The blank line: $BL ("$SOL$SPACE*$EOL" by default)


require 'shared'

## Define the global if not defined
#
# @param the name of the global
# @param the value
function global_default() {
	global=$(printenv | egrep "^$1=")
	if [[ "$global" = "" ]]
	then
		export "$1=$2"
	fi
}



global_default SOL "▶"
global_default EOL "◀"

global_default EL "$SOL$EOL"
global_default SPACE "[ 	]"
global_default BL "$SOL$SPACE*$EOL"



## Display a short help of the library or the help of the library command provided
#
# @param	[command_name]	The command name
function regex::help() {
	shared::help 'regex' "$@"
}


## Display a detailed manual of the library.
#
function regex::man() {
	shared::man 'regex'
}


## Match a regex in stdin or a file
# 
# Each line of the given file is surrounded by Start Of Line and End Of Line markers
# These markers are define by global vars
# ⚠  if stdout is a tty, then a newline is append for convenience
#
# @stdin [the content file]
# @param [input_file] the file to read
# @param regex the regex to match
# @param [group=0] the group to print
function regex::match() {
	local file_content

	if [[ -t 0 ]]
	then # stdin is a tty
		local input_file="$1"
		if ! [[ -r $input_file ]]
		then # not piped and no readable input_file
			return 1
		else
			file_content=$( cat $input_file )
			shift
		fi
	else # stdin is piped
		file_content=$( cat )
	fi

	file_content=$( echo "$file_content" | sed -E "s/(.*)/$SOL\1$EOL/g" | tr -d '\n' )

	local regex=$1
	local index=${2:-'0'}

	if [[ $file_content =~ $regex ]]
	then
		echo -n "${BASH_REMATCH[$index]}" | tr -d "$SOL" | tr "$EOL" '\n'
		[[ -t 1 ]] && echo
		return 0
	else
		return $?
	fi
}

