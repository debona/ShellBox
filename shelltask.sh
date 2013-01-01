#!/bin/bash
#
# Task executer
# PARAMETERS
#  $1 => the task file to load
# [$2 => the task command to call]
# [$+ => task sub-command options]


SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
SHELLTASK_PATH="$SHELLTASK_ROOT/tasks"

source "$SHELLTASK_ROOT/shelltask_functions.sh"

initializeANSI

source "$SHELLTASK_PATH/cli.task.sh"
source "$SHELLTASK_PATH/regex.task.sh"


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
	source "$SHELLTASK_PATH/analyse.task.sh"
	analyse_task_doc $TASK_FILE | less -R

# if cmd_function can be called (i.e. a function)
elif type $cmd_function &> /dev/null
then
	# http://tldp.org/LDP/abs/html/internalvariables.html#INCOMPAT
	# be careful using $* and $@

	shift 2 # now, parameter list does not include $TASK_NAME and $cmd_name

	$cmd_function "$@"
else
	# else print repo help
	cli_failure "${purplef}$TASK_NAME ${redf}$cmd_name${reset} does not exist!"

	cmd_list=$($0 "$SHELLTASK_PATH/analyse.task.sh" extract_commands $TASK_FILE)
	echo "Available commands for this task:"
	echo "$cmd_list" | sed -E "s:(.*):	- ${boldon}${purplef}$TASK_NAME ${bluef}\1${reset}:g"
fi

