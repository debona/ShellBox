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

SHELLTASK_LIBS="$SHELLTASK_ROOT/libs"

# TODO : Manage multiple SHELLTASK_PATH

source "$SHELLTASK_LIBS/ui.sh"

# TODO : create an auto-completion library
# TODO : source it



# TODO : create shelltask alias
# TODO : setup auto-completion

# TODO : for each task file
#			create short alias
#			setup auto-completion

