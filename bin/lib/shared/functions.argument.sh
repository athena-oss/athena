# This function checks if an argument is an integer.
# USAGE:  athena.argument.is_integer <argument>
# RETURN: 0 (true), 1 (false)
function athena.argument.is_integer()
{
	local re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
		return 1
	else
		return 0
	fi
}

# This function pops a number of arguments from the argument list $ATHENA_ARGS.
# USAGE:  athena.argument.pop_arguments <number>
# RETURN: --
function athena.argument.pop_arguments()
{
	local -i count=${1:-1}
	while ((--count >= 0)); do
		athena.argument.remove_argument 1
	done
}

# This function will copy the $ATHENA_ARGS array into a variable provided as argument, unless it is being used in a shubshell, then a string containing all the arguments will be output.
# USAGE:  athena.argument.get_arguments [array_name]
# RETURN: 0 (success) | 1 (failure)
function athena.argument.get_arguments()
{
	if [ -z "$1" ]; then
		if [ ! -z $BASH_SUBSHELL ] && [ $BASH_SUBSHELL -gt 0 ]; then
			echo "${ATHENA_ARGS[@]}"
			return 0
		fi
		return 1
	fi

	eval "$1=( \"\${ATHENA_ARGS[@]}\" )"
}

# This function removes an argument from the argument list $ATHENA_ARGS if it is in the list.
# USAGE:  athena.argument.remove_argument <argument|index>
# RETURN: 0 (successful), 1 (failed)
function athena.argument.remove_argument()
{
	if [ -z "$1" ]; then
		return 1
	fi

	if [ ${#ATHENA_ARGS[*]} -eq 0 ]; then
		return 1
	fi

	local -i remove_index

	if athena.argument.is_integer "$1"; then
		let remove_index=$1-1
	elif athena.argument.argument_exists "$1" && [ $(athena.argument._named_argument_index "$1") -ge 0 ]; then
		remove_index=$(athena.argument._named_argument_index "$1")
	else
		remove_index=$(athena.argument._argument_index "$1")
	fi

	if [ -z "$remove_index" -o "$remove_index" -lt 0 ]; then
		return 1
	fi

	local -a result
	local old_ifs=$IFS
	IFS=
	result=( "${ATHENA_ARGS[@]:0:$remove_index}" "${ATHENA_ARGS[@]:$(expr $remove_index + 1)}" )
	athena.argument.set_arguments "${result[@]}"
	IFS=$old_ifs
	return 0
}

# This function sets the argument list ($ATHENA_ARGS) to the given arguments.
# USAGE:  athena.argument.set_arguments <argument...>
# RETURN: --
function athena.argument.set_arguments()
{
	local -i arg

	ATHENA_ARGS=()
	for ((i=0; i<$#; i++)); do
		let arg=i+1
		ATHENA_ARGS[$i]=${!arg}
	done
}

# This function appends the given argumnets to the argument list ($ATHENA_ARGS).
# USAGE:  athena.argument.append_to_arguments <argument...>
# RETURN: --
function athena.argument.append_to_arguments()
{
	local -i index=${#ATHENA_ARGS[*]}

	for ((i=1; i<=$#; i++)); do
		ATHENA_ARGS[$index]=${!i}

		let index++
	done
}

# This function prepends the given argumnets to the argument list ($ATHENA_ARGS).
# USAGE:  athena.argument.prepend_to_arguments <argument...>
# RETURN: --
function athena.argument.prepend_to_arguments()
{
	local -a arguments

	athena.argument.get_arguments arguments
	athena.argument.set_arguments "$@"
	athena.argument.append_to_arguments "${arguments[@]}"
}

# This function returns the requested argument name or value if found in the argument
# list $ATHENA_ARGS. The function interpretes an given integer as argument index and a given
# string as argument name (e.g. for the list "a=3 b=5" "3" is return if "a" is
# requested and "a=3" is returned if "1" is requested).
# USAGE:  athena.argument.get_argument <argument position or name>
# RETURN: string
function athena.argument.get_argument()
{
	if [ ${#ATHENA_ARGS[*]} -eq 0 ]; then
		return 1
	fi

	local val
	local -i index

	if athena.argument.is_integer "$1"; then
		let index=$1-1
		val=${ATHENA_ARGS[$index]}
	elif athena.argument.argument_exists "$1"; then
		index=$(athena.argument._named_argument_index "$1")
		if [ $index -ge 0 ]; then
			val=$(echo "${ATHENA_ARGS[$index]}" | sed -n -e "s/^[^=]\{1,\}\=\(.*\)$/\1/p")
		fi
	else
		athena.os.exit_with_msg "something went wrong while parsing argument '$1' while having ATHENA_ARGS='${ATHENA_ARGS[*]}'"
	fi
	athena.os.return "$val"
}

# This function returns the value for the given argument and if it is not
# an integer it will exit with error.
# USAGE: athena.argument.get_integer_argument <argument position or name> [<error string>]
# RETURN: int
function athena.argument.get_integer_argument()
{
	local arg
	arg=$(athena.argument.get_argument "$1")
	if ! athena.argument.is_integer "$arg" ; then
		local msg="argument '$arg' is not an integer"
		if [ -n "$2" ]; then
			msg="$2"
		fi
		athena.os.exit_with_msg "$msg"
	fi
	athena.os.return $arg "argument"
}

# This function returns the argument name or value (see athena.argument.get_argument) and
# removes it from the $ATHENA_ARGS list.
# USAGE:  athena.argument.get_argument_and_remove <argument position or name> [<name of variable to save the value>]
# RETURN: string
function athena.argument.get_argument_and_remove()
{
	local arg
	arg=$(athena.argument.get_argument "$1")
	athena.argument.remove_argument "$1"
	athena.os.return "$arg" "$2"
}

# This function extract a argument string or value (see athena.argument.get_argument) from the
# $ATHENA_ARGS list and checks if it is a valid directory path. If it is valid the path is
# return, if not script execution is exited and an error message is thrown.
# USAGE:  athena.argument.get_path_from_argument <argument position or name>
# RETURN: string
function athena.argument.get_path_from_argument()
{
	local path
	local arg
	arg=$(athena.argument.get_argument "$1")
	path=$(athena.fs.absolutepath "$arg")
	if [ $? -ne 0 ]; then
		return 1
	fi
	athena.os.return "$path"
}

# This function returns a valid direcory path if the given argument name or value (see
# athena.argument.get_path_from_argument) could be converted and removes the argument from the
# $ATHENA_ARGS list.
# USAGE:  athena.argument.get_path_from_argument_and_remove <argument position or name>
# RETURN: string
function athena.argument.get_path_from_argument_and_remove()
{
	local tmp
	tmp=$(athena.argument.get_path_from_argument "$1")
	if [ $? -ne 0 ]; then
		return 1
	fi
	athena.argument.remove_argument "$1"
	athena.os.return "$tmp"
}

# This function checks if an argument exists in the argument list $ATHENA_ARGS.
# USAGE:  athena.argument.argument_exists <argument name>
# RETURN: 0 (true), 1 (false)
function athena.argument.argument_exists()
{
	if [[ -z "$1" ]]; then
		return 1
	fi

	local -i named_index=$(athena.argument._named_argument_index "$1")
	local -i index=$(athena.argument._argument_index "$1")

	if [ $index -ge 0 -o $named_index -ge 0 ]; then
		return 0
	fi

	return 1
}

# This function checks if an argument exists (see athena.argument.argument_exists) in the
# argument list $ATHENA_ARGS and removes it if it exists.
# USAGE:  athena.argument.argument_exists_and_remove <argument name> [<name of variable to save the value>]
# RETURN: 0 (true), 1 (false)
function athena.argument.argument_exists_and_remove()
{
	if athena.argument.argument_exists "$1"; then
		if [ -n "$2" ]; then
			athena.argument.get_argument_and_remove "$1" "val"
			athena.os.return "$val" "$2"
		else
			athena.argument.remove_argument "$1"
		fi
		return 0
	fi
	return 1
}

# This function checks if an argument exists (see athena.argument.argument_exists) in the
# argument list $ATHENA_ARGS. If no argument was given or the argument was not found script
# execution is exited and an error message is thrown.
# USAGE:  athena.argument.argument_exists_or_fail <argument name>
# RETURN: --
function athena.argument.argument_exists_or_fail()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "argument is empty!"
		return 1
	fi

	if ! athena.argument.argument_exists "$1" ;then
		athena.os.exit_with_msg "argument does not exist '$1'!"
		return 1
	fi
	return 0
}

# This function returns the number of arguments found in the argument list $ATHENA_ARGS.
# USAGE:  athena.argument.nr_of_arguments
# RETURN: int
function athena.argument.nr_of_arguments()
{
	echo "${#ATHENA_ARGS[*]}"
}

# This function returns the error code 0 if the number of arguments in $ATHENA_ARGS is less
# than the given number. If not the error code 1 is returned.
# USAGE:  athena.argument.nr_args_lt <number>
# RETURN: 0 (true), 1 (false)
function athena.argument.nr_args_lt()
{
	local nr_args
	nr_args=$(athena.argument.nr_of_arguments)
	if [ "$nr_args" -lt "$1" ]; then
		return 0
	fi
	return 1
}

# This function checks if the given arguments string is not empty.
# USAGE:  athena.argument.argument_is_not_empty <arguments string>
# RETURN: 0 (true), 1 (false)
function athena.argument.argument_is_not_empty()
{
	if [ -z "$1" ]; then
		return 1
	fi
	return 0
}

# This function checks if the given arguments string is not empty. If it is empty
# execution is stopped and an error message is thrown. If not empty the error code 0
# is returned.
# USAGE:  athena.argument.argument_is_not_empty_or_fail <argument string> [<name>]
# RETURN: 0 (true)
function athena.argument.argument_is_not_empty_or_fail()
{
	if ! athena.argument.argument_is_not_empty "$1"; then
		local arg=" "
		if [ -n "$2" ]; then
			arg=" '$2' "
		fi
		athena.os.exit_with_msg "argument${arg}does not exist!"
		return 1
	fi
	return 0
}

# This function is a wraper for the athena.argument.get_argument function.
# USAGE:  athena.argument.arg <argument position or name>
# RETURN: string
function athena.argument.arg()
{
	athena.argument.get_argument "$1"
}

# This function is a wrapper for the athena.argument.get_arguments function. It returns the
# argument list ($ATHENA_ARGS).
# USAGE:  athena.argument.args
# RETURN: string
function athena.argument.args()
{
	athena.argument.get_arguments
}

# This function if a string contains a substring. With --literal, regex is not parsed, and there's a literal comparison.
# USAGE:  athena.argument.string_contains <string> <sub-string> [--literal]
# RETURN: 0 (true), 1 (false)
function athena.argument.string_contains()
{
	if athena.argument.argument_is_not_empty "$3" && [[ "$3" == "--literal" ]]; then
		athena.argument._string_contains_literal "$1" "$2"
	else
		athena.argument._string_contains_regex "$1" "$2"
	fi

	return $?
}

# This function if a string contains a substring (without regex).
# USAGE:  athena.argument.string_contains <string> <sub-string>
# RETURN: 0 (true), 1 (false)
function athena.argument._string_contains_literal()
{
	if ! (echo "${1}" | grep -F -- "${2}" 1>/dev/null); then
		return 1
	fi
	return 0
}
# This function if a string contains a substring (with regex).
# USAGE:  athena.argument.string_contains <string> <sub-string>
# RETURN: 0 (true), 1 (false)
function athena.argument._string_contains_regex()
{
	if [[ ! "$1" =~ $2 ]]; then
		return 1
	fi
	return 0

}

# This function gives the index of a named parameter (counting
# from 0).
# If not found "-1" will be returned.
# USAGE:  athena.argument._named_argument_index <argument name>
# RETURN: int
function athena.argument._named_argument_index()
{
	for ((i=0; i<${#ATHENA_ARGS[*]}; i++)); do
		if [[ "${ATHENA_ARGS[$i]}" =~ ^$1=.* ]]; then
			echo "$i"
			return 0
		fi
	done

	echo "-1"
	return 1
}

# This function gives the index of any kind of parameter
# (counting from 0).
# If not found "-1" will be returned.
# USAGE:  athena.argument._argument_index <argument name>
# RETURN: int
function athena.argument._argument_index()
{
	for ((i=0; i<${#ATHENA_ARGS[*]}; i++)); do
		if [ "${ATHENA_ARGS[$i]}" == "$1" ]; then
			echo "$i"
			return 0
		fi
	done

	echo "-1"
	return 1
}
