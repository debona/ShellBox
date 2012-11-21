#!/bin/bash
#
# Regex functions libraries

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_LIBS="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_LIBS="$( cd -P "$( dirname "$0" )" && pwd )"
fi


# TODO : create another lib for environments
# TODO : Add global_default function
# TODO : Add which system function

## Define the global if not defined
#
# @param the name of the global
# @param the value
function global_default(){
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



# TODO : Make it more generic
# TODO : Support input pipe

## Match a regex in a file
# 
# Each line of the given file is surrounded by Start Of Line and End Of Line markers
# These markers are define by global var
#
# @param the task file
# @param the regex to match
# @param the group to print, default is group 0
function match() {
	task_file="$1"
	regex=$2
	index=${3:-'0'}

	if [[ ! -r $task_file ]]
	then
		return 1
	fi

	file_content=`cat $task_file | sed -E "s/(.*)/$SOL\1$EOL/g" | tr -d '\n'`

	if [[ $file_content =~ $regex ]]
	then
		echo -n "${BASH_REMATCH[$index]}" | tr -d "$SOL" | tr "$EOL" '\n'
		return 0
	else
		return $?
	fi
}

