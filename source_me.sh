#!/bin/bash
#
#
# All parameters are added to SHELLBOX_DIRS

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLBOX_ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLBOX_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
fi

# Put shellbox in path if needed
if ! [[ ":$PATH:" =~ ":$SHELLBOX_ROOT/path:" ]]
then
	export PATH="$PATH:$SHELLBOX_ROOT/path"
fi

# Put all parameters in SHELLBOX_DIRS
SHELLBOX_DIRS="$SHELLBOX_ROOT/tasks"
for directory in "$@"
do
	directory="$( cd -P "$directory" && pwd )"
	if [[ -d "$directory" ]]
	then
		SHELLBOX_DIRS="$SHELLBOX_DIRS:$directory"
	fi
done
export SHELLBOX_DIRS=$SHELLBOX_DIRS

# Create shortcut for all library?
shellbox shortcut all

# TODO: enabled autocompletion shellbox shortcut all
source "$SHELLBOX_ROOT/autocompletion.sh"
