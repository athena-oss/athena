# This function prints the given string on STDOUT formatted as info message.
# USAGE:  athena.color.print_info <string> [<redirect_number>]
# RETURN: --
function athena.color.print_info()
{
	athena.color.print_color "blue" "[INFO]" " $1" $2
}

# This function prints the given string on STDOUT formatted as error message.
# USAGE:  athena.color.print_error <string> [<redirect_number>]
# RETURN: --
function athena.color.print_error()
{
	athena.color.print_color "red" "[ERROR]" " $1" $2
}

# This function prints the given string on STDOUT formatted as ok message.
# USAGE:  athena.color.print_ok <string> [<redirect_number>]
# RETURN: --
function athena.color.print_ok()
{
	athena.color.print_color "green" "[OK]" " $1" $2
}

# This function prints the given string on STDOUT formatted as warn message.
# USAGE:  athena.color.print_warn <string> [<redirect_number>]
# RETURN: --
function athena.color.print_warn()
{
	athena.color.print_color "yellow" "[WARN]" " $1" $2
}

# This function prints the given string on STDOUT formatted as debug message if debug
# mode is set.
# USAGE:  athena.color.print_debug <string> [<redirect_number>]
# RETURN: --
function athena.color.print_debug()
{
	if athena.os.is_debug_active ; then
		athena.color.print_color "cyan" "[DEBUG]" " $1" $2
	fi
}

# This function prints the given string on STDOUT formatted as fatal message and exit with 1 or the given code.
# USAGE: athena.color.print_fatal <string> [<exit_code>] [<redirect_number>]
# RETURN: --
function athena.color.print_fatal()
{
	exit_code=${2:-1}
	athena.color.print_color "red" "[FATAL]" " $1" $3
	athena.os.exit $exit_code
}

# This function prints the given string in a given color on STDOUT. Available colors
# are "green", "red", "blue", "yellow", "cyan", and "normal".
# USAGE:  athena.color.print_color <color> <string> [<non_colored_string>][<redirect_number>]
# RETURN: --
function athena.color.print_color()
{
	local green
	local red
	local blue
	local yellow
	local cyan
	local normal
	local other
	local redirect
	green=$(printf "\033[32m")
	red=$(printf "\033[31m")
	blue=$(printf "\033[94m")
	yellow=$(printf "\033[43m")
	cyan=$(printf "\033[36m")
	normal=$(printf "\033[m")
	other=${3:-""}
	redirect=${4:-2}
	(
		case $1 in
			"red")
				printf "%s%b\n" "${red}$2${normal}" "$other"
				;;
			"green")
				printf "%s%b\n" "${green}$2${normal}" "$other"
				;;
			"blue")
				printf "%s%b\n" "${blue}$2${normal}" "$other"
				;;
			"yellow")
				printf "%s%b\n" "${yellow}$2${normal}" "$other"
				;;
			"cyan")
				printf "%s%b\n" "${cyan}$2${normal}" "$other"
				;;
			"normal")
				printf "%s%b\n" "${normal}$2${normal}" "$other"
				;;
			*)
				printf "%b" "$2"
				;;
		esac
	) 1>&$redirect
}
