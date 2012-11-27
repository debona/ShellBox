#!/bin/bash
#
# Task executer
# PARAMETERS
# $1 => the name of the task to load
# [$2 => task sub-command to call]
# [$+ => task sub-command options]


SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"


SHELLTASK_LIBS="$SHELLTASK_ROOT/libs"

# TODO : change SHELLTASK_TASKS to a SHELLTASK_PATH like PATH
# TODO : create library to manage PATH and taskfile fetching etc
SHELLTASK_TASKS="$SHELLTASK_ROOT/tasks"


source "$SHELLTASK_LIBS/shelltask_functions.sh"

# All this vars are reachable by the task functions
# TODO : standardize this var (uppercase)
# TODO : declare local var for unreachable var

# TODO : should take task_file as first param
task_file="$1"
task_name=$( basename "$task_file" '.task.sh' )

if [[ ! -r $task_file ]]
then
	failure "could not find task: ${redf}$task_name"
	exit 1
fi

if ! source $task_file 2> /dev/null
then
	failure "Can't load $task_file:"
	source $task_file
	exit 1
fi

cmd_name="$2"
cmd_function="${task_name}_${cmd_name}"

# if cmd_name is help
if [[ "$cmd_name" = "help" ]]
then
	source "$SHELLTASK_LIBS/analysis.sh"
	# TODO then generate basic help
	task_doc $task_file | less -R

# if cmd_function can be called (i.e. a function)
elif type $cmd_function &> /dev/null
then

	# http://tldp.org/LDP/abs/html/internalvariables.html#INCOMPAT
	# be careful using $* and $@
	
	shift # shift parameter list (remove $1 from parameter list)
	shift

	# now, parameter list does not include $task_name and $cmd_name
	$cmd_function "$@"
else
	# else print repo help
	echo "$task_name ${redf}$cmd_name${reset} does not exist!"

	# TODO : don't call help, print available command instead
	# Recursive call to help sub-command
	$0 $task_name help
fi

