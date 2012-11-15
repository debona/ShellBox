#!/bin/bash
#
# This script must be sourced!
# Tasks management functions library.


# Compatibility:
#	bash (sourced and subshell)
#	zsh  (sourced and subshell)
if [[ -n "$BASH" ]]
then
	SHELLTASK_LIBS="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
	SHELLTASK_LIBS="$( cd -P "$( dirname "$0" )" && pwd )"
fi

source "$SHELLTASK_LIBS/ui.sh"

## Print command before run it
# Allow to do: 'verbose command option && verbose something else'
#
#* all parameters are interpreted as command and its options
function verbose() {
	echo " > ${cyanf}$@${reset}" && "$@"
}

## Print command before run it
# Allow to do: 'verbose command option && verbose something else'
#
#* all parameters are interpreted as command and its options
function good() {
	echo "${greenf} ✔ ${reset}$@"
}

## Print command before run it
# Allow to do: 'verbose command option && verbose something else'
#
#* all parameters are interpreted as command and its options
function bad() {
	echo "${redf} ✘ ${reset}$@"
}
