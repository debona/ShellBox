#!/bin/bash
#
# Tasks management functions library.

source "$SHELLTASK_LIBS/ui.sh"

function verbose() { # print command before run
	echo "> ${cyanf}$@${reset}" && "$@"
}
