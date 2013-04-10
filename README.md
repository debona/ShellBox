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

