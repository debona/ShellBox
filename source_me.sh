#!/bin/bash
#
#
# All parameters are added to SHELLTASK_DIRS

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
fi

# Put shelltask in path if needed
if ! [[ ":$PATH:" =~ ":$SHELLTASK_ROOT/path:" ]]
then
	export PATH="$PATH:$SHELLTASK_ROOT/path"
fi

# Put all parameters in SHELLTASK_DIRS
SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks"
for directory in "$@"
do
	directory="$( cd -P "$directory" && pwd )"
	if [[ -d "$directory" ]]
	then
		SHELLTASK_DIRS="$SHELLTASK_DIRS:$directory"
	fi
done
export SHELLTASK_DIRS=$SHELLTASK_DIRS

# Create shortcut for all tasks?
shelltask shortcut all

# TODO: enabled autocompletion shelltask shortcut all
source "$SHELLTASK_ROOT/autocompletion.sh"
