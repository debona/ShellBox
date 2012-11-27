#!/bin/bash
#
# function library for shelltask developers

# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_LIBS="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_LIBS="$( cd -P "$( dirname "$0" )" && pwd )"
fi

# Basic UI functions library
source "$SHELLTASK_LIBS/ui.sh"

# Regex functions library
source "$SHELLTASK_LIBS/regex.sh"
