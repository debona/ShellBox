#!/bin/bash
#
# UI shell script library
# This task allows to print on stderr and stdout with differents color schemes.

## Print the message with the given color
#
# @param	color		the color
# @param	emphased	is emphased
# @params	others		is printed with default settings
function echolor() {
	local color=$1
	local first=$2
	shift 2
	echo -e "${boldon}${color}$first${reset} $@"
}

## Print the success of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_success() {
	echolor "${greenf} ✔ " "$@"
}

## Print the failure of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_failure() {
	echolor "${redf} ✘ " "$@" >&2
}


## Print the warning of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_warning() {
	echolor "${yellowf} ⚑ " "$@" >&2
}


## Print the execution the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli_step() {
	echolor "${cyanf} ● " "$@"
}


