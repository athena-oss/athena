* [Using CLI Functions](#using-cli-functions)
  * [Handling *argument*](#handling-argument)
    * [`athena.argument.append_to_arguments`](#athenaargumentappendtoarguments)
    * [`athena.argument.arg`](#athenaargumentarg)
    * [`athena.argument.args`](#athenaargumentargs)
    * [`athena.argument.argument_exists`](#athenaargumentargumentexists)
    * [`athena.argument.argument_exists_and_remove`](#athenaargumentargumentexistsandremove)
    * [`athena.argument.argument_exists_or_fail`](#athenaargumentargumentexistsorfail)
    * [`athena.argument.argument_is_not_empty`](#athenaargumentargumentisnotempty)
    * [`athena.argument.argument_is_not_empty_or_fail`](#athenaargumentargumentisnotemptyorfail)
    * [`athena.argument.get_argument`](#athenaargumentgetargument)
    * [`athena.argument.get_argument_and_remove`](#athenaargumentgetargumentandremove)
    * [`athena.argument.get_arguments`](#athenaargumentgetarguments)
    * [`athena.argument.get_integer_argument`](#athenaargumentgetintegerargument)
    * [`athena.argument.get_path_from_argument`](#athenaargumentgetpathfromargument)
    * [`athena.argument.get_path_from_argument_and_remove`](#athenaargumentgetpathfromargumentandremove)
    * [`athena.argument.is_integer`](#athenaargumentisinteger)
    * [`athena.argument.nr_args_lt`](#athenaargumentnrargslt)
    * [`athena.argument.nr_of_arguments`](#athenaargumentnrofarguments)
    * [`athena.argument.pop_arguments`](#athenaargumentpoparguments)
    * [`athena.argument.prepend_to_arguments`](#athenaargumentprependtoarguments)
    * [`athena.argument.remove_argument`](#athenaargumentremoveargument)
    * [`athena.argument.set_arguments`](#athenaargumentsetarguments)
    * [`athena.argument.string_contains`](#athenaargumentstringcontains)
  * [Handling *color*](#handling-color)
    * [`athena.color.print_color`](#athenacolorprintcolor)
    * [`athena.color.print_debug`](#athenacolorprintdebug)
    * [`athena.color.print_error`](#athenacolorprinterror)
    * [`athena.color.print_fatal`](#athenacolorprintfatal)
    * [`athena.color.print_info`](#athenacolorprintinfo)
    * [`athena.color.print_ok`](#athenacolorprintok)
    * [`athena.color.print_warn`](#athenacolorprintwarn)
  * [Handling *fs*](#handling-fs)
    * [`athena.fs.absolutepath`](#athenafsabsolutepath)
    * [`athena.fs.basename`](#athenafsbasename)
    * [`athena.fs.dir_contains_files`](#athenafsdircontainsfiles)
    * [`athena.fs.dir_exists_or_create`](#athenafsdirexistsorcreate)
    * [`athena.fs.dir_exists_or_fail`](#athenafsdirexistsorfail)
    * [`athena.fs.file_contains_string`](#athenafsfilecontainsstring)
    * [`athena.fs.file_exists_or_fail`](#athenafsfileexistsorfail)
    * [`athena.fs.get_cache_dir`](#athenafsgetcachedir)
    * [`athena.fs.get_file_contents`](#athenafsgetfilecontents)
    * [`athena.fs.get_full_path`](#athenafsgetfullpath)
  * [Handling *os*](#handling-os)
    * [`athena.os.call_with_args`](#athenaoscallwithargs)
    * [`athena.os.enable_error_mode`](#athenaosenableerrormode)
    * [`athena.os.enable_quiet_mode`](#athenaosenablequietmode)
    * [`athena.os.enable_verbose_mode`](#athenaosenableverbosemode)
    * [`athena.os.exec`](#athenaosexec)
    * [`athena.os.exit`](#athenaosexit)
    * [`athena.os.exit_with_msg`](#athenaosexitwithmsg)
    * [`athena.os.function_exists`](#athenaosfunctionexists)
    * [`athena.os.function_exists_or_fail`](#athenaosfunctionexistsorfail)
    * [`athena.os.get_base_dir`](#athenaosgetbasedir)
    * [`athena.os.get_base_lib_dir`](#athenaosgetbaselibdir)
    * [`athena.os.get_command`](#athenaosgetcommand)
    * [`athena.os.get_executable`](#athenaosgetexecutable)
    * [`athena.os.get_host_ip`](#athenaosgethostip)
    * [`athena.os.get_instance`](#athenaosgetinstance)
    * [`athena.os.get_prefix`](#athenaosgetprefix)
    * [`athena.os.handle_exit`](#athenaoshandleexit)
    * [`athena.os.include_once`](#athenaosincludeonce)
    * [`athena.os.is_command_set`](#athenaosiscommandset)
    * [`athena.os.is_debug_active`](#athenaosisdebugactive)
    * [`athena.os.is_git_installed`](#athenaosisgitinstalled)
    * [`athena.os.is_linux`](#athenaosislinux)
    * [`athena.os.is_mac`](#athenaosismac)
    * [`athena.os.is_sudo`](#athenaosissudo)
    * [`athena.os.override_exit_handler`](#athenaosoverrideexithandler)
    * [`athena.os.print_stacktrace`](#athenaosprintstacktrace)
    * [`athena.os.register_exit_handler`](#athenaosregisterexithandler)
    * [`athena.os.return`](#athenaosreturn)
    * [`athena.os.set_command`](#athenaossetcommand)
    * [`athena.os.set_debug`](#athenaossetdebug)
    * [`athena.os.set_exit_handler`](#athenaossetexithandler)
    * [`athena.os.set_instance`](#athenaossetinstance)
    * [`athena.os.split_string`](#athenaossplitstring)
    * [`athena.os.usage`](#athenaosusage)
  * [Handling *utils*](#handling-utils)
    * [`athena.utils.add_to_array`](#athenautilsaddtoarray)
    * [`athena.utils.array_pop`](#athenautilsarraypop)
    * [`athena.utils.compare_number`](#athenautilscomparenumber)
    * [`athena.utils.find_index_in_array`](#athenautilsfindindexinarray)
    * [`athena.utils.get_array`](#athenautilsgetarray)
    * [`athena.utils.get_version_components`](#athenautilsgetversioncomponents)
    * [`athena.utils.in_array`](#athenautilsinarray)
    * [`athena.utils.is_integer`](#athenautilsisinteger)
    * [`athena.utils.prepend_to_array`](#athenautilsprependtoarray)
    * [`athena.utils.remove_from_array`](#athenautilsremovefromarray)
    * [`athena.utils.set_array`](#athenautilssetarray)
    * [`athena.utils.validate_version`](#athenautilsvalidateversion)
    * [`athena.utils.validate_version_format`](#athenautilsvalidateversionformat)

# Using CLI Functions
 
## Handling *argument*
 
### <a name="athenaargumentappendtoarguments"></a>`athena.argument.append_to_arguments`
 
This function appends the given argumnets to the argument list ($ATHENA_ARGS).
 
**USAGE:**  `athena.argument.append_to_arguments <argument...>`
 
**RETURN:** `--`
 
### <a name="athenaargumentarg"></a>`athena.argument.arg`
 
This function is a wraper for the athena.argument.get_argument function.
 
**USAGE:**  `athena.argument.arg <argument position or name>`
 
**RETURN:** `string`
 
### <a name="athenaargumentargs"></a>`athena.argument.args`
 
This function is a wrapper for the athena.argument.get_arguments function. It returns the argument list ($ATHENA_ARGS).
 
**USAGE:**  `athena.argument.args`
 
**RETURN:** `string`
 
### <a name="athenaargumentargumentexists"></a>`athena.argument.argument_exists`
 
This function checks if an argument exists in the argument list $ATHENA_ARGS.
 
**USAGE:**  `athena.argument.argument_exists <argument name>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaargumentargumentexistsandremove"></a>`athena.argument.argument_exists_and_remove`
 
This function checks if an argument exists (see athena.argument.argument_exists) in the argument list $ATHENA_ARGS and removes it if it exists.
 
**USAGE:**  `athena.argument.argument_exists_and_remove <argument name> [<name of variable to save the value>]`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaargumentargumentexistsorfail"></a>`athena.argument.argument_exists_or_fail`
 
This function checks if an argument exists (see athena.argument.argument_exists) in the argument list $ATHENA_ARGS. If no argument was given or the argument was not found script execution is exited and an error message is thrown.
 
**USAGE:**  `athena.argument.argument_exists_or_fail <argument name>`
 
**RETURN:** `--`
 
### <a name="athenaargumentargumentisnotempty"></a>`athena.argument.argument_is_not_empty`
 
This function checks if the given arguments string is not empty.
 
**USAGE:**  `athena.argument.argument_is_not_empty <arguments string>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaargumentargumentisnotemptyorfail"></a>`athena.argument.argument_is_not_empty_or_fail`
 
This function checks if the given arguments string is not empty. If it is empty execution is stopped and an error message is thrown. If not empty the error code 0 is returned.
 
**USAGE:**  `athena.argument.argument_is_not_empty_or_fail <argument string> [<name>]`
 
**RETURN:** `0 (true)`
 
### <a name="athenaargumentgetargument"></a>`athena.argument.get_argument`
 
This function returns the requested argument name or value if found in the argument list $ATHENA_ARGS. The function interpretes an given integer as argument index and a given string as argument name (e.g. for the list "a=3 b=5" "3" is return if "a" is requested and "a=3" is returned if "1" is requested).
 
**USAGE:**  `athena.argument.get_argument <argument position or name>`
 
**RETURN:** `string`
 
### <a name="athenaargumentgetargumentandremove"></a>`athena.argument.get_argument_and_remove`
 
This function returns the argument name or value (see athena.argument.get_argument) and removes it from the $ATHENA_ARGS list.
 
**USAGE:**  `athena.argument.get_argument_and_remove <argument position or name> [<name of variable to save the value>]`
 
**RETURN:** `string`
 
### <a name="athenaargumentgetarguments"></a>`athena.argument.get_arguments`
 
This function will copy the $ATHENA_ARGS array into a variable provided as argument, unless it is being used in a shubshell, then a string containing all the arguments will be output.
 
**USAGE:**  `athena.argument.get_arguments [array_name]`
 
**RETURN:** `0 (success) | 1 (failure)`
 
### <a name="athenaargumentgetintegerargument"></a>`athena.argument.get_integer_argument`
 
This function returns the value for the given argument and if it is not an integer it will exit with error.
 
**USAGE:**  `athena.argument.get_integer_argument <argument position or name> [<error string>]`
 
**RETURN:** `int`
 
### <a name="athenaargumentgetpathfromargument"></a>`athena.argument.get_path_from_argument`
 
This function extract a argument string or value (see athena.argument.get_argument) from the $ATHENA_ARGS list and checks if it is a valid directory path. If it is valid the path is return, if not script execution is exited and an error message is thrown.
 
**USAGE:**  `athena.argument.get_path_from_argument <argument position or name>`
 
**RETURN:** `string`
 
### <a name="athenaargumentgetpathfromargumentandremove"></a>`athena.argument.get_path_from_argument_and_remove`
 
This function returns a valid direcory path if the given argument name or value (see athena.argument.get_path_from_argument) could be converted and removes the argument from the $ATHENA_ARGS list.
 
**USAGE:**  `athena.argument.get_path_from_argument_and_remove <argument position or name>`
 
**RETURN:** `string`
 
### <a name="athenaargumentisinteger"></a>`athena.argument.is_integer`
 
This function checks if an argument is an integer.
 
**USAGE:**  `athena.argument.is_integer <argument>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaargumentnrargslt"></a>`athena.argument.nr_args_lt`
 
This function returns the error code 0 if the number of arguments in $ATHENA_ARGS is less than the given number. If not the error code 1 is returned.
 
**USAGE:**  `athena.argument.nr_args_lt <number>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaargumentnrofarguments"></a>`athena.argument.nr_of_arguments`
 
This function returns the number of arguments found in the argument list $ATHENA_ARGS.
 
**USAGE:**  `athena.argument.nr_of_arguments`
 
**RETURN:** `int`
 
### <a name="athenaargumentpoparguments"></a>`athena.argument.pop_arguments`
 
This function pops a number of arguments from the argument list $ATHENA_ARGS.
 
**USAGE:**  `athena.argument.pop_arguments <number>`
 
**RETURN:** `--`
 
### <a name="athenaargumentprependtoarguments"></a>`athena.argument.prepend_to_arguments`
 
This function prepends the given argumnets to the argument list ($ATHENA_ARGS).
 
**USAGE:**  `athena.argument.prepend_to_arguments <argument...>`
 
**RETURN:** `--`
 
### <a name="athenaargumentremoveargument"></a>`athena.argument.remove_argument`
 
This function removes an argument from the argument list $ATHENA_ARGS if it is in the list.
 
**USAGE:**  `athena.argument.remove_argument <argument|index>`
 
**RETURN:** `0 (successful), 1 (failed)`
 
### <a name="athenaargumentsetarguments"></a>`athena.argument.set_arguments`
 
This function sets the argument list ($ATHENA_ARGS) to the given arguments.
 
**USAGE:**  `athena.argument.set_arguments <argument...>`
 
**RETURN:** `--`
 
### <a name="athenaargumentstringcontains"></a>`athena.argument.string_contains`
 
This function if a string contains a substring. With --literal, regex is not parsed, and there's a literal comparison.
 
**USAGE:**  `athena.argument.string_contains <string> <sub-string> [--literal]`
 
**RETURN:** `0 (true), 1 (false)`
 
## Handling *color*
 
### <a name="athenacolorprintcolor"></a>`athena.color.print_color`
 
This function prints the given string in a given color on STDOUT. Available colors are "green", "red", "blue", "yellow", "cyan", and "normal".
 
**USAGE:**  `athena.color.print_color <color> <string> [<non_colored_string>]`
 
**RETURN:** `--`
 
### <a name="athenacolorprintdebug"></a>`athena.color.print_debug`
 
This function prints the given string on STDOUT formatted as debug message if debug mode is set.
 
**USAGE:**  `athena.color.print_debug <string>`
 
**RETURN:** `--`
 
### <a name="athenacolorprinterror"></a>`athena.color.print_error`
 
This function prints the given string on STDOUT formatted as error message.
 
**USAGE:**  `athena.color.print_error <string>`
 
**RETURN:** `--`
 
### <a name="athenacolorprintfatal"></a>`athena.color.print_fatal`
 
This function prints the given string on STDOUT formatted as fatal message and exit with 1 or the given code.
 
**USAGE:**  `athena.color.print_fatal <string> [<exit_code>]`
 
**RETURN:** `--`
 
### <a name="athenacolorprintinfo"></a>`athena.color.print_info`
 
This function prints the given string on STDOUT formatted as info message.
 
**USAGE:**  `athena.color.print_info <string>`
 
**RETURN:** `--`
 
### <a name="athenacolorprintok"></a>`athena.color.print_ok`
 
This function prints the given string on STDOUT formatted as ok message.
 
**USAGE:**  `athena.color.print_ok <string>`
 
**RETURN:** `--`
 
### <a name="athenacolorprintwarn"></a>`athena.color.print_warn`
 
This function prints the given string on STDOUT formatted as warn message.
 
**USAGE:**  `athena.color.print_warn <string>`
 
**RETURN:** `--`
 
## Handling *fs*
 
### <a name="athenafsabsolutepath"></a>`athena.fs.absolutepath`
 
This function checks if the given argument is a valid absolute path to a directory or file. If not, execution is stopped and an error message is thrown. Otherwise the absolute path is returned.
 
**USAGE:**  `athena.fs.absolutepath <file or directory name>`
 
**RETURN:** `string`
 
### <a name="athenafsbasename"></a>`athena.fs.basename`
 
This function returns the basename of a file. If the file does not exist it will generate an error. It can be a full path or relative to the file.
 
**USAGE:**  `athena.fs.basename <filename>`
 
**RETURN:** `string`
 
### <a name="athenafsdircontainsfiles"></a>`athena.fs.dir_contains_files`
 
This function checks if the given directory contains files with certain pattern (e.g.: *.sh). Globbing has 'dotglob' and 'extglob' (see BASH(1)) enabled.
 
**USAGE:**  `athena.fs.dir_contains_files <directory> <pattern>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenafsdirexistsorcreate"></a>`athena.fs.dir_exists_or_create`
 
This function checks if the given directory name is valid. If not the directory is been created. If the creation fails execution is stopped and an error message is thrown. 0 is returned if the directory exists or was created.
 
**USAGE:**  `athena.fs.file_exists_or_fail <directory name>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenafsdirexistsorfail"></a>`athena.fs.dir_exists_or_fail`
 
This function checks if the given directory name is valid. If not execution is stopped and an error message is thrown. The displayed error message can be passed as second argument.
 
**USAGE:**  `athena.fs.dir_exists_or_fail <directory name> <message>`
 
**RETURN:** `--`
 
### <a name="athenafsfilecontainsstring"></a>`athena.fs.file_contains_string`
 
This function checks if the filename contains the given string.
 
**USAGE:**  `athena.fs.file_contains_string_<filename> <string>`
 
**RETURN:** `0 (true), 1 (true)`
 
### <a name="athenafsfileexistsorfail"></a>`athena.fs.file_exists_or_fail`
 
This function checks if the given filename is valid. If not execution is stopped and an error message is thrown. The displayed error message can be passed as second argument.
 
**USAGE:**  `athena.fs.file_exists_or_fail <filename> <message>`
 
**RETURN:** `--`
 
### <a name="athenafsgetcachedir"></a>`athena.fs.get_cache_dir`
 
Returns the name of athena cache directory. If it does not exist, then it will be created and then returned.
 
**USAGE:**  `athena.fs.get_cache_dir`
 
**RETURN:** `string`
 
### <a name="athenafsgetfilecontents"></a>`athena.fs.get_file_contents`
 
This function checks if the given filename is valid. If not execution is stopped and an error message is thrown. If the given name is a valid filename the file content returned.
 
**USAGE:**  `athena.fs.get_file_contents <filename>`
 
**RETURN:** `string`
 
### <a name="athenafsgetfullpath"></a>`athena.fs.get_full_path`
 
This function checks if the given argument is a valid directory or file and returns the absolute directory path of the given file or directory (a relative path is converted in an absolute directory path). If the path is not valid execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.fs.get_full_path <file or directory name>`
 
**RETURN:** `string`
 
## Handling *os*
 
### <a name="athenaoscallwithargs"></a>`athena.os.call_with_args`
 
This function will call the command/function passed as argument with all the arguments existing in $ATHENA_ARGS.
 
**USAGE:**  `athena.os.call_with_args <command>`
 
**RETURN:** `<command> result | 1 (false) if no <command> was specified or it doesn' exist`
 
### <a name="athenaosenableerrormode"></a>`athena.os.enable_error_mode`
 
This function enables the error only output mode. To be used in conjunction with athena.os.exec.
 
**USAGE:**  `athena.os.enable_error_mode`
 
**RETURN:** `--`
 
### <a name="athenaosenablequietmode"></a>`athena.os.enable_quiet_mode`
 
This function enables the no output mode. To be used in conjunction with athena.os.exec.
 
**USAGE:**  `athena.os.enable_quiet_mode`
 
**RETURN:** `--`
 
### <a name="athenaosenableverbosemode"></a>`athena.os.enable_verbose_mode`
 
This function enables the all output mode. To be used in conjunction with athena.os.exec.
 
**USAGE:**  `athena.os.enable_verbose_mode`
 
**RETURN:** `--`
 
### <a name="athenaosexec"></a>`athena.os.exec`
 
This function wraps command execution to allow for switching output modes. The output mode is defined by using the athena.os.set_output_* functions.
 
**USAGE:**  `athena.os.exec <function> <args>`
 
**RETURN:** `int`
 
### <a name="athenaosexit"></a>`athena.os.exit`
 
This function exits Athena if called (if a forced exit is required). Default exit_code is 1.
 
**USAGE:**  `athena.os.exit [<exit_code>]`
 
**RETURN:** `--`
 
### <a name="athenaosexitwithmsg"></a>`athena.os.exit_with_msg`
 
This function exits Athena with an error message (see athena.os.exit).
 
**USAGE:**  `athena.os.exit_with_msg <error message> [<exit_code>]`
 
**RETURN:** `--`
 
### <a name="athenaosfunctionexists"></a>`athena.os.function_exists`
 
This functions checks if the function with the given name exists.
 
**USAGE:**  `athena.os.function_exists <name>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenaosfunctionexistsorfail"></a>`athena.os.function_exists_or_fail`
 
This functions checks if the function with the given name exists, if not it will abort the current execution.
 
**USAGE:**  `athena.os.function_exists_or_fail <name>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenaosgetbasedir"></a>`athena.os.get_base_dir`
 
This functions returns the base directory of athena.
 
**USAGE:**  `athena.os.get_base_dir`
 
### <a name="athenaosgetbaselibdir"></a>`athena.os.get_base_lib_dir`
 
This functions returns the base lib directory of athena.
 
**USAGE:**  `athena.os.get_base_lib_dir`
 
### <a name="athenaosgetcommand"></a>`athena.os.get_command`
 
This function returns the content of the $ATHENA_COMMAND variable. If it is not set execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.os.get_command <command>`
 
**RETURN:** `string`
 
### <a name="athenaosgetexecutable"></a>`athena.os.get_executable`
 
This function returns the executable for athena.
 
**USAGE:**  `athena.os.get_executable`
 
**RETURN:** `string`
 
### <a name="athenaosgethostip"></a>`athena.os.get_host_ip`
 
This functions returns the ip of the host of athena.
 
**USAGE:**  `athena.os.get_host_ip`
 
**RETURN:** `string`
 
### <a name="athenaosgetinstance"></a>`athena.os.get_instance`
 
This function returns the value of the current instance as set in the $ATHENA_INSTANCE variable.
 
**USAGE:**  `athena.os.get_instance`
 
**RETURN:** `string`
 
### <a name="athenaosgetprefix"></a>`athena.os.get_prefix`
 
This functions returns the prefix that is used to create names for
 
**USAGE:**  `athena.os.get_prefix`
 
**RETURN:** `string`
 
### <a name="athenaoshandleexit"></a>`athena.os.handle_exit`
 
This function handles the signals sent to and by athena.
 
**USAGE:**  `athena.os.handle_exit <signal>`
 
**RETURN:** `--`
 
### <a name="athenaosincludeonce"></a>`athena.os.include_once`
 
This function checks if a given Bash source file exists and includes it if it wasn't loaded before. If it was loaded nothing is done (avoid multiple sourcing).
 
**USAGE:**  `athena.os.include_once <Bash source file>`
 
**RETURN:** `--`
 
### <a name="athenaosiscommandset"></a>`athena.os.is_command_set`
 
This functions checks if $ATHENA_COMMAND variable is set.
 
**USAGE:**  `athena.os.is_command_set`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenaosisdebugactive"></a>`athena.os.is_debug_active`
 
This function returns the error code 0 if the debug flag ($ATHENA_IS_DEBUG) is set. If not it returns the error code 1.
 
**USAGE:**  `athena.os.is_debug_active`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaosisgitinstalled"></a>`athena.os.is_git_installed`
 
This function checks if the 'git' command is available (i.e. if git is installed). If not execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.os.is_git_installed`
 
**RETURN:** `--`
 
### <a name="athenaosislinux"></a>`athena.os.is_linux`
 
This function checks if Athena runs on a Linux machine.
 
**USAGE:**  `athena.os.is_mac`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaosismac"></a>`athena.os.is_mac`
 
This function checks if Athena runs on a Mac OS X.
 
**USAGE:**  `athena.os.is_mac`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaosissudo"></a>`athena.os.is_sudo`
 
This function checks if the $ATHENA_SUDO variable is set.
 
**USAGE:**  `athena.os.is_sudo`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaosoverrideexithandler"></a>`athena.os.override_exit_handler`
 
This functions overrides the exit handler with the default signals to catch.
 
**USAGE:**  `athena.os.override_exit_handler <function_name>`
 
**RETURN:** `--`
 
### <a name="athenaosprintstacktrace"></a>`athena.os.print_stacktrace`
 
This function prints the stacktrace.
 
**USAGE:**  `athena.os.print_stacktrace`
 
**RETURN:** `--`
 
### <a name="athenaosregisterexithandler"></a>`athena.os.register_exit_handler`
 
This function register the exit handler that takes the decision of what to do when interpreting the exit codes and signals.
 
**USAGE:**  `athena.os.register_exit_handler <function_name> <list_of_signals_to_trap>`
 
**RETURN:** `--`
 
### <a name="athenaosreturn"></a>`athena.os.return`
 
This function assigns a value to a variable and overcomes the problem of assignment in subshells losing the current environment. It is meant to be used in the getters and expects that the function using it follows the convention athena.get_<variable>. NOTE: when used in subshell it will echo the value to be assigned to a variable.
 
**USAGE:**  `athena.os.return <value> [<name_of_variable_to_assign_to>]`
 
**RETURN:** `string`
 
### <a name="athenaossetcommand"></a>`athena.os.set_command`
 
This function sets the $ATHENA_COMMAND variable to the given command string if it is not empty. If it is empty execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.os.set_command <command>`
 
**RETURN:** `--`
 
### <a name="athenaossetdebug"></a>`athena.os.set_debug`
 
This function sets the debug flag ($ATHENA_IS_DEBUG) to the given value. If no value is provided $ATHENA_IS_DEBUG is set to 0 (disabled).
 
**USAGE:**  `athena.os.set_debug <debug value>`
 
**RETURN:** `--`
 
### <a name="athenaossetexithandler"></a>`athena.os.set_exit_handler`
 
This functions registers the exit handler with the default signals to catch.
 
**USAGE:**  `athena.os.set_exit_handler`
 
**RETURN:** `--`
 
### <a name="athenaossetinstance"></a>`athena.os.set_instance`
 
This functions sets the instance value.
 
**USAGE:**  `athena.os.set_instance <value>`
 
**RETURN:** `--`
 
### <a name="athenaossplitstring"></a>`athena.os.split_string`
 
This function splits up a string on the specified field separator and will write the array into the given variable.
 
**USAGE:**  `athena.os.split_string <string_to_split> <separator_character> <variable_name>`
 
**RETURN:** `--`
 
### <a name="athenaosusage"></a>`athena.os.usage`
 
This function prints the usage and exits with 1 and handles the name of the command automatically and the athena executable.
 
**USAGE:**  `athena.os.usage [<min_args>] [<options>] [<multi-line options>]`
 
**RETURN:** `--`
 
## Handling *utils*
 
### <a name="athenautilsaddtoarray"></a>`athena.utils.add_to_array`
 
This functions adds elements to the given array.
 
**USAGE:**  `athena.utils.add_to_array <array_name> <element...>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsarraypop"></a>`athena.utils.array_pop`
 
This function pops elements from the given array, if argument 2 is an integer then it will pop as many times as specified.
 
**USAGE:**  `athena.utils.array_pop <array_name> [number_of_times]`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilscomparenumber"></a>`athena.utils.compare_number`
 
This function compares a number to another with the given operator (>, >=, <, <=)
 
**USAGE:**  `athena.utils.compare_number <number_a> <number_b> <comparator>`
 
### <a name="athenautilsfindindexinarray"></a>`athena.utils.find_index_in_array`
 
This function returns the index of the element specified.
 
**USAGE:**  `athena.utils.find_index_in_array <array_name> <needle> [strict]`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsgetarray"></a>`athena.utils.get_array`
 
This function returns the elements of the given array in case of subshell assignment or stores them in a new variable if specified in argument 2.
 
**USAGE:**  `athena.utils.get_array <array_name> [other_array_name]`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsgetversioncomponents"></a>`athena.utils.get_version_components`
 
This function extracts the values from a Semantic Versioning 2 format into an array. index 0 contains the operation, index 1 the MAJOR version, index 2 MINOR version and index 3 the PATCH version.
 
**USAGE:**  `athena.utils.get_version_components <sem_ver_string> <array_name_to_store>`
 
### <a name="athenautilsinarray"></a>`athena.utils.in_array`
 
This function checks if the element exists in the given array.
 
**USAGE:**  `athena.utils.in_array <array_name> <element> [strict]`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsisinteger"></a>`athena.utils.is_integer`
 
This function checks if a value is an integer.
 
**USAGE:**  `athena.utils.is_integer <value>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsprependtoarray"></a>`athena.utils.prepend_to_array`
 
This function prepends the given elements to the specified array.
 
**USAGE:**  `athena.utils.prepend_to_array <array_name> <element...>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsremovefromarray"></a>`athena.utils.remove_from_array`
 
This function removes the specified element from the array.
 
**USAGE:**  `athena.utils.remove_from_array <array_name> <needle> [strict]`
 
**RETURN:** `0 (succeeded), 1 (failed)`
 
### <a name="athenautilssetarray"></a>`athena.utils.set_array`
 
This function assigns the given elements to the specified array.
 
**USAGE:**  `athena.utils.set_array <array_name> <element...>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenautilsvalidateversion"></a>`athena.utils.validate_version`
 
This function validates if the given version meets the expected version criteria.
 
**USAGE:**  `athena.utils.validate_version <version_str> <expected_version|base_version end_version>`
 
### <a name="athenautilsvalidateversionformat"></a>`athena.utils.validate_version_format`
 
This function validates if the given version follows Semantic Versioning 2.0.
 
**USAGE:**  `athena.utils.validate_version_format <version>`
 
**RETURN:** `0 (true) 1 (false)`
