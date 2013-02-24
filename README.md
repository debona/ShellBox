
ShellBox
=========

**ShellBox is a straightforward framework** which help to organize the **shellscript** development.

### ShellBox's goals

- Lightly standardize shellscript development
- Build a library of small reusable shellscript
- Provide free `man`like manuals from the code documentation
- Provide free option completions from the code (documentation)


Example
-------

### Your shell code

...

### The generated manual

...

### How to use it

...


Usage
-----

### Standalone

Shellbox allow to use directly library file. This is a straightforward but pretty verbose usage.

	shellbox/full/path/shellbox.sh	path/to/taks/my_library.task.sh
	shellbox/full/path/shellbox.sh	path/to/taks/my_library.task.sh	command_1


### Automagic

If you are a magic enthusiast, you would appreciate to use shellbox this way:

	source	shellbox/full/path/source_me.sh	path/to/taks

Now, enjoy `my_library`

	my_library
	my_library	command_1

The `source_me.sh` script creates the aliases for shellbox emmbeded librarys and all librarys in `path/to/taks`.
It also add awesome library commands completion to your shell environment. So `my_library	c` will be complete by `my_library	command_1`.


### More details

For more details about how it works, please read the fuckin' source code :trollface:.
I might explain how it works but I would be so happy if you could understand it yourself.

The 3 kind of script

How to dive into source code


Contribute
----------

### Fork it

...


### Use it in your dotfiles

...


### Use it as submodule in project

...
