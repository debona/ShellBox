#!/bin/bash
#
# Regex functions libraries


# TODO : create another lib for environments
# TODO : Add global_default function
# TODO : Add which system function


global_default SOL "▶"
global_default EOL "◀"

global_default EL "$SOL$EOL"
global_default SPACE "[ 	]"
global_default BL "$SOL$SPACE*$EOL"


## Match a regex in stdin or a file
# 
# Each line of the given file is surrounded by Start Of Line and End Of Line markers
# These markers are define by global var
# ⚠  if stdout is a tty then a newline is append for convenience
#
# @param [input_file] the file to read
# @param regex the regex to match
# @param [group=0] the group to print
function regex_match() {
	local file_content

	if [[ -t 0 ]]
	then # match stdin is a tty
		local input_file="$1"
		if ! [[ -r $input_file ]]
		then # not piped and no readable input_file
			return 1
		else
			file_content=$( cat $input_file )
			shift
		fi
	else # match stdin is piped
		file_content=$( cat )
	fi

	file_content=$( echo "$file_content" | sed -E "s/(.*)/$SOL\1$EOL/g" | tr -d '\n' )

	regex=$1
	index=${2:-'0'}

	if [[ $file_content =~ $regex ]]
	then
		echo -n "${BASH_REMATCH[$index]}" | tr -d "$SOL" | tr "$EOL" '\n'
		return 0
	else
		return $?
	fi
}

