function athena.get_current_script_dir()
{
	local src="${BASH_SOURCE[0]}"
	local dir

	# While $src is a symlink, resolve it
	while [ -h "$src" ]; do
	  dir="$( cd -P "$( dirname "$src" )" && pwd )"
	  src="$( readlink "$src" )"

	  # relative symlink
	  [[ $src != /* ]] && src="$dir/$src"
	done
	dir="$( cd -P "$( dirname "$src" )" && pwd )"
	echo "$dir"
}

source "$(athena.get_current_script_dir)/bootstrap/variables.sh"
source "$(athena.get_current_script_dir)/bootstrap/host.functions.sh"
