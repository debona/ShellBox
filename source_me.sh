#!/bin/bash
#
## Creates some aliases
#

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
fi


source "$SHELLTASK_ROOT/shelltask_functions.sh"
source "$SHELLTASK_ROOT/autocompletion.sh"



SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks"

echo "source all task file in $SHELLTASK_DIRS:"
for task_file in `find $SHELLTASK_DIRS -type f -maxdepth 1 | egrep 'task.sh$'`
do
	load_task "$task_file"
done

# All parameters are added to SHELLTASK_DIRS
for directory in "$@"
do
	directory="$( cd -P "$directory" && pwd )"
	if [[ -d "$directory" ]]
	then
		SHELLTASK_DIRS="$SHELLTASK_DIRS:$directory"
		echo
		echo "source all task file in $directory:"
		for task_file in `find $directory -type f -maxdepth 1 | egrep '.sh$'`
		do
			load_task "$task_file"
		done
	fi
done
