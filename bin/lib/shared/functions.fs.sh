# This function checks if the given directory contains files with certain pattern (e.g.: *.sh).
# Globbing has 'dotglob' and 'extglob' (see BASH(1)) enabled.
# USAGE: athena.fs.dir_contains_files <directory> <pattern>
# RETURN: 0 (true), 1 (false)
function athena.fs.dir_contains_files()
{
	athena.fs.dir_exists_or_fail "$1"
	athena.argument.argument_is_not_empty_or_fail "$2"
	local files
	files=$(shopt -s nullglob dotglob extglob; echo $1/$2)
	if [ ${#files} -gt 0 ]; then
		return 0
	fi
	return 1
}

# This function returns a full path to a file or directory from the arguments
# in case it is an integer passed (positional argument) or from a given string.
# When a string is provided, it checks on the arguments for that string and then
# tries to get from the function athena.fs.absolutepath.
# USAGE: athena.fs.get_path_from_string_or_argument <arg position|arg name|relative path>
# RETURN: string
function athena.fs.get_path_from_string_or_argument()
{
	athena.argument.argument_is_not_empty_or_fail "$1"

	local arg=$1

	athena.argument.get_path_from_argument "$arg"
	if [ $? -ne 0 ]; then
		athena.os.exit_with_msg "argument '$arg' does not exist"
		return 1
	fi
	return 0
}

# This function checks if the given argument is a valid directory or file and returns
# the absolute directory path of the given file or directory (a relative path is
# converted in an absolute directory path). If the path is not valid execution is
# stopped and an error message is thrown.
# USAGE:  athena.fs.get_full_path <file or directory name>
# RETURN: string
function athena.fs.get_full_path()
{
	if test ! -e "$1" ; then
		athena.os.exit_with_msg "path is empty!"
		return 1
	fi

	if [ -d "$1" ]; then
		cd "$1" && pwd
	else
		athena.fs.file_exists_or_fail "$1"
		cd "$(dirname "$1")" && pwd
	fi
	return 0
}

# This function returns the basename of a file. If the file does not exist
# it will generate an error. It can be a full path or relative to the file.
# USAGE: athena.fs.basename <filename>
# RETURN: string
function athena.fs.basename()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "file"

	local file
	file=$(athena.fs.absolutepath "$1")

	basename "$file"
}

# This function checks if the given argument is a valid absolute path to a directory
# or file. If not, execution is stopped and an error message is thrown. Otherwise the
# absolute path is returned.
# USAGE:  athena.fs.absolutepath <file or directory name>
# RETURN: string
function athena.fs.absolutepath()
{
	if [[ -z "$1" ]]; then
		return 1
	fi

	local dir
	dir=$(dirname "$1")
	if [ ! -d "$dir" ]; then
		athena.os.exit_with_msg "'$dir' does not exist!"
		return 1
	fi

	local path
	path=$(cd "$dir" && pwd)/$(basename "$1")
	if test ! -f "$path" && test ! -d "$path"; then
		athena.os.exit_with_msg "'$path' does not exist!"
		return 1
	fi
	athena.os.return "$path" "path"
	return 0
}

# This function checks if the given filename is valid. If not execution is stopped
# and an error message is thrown. The displayed error message can be passed as second
# argument.
# USAGE:  athena.fs.file_exists_or_fail <filename> <message>
# RETURN: --
function athena.fs.file_exists_or_fail()
{
	if [ ! -f "$1" ]; then
		if [ -z "$2" ]; then
			athena.os.exit_with_msg "file '$1' does not exist!"
		else
			athena.os.exit_with_msg "$2"
		fi
		return 1
	fi
	return 0
}

# This function checks if the given directory name is valid. If not the directory is
# been created. If the creation fails execution is stopped and an error message is
# thrown. 0 is returned if the directory exists or was created.
# USAGE:  athena.fs.file_exists_or_fail <directory name>
# RETURN: 0 (true), 1 (false)
function athena.fs.dir_exists_or_create()
{
	if [ ! -d "$1" ]; then
		if ! mkdir -p "$1" ; then
			athena.os.exit_with_msg "directory '$1' could not be created!"
			return 1
		fi
	fi
	return 0
}

# This function checks if the given directory name is valid. If not execution is
# stopped and an error message is thrown. The displayed error message can be passed as
# second argument.
# USAGE:  athena.fs.dir_exists_or_fail <directory name> <message>
# RETURN: --
function athena.fs.dir_exists_or_fail()
{
	if [ -d "$1" ]; then
		return 0
	fi

	if [ -n "$2" ]; then
		athena.os.exit_with_msg "$2"
		return 1
	fi

	athena.os.exit_with_msg "'$1' is not a directory!"
	return 1
}

# This function checks if the given filename is valid. If not execution is stopped and
# an error message is thrown. If the given name is a valid filename the file content
# returned.
# USAGE:  athena.fs.get_file_contents <filename>
# RETURN: string
function athena.fs.get_file_contents()
{
	athena.fs.file_exists_or_fail "$1"
	cat "$1"
}

# This function checks if the filename contains the given string.
# USAGE: athena.fs.file_contains_string_<filename> <string>
# RETURN: 0 (true), 1 (true)
function athena.fs.file_contains_string()
{
	local content
	content=$(athena.fs.get_file_contents "$1")
	if athena.argument.string_contains "$content" "$2"; then
		return 0
	fi
	return 1
}

# Return filename or directory portion of pathname
# USAGE: athena.fs._basename <path>
# RETURN: --
function athena.fs._basename()
{
	basename $1
}
