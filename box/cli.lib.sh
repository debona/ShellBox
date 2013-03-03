#!/bin/bash
#
# UI shell script library
# This library allows to print on stderr and stdout with differents color schemes.


include 'shared'

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
function cli::success() {
	echolor "${greenf} ✔ " "$@"
}

## Print the failure of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli::failure() {
	echolor "${redf} ✘ " "$@" >&2
}


## Print the warning of the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli::warning() {
	echolor "${yellowf} ⚑ " "$@" >&2
}


## Print the execution the given messages
#
# @param	emphased	is emphased
# @params	others		is printed with default settings
function cli::step() {
	echolor "${cyanf} ● " "$@"
}


## Print command before run it
# Allow to do: 'verbose command option && verbose something else'
#
#* all parameters are interpreted as command and its options
function verbose() {
	step "$@"

	# exec the line
	if "$@"
	then
		success "$@"
		return 0
	else
		status=$? # remember the exit status
		failure "$@"
		return $status
	fi
}
