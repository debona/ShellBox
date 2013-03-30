#!/bin/bash
#
#
# All parameters are added to SHELLBOXES

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
[[ ":$PATH:" =~ ":$SHELLBOX_ROOT/bin:" ]] || export PATH="$SHELLBOX_ROOT/bin:$PATH"


# Put all parameters in SHELLBOXES
SHELLBOXES="$SHELLBOX_ROOT/box"
for directory in "$@"
do
	directory="$( cd -P "$directory" && pwd )"
	if [[ -d "$directory" ]]
	then
		SHELLBOXES="$SHELLBOXES:$directory"
	fi
done
export SHELLBOXES=$SHELLBOXES

# Create shortcut for all library?
shellbox shortcut all

if [[ -n "$BASH" ]]
then
	function __complete() {
		COMPREPLY=( $( "$SHELLBOX_ROOT/bin/complete" dispatch "$COMP_CWORD" ${COMP_WORDS[@]} ) )
	}
	complete -o default -F __complete "shellbox"
fi
