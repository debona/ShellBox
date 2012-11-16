#!/bin/bash
#
# Task executer
# PARAMETERS
# $1 => the name of the task to load
# [$2 => task sub-command to call]
# [$+ => task sub-command options]


SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"


SHELLTASK_LIBS="$SHELLTASK_ROOT/libs"
SHELLTASK_TASKS="$SHELLTASK_ROOT/tasks"


source "$SHELLTASK_LIBS/shelltask_functions.sh"


task_name="$1"
task_file="$SHELLTASK_TASKS/$task_name.task.sh"

if [[ ! -r $task_file ]]
then
	bad "could not find task: ${redf}$task_name"
	exit 1
fi

source $task_file # load task functions

cmd_name="$2"
cmd_function="${task_name}_${cmd_name}"

# if cmd_name is help
if [[ $2 = "help" ]]
then
	# then gerate basic help
	echo "TODO synopsis $task"
fi

# if cmd_function can be called (i.e. a function)
if type $cmd_function &> /dev/null
then

	# http://tldp.org/LDP/abs/html/internalvariables.html#INCOMPAT
	# be carefull using $* and $@
	
	shift # shift parameter list (remove $1 from parameter list)
	shift

	# now, parameter list does not include $task_name and $cmd_name
	$cmd_function "$@"
else
	# else print repo help
	echo "$task_name ${redf}$cmd_name${reset} does not exist!"

	# Recursive call to help sub-command
	$0 $task_name help
fi

