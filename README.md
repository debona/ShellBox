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

```sh
git clone git@github.com:FooPixel/ShellBox.git ShellBox
cd ShellBox
export PATH="`pwd`/bin:$PATH" # make the shellbox libraries executable
export PATH="`pwd`/box:$PATH" # make the libraries of this shellbox available in your PATH
```

ShellBox is now ready for your current shell session.
To get it automatically available in all your shell sessions, add the PATH configuration to your `.profile` file.

```sh
echo "export PATH=\"`pwd`/bin:\$PATH\"" >> ~/.profile
echo "export PATH=\"`pwd`/box:\$PATH\"" >> ~/.profile
```

### Create your commands library

#### Basic library example

The first library allows you to print colored messages in shell console. The library print colors *iff* it's called in an interactive console.

`print.sb`:

```sh
#!/usr/bin/env shellbox
#
# A print library.
# It's purpose is to illustrate how ShellBox is fun.

# The following lines are executed when this library is required or executed.
if [[ -t 1 ]] && [[ -t 2 ]] # if stdout and stderr are tty, then define colors
then
	reset='\033[0m'
	yellowf='\033[33m'
fi

# COMMANDS:

## Print a warning message on stderr.
#
# @params	args	The warning message
function print::warning() {
	echo -e "${yellowf} ⚑ $@${reset}" >&2
}
```

Make `print.sb` executable: `chmod 755 print.sb`

Now you can execute `print` commands in your console:

```sh
$ ./print.sb warning "printed on stderr" 1> /dev/null
 ⚑ printed on stderr
```

#### Advanced library example

This library is an example of a library that rely on other's commands libraries. The `complexe.sb` library require our `print.sb` library and the `shared` library.

`complex.sb`:

```sh
#!/usr/bin/env shellbox
#
# A complex library.
# It's purpose is to illustrate how to rely on other libraries.

require 'print' # that means the complex library rely on the `print.sb` library

# COMMANDS:

## Print each parameter in one line.
#
# @params	args	The params to print
function complex::print() {
	if [[ $# -lt 1 ]]
	then
		print::warning 'There is no parameters'
	else
		complex_print_list "$@"
	fi
}

## Display a short help of the library or the help of the library command provided
#
# @param	[command_name]	The command name
function complex::help() {
	require 'shared' # a library can be required everywhere
	shared::help 'complex' "$@"
}

# PRIVATE FUNCTIONS:

## Print all the given params separated with the delimiter
#
# @param	args	The parameters
function complex_print_list() {
	for param in "$@"
	do
		echo " ● $param"
	done
}
```

Make `complex.sb` executable: `chmod 755 complex.sb`

Now you can execute `complex` commands in your console:

	$ complex.sb print `seq 1 3`
	 ● 1
	 ● 2
	 ● 3

	$ complex.sb help
	Available commands for this library:
	    complex help [command_name]
	    complex print args*


## How does it work?

Every **libraries** are executed through the `shellbox` **library interpreter**. This *interpreter* define few functions and then execute the given library command.

#### What happen when you execute a library command?

1. Your shell reads the first line of your script (the shebang) and runs the `shellbox` lib interpreter (with your lib as parameter).
2. The interpreter declares few functions. The most important function is the **require** function.
3. The interpreter calls the **require** function on your library. The most important thing this function does is sourcing your library.
4. The interpreter looks for a function like `your_lib::the_command` to call, and then call it.


#### How does the require function look for libraries?

1. The **require** function look for the `*.sb` files present in your `PATH`.
2. The first library that match the given library name is taken.

