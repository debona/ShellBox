#!/bin/bash
#
# UI shell script library
# This task allows to print on stderr and stdout with differents color schemes.

## Print the success of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_success() {
	local first=$1
	shift
	echo -e "${greenf}${boldon} ✔ $first${reset} $@"
}


## Print the failure of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_failure() {
	# TODO : print on stderr
	local first=$1
	shift
	echo -e "${redf}${boldon} ✘ $first${reset} $@"
}


## Print the warning of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_warning() {
	# TODO : print on stderr
	local first=$1
	shift
	echo -e "${yellowf}${boldon} ⚑ $first${reset} $@"
}


## Print the execution the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_step() {
	local first=$1
	shift
	echo -e "${cyanf}${boldon} ● $first${reset} $@"
}


