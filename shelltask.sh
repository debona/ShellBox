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

# load task functions
source $task_file

command_name="$2"
function_name="${task_name}_${command_name}"

# if command_name is help
if [[ $2 = "help" ]]
then
	# then gerate basic help
	echo "TODO synopsis $task"
fi

# if function_name can be called (i.e. a function)
if type $function_name &> /dev/null
then

	# http://tldp.org/LDP/abs/html/internalvariables.html#INCOMPAT
	# be carefull using $* and $@
	
	shift # shift parameter list (remove $1 from parameter list)
	shift

	# now, parameter list does not include $task_name and $command_name
	$function_name "$@"
else
	# else print repo help
	echo "$task_name ${redf}$command_name${reset} does not exist!"

	# Recursive call to help sub-command
	$0 $task_name help
fi

