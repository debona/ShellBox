#!/bin/bash
#
# A complete library file sample.
# This file is sourced by shellbox each time.
# ShellBox declare the following globals:
# - SHELLBOX_ROOT: Root directory
# - SHELLBOXES: libraries directory
# - LIB_FILE: Loaded library file (i.e. path/to/sample.lib.sh)
# - LIB_NAME: Loaded library name (i.e. sample)
# - CMD_NAME: Invoked library command

require "cli.lib.sh"

## Default command
# Default command cannot have parameters!
function sample::() {
	if [[ -z $1 ]]
	then
		cli::success "There are no parameters"
		return 0
	else
		cli::failure "There is at least one parameter: $@"
		return 1
	fi
}

## Display all arguments on a single line
#
# @param	{echo "herp"}	args	arguments to display
# @params	{echo "derp"}	arg		another arg
function sample::oneline () {
	cli::step "Print all parameters in one line:"
	if [[ -z $1 ]]
	then
		cli::warning "There is no parameters"
	else
		cli::success "$@"
	fi
}

## Print one parameter by line
#
# @params	args	arguments to display
function sample::multiline() {
	cli::step "Print one parameter by line"
	if [[ -z $1 ]]
	then
		cli::warning "There is no parameters"
	else
		for i in `seq 1 $#`
		do
			cli::success "$i => '$1'"
			shift
		done
	fi
}


## Self-tested function
# This is a self tested function to assert that analysis can extract
# Note that this command does not respect any code convention
# Test to extract the raw documentation of library command

sample::self_tested ( ){
	require "analyse.lib.sh"

	local raw_function_doc=$(cat "$LIB_FILE" | analyse_function_raw_doc "sample::self_tested")

	local first_line=$(echo "$raw_function_doc" | head -n 1)
	local last_line=$(echo "$raw_function_doc" | tail -n 1)

	if [[ "$first_line" != "## Self-tested function" ]]
	then
		cli::failure "First documentation line not found"
		return 1
	fi

	if [[ "$last_line" != "# Test to extract the raw documentation of library command" ]]
	then
		cli::failure "Last documentation line not found"
		return 1
	fi

	cli::success "Documentation found"
}
