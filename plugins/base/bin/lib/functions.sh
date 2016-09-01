athena.os.include_once "$(athena.plugin.get_plg_lib_dir base)/functions.wizard.sh"

function athena.plugins.base.check_for_undefined_athena_functions()
{
	local to_exclude="athena\.lock"
	local rc=0
	for line in $(grep -Hnr -e "athena\." "$1" | grep -v -e "$to_exclude")
	do
		func=$(echo "$line" | awk -F":" '{ print $3 }'| sed -n -e "s#.*\(athena\..*\)#\1#p"|awk '{ print $1 }')
		if [[ -n "$func" ]]; then
			# cleanup of misplaced characters
			func=$(echo $func | sed -e 's#[")]##g')

			# looking for declared functions
			grep -R -e "[function|alias] ${func}[=|()]" $ATHENA_BASE_LIB_DIR 1>/dev/null 2>/dev/null
			if [ $? -ne 0 ]; then
				grep -R -e "[function|alias] ${func}[=|()]" $ATHENA_PLG_LIB_DIR 1>/dev/null 2>/dev/null
				if [ $? -ne 0 ]; then
					file=$(echo "$line" | awk -F":" '{ print $1 }')
					line_nr=$(echo "$line" | awk -F":" '{ print $2 }')
					athena.error "$file:$line_nr function '$func' does not exist"
					rc=1
				fi
			fi
		fi
	done
	return $rc
}

function athena.plugins.base.validate_dir()
{
	local rc=0
	for file in $(find "$1" -type f -name "*.sh")
	do
		athena.plugins.base.validate_file "$file"
		if [[ $? -ne 0 ]]; then
			rc=1
		fi
	done
	return $rc
}

function athena.plugins.base.validate_file()
{
	athena.plugins.base.check_for_undefined_athena_functions "$1"
	return $?
	# TODO: add more checks later
}

function athena.plugins.base.check()
{
	if [[ -f "$1" ]]; then
		type="file"
		if [ -n "$2" ]; then
			athena.info "checking file : $1"
		fi
		athena.plugins.base.validate_file "$1"
		return $?
	fi

	if [[ -d "$1" ]]; then
		type="directory"
		if [ -n "$2" ]; then
			athena.info "checking directory : $1"
		fi
		athena.plugins.base.validate_dir "$1"
		return $?
	fi
	return 1
}
