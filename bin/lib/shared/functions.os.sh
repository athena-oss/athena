# This function will call the command/function passed as argument with all the
# arguments existing in $ATHENA_ARGS.
# USAGE:  athena.os.call_with_args <command>
# RETURN: <command> result | 1 (false) if no <command> was specified or it doesn' exist
function athena.os.call_with_args()
{
	if [ -z "$1" ]; then
		return 1
	fi

	if ! athena.os.function_exists "$1" && ! which "$1" >/dev/null 2>&1; then
		return 1
	fi

	"$1" "${ATHENA_ARGS[@]}"
}

# This function prints the usage and exits with 1 and handles the name of the command
# automatically and the athena executable.
# USAGE: athena.os.usage [<min_args>] [<options>] [<multi-line options>]
# RETURN: --
function athena.os.usage()
{
	local arg1="$1"
	if athena.argument.is_integer "$arg1"; then
		shift
		if ! athena.argument.nr_args_lt "$arg1" ; then
			return 0
		fi
	fi

	local athena_cmd
	local cmd
	local args=""
	local opts="$1"
	local multi_opts="$2"
	local plugin=$ATHENA_PLUGIN
	athena_cmd=$(athena.os.get_executable)
	cmd=$(athena.os.get_command)
	if [[ -n "$opts" ]]; then
		if [[ -n "$multi_opts" ]]; then
			# multi-line usage
			args=$(echo "$multi_opts" | while read line
			do
				echo "	    $line"
			done)
			args=$(printf "\n%s\n" "$args" | tr -d '\t' | column -t -s";")
			printf "usage: %s %s %s %s\n\n%s\n" "$athena_cmd" "$plugin" "$cmd" "$opts" "$args"
		else
			# single line usage
			printf "usage: %s %s %s %s \n" "$athena_cmd" "$plugin" "$cmd" "$opts"
		fi

		cat <<EOF

You can also use the following athena flags :
    --athena-dbg                                     Enables the debug mode.
    --athena-env=<name|file_with_environment_config> Specifies the environment to be used.
    --athena-dns=<nameserver_ip>                     Specifies which nameserver will be used in the container.
    --athena-no-logo                                 Suppresses the logo.

EOF
	fi
	athena.os.exit 1
}

# This function returns the executable for athena.
# USAGE: athena.os.get_executable
# RETURN: string
function athena.os.get_executable()
{
	if which athena 1>/dev/null 2>/dev/null; then
		echo "athena"
	else
		echo "$0"
	fi
	return 0
}

# This function enables the error only output mode.
# To be used in conjunction with athena.os.exec.
# USAGE: athena.os.enable_error_mode
# RETURN: --
function athena.os.enable_error_mode()
{
	ATHENA_OUTPUT_MODE=1
}

# This function enables the no output mode.
# To be used in conjunction with athena.os.exec.
# USAGE: athena.os.enable_quiet_mode
# RETURN: --
function athena.os.enable_quiet_mode()
{
	ATHENA_OUTPUT_MODE=2
}

# This function enables the all output mode.
# To be used in conjunction with athena.os.exec.
# USAGE: athena.os.enable_verbose_mode
# RETURN: --
function athena.os.enable_verbose_mode()
{
	ATHENA_OUTPUT_MODE=0
}

# This function wraps command execution to allow for switching output modes.
# The output mode is defined by using the athena.os.set_output_* functions.
# USAGE: athena.os.exec <function> <args>
# RETURN: int
function athena.os.exec()
{
	local func=$1
	shift
	case $ATHENA_OUTPUT_MODE in
		1)
			$func "$@" 1>/dev/null
			;;
		2)
			$func "$@" 1>/dev/null 2>/dev/null
			;;
		*)
			$func "$@"
			;;
	esac
	return $?
}

# This functions checks if $ATHENA_COMMAND variable is set.
# USAGE:  athena.os.is_command_set
# RETURN: 0 (true) 1 (false)
function athena.os.is_command_set()
{
	if [ -z "$ATHENA_COMMAND" ]; then
		return 1
	fi

	return 0
}

# This function sets the $ATHENA_COMMAND variable to the given command string if it
# is not empty. If it is empty execution is stopped and an error message is thrown.
# USAGE:  athena.os.set_command <command>
# RETURN: --
function athena.os.set_command()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "command name is empty!"
		return 1
	fi
	ATHENA_COMMAND=$1
	return 0
}

# This function returns the content of the $ATHENA_COMMAND variable. If it is not set
# execution is stopped and an error message is thrown.
# USAGE:  athena.os.get_command <command>
# RETURN: string
function athena.os.get_command()
{
	if ! athena.os.is_command_set; then
		athena.os.exit_with_msg "command name is not specified!"
		return 1
	fi
	echo "$ATHENA_COMMAND"
	return 0
}


# This functions checks if the function with the given name exists.
# USAGE: athena.os.function_exists <name>
# RETURN: 0 (true) 1 (false)
function athena.os.function_exists()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "function name must be specified."
		return 1
	fi

	if ! type -t "$1" 1>/dev/null 2>/dev/null ; then
		return 1
	fi

	return 0
}

# This functions checks if the function with the given name exists,
# if not it will abort the current execution.
# USAGE: athena.os.function_exists_or_fail <name>
# RETURN: 0 (true) 1 (false)
function athena.os.function_exists_or_fail()
{
	if ! athena.os.function_exists "$1" ; then
		athena.os.exit_with_msg "function does not exist '$1'."
		return 1
	fi

	return 0
}

# This function assigns a value to a variable and overcomes the problem of
# assignment in subshells losing the current environment.
# It is meant to be used in the getters and expects that the function
# using it follows the convention athena.get_<variable>.
# NOTE: when used in subshell it will echo the value to be assigned to a variable.
# USAGE: athena.os.return <value> [<name_of_variable_to_assign_to>]
# RETURN: string
function athena.os.return()
{
	# name of the variable we want to assign the value
	if [ -n "$2" ]; then
		read -r $2 <<< "$1"
	else
		local func
		func=${FUNCNAME[1]}
		if ! athena.argument.string_contains "${FUNCNAME[1]}" "athena.([^.]+.)?get_" ; then
			athena.os.exit_with_msg "not a valid getter '$func'."
			return 1
		fi
		local varname
		varname=$(echo "$func" | sed -n -e "s#.*athena\.\(.*\.\)*get_\([^_]*\).*#\2#p")
		if [ -z "$varname" ]; then
			athena.os.exit_with_msg "name of variable not found in getter."
			return 1
		fi
		read -r $varname <<< "$1"
	fi

	# used in subshell it will echo the value to be assigned to a variable
	if [ ! -z $BASH_SUBSHELL ] && [ $BASH_SUBSHELL -gt 0 ]; then
		echo "$1"
	fi
	return 0
}

# This function checks if a given Bash source file exists and includes it if it wasn't
# loaded before. If it was loaded nothing is done (avoid multiple sourcing).
# USAGE:  athena.os.include_once <Bash source file>
# RETURN: --
function athena.os.include_once()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "no file supplied!"
		return 1
	fi

	# var id is name of file without special chars appended with pid
	local var_id
	var_id=${1//[\/|\.-]/}$$
	if [ -z "${!var_id}" ]; then
		if [ ! -f "$1" ]; then
			athena.os.exit_with_msg "file does not exist '$1'!"
			return 1
		fi
		eval export "$var_id=loaded"
		source "$1"
	fi
	return 0
}

# This function exits Athena if called (if a forced exit is required).
# Default exit_code is 1.
# USAGE:  athena.os.exit [<exit_code>]
# RETURN: --
function athena.os.exit()
{
	local exit_code=${1:-1}
	if [ ! -z $BASH_SUBSHELL ] && [ $BASH_SUBSHELL -gt 0 ]; then
		kill -s ABRT $$
	fi
	exit $exit_code
}

# This function exits Athena with an error message (see athena.os.exit).
# USAGE:  athena.os.exit_with_msg <error message> [<exit_code>]
# RETURN: --
function athena.os.exit_with_msg()
{
	local source
	local level
	local idx
	local exit_code=${2:-1}
	level=$(( ${#FUNCNAME[@]} - 3 ))
	if [ $level -gt 1 ]; then
		source="[${BASH_SOURCE[$level]//$ATHENA_BASE_DIR/}:${BASH_LINENO[(($level - 1))]}]"
	else
		source="[${BASH_SOURCE[1]//$ATHENA_BASE_DIR/}:${BASH_LINENO}]"
	fi
	athena.color.print_error "$1 $source" 1>&2
	level=${#FUNCNAME[@]}
	idx=1
	if athena.os.is_debug_active && [ $level -gt 0 ]; then
		printf "\nStacktrace:\n"
		while [ $level -gt 1  ];
		do
			source="${BASH_SOURCE[$idx]//$ATHENA_BASE_DIR/}:${BASH_LINENO[(($idx - 1))]}"
			printf "\t%s\n" "$source"
			((level--))
			((idx++))
		done
	fi
	athena.os.exit $exit_code
	return $exit_code
}

# This function handles the signals sent to and by athena.
# USAGE: athena.os.handle_exit <signal>
# RETURN: --
function athena.os.handle_exit()
{
	local exit_code=$?
	case $1 in
		EXIT)
			if athena.docker.container_has_started && ! athena.docker.has_option "-d" ; then
				athena.docker.cleanup
			fi
			athena._print_time
			exit $exit_code
			;;
		ABRT)
			exit 99
			;;
		ERR)
			# ignore
			;;
		INT)
			# make sure that we stop the running container in case we signal interruption
			athena.color.print_debug "SIGNAL '$1' caught!"
			if athena.docker.container_has_started ; then
				athena.docker.stop_container "$(athena.plugin.get_container_name)"
			fi
			exit $exit_code
			;;
		*)
			athena.color.print_debug "SIGNAL '$1' caught!"
			;;
	esac
}

# This function register the exit handler that takes the decision of
# what to do when interpreting the exit codes and signals.
# USAGE: athena.os.register_exit_handler <function_name> <list_of_signals_to_trap>
# RETURN: --
function athena.os.register_exit_handler()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "function name"
	local func=$1
	shift
	for sig in "$@"
	do
		athena.os._trap "$func $sig" "$sig"
	done
}


# This functions registers the exit handler with the default signals to catch.
# USAGE: athena.os.set_exit_handler
# RETURN: --
function athena.os.set_exit_handler()
{
	athena.os.register_exit_handler "athena.os.handle_exit" $(athena.os._get_trap_signals)
}

# This functions overrides the exit handler with the default signals to catch.
# USAGE: athena.os.override_exit_handler <function_name>
# RETURN: --
function athena.os.override_exit_handler()
{
	athena.color.print_debug "Exit handler is now overriden."
	local signals
	signals=$(athena.os._get_trap_signals)
	# unset the previous traps
	athena.os._trap - $signals
	athena.os.register_exit_handler "$1" $signals
}


# This function checks if Athena runs on a Mac OS X.
# USAGE:  athena.os.is_mac
# RETURN: 0 (true), 1 (false)
function athena.os.is_mac()
{
	if [ "$ATHENA_IS_MAC" -eq 0 ]; then
		return 1
	fi
	return 0
}

# This function checks if Athena runs on a Linux machine.
# USAGE:  athena.os.is_mac
# RETURN: 0 (true), 1 (false)
function athena.os.is_linux()
{
	if [ "$ATHENA_IS_LINUX" -eq 0 ]; then
		return 1
	fi
	return 0
}

# This functions returns the ip of the host of athena.
# USAGE: athena.os.get_host_ip
# RETURN: string
function athena.os.get_host_ip()
{
	if [ -n "$ATHENA_DOCKER_HOST_IP" ]; then
		echo "$ATHENA_DOCKER_HOST_IP"
		return 0
	fi

	if [ "$ATHENA_IS_MAC" -ne 0 ]; then
		athena.os._get_host_ip_for_mac
	else
		athena.os._get_host_ip_for_linux
	fi
	return $?
}

# This function checks if the 'git' command is available (i.e. if git is
# installed). If not execution is stopped and an error message is thrown.
# USAGE:  athena.os.is_git_installed
# RETURN: --
function athena.os.is_git_installed()
{
	if ! athena.os._which_git ; then
		athena.os.exit_with_msg "git is not installed"
		return 1
	fi
	return 0
}

# This functions returns the base directory of athena.
# USAGE: athena.os.get_base_dir
# RETURNS: string
function athena.os.get_base_dir()
{
	echo "$ATHENA_BASE_DIR"
}

# This functions returns the base lib directory of athena.
# USAGE: athena.os.get_base_lib_dir
# RETURNS: string
function athena.os.get_base_lib_dir()
{
	echo "$ATHENA_BASE_LIB_DIR"
}

# This function returns the value of the current instance as set in the $ATHENA_INSTANCE
# variable.
# USAGE:  athena.os.get_instance
# RETURN: string
function athena.os.get_instance()
{
	echo "$ATHENA_INSTANCE"
}

# This functions sets the instance value.
# USAGE: athena.os.set_instance <value>
# RETURN: --
function athena.os.set_instance()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "instance value"
	ATHENA_INSTANCE=$1
}

# This functions returns the prefix that is used to create names for
# USAGE: athena.os.get_prefix
# RETURN: string
function athena.os.get_prefix()
{
	echo "$ATHENA_PREFIX"
}

# This function splits up a string on the specified field
# separator and will write the array into the given variable.
# USAGE: athena.os.split_string <string_to_split> <separator_character> <variable_name>
# RETURN: --
function athena.os.split_string()
{
	local string_to_split=$1
	local sc=$2
	local variable_name=$3

	if [ -z "$string_to_split" ]; then
		athena.exit_with_msg "missing variable 'string_to_split'"
	fi
	if [ -z "$sc" ]; then
		athena.exit_with_msg "missing variable 'separator_character'"
	fi
	if [ -z "$variable_name" ]; then
		athena.exit_with_msg "missing variable 'variable_name'"
	fi

	OLD_IFS=$IFS
	IFS=$sc read -a $variable_name <<< "$string_to_split"
	IFS=$OLD_IFS
}

# This function prints the duration time if the $ATHENA_NO_LOGO variable is set to 0 and
# debug is enabled.
# USAGE:  athena._print_time
# RETURN: --
function athena._print_time() {
	if [[ "$ATHENA_NO_LOGO" -eq 0 ]] && athena.os.is_debug_active; then
		local duration=$SECONDS
		echo
		athena.color.print_debug "Time: $((duration / 60)) minutes and $((duration % 60)) seconds elapsed."
	fi
}

# This function returns the error code 0 if the debug flag ($ATHENA_IS_DEBUG) is set. If not
# it returns the error code 1.
# USAGE:  athena.os.is_debug_active
# RETURN: 0 (true), 1 (false)
function athena.os.is_debug_active()
{
	if [[ $ATHENA_IS_DEBUG -eq 0 ]]; then
		return 1
	fi
	return 0
}

# This function sets the debug flag ($ATHENA_IS_DEBUG) to the given value. If no value is
# provided $ATHENA_IS_DEBUG is set to 0 (disabled).
# USAGE:  athena.os.set_debug <debug value>
# RETURN: --
function athena.os.set_debug()
{
	ATHENA_IS_DEBUG=${1:-0}

	# propagate to container
	athena.docker.add_env "ATHENA_IS_DEBUG" "$ATHENA_IS_DEBUG"
}

# This function returns the 0 if the $ATHENA_SUDO variable is set. If not
# it returns the error code 1.
# USAGE:  athena.os.is_sudo
# RETURN: 0 (true), 1 (false
function athena.os.is_sudo()
{
    if [ -z "$ATHENA_SUDO" ]; then
      return 1
    fi
    return 0
}

# This function prints the Athena logo including infos about base plugin and current
# plugin versions if $ATHENA_NO_LOGO is set to 0. If the $ATHENA_NO_LOGO flag is set to a value
# unequal to 0 no logo will be printed.
# USAGE:  athena.os._print_logo
# RETURN: --
function athena.os._print_logo()
{
	if [ "$ATHENA_NO_LOGO" -ne 0 ]; then
		return 0
	fi

	if [ -f "$ATHENA_PLG_DIR/.logo" ]; then
		cat "$ATHENA_PLG_DIR/.logo"
		return 0
	fi

	local version=""
	if [[ "$ATHENA_PLUGIN" != "base" ]]; then
		local ver="[$ATHENA_PLUGIN v$ATHENA_PLG_IMAGE_VERSION]"
		version=$(printf "%s\n  ----------------------------------\n\n\n" "$ver")
	fi
	cat <<EOF
       ___   __  __
      /   | / /_/ /_  ___  ____  ____ _
     / /| |/ __/ __ \/ _ \/ __ \/ __  /
    / ___ / /_/ / / /  __/ / / / /_/ /
   /_/  |_\__/_/ /_/\___/_/ /_/\__,_/
                              v$ATHENA_BASE_IMAGE_VERSION
  ==================================
  $version

EOF
}

# This function preprocesses all flags that are intended for Athena to setup the
# runtime environment found in $ATHENA_ARGS. All flags must be prefixed with --athena and
# can have values or not.
# USAGE:  athena.os._process_flags
# RETURN: --
function athena.os._process_flags()
{
	if athena.argument.argument_exists "--athena-env" ; then
		athena.argument.get_argument_and_remove "--athena-env"
		athena.plugin.set_environment "$argument"
	fi

	if athena.argument.argument_exists "--athena-dns" ; then
		athena.argument.get_argument_and_remove "--athena-dns"
		athena.docker.add_option "--dns=$argument"
	fi

	if athena.argument.argument_exists_and_remove "--athena-dbg" ; then
		athena.os.set_debug 1
	fi

	if athena.argument.argument_exists_and_remove "--athena-no-logo" ; then
		athena.os._set_no_logo 1
	fi
}

# This functions sets the flag to display or not the logo.
# USAGE: athena.os._set_no_logo [1|0]
# RETURN: --
function athena.os._set_no_logo()
{
	ATHENA_NO_LOGO=${1:-1}
}

# This function prepares the running container with the configuration that was set
# previously by flags or direct calls in the pre-command script.
# USAGE:  athena.os._bootstrap
# RETURN: --
function athena.os._bootstrap()
{
	athena.plugin.handle_environment
	athena.plugin.handle_container
}
# internal functions
function athena.os._get_host_ip_for_linux()
{
	local docker_host_ip
	if which 'ifconfig' 1>/dev/null 2>/dev/null; then
		for iface in docker0 eth0; do
			if /sbin/ifconfig $iface 1>/dev/null 2>/dev/null; then
				docker_host_ip=$(/sbin/ifconfig $iface | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
				break
			fi
		done
	elif which 'ip' 1>/dev/null 2>/dev/null; then
		docker_host_ip=$(/sbin/ip route|awk '/default/ { print $3 }')
	else
		athena.os.exit_with_msg "cannot determine DOCKER HOST IP"
	fi
	echo "$docker_host_ip"
}

function athena.os._get_host_ip_for_mac()
{
	if which 'ipconfig' 1>/dev/null 2>/dev/null; then
		# we are using docker for mac
		if [ -z "$DOCKER_MACHINE_NAME" ]; then
				/sbin/ifconfig en0 | grep 'inet ' | cut -f2 | awk '{ print $2 }'
			return 0
		fi
		docker-machine inspect --format="{{.Driver.HostOnlyCIDR}}" "$DOCKER_MACHINE_NAME" | cut -d"/" -f1
		if [ $? -ne 0 ]; then
			athena.os.exit_with_msg "cannot determine DOCKER HOST IP"
		fi
		return 0
	fi
	athena.os.exit_with_msg "cannot determine DOCKER HOST IP"
}

function athena.os._handle_os()
{
	if [ "$(uname -s)" = 'Linux' ]; then
		ATHENA_IS_LINUX=1
		ATHENA_IS_MAC=0
		if [ "${ATHENA_SUDO_DISABLED}" != "true" ] ; then
			ATHENA_SUDO="sudo"
		fi
	else
		ATHENA_IS_LINUX=0
		ATHENA_IS_MAC=1
	fi
}

function athena.os._which_git()
{
	which git 1>/dev/null 2>/dev/null
}

# This function returns the signals to trap.
# USAGE: athena.os._get_trap_signals
# RETURN: --
function athena.os._get_trap_signals()
{
	echo "EXIT QUIT ABRT INT TERM ERR KILL STOP HUP"
}

# This function executes the native bash trap command.
# USAGE: athena.os._trap <arguments>
# RETURN: --
function athena.os._trap()
{
	trap "$@"
}

# This function adds the athena executable to the path in order to be used globally.
# USAGE: athena.os._add_athena_path_to_user_profile <shell>
# RETURN: int
function athena.os._add_athena_path_to_user_profile()
{
	if which athena 1>/dev/null 2>/dev/null; then
		return 0
	fi

	local profile_file
	local append_str="export PATH=\"\$PATH:$ATHENA_BASE_DIR\""
	case $1 in
		*zsh*)
			profile_file="$HOME/.zshrc"
			;;
		*bash*)
			profile_file="$HOME/.bashrc"
			;;
		*)
			athena.color.print_debug "could not identify shell '$SHELL'."
			;;
	esac

	if [ -f "$profile_file" ] && ! $(grep "PATH" "$profile_file" | grep "$ATHENA_BASE_DIR" "$profile_file") ; then
		echo $append_str >> $profile_file
		if [ $? -eq 0 ]; then
			athena.color.print_info "To use athena globally run source '$profile_file'"
		else
			athena.color.print_error "Could not update current shell profile!"
		fi
	elif ! which athena 1>/dev/null 2>/dev/null; then
		athena.color.print_info "To use athena globally run source '$profile_file'"
	fi
	return 0
}
