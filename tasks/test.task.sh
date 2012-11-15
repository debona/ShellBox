#!/bin/bash
#
# test shell task


# TODO : test auto-completion pattern

## Simply test parameters
# Be carefull with this task... it does nothing
#
#1 [file] first arg
#2 [] arg
function test_help() {
	echo "repo without subcommand runs ${bluef}status${reset}"
}


## Default action
#
#1 [file] first arg
#2 [] arg
function test_() {
	verbose test_test "$@"
}


## Simply test parameters
# Be carefull with this task... it does nothing
#
#1 [file] first arg
#2 [] arg
function test_test() {
	echo "1 => $1"
	echo "2 => $2"
	echo "3 => $3"
	echo "4 => $4"
}
