#!/bin/bash
#
# A complete task file sample.
# This file is sourced by shelltask each time.
# Shelltask declare the following globals:
# - SHELLTASK_ROOT: Root directory
# - SHELLTASK_DIRS: Tasks directory
# - TASK_FILE: Loaded task file (i.e. path/to/sample.task.sh)
# - TASK_NAME: Loaded task name (i.e. sample)
# - CMD_NAME: Invoked task command

## Default command
# Default command cannot have parameters!
function sample_() {
	if [[ -z $1 ]]
	then
		cli_success "There are no parameters"
		return 0
	else
		cli_failure "There is at least one parameter: $@"
		return 1
	fi
}

## Display all arguments on a single line
#
# @param	{echo "herp"}	args	arguments to display
# @params	{echo "derp"}	arg		another arg
function sample_oneline () {
	cli_step "Print all parameters in one line:"
	if [[ -z $1 ]]
	then
		cli_warning "There is no parameters"
	else
		cli_success "$@"
	fi
}

## Print one parameter by line
#
# @params	args	arguments to display
function sample_multiline() {
	cli_step "Print one parameter by line"
	if [[ -z $1 ]]
	then
		cli_warning "There is no parameters"
	else
		for i in `seq 1 $#`
		do
			cli_success "$i => '$1'"
			shift
		done
	fi
}


## Self-tested function
# This is a self tested function to assert that analysis can extract
# Note that this command does not respect any code convention
# Test to extract the raw documentation of task command

sample_self_tested ( ){
	require "analyse.task.sh"

	local raw_function_doc=$(cat "$TASK_FILE" | analyse_function_raw_doc "sample_self_tested")

	local first_line=$(echo "$raw_function_doc" | head -n 1)
	local last_line=$(echo "$raw_function_doc" | tail -n 1)

	if [[ "$first_line" != "## Self-tested function" ]]
	then
		cli_failure "First documentation line not found"
		return 1
	fi

	if [[ "$last_line" != "# Test to extract the raw documentation of task command" ]]
	then
		cli_failure "Last documentation line not found"
		return 1
	fi

	cli_success "Documentation found"
}
