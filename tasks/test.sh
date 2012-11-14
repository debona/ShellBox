#!/bin/bash
#
# test shell task


### exposed subcommands

function test_help() { # display this help
	$LIB_DIR/synopsis.sh $0
	echo "repo without subcommand runs ${bluef}status${reset}"
}

function test_() { # execute all tasks
	verbose test_test
}

function test_test() { # print args
	echo "1 => $1"
	echo "2 => $2"
	echo "3 => $3"
	echo "4 => $4"
}
