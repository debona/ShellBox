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

source "$SHELLTASK_ROOT/autocompletion.sh"

export PATH="$PATH:$SHELLTASK_ROOT/path"

SHELLTASK_DIRS="$SHELLTASK_ROOT/tasks"

# All parameters are added to SHELLTASK_DIRS
for directory in "$@"
do
	directory="$( cd -P "$directory" && pwd )"
	if [[ -d "$directory" ]]
	then
		SHELLTASK_DIRS="$SHELLTASK_DIRS:$directory"
	fi
done

shelltask shortcut all

# TODO: enabled autocompletion shelltask shortcut all
