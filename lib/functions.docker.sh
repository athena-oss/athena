# This function returns the ip address of the docker machine. It checks for the
# 'docker-machine' and 'boot2docker' commands to do this (default on Mac). If not
# found it searches for the docker0 device (default on Linux) and returns the
# localhost ip if found. If no docker0 device is available the function assumes to
# run inside a docker container and checks if a docker daemon is running in this
# container. If so localhost is returned. If not it returns the default route ip
# address.
# USAGE:  athena.docker.get_ip
# RETURN: string
function athena.docker.get_ip()
{
	# For now the support is limited for mac or linux
	if [ "$ATHENA_IS_MAC" -ne 0 ]; then
		athena._get_docker_ip_for_mac
	else
		athena._get_docker_ip_for_linux
	fi
}

# This function returns the container internal ip provided by docker.
# USAGE: athena.docker.get_ip_for_container <container_name>
# RETURN: string
function athena.docker.get_ip_for_container()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "container name"
	athena.docker.inspect --format '{{ .NetworkSettings.IPAddress }}' "$1"
	if [ $? -ne 0 ]; then
		athena.os.exit_with_msg "could not retrieve the IP for container '$1'"
	fi
}

# This function checks if a docker image with the given tag name and version
# exists.
# USAGE:  athena.docker.image_exists <image name> <version>
# RETURN: 0 (true), 1 (false)
function athena.docker.image_exists() {
	athena.docker.images "$1" | grep "$1" | grep "$2" 1>/dev/null 2>/dev/null
}

# This function checks if a docker container with the given name is running. If no
# container with the given name is running all stopped containers with this name
# are removed (to avoid collisions).
# USAGE:  athena.docker.is_container_running <container name>
# RETURN: 0 (true), 1 (false)
function athena.docker.is_container_running()
{
	athena.docker ps | awk '{ print $NF }' | grep "$1$" 1>/dev/null 2>/dev/null
	local rc=$?
	if [ $rc -ne 0 ]; then
		athena.docker ps -a | grep "$1" | grep -v Up | awk '{ print $1 }' | while read cid
		do
			# removing containers that are not running to avoid collisions
			athena.docker.rm "$cid" 1>/dev/null
		done
	fi
	return $rc
}

# This function checks if the container assigned for running is already running.
# USAGE: athena.docker.is_current_container_running
# RETURN: 0 (true), 1 (false)
function athena.docker.is_current_container_running()
{
	local container_name
	container_name=$(athena.plugin.get_container_name)
	athena.docker.is_container_running "$container_name"
}

# This function checks if the container assigned for running is already running and if it is then exits with an error message.
# USAGE: athena.docker.is_current_container_not_running_or_fail [msg]
# RETURN: 0 (false)
function athena.docker.is_current_container_not_running_or_fail()
{
	if athena.docker.is_current_container_running ; then
		local container_name
		container_name=$(athena.plugin.get_container_name)
		local msg=${1:-"container '$container_name' is already running!"}
		athena.os.exit_with_msg "$msg"
	fi
	return 0
}

# This function stops a docker container with the given name if running or the current container
#if container name is not specified. In any case (running or already stopped) the containers with
# the given name will be removed including associated volumes.
# USAGE:  athena.docker.stop_container [container name]
# RETURN: --
function athena.docker.stop_container()
{
	local container=$1
	if [ -z "$container" ]; then
		container="$(athena.plugin.get_container_name)"
	fi

	if athena.docker.is_container_running "$container"; then
		athena.color.print_info "Stopping $container"
		athena.docker stop "$container" 2>/dev/null 1>/dev/null
		if [ $? -eq 0 ]; then
			athena.color.print_info "$container is now stopped"
		fi
	fi
	athena.docker.rm -v "$container" 2>/dev/null 1>/dev/null
}

# This function stops and removes docker containers which run in this instance with
# the given name. If '--global' is set as additional argument all (regardless the
# instance) docker containers with the given name are stopped/removed. Since the
# containers are stopped/removed in parallel the function waits until all
# containers were stopped and removed successfully.
# OPTION: --global
# USAGE:  athena.docker.stop_all_containers <name_to_filter> [<option>]
# RETURN: --
function athena.docker.stop_all_containers()
{
	local instance
	instance=$(athena.os.get_instance)
	local n=0
	local containers_to_stop
	containers_to_stop=$(athena._get_list_of_docker_containers "$1")
	if [ -n "$containers_to_stop" ]; then
		nr_containers=$(echo "$containers_to_stop" | wc -w | awk '{ print $1}')
		for i in $containers_to_stop
		do
			# only stop this instance containers
			if [[ "$i" == *$instance || "$2" == "--global" ]]; then
				athena.docker.stop_container "$i" &
			fi

			if (( $(($((++n)) % nr_containers)) == 0 )) ; then
				athena.color.print_debug "Waiting for '$nr_containers' containers to stop..."
				wait
			fi
		done
		return 0
	fi
	return 1
}

# This function removes a docker container and the associated image.
# USAGE:  athena.docker.remove_container_and_image <tag name> <version>
# RETURN: --
function athena.docker.remove_container_and_image()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "tag"
	athena.argument.argument_is_not_empty_or_fail "$2" "version"
	local container
	container=$(athena.docker.get_tag_and_version "$1" "$2")
	if [ -n "$container" ]; then
		athena.docker.rm "$container"
	fi

	athena.docker.images "$1" | grep "$2" 1>/dev/null
	if [ $? -eq 0 ]; then
		athena.docker.rmi -f "$1:$2"
	fi
}

# This function gets the name ($ATHENA_PLUGIN), docker directory (see
# athena.plugin.get_plg_docker_dir), tag name (see athena.plugin.get_tag_name), and version
# ($ATHENA_PLG_IMAGE_VERSION) of the current plugin and builds a docker image
# from these resources. If no valid Dockerfile exists or the build is
# unsuccessful execution is stopped and an error message is thrown.
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

# This function builds a docker image for a plugin. Plugin name, sub-plugin name,
# and version must be provided. If no valid docker directory or Dockerfile is found
# execution is stopped and an error message is thrown.
# USAGE: athena.docker.build_from_plugin <plugin name> <sub-plugin name> <plugin version>
# RETURN: --
function athena.docker.build_from_plugin()
{
	local plg=$1
	local sub_plg=$2
	local version=$3
	local docker_dir
	docker_dir=$(athena.plugin.get_plg_docker_dir "$plg")/$sub_plg

	# validate docker reqs for other container inside plugin
	local msg_no_docker_dir="Docker directory not found '$docker_dir'"
	athena.fs.dir_exists_or_fail "$docker_dir" "$msg_no_docker_dir"

	local msg_no_dockerfile="Dockerfile not found '$docker_dir/Dockerfile'"
	athena.fs.file_exists_or_fail "$docker_dir/Dockerfile" "$msg_no_dockerfile"

	local tag_name
	tag_name=$(athena.plugin.get_tag_name)
	athena.docker.build_container "$tag_name" "$version" "$docker_dir"
}

# This function builds a docker image using the given tag name, version and docker
# directory (Dockerfile must exists in the given directory). If a docker image with
# tag:version already exists nothing is done. If not the function checks if it is
# in the right directory, loads build environment variables if provided (see
# athena.docker.get_build_args), and builds the docker image. If the function is called
# in a wrong directory or the build is unsuccessful execution is stopped and an
# error message is thrown.
# USAGE:  athena.docker.build_container <tag name> <version> <docker directory>
# RETURN: --
function athena.docker.build_container()
{
	local tag_name=$1
	local version=$2
	local docker_dir=$3
	if ! athena.docker.image_exists "$tag_name" "$version"; then
		local -a build_args=()
		athena.docker.get_build_args "build_args"
		if [ ${#build_args[@]} -gt 0 ]; then
			local build_args_file
			build_args_file=$(athena.plugin.get_environment_build_file)
			athena.color.print_debug "loading build environment variables from file '$build_args_file'"
		fi

		athena.docker._validate_if_build_args_exist "$docker_dir/Dockerfile" "$(athena.docker.get_build_args_file)"

		athena.color.print_info "Building ATHENA container '$tag_name:$version'..."
		athena.docker.build "${build_args[@]}" -t "$tag_name:$version" -f "$docker_dir/Dockerfile" "$docker_dir"
		local rc=$?

		# ensure that the process stops here if build error occurred
		if [ $rc -ne 0 ]; then
			athena.os.exit $rc
		fi
	fi
}

# This function generates and stores, in the given array,  the build arguments from the build args file
# returned by athena.docker.get_build_args_file or does nothing if no file was found.
# USAGE:  athena.docker.get_build_args <array_name>
# RETURN: string | 1 (false)
function athena.docker.get_build_args()
{
	local file
	file=$(athena.docker.get_build_args_file)
	if [ $? -ne 0 ]; then
		return 1
	fi
	while read build_arg
	do
		athena.utils.add_to_array "$1" --build-arg "${build_arg[@]}"
	done < "$file"
	return 0
}

# This function checks if a docker build environment file is defined in the
# $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable. If not it returns 1. If defined it checks
# if the file exists and returns the name of the file.
# USAGE:  athena.docker.get_build_args_file
# RETURN: string | 1 (false)
function athena.docker.get_build_args_file()
{
	local file
	file=$(athena.plugin.get_environment_build_file)
	if [ -f "$file" ] && grep "=" "$file" 1>/dev/null; then
		echo $file
		return 0
	fi

	return 1
}

# This function cleans up the container for the current plugin in case is not running.
# USAGE:  athena.docker.cleanup
# RETURN: --
function athena.docker.cleanup() {
	local container_name
	container_name=$(athena.plugin.get_container_name)
	if athena.docker.inspect "$container_name" >/dev/null 2>&1 ; then
		if ! athena.docker.is_container_running "$container_name" >/dev/null; then
			athena.docker.rm -v "$container_name" 1>/dev/null 2>/dev/null
		fi
	fi
}

# This function adds the given option to the docker run option string ($ATHENA_DOCKER_OPTS).
# USAGE:  athena.docker.add_option <your option>
# RETURN: --
function athena.docker.add_option()
{
	athena.utils.add_to_array "ATHENA_DOCKER_OPTS" "$@"
}

# This function adds an environment variable to the docker run option string
# ($ATHENA_DOCKER_OPTS).
# USAGE:  athena.docker.add_env <variable name> <variable value>
# RETURN: --
function athena.docker.add_env()
{
	local name="$1"
	athena.docker.add_option --env $name"="$2
}

# This function adds environment variables with the given prefix to the docker run option string.
# USAGE: athena.docker.add_envs_with_prefix <prefix>
# RETURN: --
function athena.docker.add_envs_with_prefix()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	local prefix
	prefix=$1
	local tmp=$(eval echo \${!$prefix@})
	for var in $(echo $tmp | grep -v ^$ | tr ' ' '\n')
	do
		athena.docker.add_option --env $var=${!var}
	done
	return 0
}

# This function adds environment variables from the given file (ini format).
# USAGE: athena.docker.add_envs_from_file <filename>
# RETURN: --
function athena.docker.add_envs_from_file()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.fs.file_exists_or_fail "$1"
	while read env
	do
		athena.docker.add_option --env $env
	done < "$1"
	return 0
}

# This function adds the daemon flag to the docker run option string ($ATHENA_DOCKER_OPTS).
# USAGE:  athena.docker.add_daemon
# RETURN: --
function athena.docker.add_daemon()
{
	athena.docker.add_option -d
	athena.os.enable_error_mode
}

# This function adds the --rm flag (automatically remove the container when it
# exits) to the docker run option string ($ATHENA_DOCKER_OPTS).
# USAGE:  athena.docker.add_autoremove
# RETURN: --
function athena.docker.add_autoremove()
{
	athena.docker.add_option --rm=true
}

# This function checks if either the daemon or the autoremove flag is set in the
# docker run option string ($ATHENA_DOCKER_OPTS). If one of both is set it returns the
# error code 0. If none is set it sets the autoremove flag (--rm) and returns the
# error code 1.
# USAGE:  athena.docker.handle_run_type
# RETURN: 0 (true), 1 (false)
function athena.docker.handle_run_type()
{
	# if run type is not specified explicitly then
	# it will be auto remove
	if ! athena.docker.has_option "-d" 1 -a ! athena.docker.has_option "--rm" 1; then
		athena.docker.add_autoremove
		return 1
	fi
	return 0
}

# This function checks if a certain string can be found in the container logs. If
# not the container is considered to be not running and the function keeps
# rechecking every second. If 300 seconds are reached it stops execution and throws
# an error message.
# USAGE:  athena.docker.wait_for_string_in_container_logs <container> <log message>
# RETURN: 0 (true)
function athena.docker.wait_for_string_in_container_logs()
{
	local component=$1
	local message="$2"
	athena.docker.logs "$component" 2>&1 | grep -i "$message" 2>/dev/null 1>/dev/null
	local status=$?
	local counter=0
	local wait_for_seconds=300
	while [ $status -ne 0 ]; do
		let counter++
		athena.color.print_debug "waiting for $component..."
		if [ $counter -gt $wait_for_seconds ]; then
			athena.os.exit_with_msg "not reaching the component after ${wait_for_seconds}s"
		fi

		sleep 1
		athena.docker.logs "$component" 2>&1 | grep -i "$message" 2>/dev/null 1>/dev/null
		status=$?
		echo -n "."
	done
	if [ $counter -gt 0 ]; then
		echo
	fi
	athena.color.print_info "$component is UP"
	return 0
}

# This function adds the given volume to the docker run option string
# ($ATHENA_DOCKER_OPTS). If source or target directory are not specified it stops
# execution and throws an error message or if source is not a directory also stops.
# USAGE: athena.docker.mount_dir <source directory> <target directory>
# RETURN: --
function athena.docker.mount_dir()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "you must specify source dir!"
	fi

	if [ -z "$2" ]; then
		athena.os.exit_with_msg "you must specify target dir!"
	fi

	athena.fs.dir_exists_or_fail "$1"

	athena.docker.add_option -v "$1:$2"
}

# This function adds the given volume to the docker run option string
# ($ATHENA_DOCKER_OPTS). If source or target directory are not specified it stops
# execution and throws an error message and if source is neither a file or a directory
# also stops the execution.
# USAGE: athena.docker.mount <source> <target>
# RETURN: --
function athena.docker.mount()
{
	if [ -z "$1" ]; then
		athena.os.exit_with_msg "you must specify source dir!"
	fi

	if [ -z "$2" ]; then
		athena.os.exit_with_msg "you must specify target dir!"
	fi

	if [ ! -f "$1" ] && [ ! -d "$1" ]; then
		athena.os.exit_with_msg "source does not exist \"$1\"!"
	fi

	athena.docker.add_option -v $1:$2
}

# This function checks if the given option is already set.
# USAGE: athena.docker.has_option <option> [strict]
# RETURN: 0 (true) 1 (false)
function athena.docker.has_option()
{
	athena.argument.argument_is_not_empty_or_fail "$@"
	athena.utils.in_array "ATHENA_DOCKER_OPTS" "$@" ${2:-0}
}

# This function checks if docker option -d is already set.
# USAGE: athena.docker.is_running_as_daemon
# RETURN: 0 (true) 1 (false)
function athena.docker.is_running_as_daemon()
{
	athena.docker.has_option "-d"
}

# This function checks if container has started
# USAGE: athena.docker.container_has_started
# RETURN: 0 (true) 1 (false)
function athena.docker.container_has_started()
{
	if [[ $ATHENA_CONTAINER_STARTED -eq 1 ]]; then
		return 0
	fi
	return 1
}

# This function adds the given volume to the docker run option from a relative
# path to the current plugin.
# USAGE: athena,docker.mount_dir_from_plugin <relative_path_from_plugin> <target_directory>
# RETURN: --
function athena.docker.mount_dir_from_plugin()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.argument.argument_is_not_empty_or_fail "$2"
	local plg_dir
	local dir_from_plg
	plg_dir=$(athena.plugin.get_plg_dir)
	dir_from_plg="$plg_dir/$1"
	athena.fs.dir_exists_or_fail "$dir_from_plg"
	athena.docker.mount_dir "$dir_from_plg" "$2"
	return 0
}

# This function outputs the extra options to be passed for running docker. As an alternative
# you can also assign to a given array name.
# USAGE: athena.docker.get_options [array_name]
# RETURN: string
function athena.docker.get_options()
{
	athena.utils.get_array "ATHENA_DOCKER_OPTS" "$1"
}

# This function sets the options to be passed to docker.
# USAGE: athena.docker.set_options <options>
# RETURN: --
function athena.docker.set_options()
{
	athena.utils.set_array "ATHENA_DOCKER_OPTS" "$@"
}

# This function runs a container.
# USAGE: athena.docker.run_container <container_name> <tag_name>
# RETURN: --
function athena.docker.run_container()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.argument.argument_is_not_empty_or_fail "$2"
	local name="$1"
	local tag_name="$2"
	local docker_opts="$(athena.docker.get_options)"
	local arguments="$(athena.argument.get_arguments)"
	athena.docker.run --name "$name" ${docker_opts[@]} "$tag_name" ${arguments[@]}
}

# This function runs a container using the default router.
# The ATHENA_COMMAND and ATHENA_ARGS will be set dynamically
# within the router inside the container so that even executing
# something inside an already running container will have the
# correct COMMAND being executed with the correct ARGS.
# USAGE: athena.docker.run_container_with_default_router <container_name> <tag_name> <command>
# RETURN: --
function athena.docker.run_container_with_default_router()
{
	athena.argument.argument_is_not_empty_or_fail "$1"
	athena.argument.argument_is_not_empty_or_fail "$2"
	athena.argument.argument_is_not_empty_or_fail "$3"
	local router="/opt/bootstrap/router.sh"
	local name="$1"
	local tag_name="$2"
	local athena_command="$3"

	athena.docker.add_env "ATHENA_PLUGIN" "$(athena.plugin.get_plugin)"
	athena.docker.add_env "ATHENA_BASE_SHARED_LIB_DIR" "/opt/shared"
	athena.docker.add_env "BIN_DIR" "/opt/athena/bin"
	athena.docker.add_env "CMD_DIR" "/opt/athena/bin/cmd"
	athena.docker.add_env "LIB_DIR" "/opt/athena/bin/lib"
	athena.docker.add_env "ATHENA_DOCKER_IP" "$(athena.docker.get_ip)"
	athena.docker.add_env "ATHENA_DOCKER_HOST_IP" "$(athena.os.get_host_ip)"
	athena.docker.mount_dir "$(athena.plugin.get_shared_lib_dir)" "/opt/shared"
	athena.docker.mount_dir "$(athena.plugin.get_plg_dir)" "/opt/athena"
	athena.docker.mount_dir "$(athena.plugin.get_bootstrap_dir)" "/opt/bootstrap"
	athena.docker.add_option "--name" "$name"
	athena.docker.add_option "$tag_name"
	athena.docker.add_option "$router"
	athena.docker.add_option "$athena_command"
	athena.docker.add_option "$(athena.argument.get_arguments)"

	local docker_opts="$(athena.docker.get_options)"
	athena.docker.run ${docker_opts[@]}
}

# This function specifies that the default router should not be used.
# USAGE: athena.docker.set_no_default_router [value]
# RETURN: --
function athena.docker.set_no_default_router()
{
	ATHENA_DOCKER_NO_DEFAULT_ROUTER=${1:-1}
}

# This function checks if the default router should be used.
# USAGE: athena.docker.is_default_router_to_be_used
# RETURN: 0 (true) 1 (false)
function athena.docker.is_default_router_to_be_used()
{
	if [[ "$ATHENA_DOCKER_NO_DEFAULT_ROUTER" -eq 0 ]]; then
		return 0
	fi
	return 1
}

# Either print or follow the output of one or more container logs.
# USAGE: athena.docker.print_or_follow_container_logs <containers> [-f]
# RETURN: --
function athena.docker.print_or_follow_container_logs()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "containers"

	local containers="$1"
	local follow_logs="$2"

	for container_name in $containers; do
		if ! athena.docker.is_container_running "$container_name"; then
			continue
		fi

		athena.color.print_info "Debugging '$container_name':"

		if [[ "$follow_logs" == "-f" ]]; then
			athena.color.print_info "Hit CTRL-C to stop following..."
		else
			unset follow_logs
		fi
		athena.docker logs $follow_logs "$container_name"
	done

	return 0
}

# This function returns a list of docker containers filtered by name.
# USAGE: athena._get_list_of_docker_containers <name>
# RETURNS: a string with the names of the containers
function athena._get_list_of_docker_containers()
{
	athena.docker ps -a --filter="name=$1" --format="{{.Names}}" | grep -v ^$
}

function athena._get_docker_ip_for_mac()
{
	# running docker for mac maybe
	if [ -z "$DOCKER_MACHINE_NAME" ]; then
		echo 127.0.0.1
	elif which 'docker-machine' 1>/dev/null 2>/dev/null ; then
		docker-machine ip "${DOCKER_MACHINE_NAME:-default}"
	elif which 'boot2docker'; then
		boot2docker ip
	fi

	if [ $? -ne 0 ]; then
		athena.os.exit_with_msg "could not get the ip for docker! Please check if it is running."
	fi
	return 0
}

function athena._get_docker_ip_for_linux()
{
	# default for linux
	# if this runs plain it should exist an docker0
	# network device, then use 127.0.0.1,
	if ip link show dev docker0 1>/dev/null 2>/dev/null; then
		echo 127.0.0.1
	else
		# otherwise it will probably run inside a docker container
		# and then it depends if it is using an external docker daemon
		# or running it's own docker daemon
		if pgrep docker >/dev/null; then
			# running it's own docker daemon so it is still
			# accessible via localhost
			echo 127.0.0.1
		else
			# now use the ip address which is probably mapped
			# to the outside docker0 device by using the
			# default route ip address
			ip route | grep ^default | awk '{print $3}'
		fi
	fi
}

# This is a wrapper function for executing docker, which helps with mocking and tweaking.
# USAGE: athena.docker <args>
# RETURN: --
function athena.docker()
{
	local cmd
	cmd="$ATHENA_SUDO docker"
	if [ "$ATHENA_DOCKER_DAEMON_IS_RUNNING" -eq 0 ]; then
		if $cmd ps 1>/dev/null 2>/dev/null; then
			ATHENA_DOCKER_DAEMON_IS_RUNNING=1
		else
			ATHENA_DOCKER_DAEMON_IS_RUNNING=0
			athena.os.exit_with_msg "docker daemon is not running."
		fi
	fi
	$cmd "$@"
}

# This is a wrapper function for executing docker rm, which helps with mocking and tweaking.
# USAGE: athena.docker.rm <args>
# RETURN: --
function athena.docker.rm()
{
	athena.docker rm "$@"
}

# This is a wrapper function for executing docker rmi, which helps with mocking and tweaking.
# USAGE: athena.docker.rmi <args>
# RETURN: --
function athena.docker.rmi()
{
	athena.docker rmi "$@"
}

# This is a wrapper function for executing docker images, which helps with mocking and tweaking.
# USAGE: athena.docker.images <args>
# RETURN: --
function athena.docker.images()
{
	athena.docker images "$@"
}

# This is a wrapper function for executing docker inspect, which helps with mocking and tweaking.
# USAGE: athena.docker.inspect <args>
# RETURN: --
function athena.docker.inspect()
{
	athena.docker inspect "$@"
}

# This is a wrapper function for executing docker build, which helps with mocking and tweaking.
# USAGE: athena.docker.build <args>
# RETURN: --
function athena.docker.build()
{
	athena.docker build "$@"
}

# This is a wrapper function for executing docker logs, which helps with mocking and tweaking.
# USAGE: athena.docker.logs <args>
# RETURN: --
function athena.docker.logs()
{
	athena.docker logs "$@"
}

# This is a wrapper function for executing docker run, which helps with mocking and tweaking.
# USAGE: athena.docker.run <args>
# RETURN: --
function athena.docker.run()
{
	athena.docker run "$@"
}

# This is a wrapper function for executing docker exec, which helps with mocking and tweaking.
# USAGE: athena.docker.exec <args>
# RETURN: --
function athena.docker.exec()
{
	athena.docker exec "$@"
}

function athena.docker.get_tag_and_version()
{
	athena.docker ps -a | grep "$1:$2" | awk '{ print $1 }'
}

# This function returns a list of athena custom containers.
# USAGE: athena.docker.list_athena_containers
# RETURN: string
function athena.docker.list_athena_containers()
{
	athena.docker ps -a --filter="name=$(athena.os.get_prefix)" --format="{{.Names}}:{{.Ports}}:{{.Image}}" | sed "s# ##g" | sed 's#0.0.0.0:##g' | sed  's#/tcp##g'
}

# Check if docker volume with the <name> exists.
# USAGE: athena.docker.volume_exists <name>
# RETURN: 0 (true), exit 1 (failed)
function athena.docker.volume_exists()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	if ! athena.docker volume inspect "$1" 1>/dev/null 2>/dev/null; then
		return 1
	fi
	return 0
}

# Create a new docker volume with <name>.
# USAGE: athena.docker.volume_create <name>
# RETURN: 0 (true), exit 1 (failed)
function athena.docker.volume_create()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	athena.docker volume create --name "$1" 1>/dev/null
}

# Check if a volume with the <name> already exists, if not the volume is
# created.
# USAGE:  athena.docker.volume_exists_or_create <name>
# RETURN: 0 (true), 1 (false)
function athena.docker.volume_exists_or_create()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	if ! athena.docker.volume_exists "$1"; then
		if ! athena.docker.volume_create "$1"; then
			athena.os.exit_with_msg "Failed to create volume ${1} ..."
			return 1
		fi
	fi
	return 0
}

# Check if docker network with the <name> exists.
# USAGE: athena.docker.network_exists <name> [opts...]
# RETURN: 0 (true), exit 1 (failed)
function athena.docker.network_exists()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	if ! athena.docker network inspect "$1" 1>/dev/null 2>/dev/null; then
		return 1
	fi
	return 0
}

# Create a new docker network with <name>.
# USAGE: athena.docker.network_create <name> [opts...]
# RETURN: 0 (true), exit 1 (failed)
function athena.docker.network_create()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	athena.docker network create ${@:2} "$1" 1>/dev/null
}

# Check if a network with the <name> already exists, if not the network is
# created.
# USAGE:  athena.docker.network_exists_or_create <name> [opts...]
# RETURN: 0 (true), 1 (false)
function athena.docker.network_exists_or_create()
{
	athena.argument.argument_is_not_empty_or_fail "$1" "name"
	if ! athena.docker.network_exists "$1"; then
		if ! athena.docker.network_create "$1" ${@:2}; then
			athena.os.exit_with_msg "Failed to create network '${1}'..."
			return 1
		fi
	fi
	return 0
}

# This function validates if the mandatory build args that exist in a given Dockerfile without
# a default value are specified in the build_args file if it was given.
# USAGE: athena.docker._validate_if_build_args_exist <dockerfile> [build_args_file]
# RETURN: 0 (true), exit 1 (failed)
function athena.docker._validate_if_build_args_exist()
{
	local file=$2
	local error_msg

	while read arg_line
	do
		arg=$(echo $arg_line | awk '{ split($2, a, "="); print a[1] }')
		arg_default_value=$(echo $arg_line | awk -F= '{ print $2 }')
		if [ -n "$arg_default_value" ]; then
			continue
		fi

		if [ -n "$file" ]; then
			grep -qE "^[[:blank:]]{0,}$arg=" "$file" && continue

			error_msg="in file $file"
		else
			error_msg="and no args file exists"
		fi

		athena.os.exit_with_msg "Build arg '$arg' missing $error_msg"
	done < <(grep "^ARG" "$1")
	return 0
}
