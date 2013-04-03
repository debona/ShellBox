#!/bin/bash
#
#

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

# Put this box in path if needed
[[ ":$PATH:" =~ ":$SHELLBOX_ROOT/box:" ]] || export PATH="$SHELLBOX_ROOT/box:$PATH"

if [[ -n "$BASH" ]]
then
	function __complete() {
		COMPREPLY=( $( complete.lib.sh dispatch "$COMP_CWORD" ${COMP_WORDS[@]} ) )
	}
	complete -o bashdefault -o default -F __complete `shellbox list_library_names | sed 's/$/.lib.sh/'`
fi
