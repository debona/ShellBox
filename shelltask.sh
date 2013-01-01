#!/bin/bash
#
# Task executer
# PARAMETERS
#  $1 => the task file to load
# [$2 => the task command to call]
# [$+ => task sub-command options]


SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"


SHELLTASK_LIBS="$SHELLTASK_ROOT/libs"


source "$SHELLTASK_LIBS/shelltask_functions.sh"

# All this vars are reachable by the task functions
# TODO : standardize this var (uppercase)
# TODO : declare local var for unreachable var

TASK_FILE="$1"
TASK_NAME=$( basename "$TASK_FILE" '.task.sh' )

if [[ ! -r "$TASK_FILE" ]]
then
	failure "Can't read the file: ${redf}$TASK_FILE${reset}"
	exit 1
fi

if ! source $TASK_FILE 2> /dev/null
then
	failure "Can't load $TASK_FILE:"
	source $TASK_FILE
	exit 1
fi

cmd_name="$2"
cmd_function="${TASK_NAME}_${cmd_name}"

# if cmd_name is help
if [[ "$cmd_name" = "help" ]]
then
	source "$SHELLTASK_LIBS/analysis.sh"
	# TODO then generate basic help
	task_doc $TASK_FILE | less -R

# if cmd_function can be called (i.e. a function)
elif type $cmd_function &> /dev/null
then

	# http://tldp.org/LDP/abs/html/internalvariables.html#INCOMPAT
	# be careful using $* and $@
	
	shift # shift parameter list (remove $1 from parameter list)
	shift

	# now, parameter list does not include $TASK_NAME and $cmd_name
	$cmd_function "$@"
else
	# else print repo help
	echo "$TASK_NAME ${redf}$cmd_name${reset} does not exist!"

	# TODO : don't call help, print available command instead
	# Recursive call to help sub-command
	$0 $TASK_FILE help
fi

