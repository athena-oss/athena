CMD_DESCRIPTION="Create, list, install and update plugin(s)."

function _list_plugins()
{
	for plg in $(ls $ATHENA_PLGS_DIR)
	do
		echo " * $plg"
	done
}

function _install_plugin()
{
	athena.os.is_git_installed

	athena.plugin.validate_plugin_name $1

	if [ -z "$2" ]; then
		athena.error "git repository is not specified"
		athena.exit 1
	fi
	git clone $2 $(athena.plugin.get_plugins_dir)/$1
}

function _update_plugin()
{
	local plugin_dir=$(athena.plugin.get_plugins_dir)/$1

	if [ ! -d "$plugin_dir/.git" ]; then
	   athena.debug "'$plugin_dir' is not a git repository!"
	   return 0
	fi

	athena.os.is_git_installed

	athena.plugin.validate_plugin_name $1

	local output
	output=$(git -C $plugin_dir pull origin master 2>&1)
	if [ $? -ne 0 ]; then
		athena.error "there was a problem updating the plugin '$1'"
		return 1
	fi

	if athena.argument.string_contains "$output" "Already up-to-date" ; then
		athena.info "Plugin '$1' already up-to-date."
		return 0
	fi

	athena.ok "Plugin '$1' was updated."
	rm $plugin_dir/athena.lock
	return $?
}


function _update_all_plugins()
{
	athena.os.is_git_installed
	local plugins_dir
	plugins_dir="$(athena.plugin.get_plugins_dir)"
	find $plugins_dir -maxdepth 1 -type d | while read dir
	do
		plg=$(basename "$dir")
		_update_plugin "$plg"
		if [ $? -ne 0 ]; then
			athena.exit_with_msg "Could not update plugin '$plg'!"
		fi
	done
}

function _print_usage()
{
	local options=$(cat <<EOF
list                  ;List all available plugins.
install <name> <repo> ;Installs a plugin from a git repo.
update <name|--all>   ;Update the existing plugin(s).
EOF
)
	athena.usage 1 "<list|install|update>" "$options"
}

# Main Execution
arg1=$(athena.arg 1)
arg2=$(athena.arg 2)
arg3=$(athena.arg 3)
case $arg1 in
	create )
		_create_plugin $arg2
		;;
	list )
		_list_plugins
		;;
	install)
		_install_plugin $arg2 $arg3
		;;
	update)
		if athena.arg_exists "--all" ; then
			_update_all_plugins
		else
			_update_plugin $arg2
		fi
	    ;;
	* )
		_print_usage
		athena.exit 1
		;;
esac
