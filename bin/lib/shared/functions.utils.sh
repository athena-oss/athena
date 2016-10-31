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

# This function removes the specified element from the array.
# USAGE: athena.utils.remove_from_array <array_name> <needle> [strict]
# RETURN: 0 (succeeded), 1 (failed)
function athena.utils.remove_from_array()
{
	if [ -z "$2" ]; then
		return 1
	fi

	local array_name=$1
	eval "local -i elems=\"\${#${array_name}[@]}\""

	if [ $elems -eq 0 ]; then
		return 1
	fi

	local -i remove_index

	# by index
	if athena.utils.is_integer "$2" ; then
		if [ ! $2 -ge 0 ]; then
			return 1
		fi
		remove_index=$2
	else
		# by name
		remove_index=$(athena.utils.find_index_in_array "$array_name" "$2" "$3")
		if [ $? -ne 0 ]; then
			return 1
		fi
	fi

	# remove
	eval "local -a tmp_array=( \"\${${array_name}[@]}\" )"
	tmp_array=( "${tmp_array[@]:0:$remove_index}" "${tmp_array[@]:$(expr $remove_index + 1)}" )
	athena.utils.set_array "$1" "${tmp_array[@]}"
}

# This function returns the index of the element specified.
# USAGE: athena.utils.find_index_in_array <array_name> <needle> [strict]
# RETURN: 0 (true), 1 (false)
function athena.utils.find_index_in_array()
{
	if ! athena.utils.in_array "$1" "$2" "${3:-1}"; then
		return 1
	fi

	eval "local -a tmp=( \"\${${1}[@]}\" )"
	for ((i=0; i<${#tmp[@]}; i++)); do
		if [[ "${tmp[$i]}" =~ ^$2.* ]]; then
			echo "$i"
			return 0
		fi
	done

	return 1
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
	eval "local -a array=( \"\${${1}[@]}\" )"
	local strict=${3:-1}
	for ((i=0; i<${#array[*]}; i++)); do
		if [[ "$strict" == "1" ]] && [[ "${array[$i]}" == $2 ]]; then
			return 0
		elif [[ "$strict" == "0" ]] && [[ "${array[$i]}" =~ ^$2.* ]]; then
			return 0
		fi
	done
	return 1
}

# This function checks if a value is an integer.
# USAGE:  athena.utils.is_integer <value>
# RETURN: 0 (true), 1 (false)
function athena.utils.is_integer()
{
	local re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
		return 1
	else
		return 0
	fi
}

# This function validates if the given version meets the expected version criteria.
# USAGE: athena.utils.validate_version <version_str> <expected_version|base_version end_version>
# RETURNS: 0 (true), 1 (false)
function athena.utils.validate_version()
{
	local -a version_components=()
	local -a version_compareto_components=()
	local base_version_str=$(echo $2 | awk -F' ' '{ print $1}')
	local end_version_str=$(echo $2 | awk -F' ' '{ print $2}')
	athena.utils.get_version_components "$1" "version_components"
	athena.utils.get_version_components "$base_version_str" "version_compareto_components"

	# comparator defaults to >= (greater or equal) when it is not specified
	local comparator=${version_compareto_components[0]:-">="}
	local major=${version_components[1]}
	local major_compareto=${version_compareto_components[1]}
	local minor=${version_components[2]}
	local minor_compareto=${version_compareto_components[2]}
	local patch=${version_components[3]}
	local patch_compareto=${version_compareto_components[3]}

	# simply compare the numbers
	local -i number="$major$minor$patch"
	local -i number_compareto="$major_compareto$minor_compareto$patch_compareto"

	if ! athena.utils.compare_number $number $number_compareto $comparator ; then
		return 1
	fi

	# validate end version
	if [[ -n "$end_version_str" ]]; then
		athena.utils.validate_version "$1" "$end_version_str"
		return $?
	fi

	return 0
}

# This function compares a number to another with the given operator (>, >=, <, <=)
# USAGE: athena.utils.compare_number <number_a> <number_b> <comparator>
# RETURNS: 0 (true), 1 (false)
function athena.utils.compare_number()
{
	local -i value=$1
	local -i compareto_value=$2
	local comparator=$3
	case "$comparator" in
		">" )
			if [[ $value -gt $compareto_value ]]; then
				return 0
			fi
			;;
		">=")
			if [[ $value -ge $compareto_value ]]; then
				return 0
			fi
			;;
		"<")
			if [[ $value -lt $compareto_value ]]; then
				return 0
			fi
			;;
		"<=")
			if [[ $value -le $compareto_value ]]; then
				return 0
			fi
			;;
	esac

	return 1
}

# This function extracts the values from a Semantic Versioning 2 format into an array.
# index 0 contains the operation, index 1 the MAJOR version, index 2 MINOR version and
# index 3 the PATCH version.
# USAGE: athena.utils.get_version_components <sem_ver_string> <array_name_to_store>
# RETURNS: 0 (true), 1 (false)
function athena.utils.get_version_components()
{
	if ! athena.utils.validate_version_format "$1" ; then
		return 1
	fi

	local major
	local minor
	local patch
	local version

	# handle end version
	local base_version=$(echo $1 | awk -F' ' '{ print $1 }')
	local operator=${base_version//[0-9A-Za-z.-]/}
	local version=${base_version//$operator/}
	major=$(echo "$version" | awk -F'.' '{ print $1 }')
	minor=$(echo "$version" | awk -F'.' '{ print $2 }')
	patch=$(echo "$version" | awk -F'.' '{ print $3 }' | awk -F'-' '{ print $1 }' | tr -d '[:alpha:]')

	athena.utils.add_to_array "$2" "$operator"
	athena.utils.add_to_array "$2" "$major"
	if [ -n "$minor" ]; then
		athena.utils.add_to_array "$2" "$minor"
	fi

	if [ -n "$patch" ]; then
		athena.utils.add_to_array "$2" "$patch"
	fi

	return 0
}


# This function validates if the given version follows Semantic Versioning 2.0.
# USAGE: athena.utils.validate_version_format <version>
# RETURN: 0 (true) 1 (false)
function athena.utils.validate_version_format()
{
	if [ -z "$1" ]; then
		return 1
	fi

	local regex="^(>|>=|<|<=)?[0-9]+(\\.[0-9]+\\.[0-9]+(-.*)?)?"
	if [[ ! "$1" =~ $regex ]]; then
		return 1
	fi
	return 0
}
