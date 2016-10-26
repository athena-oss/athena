# This functions adds elements to the given array.
# USAGE: athena.utils.add_to_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function athena.utils.add_to_array()
{
	local array_name=$1
	local val
	shift
	for ((i=1; i<=$#; i++)); do
		val="${!i}"
		eval "${array_name}+=( \"\${val[@]}\" )"
	done
	return 0
}

# This function prepends the given elements to the specified array.
# USAGE: athena.utils.prepend_to_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function athena.utils.prepend_to_array()
{
	local array_name=$1
	shift
	eval "local -a array_to_copy=( \"\${${array_name}[@]}\" )"
	athena.utils.set_array "$array_name" "$@"
	athena.utils.add_to_array "${array_name}" "${array_to_copy[@]}"
}

# This function assigns the given elements to the specified array.
# USAGE: athena.utils.set_array <array_name> <element...>
# RETURN: 0 (true), 1 (false)
function athena.utils.set_array()
{
	local array_name=$1
	shift
	eval "$array_name=()"
	athena.utils.add_to_array "${array_name}" "$@"
}

# This function returns the elements of the given array in case of subshell
# assignment or stores them in a new variable if specified in argument 2.
# USAGE: athena.utils.get_array <array_name> [other_array_name]
# RETURN: 0 (true), 1 (false)
function athena.utils.get_array()
{
	if [ -z "$2" ]; then
		if [ ! -z $BASH_SUBSHELL ] && [ $BASH_SUBSHELL -gt 0 ]; then
			eval "echo \"\${${1}[@]}\""
			return 0
		fi
		return 1
	fi

	eval "$2=( \"\${${1}[@]}\" )"
}

# This function pops elements from the given array, if argument 2 is an integer
# then it will pop as many times as specified.
# USAGE: athena.utils.array_pop <array_name> [number_of_times]
# RETURN: 0 (true), 1 (false)
function athena.utils.array_pop()
{
	local array_name=$1
	local -i elems=${2:-1}
	eval "local -a array_to_copy=( \"\${${array_name}[@]:$elems}\" )"
	athena.utils.set_array "$array_name" "${array_to_copy[@]}"
}

# This function checks if the element exists in the given array.
# USAGE: athena.utils.in_array <array_name> <element> [strict]
# RETURN: 0 (true), 1 (false)
function athena.utils.in_array()
{
	eval "local -a tmp=( \"\${${1}[@]}\" )"
	athena.os.in_array ${3:-1} $2 "${tmp[@]}"
}
