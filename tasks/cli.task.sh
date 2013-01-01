#!/bin/bash
#
# UI shell script library
# Define colors



## Print the success of the given messages
#
#* all parameters describe the message
function cli_success() {
	echo "${greenf}${boldon} ✔ $@${reset}"
}


## Print the failure of the given messages
#
#* all parameters describe the message
function cli_failure() {
	# TODO : print on stderr
	echo "${redf}${boldon} ✘ $@${reset}"
}


## Print the warning of the given messages
#
#* all parameters describe the message
function cli_warning() {
	# TODO : print on stderr
	echo "${yellowf}${boldon} ⚑ $@${reset}"
}


## Print the execution the given messages
#
#* all parameters describe the message
function cli_step() {
	echo "${cyanf}${boldon} ● $@${reset}"
}


