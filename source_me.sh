#!/bin/bash
#
## Creates some aliases
#
#1 [short] create short aliases

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_ROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_ROOT="$( cd -P "$( dirname "$0" )" && pwd )"
fi

# TODO : create shelltask alias
# TODO : setup auto-completion

# TODO : for each task file
#			display the help

if [[ "$1" == "short" ]]
then
	# TODO : for each task
	#			create short alias
	#			setup auto-completion
fi
