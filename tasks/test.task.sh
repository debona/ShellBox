#!/bin/bash
#
# Auto-test task file
# This task file provide some test functions to test ShellTask libraries


## Default command
# Default command cannot have parameters!
function test_() {
	if [[ "$1" = "" ]]
	then
		success "There are no parameters"
		return 0
	else
		failure "There is at least one parameter"
		return 1
	fi
}

## Display all args on one line
#
# @params args to display
function test_oneline () {
	step "Print all parameters in one line:"
	success "$@"
}

## Print one parameter by line
#
# @param printed on the first line
# ...
# @param printed on the last line
function test_multiline() {
	step "Print one parameter by line"
	if [[ -z $1 ]]
	then
		warning "There is no parameters"
	else
		for i in `seq 1 $#`
		do
			success "$i => '$1'"
			shift
		done
	fi
}


# Self-tested function
# This is a self tested function to assert that analysis can extract
# Note that this command does not respect any code convention
# Test to extract the raw documentation of task command

test_self_tested ( ){
	source "$SHELLTASK_LIBS/analysis.sh"
	first_line=$(command_raw_doc "${BASH_SOURCE[0]}" "self_tested" | head -n 1)
	last_line=$(command_raw_doc "${BASH_SOURCE[0]}" "self_tested" | tail -n 1)

	if [[ "$first_line" != "# Self-tested function" ]]
	then
		failure "First documentation line not found"
		return 1
	fi

	if [[ "$last_line" != "# Test to extract the raw documentation of task command" ]]
	then
		failure "Last documentation line not found"
		return 1
	fi

	success "Documentation found"
}
