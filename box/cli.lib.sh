#!/usr/bin/env shellbox
#
# UI shell script library
# This library allows to print on stderr and stdout with differents color schemes.


require 'shared'


####################################################################
###########                  COMMANDS                    ###########
####################################################################

## Display a short help of the library or the help of the library command provided
#
# @param	[command_name]	The command name
function cli::help() {
	shared::help 'cli' "$@"
}


## Display a detailed manual of the library.
#
function cli::man() {
	shared::man
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


####################################################################
###########              PRIVATE FUNCTIONS               ###########
####################################################################

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

## Define colors.
# From http://www.intuitive.com/wicked/showscript.cgi?011-colors.sh
# Author: Dave Taylor
function enableColors()
{
	esc=""

	blackf="${esc}[30m";	redf="${esc}[31m";		greenf="${esc}[32m";
	yellowf="${esc}[33m";	bluef="${esc}[34m";		purplef="${esc}[35m";
	cyanf="${esc}[36m";		whitef="${esc}[37m";

	blackb="${esc}[40m";	redb="${esc}[41m";		greenb="${esc}[42m";
	yellowb="${esc}[43m";	blueb="${esc}[44m";		purpleb="${esc}[45m";
	cyanb="${esc}[46m";		whiteb="${esc}[47m";

	boldon="${esc}[1m";		boldoff="${esc}[22m";
	italicson="${esc}[3m";	italicsoff="${esc}[23m";
	ulon="${esc}[4m";		uloff="${esc}[24m";
	invon="${esc}[7m";		invoff="${esc}[27m";

	reset="${esc}[0m";
}

## Undefine colors to write readable log files.
#
function disableColors() {
	unset esc

	unset blackf;		unset redf;		unset greenf;
	unset yellowf;		unset bluef;	unset purplef;
	unset cyanf;		unset whitef;

	unset blackb;		unset redb;		unset greenb;
	unset yellowb;		unset blueb;	unset purpleb;
	unset cyanb;		unset whiteb;

	unset boldon;		unset boldoff;
	unset italicson;	unset italicsoff;
	unset ulon;			unset uloff;
	unset invon;		 unset invoff;

	unset reset;
}


####################################################################
###########                MANAGE COLORS                 ###########
####################################################################

enableColors
[[ -t 1 ]] && [[ -t 2 ]] || disableColors # Disable color in shell if the outputs are not tty
