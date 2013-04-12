ShellBox
=========

ShellBox helps you to organize your **shellscripts** by splitting them in **commands libraries**.

If you spend much time on unix consoles in your developer's life, you probably built a set of ninja's scripts you use everyday to work an efficient way. ShellBox's original purpose is to provide a frame to build *project development Command Line Interfaces* (= your set of ninja's scripts).

### Features:

- **Lightly standardize shellscripts:**
    - Every library is composed of public commands and private functions.
    - Your libraries are directly executable: `$ a_library.sb a_command opt_1 opt_2 ...`.
- **Build libraries of reusable commands:**
    - Your scripts are sliced in namespaced commands libraries.
    - Every libraries can run other's command by requiring them: `require 'other_lib'; other_lib::command 'foo'`.
- **Designed for Command Line Interface:**
    - Easily create a command that generates a "manual" from your code documentation.
    - Enjoy the `bash` and `zsh` completions of commands and options.


## Getting started

### Installation

	git clone git@github.com:FooPixel/ShellBox.git ShellBox
	cd ShellBox
	export PATH="`pwd`/bin:$PATH" # make the shellbox libraries executable
	export PATH="`pwd`/box:$PATH" # make the libraries of this shellbox available in your PATH

ShellBox is now ready for your current shell session.
To get it automatically available in all your shell sessions, add the PATH configuration to your `.profile` file.

	echo "export PATH=\"`pwd`/bin:\$PATH\"" >> ~/.profile
	echo "export PATH=\"`pwd`/box:\$PATH\"" >> ~/.profile


### Create your commands library

#### print.sb

The first library allows you to print colored messages in shell console. The library print colors *iff* it's called in an interactive console.

	#!/usr/bin/env shellbox
	#
	# A console print library.
	# It's purpose is to illustrate how ShellBox is fun.


	# The following lines are executed when this library is required or executed.
	if [[ -t 1 ]] && [[ -t 2 ]] # if stdout and stderr are tty, then define colors
	then
		esc=""
		reset="${esc}[0m"
		cyanf="${esc}[36m"
		yellowf="${esc}[33m"
	fi


	# COMMANDS:

	## Print a warning message on stderr.
	# The parameters are printed in yellow and prefixed with ` ⚑ `.
	#
	# @params	args	The warning message
	function print::warning() {
		echo "${yellowf} ⚑ $@${reset}" >&2
	}

	## Print an item on stdout.
	# The parameters are printed in cyan and prefixed with ` ● `.
	#
	# @params	args	The item to print
	function print::item() {
		echo "${cyanf} ● $@${reset}"
	}

Make `print.sb` executable: `chmod 755 print.sb`

Now you can execute `print` commands:

	$ ./print.sb warning This is a warning message, printed on stderr
	 ⚑ This is a warning message, printed on stderr

	$ ./print.sb item `seq 1 10`
	 ● 1 2 3 4 5 6 7 8 9 10


#### complex.sb

This library is an example of a library that rely on other's commands libraries. The `complexe.sb` library require our `print.sb` library and the `shared` library.

`complex.sb`:

	#!/usr/bin/env shellbox
	#
	# A complex library.
	# It's purpose is to illustrate how it's easy to share commands between libraries.

	require 'print' # that means the complex library rely on the `print.sb` library

	# COMMANDS:

	## Print each parameter in one line.
	#
	# @params	args	The params to print
	function complex::print() {
		if [[ $# -lt 1 ]]
		then
			print::warning "There is no parameters" # assume the warning command print the message on stderr and return 1
		else
			complex_print_array "$@"
		fi
	}


	## Display a short help of the library or the help of the library command provided
	#
	# @param	[command_name]	The command name
	function complex::help() {
		require 'shared'
		shared::help 'complex' "$@"
	}


	# PRIVATE FUNCTIONS:

	## Print all the given params separated with the delimiter
	#
	# @param	args		The parameters
	function complex_print_array() {
		for param in "$@"
		do
			print::item "$param"
		done
	}

Make `complex.sb` executable: `chmod 755 complex.sb`

Now you can execute `complex` commands:

	$ ./complex.sb print `seq 1 10`
	 ● 1
	 ● 2
	 ● 3
	 ● 4
	 ● 5
	 ● 6
	 ● 7
	 ● 8
	 ● 9
	 ● 10

	$ ./complex.sb help
	Available commands for this library:
	    complex help [command_name]
	    complex man
	    complex print args*

