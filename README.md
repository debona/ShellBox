
ShellTask
=========

**ShellTask is a straightforward framework** which help to organize the **shellscript** development.

### ShellTask's goals

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

Shelltask allow to use directly task file. This is a straightforward but pretty verbose usage.

	shelltask/full/path/shelltask.sh	path/to/taks/my_task.task.sh
	shelltask/full/path/shelltask.sh	path/to/taks/my_task.task.sh	command_1


### Automagic

If you are a magic enthusiast, you would appreciate to use shelltask this way:

	source	shelltask/full/path/source_me.sh	path/to/taks

Now, enjoy `my_task`

	my_task
	my_task	command_1

The `source_me.sh` script creates the aliases for shelltask emmbeded tasks and all tasks in `path/to/taks`.
It also add awesome task commands completion to your shell environment. So `my_task	c` will be complete by `my_task	command_1`.


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
