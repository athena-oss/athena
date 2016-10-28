# The aliases declared in here are intended to simplify the life of the developer
# of plugins or core functionality of athena, by creating allowing for shorter names

shopt -s expand_aliases

# handling arguments
alias athena.arg=athena.argument.get_argument
alias athena.args=athena.argument.get_arguments
alias athena.nr_args_lt=athena.argument.nr_args_lt
alias athena.arg_exists=athena.argument.argument_exists
alias athena.pop_args=athena.argument.pop_arguments
alias athena.int=athena.argument.get_integer_argument

# handling fs
alias athena.dir_exists_or_fail=athena.fs.dir_exists_or_fail
alias athena.path=athena.argument.get_path_from_argument

# handling os
alias athena.usage=athena.os.usage
alias athena.exit=athena.os.exit
alias athena.exit_with_msg=athena.os.exit_with_msg

# handling color
alias athena.info=athena.color.print_info
alias athena.error=athena.color.print_error
alias athena.warn=athena.color.print_warn
alias athena.ok=athena.color.print_ok
alias athena.debug=athena.color.print_debug
alias athena.fatal=athena.color.print_fatal
alias athena.print=athena.color.print_color

# handling values
alias athena.is_integer=athena.argument.is_integer
