# This function handles the routing after the plugin has been found.
# USAGE: athena.plugin._router <plugin> <bin_dir> <cmd_dir> <lib_dir> <hooks_dir> [arguments]
# RETURN: 0 (successful), 1 (failed)
function athena.plugin._router()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	local plugin=$1
	local bin_dir=$2
	local cmd_dir=$3
	local lib_dir=$4
	local hooks_dir=$5

	shift 5

	local -a args=("$@")
	local arg_idx=0
	local return_code=0
	local cmd

	# find first argument that does not start with '-' to exclude flags
	for arg in "${args[@]}"
	do
		((arg_idx++))
		if [[ "$arg" != -* ]]; then
			cmd=$arg
			athena.os.set_command "$cmd"

			# remove the name of the command from the args
			athena.argument.remove_argument $arg_idx
			break
		fi
	done

	if [[ "$cmd" = "version" ]] ; then
		athena.os._set_no_logo 1
	fi

	# plugin pre-hooks
	athena.plugin._run_hooks_if_exist "$hooks_dir/plugin_pre.sh"

	athena.plugin._print_logo
	athena.plugin.validate_usage "$plugin" "${args[@]}"

	athena.plugin.handle "$cmd" "$cmd_dir" "$lib_dir" "$bin_dir" "$hooks_dir"
	return_code=$?

	# plugin post-hooks
	athena.plugin._run_hooks_if_exist "$hooks_dir/plugin_post.sh"

	return $return_code
}

# This function handles the routing of the plugin.
# USAGE: athena.plugin.handle <command> <command_dir> <lib_dir> <bin_dir> <hooks_dir>
# RETURN: 0 (sucessfull), 1 (failed)
function athena.plugin.handle()
{
	local command_to_execute=$1
	local -a cmd_dir
	local lib_dir=$3
	local bin_dir=$4
	local hooks_dir=$5
	local cmd_found=0
	local return_code=0

	athena.argument.argument_is_not_empty_or_fail "$1"

	athena.os.split_string "$2" ":" cmd_dir

	for dir in "${cmd_dir[@]}" ; do
		athena.fs.dir_exists_or_fail "$dir"
	done

	# in case $cmd_dir is a list of dirs, then the command must be
	# located in only one of the directories, so we need to search for it.
	for dir in "${cmd_dir[@]}"
	do
		if athena.fs.dir_contains_files "$dir" "$command_to_execute?(_pre|_post).sh" ; then

			# per plugin functions
			if [ -f "$lib_dir/functions.sh" ]; then
				athena.os.include_once "$lib_dir/functions.sh"
			fi

			# per plugin variables
			if [ -f "$bin_dir/variables.sh" ]; then
				athena.os.include_once "$bin_dir/variables.sh"
			fi

			# command pre-hooks
			athena.plugin._run_hooks_if_exist "$hooks_dir/command_pre.sh"

			athena.plugin.run_command "$command_to_execute" $dir
			return_code=$?

			# command post-hooks
			athena.plugin._run_hooks_if_exist "$hooks_dir/command_post.sh"

			cmd_found=1
			break
		fi
	done

	if [ $cmd_found -eq 0 ]; then
		athena.os.exit_with_msg "Unrecognized command '$command_to_execute'."
	fi

	return $return_code
}

# This function builds the container for the current plugin.
# USAGE: athena.plugin.build
# RETURN: --
function athena.plugin.build()
{
	local plg
	plg=$(athena.plugin.get_plugin)
	local plg_docker_dir
	plg_docker_dir=$(athena.plugin.get_plg_docker_dir "$plg")
	local tag_name
	tag_name=$(athena.plugin.get_tag_name)
	local version
	version=$(athena.plugin.get_image_version)
	athena.docker.build_container "$tag_name" "$version" "$plg_docker_dir"
}

# This function runs the given command from the plugin.
# USAGE: athena.plugin.run_command <command_name> <plugin_cmd_dir>
# RETURN: int
function athena.plugin.run_command()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.fs.dir_exists_or_fail "$2"

	local pre_cmd_file
	local cmd_file
	local post_cmd_file
	local rc=0
	local found_cmd=0
	local command=$1
	local plg_cmd_dir=$2

	# run pre-command outside container
	pre_cmd_file="$plg_cmd_dir/${command}_pre.sh"
	if [ -f "$pre_cmd_file" ]; then
		found_cmd=1
		source "$pre_cmd_file"
		rc=$?
	fi

	# run command inside container
	cmd_file="$plg_cmd_dir/${command}.sh"
	if [ -f "$cmd_file" ] || athena.docker.is_running_as_daemon || ! athena.docker.is_default_router_to_be_used ; then
		found_cmd=1

		# TODO: check if it is better to make it as a flag or environment variable
		athena.docker.add_option "--privileged"

		if [ "$ATHENA_NO_TTY" -ne 1 ]; then
			athena.docker.add_option "-t"
		fi

		athena.plugin.run_container "$command"
		local tmp=$?
		if [ $tmp -ne 0 ]; then
			rc=$tmp
		fi
	fi

	# run post-command outside container
	post_cmd_file="$plg_cmd_dir/${command}_post.sh"
	if [ -f "$post_cmd_file" ]; then
		found_cmd=1
		source "$post_cmd_file"
		local tmp=$?
		if [ $tmp -ne 0 ]; then
			rc=$tmp
		fi
	fi

	if [ $found_cmd -eq 0 ]; then
		athena.os.exit_with_msg "Unrecognized command or plugin '$command'."
	fi
	return $rc
}

# This function checks if the plugin root directory of the given plugin name exists.
# If not it stops execution and throws an error message. If it exists it sources
# 'bin/variables.sh' and 'bin/lib/functions.sh' if available in the plugin.
# USAGE:  athena.plugin.require <plugin name> <version>
# RETURN: --
function athena.plugin.require()
{
	if [ "$1" == "$(athena.plugin.get_plugin)" ]; then
		return 1
	fi

	athena.plugin.plugin_exists "$1" "$2"
	athena.plugin.init "$1"

	# source files from plugin
	local variables_file="$(athena.plugin.get_plg_bin_dir $1)/variables.sh"
	local functions_file="$(athena.plugin.get_plg_lib_dir $1)/functions.sh"

	if [ -f "$functions_file" ]; then
		source "$functions_file"
	fi

	if [ -f "$variables_file" ]; then
		source "$variables_file"
	fi

	return 0
}

# This function checks if the given plugin was initialised (i.e. if athena.lock is
# set in the plugin directory). If not it checks the plugin dependencies (using
# athena.plugin.check_dependencies) and then runs the plugin init script if
# successful. If the required plugins (dependencies) are not installed it stops
# execution and throws an error message.
# USAGE:  athena.plugin.init <plugin_name>
# RETURN: --
function athena.plugin.init()
{
	local plg
	local plg_dir
	local -a plg_cmd_dir
	plg="$1"
	plg_dir=$(athena.plugin.get_plg_dir "$plg")
	plg_cmd_dir=$(athena.plugin.get_plg_cmd_dir "$plg")

	# plugins might not require initialisation so only
	# if an init command exists then it will try to init
	if  [ ! -f "$plg_dir/athena.lock" ]; then
		if ! athena.plugin.check_dependencies "$plg"; then
			athena.os.exit_with_msg "dependencies are not installed"
			return 1
		fi
		if [ -f "$plg_cmd_dir/init.sh" ] || [ -f "$plg_cmd_dir/init_pre.sh" ] || [ -f "$plg_cmd_dir/init_post.sh" ]; then
			athena.color.print_info "Athena plugin '$plg' has not been initialized!"
			athena.color.print_info "Athena plugin '$plg' is initialising..."
			athena.plugin._init_plugin "$plg"
			if [ $? -ne 0 ]; then
				athena.os.exit 1
			fi
			echo
		fi

		# create the lock file
		echo $(date +%s) > $plg_dir/athena.lock
	fi
	return 0
}

# This function returns the directory name where plugins are installed (i.e. the
# value of the $ATHENA_PLGS_DIR variable).
# USAGE:  athena.plugin.get_plugins_dir
# RETURN: string
function athena.plugin.get_plugins_dir()
{
	echo "$ATHENA_PLGS_DIR"
}

# This function returns the version of a plugin as set in its version.txt.
# USAGE:  athena.plugin.get_plg_version [plugin name]
# RETURN: string
function athena.plugin.get_plg_version()
{
	local plg_dir

	plg_dir=$(athena.plugin.get_plg_dir "$1")
	athena.fs.get_file_contents "$plg_dir/version.txt"
}

# This function returns the version of a sub-plugin as set in its version.txt.
# USAGE:  athena.plugin.get_subplg_version <plugin name> <sub-plugin name>
# RETURN: string
function athena.plugin.get_subplg_version()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.argument.argument_is_not_empty_or_fail "$2"
	local subplg_dir
	subplg_dir=$(athena.plugin.get_plg_docker_dir "$1")/$2
	athena.fs.dir_exists_or_fail "$subplg_dir" "subplugin directory '$subplg_dir' does not exist!"
	local version_file=$subplg_dir/version.txt
	athena.fs.file_exists_or_fail "$version_file" "version file '$version_file' not found!"
	athena.fs.get_file_contents "$version_file"
}

# This function returns the plugin root directory name and checks if it exists. If
# it does not exist execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.get_plg_dir [plugin name]
# RETURN: string
function athena.plugin.get_plg_dir()
{
	local plugin_name=$1

	if [ -z "$plugin_name" ]; then
		plugin_name="$(athena.plugin.get_plg)"
	fi

	local plg_dir=$ATHENA_PLGS_DIR/$plugin_name
	athena.fs.dir_exists_or_fail "$plg_dir" "plugin dir does not exist '$plg_dir'."
	echo "$plg_dir"
}

# This function returns the plugin binary directory name and checks if the plugin
# root exists. If not, execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.get_plg_bin_dir [plugin name]
# RETURN: string
function athena.plugin.get_plg_bin_dir()
{
	echo "$(athena.plugin.get_plg_dir $1)/bin"
}

# This function returns the plugin hooks directory and checks if the plugin root
# root exists. If not, execution is stopped and an error message is thrown.
# USAGE: athena.plugin.get_plg_hooks_dir [plugin name]
# RETURN: string
function athena.plugin.get_plg_hooks_dir()
{
	echo "$(athena.plugin.get_plg_bin_dir $1)/hooks"
}

# This function returns the plugin library directory name and checks if the plugin
# root exists. If not, execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.get_plg_lib_dir [plugin name]
# RETURN: string
function athena.plugin.get_plg_lib_dir()
{
	echo "$(athena.plugin.get_plg_bin_dir $1)/lib"
}

# This function returns the plugin command directory name and checks if the plugin
# root exists. If not execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.get_plg_cmd_dir [plugin name]
# RETURN: string
function athena.plugin.get_plg_cmd_dir()
{
	# to allow to override in the plugin hooks for example
	if [ -n "$ATHENA_PLG_CMD_DIR" ]; then
		echo "$ATHENA_PLG_CMD_DIR"
		return 0
	fi
	echo "$(athena.plugin.get_plg_bin_dir $1)/cmd"
}

# This functions sets the plg cmd dir(s).
# The parameter should be one or more directories separated by colons.
# USAGE: athena.plugin.set_plg_cmd_dir <dir(s)>
# RETURN: --
function athena.plugin.set_plg_cmd_dir()
{
	ATHENA_PLG_CMD_DIR=$1
}

# This function returns the plugin docker directory name and checks if the plugin
# root exists. If not execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.get_plg_docker_dir <plugin name>
# RETURN: string
function athena.plugin.get_plg_docker_dir()
{
	echo "$(athena.plugin.get_plg_dir $1)/docker"
}

# This function returns the name of the current plugin as set in the $ATHENA_PLUGIN
# variable.
# USAGE:  athena.plugin.get_plg
# RETURN: string
function athena.plugin.get_plg()
{
	echo "$ATHENA_PLUGIN"
}

# This function returns the shared lib directory.
# USAGE: athena.plugin.get_shared_lib_dir
# RETURN: string
function athena.plugin.get_shared_lib_dir()
{
	echo "$ATHENA_BASE_SHARED_LIB_DIR"
}

# This function returns the bootstrap directory.
# USAGE: athena.plugin.get_bootstrap_dir
# RETURN: string
function athena.plugin.get_bootstrap_dir()
{
	echo "$ATHENA_BASE_BOOTSTRAP_DIR"
}


# This function sets the current container name in the $ATHENA_CONTAINER_NAME variable to
# the given value.
# USAGE:  athena.plugin.set_container_name <container name>
# RETURN: --
function athena.plugin.set_container_name()
{
	export ATHENA_CONTAINER_NAME=$1
}

# This function returns a generic container name generated from the current plugin and
# instance settings (i.e. $ATHENA_PLUGIN and $ATHENA_INSTANCE variables will be considered for the
# container name generation).
# USAGE:  athena.plugin.get_container_name
# RETURN: string
function athena.plugin.get_container_name()
{
	if [ -z "$ATHENA_CONTAINER_NAME" ]; then
		local container_to_use
		local name
		local env
		name="$(athena.plugin.get_prefix_for_container_name)"

		container_to_use=$(athena.plugin.get_container_to_use)
		if [ $? -eq 0  ]; then
			name="${name}-${container_to_use}"
		fi

		env=$(athena.plugin.get_environment)
		if [ $? -eq 0  ]; then
			name="${name}-${env}"
		fi
		ATHENA_CONTAINER_NAME="${name}-$(athena.os.get_instance)"
		ATHENA_CONTAINER_NAME="${ATHENA_CONTAINER_NAME/:/}"
	fi
	echo $ATHENA_CONTAINER_NAME
}

# This function returns the prefix for creating a container name.
# USAGE: athena.plugin.get_prefix_for_container_name [plugin name]
# RETURN: string
function athena.plugin.get_prefix_for_container_name()
{
	if [ -n "$1" ]; then
		echo "athena-plugin-$1"
	else
		echo "athena-plugin-$(athena.plugin.get_plugin)"
	fi
	return 0
}

# This function wraps the athena.plugin.get_plg function.
# USAGE:  athena.plugin.get_plugin
# RETURN: string
function athena.plugin.get_plugin()
{
	athena.plugin.get_plg
}

# This function sets the current plugin in the $ATHENA_PLUGIN variable to the given value.
# USAGE:  athena.plugin.set_plugin <plugin name>
# RETURN: --
function athena.plugin.set_plugin()
{
	ATHENA_PLUGIN=$1
}


# This function returns the value of the current plugin image name as set in the
# $ATHENA_PLG_IMAGE_NAME variable.
# USAGE:  athena.plugin.get_image_name
# RETURN: string
function athena.plugin.get_image_name()
{
	echo "$ATHENA_PLG_IMAGE_NAME"
}

# This function sets the current plugin image name in the $ATHENA_PLG_IMAGE_NAME
# variable to the given value.
# USAGE:  athena.plugin.set_image_name <image name>
# RETURN: --
function athena.plugin.set_image_name()
{
	ATHENA_PLG_IMAGE_NAME=$1
}

# This function generates and returns a tag name from current plugin settings (i.e.
# $ATHENA_PLG_IMAGE_NAME, $ATHENA_PLUGIN, and $ATHENA_PLG_ENVIRONMENT variables will be
# considered for the tag name generation).
# USAGE:  athena.plugin.get_tag_name
# RETURN: string
function athena.plugin.get_tag_name()
{
	local image_name
	local container_to_use
	local plg
	local env
	local tag
	image_name=$(athena.plugin.get_image_name)
	container_to_use=$(athena.plugin.get_container_to_use)
	plg=$(athena.plugin.get_plugin)
	env=$(athena.plugin.get_environment)
	tag=$image_name-$plg

	if [ -n "$container_to_use" ]; then
		tag=${tag}-$container_to_use
	fi

	if [[ ! -z "$env" ]]; then
		tag="$tag-$env"
	fi
	echo "$tag"
}

# This function returns the value of the current plugin image version as set in
# $ATHENA_PLG_IMAGE_VERSION variable.
# USAGE:  athena.plugin.get_image_version
# RETURN: string
function athena.plugin.get_image_version()
{
	echo "$ATHENA_PLG_IMAGE_VERSION"
}

# This function sets the current plugin image version in the
# $ATHENA_PLG_IMAGE_VERSION variable to the given value.
# USAGE:  athena.plugin.set_image_version <image version>
# RETURN: --
function athena.plugin.set_image_version()
{
	if ! athena.utils.validate_version_format "$1" ; then
		athena.os.exit_with_msg "version is not valid '$1'."
	fi
	ATHENA_PLG_IMAGE_VERSION=$1
}

# This function checks if the current plugin environment ($ATHENA_PLG_ENVIRONMENT)
# is set. If set error code 0 is returned. If not error code 1 is returned.
# USAGE:  athena.plugin.is_environment_specified
# RETURN: 0 (true), 1 (false)
function athena.plugin.is_environment_specified()
{
	local env
	env=$(athena.plugin.get_environment)
	if [[ -n "$env" ]]; then
		return 0
	else
		return 1
	fi
}

# This function returns the value of the current plugin environment as set in the
# $ATHENA_PLG_ENVIRONMENT variable. If $ATHENA_PLG_ENVIRONMENT is not set error
# code 1 is returned.
# USAGE:  athena.plugin.get_environment
# RETURN: string
function athena.plugin.get_environment()
{
	if [ -z "$ATHENA_PLG_ENVIRONMENT" ]; then
		return 1
	fi
	echo "$ATHENA_PLG_ENVIRONMENT"
	return 0
}

# This function sets the current plugin environment in the $ATHENA_PLG_ENVIRONMENT
# variable to the given value. If no plugin environment is provided execution will
# be stopped.
# USAGE:  athena.plugin.set_environment <plugin environment>
# RETURN: --
function athena.plugin.set_environment()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "environment not specified!"
		return 1
	fi
	ATHENA_PLG_ENVIRONMENT=$1
	return 0
}

# This function checks if the name, environment, and container of the current
# plugin are set. If so it checks if a build environment file exists and sets
# the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable pointing to it. If not execution is
# stopped and an error message is thrown.
# USAGE:  athena.plugin.handle_environment
# RETURN: --
function athena.plugin.handle_environment()
{
	local env
	env=$(athena.plugin.get_environment)
	if [ $? -eq 1 ]; then
		# nothing to do here, use the normal flow
		return 0
	fi

	local plg
	local docker_dir
	local other_ctr
	plg=$(athena.plugin.get_plugin)
	docker_dir=$(athena.plugin.get_plg_docker_dir "$plg")
	other_ctr=$(athena.plugin.get_container_to_use)
	if [ $? -ne 1 ]; then
			# base container will be used
			if athena.argument.string_contains "$other_ctr" ":" ; then
				return 0
			fi
		docker_dir=$docker_dir/$other_ctr
	fi

	local build_file
	if [ -f "$env" ]; then
		build_file="$env"
		env_name=$(basename $build_file | sed "s#\..*##g" )
		athena.plugin.set_environment $env_name
	else
		build_file="$docker_dir/$env.env"
	fi
	athena.fs.file_exists_or_fail "$build_file" "environment file not found '$build_file' for environment '$env'"
	athena.plugin.set_environment_build_file "$build_file"
}

# This function returns the current docker build environment file name as set in
# the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable. If $ATHENA_PLG_DOCKER_ENV_BUILD_FILE is not set
# error code 1 is returned.
# USAGE:  athena.plugin.get_environment_build_file
# RETURN: string
function athena.plugin.get_environment_build_file()
{
	if [ -z "$ATHENA_PLG_DOCKER_ENV_BUILD_FILE" ]; then
		return 1
	fi
	echo "$ATHENA_PLG_DOCKER_ENV_BUILD_FILE"
}

# This function sets the current docker build environment file name in the
# $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable to the given value.
# USAGE:  athena.plugin.set_environment_build_file <docker build environment file name>
# RETURN: --
function athena.plugin.set_environment_build_file()
{
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=$1
}

# This function checks if the name, docker directory, and container of the current
# plugin are set. If no container is set it checks if a Dockerfile is available in
# the docker directory and will run athena.docker.build with it. If no Dockerfile is
# available it will return doing nothing (some plugins might not need a container).
# If a container was already set it will check if its docker directory (e.g. of a
# given sub-plugin) with version.txt exists, sets image version
# ($ATHENA_PLG_IMAGE_VERSION) and plugin name ($ATHENA_PLUGIN) accordingly, and builds the
# docker image for it. If no valid docker directory is found execution is stopped
# and an error message is thrown.
# USAGE:  athena.plugin.handle_container
# RETURN: --
function athena.plugin.handle_container()
{
	local plg
	local docker_dir
	local other_ctr
	plg=$(athena.plugin.get_plugin)
	docker_dir=$(athena.plugin.get_plg_docker_dir "$plg")
	other_ctr=$(athena.plugin.get_container_to_use)
	if [ $? -eq 1  ]; then
		# some plugins might not need a container to run
		# e.g. : plugins that only manage services
		if [ -f "$docker_dir/Dockerfile" ]; then
			athena.plugin.build
		fi
		return 0
	fi

	local other_ctr_dir
	other_ctr_dir="$docker_dir/$other_ctr"
	if [ ! -d "$other_ctr_dir" ]; then
		# lets try external image
		return 0
	fi

	local version_file
	version_file="$other_ctr_dir/version.txt"
	athena.fs.file_exists_or_fail "$version_file"

	local version
	version=$(athena.fs.get_file_contents "$version_file")
	athena.plugin.set_image_version "$version"
	athena.docker.build_from_plugin "$plg" "$other_ctr" "$version"
}

# This function checks if the plugin root directory of the given plugin exists. If
# not execution is stopped and an error message is thrown. If a version is given
# as second argument it checks if it complies with the found plugin version. If not
# an error message is thrown.
# USAGE:  athena.plugin.plugin_exists <plugin name> <version>
# RETURN: 0 (true), 1 (false)
function athena.plugin.plugin_exists()
{
	local plugin_dir
	plugin_dir=$(athena.plugin.get_plugins_dir)/$1
	if [ ! -d "$plugin_dir" ]; then
		athena.os.exit_with_msg "plugin does not exist $1!"
		return 1
	fi
	if [ -n "$2" ]; then
		local version
		version=$(cat "$plugin_dir/version.txt")
		if ! athena.utils.validate_version "$version" "$2"; then
			athena.os.exit_with_msg "'$1' plugin version '$version' does not match expected '$2'! Maybe you should consider update it."
			return 1
		fi
	fi
	return 0
}

# This function checks if the given argument (e.g. <plugin name>) is not empty. If
# the given string is empty execution is stopped and an error message is thrown.
# USAGE:  athena.plugin.validate_plugin_name <$VARIABLE>
# RETURN: --
function athena.plugin.validate_plugin_name()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "plugin name is not specified"
		return 1
	fi
	return 0
}

# This function checks if the given plugin has dependencies (i.e. it checks the
# content of dependencies.ini). It checks each specified dependency by name and
# version. If a plugin specified as dependency is not installed or has the wrong
# version number the error code 1 is returned. If all dependencies are installed the
# error code 0 is returned.
# USAGE:  athena.plugin.check_dependencies <plugin name>
# RETURN: 0 (true), 1 (false)
function athena.plugin.check_dependencies()
{
	athena.plugin.plugin_exists "$1"
	local plg_dir
	local reqs_file
	plg_dir=$(athena.plugin.get_plugins_dir)/$1
	reqs_file=$plg_dir/dependencies.ini
	athena.color.print_debug "checking plugin dependencies..."
	# check plugin dependencies
	if [ -f  "$reqs_file" ]; then
		while read line
		do
			name=$(echo "$line" | awk -F"=" '{ print $1 }')
			# version can include also an equal sign and be enclosed by double quotes
			version=$(echo "$line" | sed -e "s/${name}=//g")
			version=${version//\"/}
			if ! athena.plugin.plugin_exists "$name" "$version"; then
				return 1
			fi
		done < "$reqs_file"
	fi
	return 0
}

# This function sets the container that will be used for running (i.e. assigning the
# given value to $ATHENA_PLG_CONTAINER_TO_USE variable). If no value is provided it stops
# the execution and throws an error message.
# USAGE:  athena.plugin.use_container <container name>
# RETURN: --
function athena.plugin.use_container()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "container name cannot be empty!"
		return 1
	fi
	ATHENA_PLG_CONTAINER_TO_USE=$1
	return 0
}

# This function uses an external container as a daemon and disables the default router.
# USAGE: athena.plugin.use_external_container_as_daemon <container name> [instance_name]
# RETURN: --
function athena.plugin.use_external_container_as_daemon()
{
	athena.docker.add_daemon
	athena.docker.set_no_default_router
	athena.plugin.use_container "$1"

	if [ -n "$2" ]; then
		athena.os.set_instance "$2"
	fi
}

# This function checks if a container was set for running (in the
# $ATHENA_PLG_CONTAINER_TO_USE variable). If so the container name is returned. If not the
# error code 1 is returned.
# USAGE:  athena.plugin.get_container_to_use
# RETURN: string
function athena.plugin.get_container_to_use()
{
	if [ -z "$ATHENA_PLG_CONTAINER_TO_USE" ]; then
		# then the default must be used
		return 1
	fi
	echo "$ATHENA_PLG_CONTAINER_TO_USE"
	return 0
}

# This function prints the usage info list of all commands found for
# this plugin (in $ATHENA_PLG_CMD_DIR).
# USAGE:  athena.plugin.get_available_cmds
# RETURN: --
function athena.plugin.get_available_cmds()
{
	local -a plg_cmd_dir
	athena.os.split_string "$(athena.plugin.get_plg_cmd_dir)" ":" plg_cmd_dir

	for dir in "${plg_cmd_dir[@]}"; do
		ls "$dir" | while read cmd
		do
			description=$(sed -n -e 's/CMD_DESCRIPTION\="\(.*\)"/\1/p' "$dir/$cmd" | head -1 | sed 's# #_#g' | tr -d '\n')
			cmd=${cmd/\.sh/}
			cmd=${cmd/_pre/}
			cmd=${cmd/_post/}
			# the init command should only be used internally
			if [[ ! "$cmd" = "init" ]]; then
				if [ -n "$description" ]; then
					echo "$cmd:$description"
				else
					echo "$cmd:"
				fi
			fi
		done;
	done | tr ' ' '\n' | sort -r -t: -k1,1 | sort -u -t: -k1,1
}

# This function prints the usage screen of the given plugin including all
# commands found in the plugin directory ($ATHENA_PLG_CMD_DIR).
# USAGE:  athena.plugin.print_available_cmds <plugin_name>
# RETURN: --
function athena.plugin.print_available_cmds()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "plugin_name"

	local plugin_name="$1"
	local plugins_dirs
	local athena_cmd
	plugins_dirs=$(athena.plugin.get_plugins_dir)
	athena_cmd=$0
	if which athena 1>/dev/null 2>/dev/null ; then
		athena_cmd="athena"
	fi
cat <<EOF
usage: $athena_cmd $plugin_name <command> [arg...]

These are the available commands for plugin [$plugin_name]:
EOF
	for cmd in $(athena.plugin.get_available_cmds); do
		printf "\t%s\n" "$cmd" | sed "s#_# #g"
	done | column -t -s:

	if [ "$plugin_name" = "base" ]; then
		echo
		echo "You can also use any of the other available plugins:"
		local plugins
		plugins=$(ls "$plugins_dirs" | grep -v "^base$")
		for plugin_name in $plugins
		do
			printf "\t%s %s <command> [arg...]\n" "$athena_cmd" "$plugin_name"
		done
	fi
}

# This function checks the number of arguments in the given list. If no argument is
# given it shows the available commands of the given plugin and exits. If another
# argument than 'init' or 'cleanup' is given it checks if the plugin was initialised.
# USAGE:  athena.plugin.validate_usage <plugin_name> <argument1> <argument2> ...
# RETURN: --
function athena.plugin.validate_usage()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "plugin_name"

	local plugin_name="$1"

	if [ -z "$plugin_name" ]; then
		athena.exit_with_msg "Missing first argument with plugin name."
	fi

	if [[ "$2" != "init" && "$2" != "cleanup" ]]; then
		athena.plugin.init "$plugin_name"
	fi
	if [ -z "$ATHENA_COMMAND" ] ; then
		athena.plugin.print_available_cmds "$plugin_name"
		athena.os.exit 1
	fi

	return 0
}

# This functions runs the given container.
# USAGE: athena.plugin.run_container <command>
# RETURN: 0 (true), 1 (false)
function athena.plugin.run_container()
{
	athena.argument.argument_is_not_empty_or_fail "$1"

	local command=$1
	local arguments
	athena.argument.get_arguments arguments

	# bootstrap all the configuration that was predefined before
	athena.os._bootstrap

	local tag_name
	container_to_use=$(athena.plugin.get_container_to_use)
	if [ -n "$container_to_use" ]; then
		local docker_dir
		local plg
		plg_dir=$(athena.plugin.get_plg_dir)
		if  [ ! -d "$plg_dir/docker/$container_to_use" ]; then
			tag_name=$container_to_use
		fi
	fi

	# no external container will be used
	if [ -z "$tag_name" ]; then
		local tag
		local version
		tag=$(athena.plugin.get_tag_name)
		version=$(athena.plugin.get_image_version)
		tag_name="$tag:$version"

		# we should already have built an image by this point
		if ! athena.docker.image_exists "$tag" "$version"; then
			athena.os.exit_with_msg "cannot run command inside container because container image is not found!"
		fi
	fi

	# now run
	ATHENA_CONTAINER_STARTED=1
	local container_name
	local router="/opt/shared/router.sh"
	container_name=$(athena.plugin.get_container_name)
	athena.docker.handle_run_type
	if athena.docker.is_default_router_to_be_used ; then
		athena.color.print_debug "using container with default router"
		if athena.docker.is_container_running "$container_name" ; then
			athena.color.print_debug "using already running container $container_name"
			# TODO: check why command needs to be passed to container via arguments
			athena.os.exec athena.docker.exec -i "$container_name" "$router" "$command" "${arguments[@]}"
		else
			athena.color.print_debug "starting container $container_name for command '$command' ..."
			athena.os.exec athena.docker.run_container_with_default_router \
				"$container_name" \
				"$tag_name" \
				"$command"
		fi
	elif athena.docker.is_container_running "$container_name" ; then
		athena.color.print_debug "using already running container $container_name"
		athena.os.exec athena.docker.exec -i "$container_name" "${arguments[@]}"
	else
		athena.color.print_debug "starting container $container_name for command '$command' ..."
		athena.os.exec athena.docker.run_container "$container_name" "$tag_name"
	fi
	local rc=$?
	return $rc
}

# This function executes the init command of the plugin specified
# USAGE: athena.plugin._init_plugin <name>
# RETURN: --
function athena.plugin._init_plugin()
{
	"$0" "$1" "init" "--athena-no-logo"
}

# This function sources the given hooks if they exist.
# USAGE: athena.plugin._run_hooks_if_exist <filename>
# RETURN: 0 (true), 1 (false)
function athena.plugin._run_hooks_if_exist()
{
	if [ -f "$1" ]; then
		source "$1"
		return $?
	fi
	return 1
}

# This function prints the Athena logo including infos about base plugin and current
# plugin versions if $ATHENA_NO_LOGO is set to 0. If the $ATHENA_NO_LOGO flag is set to a value
# unequal to 0 no logo will be printed.
# USAGE:  athena.plugin._print_logo
# RETURN: --
function athena.plugin._print_logo()
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
