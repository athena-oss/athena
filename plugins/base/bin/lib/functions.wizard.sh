function athena.plugins.base.wizard.init_plugin()
{
	local plugin_dir=$1
	mkdir -p "$plugin_dir/bin/cmd"
	echo "1.0.0" > "$plugin_dir/version.txt"
	echo "athena.lock" > "$plugin_dir/.gitignore"
	echo "base=$(athena.plugin.get_plg_version base)" > "$plugin_dir/dependencies.ini"
	cat <<EOF > "$plugin_dir/bin/cmd/init_pre.sh"
CMD_DESCRIPTION="Initialise plugin for the first time."
EOF
}

function athena.plugins.base.wizard.create_docker_structure()
{
	cat <<EOF > "$1/Dockerfile"
FROM debian:jessie
MAINTAINER your_email@example.com
EOF
}

function athena.plugins.base.wizard.plugin()
{
	local name=${1:-}
	echo "Welcome to the plugin creator wizard."
	echo

	while [[ -z "$name" ]];
	do
		name=$(_ask_question "Plugin" "what is the name of the plugin?")
	done
	name=$(echo $name | awk '{print tolower($0)}' | tr ' ' '-')

	local plugin_dir="$ATHENA_PLGS_DIR/$name"

	if [ -d "$plugin_dir" ]; then
		answer=$(_ask_question "Plugin:$name" "Plugin '$name' already exists! do you want to create commands for it? (Y/n)?")
		if [[ "$answer" == "n" ]]; then
			athena.exit 1
		fi
	fi

	athena.plugins.base.wizard.init_plugin "$plugin_dir"
	athena.plugins.base.wizard.commands "$name"
	echo
}

function athena.plugins.base.wizard.commands()
{
	local idx=1
	local plugin=$1
	local nr_commands=0
	local plugin_dir="$ATHENA_PLGS_DIR/$plugin"
	local answer
	local name

	if [ ! -d "$plugin_dir" ]; then
		answer=$(_ask_question "Plugin" "plugin '$plugin' does not exist! Do you want to create it (Y/n)?")
		if [[ "$answer" == "n" ]]; then
			return 1
		fi
		athena.plugins.base.wizard.plugin "$plugin"
		return $?
	fi

	while [[ "$nr_commands" -lt 1 ]];
	do
		nr_commands=$(_ask_question "Plugin:$plugin" "how many commands do you want do add?")
	done

	while [[ $nr_commands -gt 0 ]]
	do
		local name=""
		while [[ -z "$name" ]] || athena.argument.string_contains "$name" " " || athena.argument.string_contains "$name" "_";
		do
			name=$(_ask_question "Plugin:$plugin" "what is the name of the command #$idx? (Cannot contain spaces or underscore and should be in lowercase)")
		done

		if ! _command_exists "$plugin" "$name" ; then
			local description=""
			while [[ -z "$description" ]];
			do
				description=$(_ask_question "Command:$name" "what is the description?")
			done
		fi

		athena.plugins.base.wizard.command "$plugin" "$name" "$description"
		echo

		((nr_commands--))
		((idx++))
	done
}

function athena.plugins.base.wizard.command()
{
	local plugin=$1
	local cmd_name=$2
	local description="$3"
	local suffix=""
	local container_name=""
	local answer
	local run_as_daemon=0
	local use_custom_container=0
	local cmd_file
	local cmd_file_pre
	local cmd_file_post

	local has_pre=0
	local has_cmd=0
	local has_post=0
	cmd_file_pre=$(_get_filename $plugin $cmd_name 1)
	cmd_file=$(_get_filename $plugin $cmd_name 0)
	cmd_file_post=$(_get_filename $plugin $cmd_name 2)


	uses_container=$(_ask_question "Command:$name" "will you require a docker container (Y/n)?")
	if [[ "$uses_container" == "n" ]]; then
		if [ -f "$cmd_file_pre" ]; then
			athena.exit_with_msg "Command '$cmd_name' already exists for plugin '$plugin'!"
		fi
		has_pre=1
	else
		has_cmd=1
		if [ -f "$plugin_dir/docker/Dockerfile" ]; then
			answer=$(_ask_question "Command:$cmd_name" "a dockerfile was found. Do you want to use it for this command (Y/n)?")
		fi

		if [[ "$answer" != "Y" ]]; then
			answer=$(_ask_question "Command:$cmd_name" "do you want to create your own container (Y/n)?")
			if [[ "$answer" == "n" ]]; then
				container_name=$(_ask_question "Command:$cmd_name" "what will be the image that you will be using, e.g.: debian:jessie, ubuntu:latest, php:7.0-apache, etc...")
			else
				mkdir -p "$plugin_dir/docker"
				athena.plugins.base.wizard.create_docker_structure "$plugin_dir/docker"
				use_custom_container=1
			fi
		fi

		if [[ -n "$container_name" ]]; then
			answer=$(_ask_question "Command:$cmd_name" "will the container run as a daemon(y/N)?")
			if [[ "$answer" == "y" ]]; then
				run_as_daemon=1
			fi
		fi

		answer=$(_ask_question "Command:$cmd_name" "will you execute some tasks after the container starts/executes (y/N)?")
		if [[ "$answer" == "y" ]]; then
			has_post=1
		fi
	fi

	local nr_args=0
	nr_args=$(_ask_question "Command:$cmd_name" "how many mandatory arguments does it have *(0)?")

	local idx=1
	local args_str=""
	local args_vars=""

	if [[ $nr_args -gt 0 ]]; then
		has_pre=1
	fi

	while [[ $nr_args -gt 0 ]];
	do
		name=$(_ask_question "Command:$cmd_name" "what is the name of the argument #$idx?")

		# prepare the usage string parameters and the variables for retrieving the args
		name=$(echo $name | awk '{print tolower($0)}' | tr ' ' '_')
		args_str="$args_str <$name>"
		args_vars="$args_vars$name=\"\$(athena.arg $idx)\"\n"
		((idx++))
		((nr_args--))
	done

	((idx--))

	args_str=$(echo $args_str | awk '$1=$1')
	args_vars=$(echo $args_vars | awk '$1=$1')

	answer=$(_ask_question "Command:$cmd_name" "do you want to save (Y/n)?")
	if [[ "$answer" != "n" ]]; then
		mkdir -p "$plugin_dir/bin/cmd"

		local done_desc=0

		if [[ $has_pre -eq 1 ]]; then
			_handle_description "$description" "$cmd_file_pre"
			_handle_pre_command "$cmd_file_pre" "$idx" "$args_str" "$args_var" "$run_as_daemon" "$use_custom_container" "$container_name"
			done_desc=1
		fi

		if [[ $has_cmd -eq 1 ]]; then
			if [ $done_desc -eq 0 ]; then
				_handle_description "$description" "$cmd_file"
			fi
			_handle_command "$cmd_file"
		fi

		if [[ $has_post -eq 1 ]]; then
			_handle_post_command "$cmd_file_post"
		fi

		athena.ok "Command '$cmd_name' was created for plugin '$plugin'."
		echo
		athena.info "To use it execute \"$(athena.os.get_executable) $plugin $cmd_name\""
	fi
}

function _handle_description()
{
	local description="$1"
	local cmd_file=$2
	echo "CMD_DESCRIPTION=\"$description\"" > "$cmd_file"
	echo >> $cmd_file
}

function _handle_pre_command()
{
	local cmd_file="$1"
	local idx="$2"
	local args_str="$3"
	local args_var="$4"
	local run_as_daemon=$5
	local use_custom_container=$6
	local container_name=$7

	echo "athena.usage $idx \"$args_str\"" >> "$cmd_file"
	echo >> "$cmd_file"

	echo "# arguments are found below" >> "$cmd_file"
	printf "%b\n" "$args_vars" >> "$cmd_file"
	echo "# clearing arguments from the stack" >> "$cmd_file"
	printf "athena.pop_args %d\n\n" "$idx" >> "$cmd_file"

	if [[ -n "$container_name" ]]; then
		echo "# options for container are found below" >> "$cmd_file"

		if [[ "$run_as_daemon" -eq 1 ]]; then
			if [[ "$use_custom_container" ]]; then
				echo "athena.plugin.use_external_container_as_daemon \"$container_name\"" >> "$cmd_file"
			else
				echo "athena.plugin.use_container \"$container_name\"" >> "$cmd_file"
				echo "athena.docker.add_daemon" >> "$cmd_file"
			fi
		else
			echo "athena.plugin.use_container \"$container_name\"" >> "$cmd_file"
		fi
	fi
}

function _handle_command()
{
	local cmd_file=$1
	echo "# here is where you add you the instructions that should run inside the container" >> "$cmd_file"
}

function _handle_post_command()
{
	local cmd_file=$1
	echo "# here is where you add you the instructions that should run after the container task ends" >> "$cmd_file"
}

function _ask_question()
{
	local answer
	local topic=$1
	local question="$2"
	athena.print "cyan" "[$topic] " "$question" 1>&2
	read answer
	echo "$answer"
	echo 1>&2
}

function _command_exists()
{
	local plugin=$1
	local cmd_name=$2
	local plugin_dir="$ATHENA_PLGS_DIR/$plugin"
	local cmd_file_pre="$plugin_dir/bin/cmd/${cmd_name}_pre.sh"
	local cmd_file="$plugin_dir/bin/cmd/$cmd_name.sh"
	local cmd_file_post="$plugin_dir/bin/cmd/${cmd_name}_post.sh"
	if [ -f "$cmd_file_pre" ]; then
		return 0
	fi
	if [ -f "$cmd_file" ]; then
		return 0
	fi
	if [ -f "$cmd_file_post" ]; then
		return 0
	fi
	return 1
}

function _get_filename()
{
	local suffix
	local plugin=$1
	local cmd_name=$2
	local type=$3
	case $type in
		1)
				suffix="_pre"
				;;
		2)
				suffix="_post"
				;;
	esac
	echo "$ATHENA_PLGS_DIR/$plugin/bin/cmd/$cmd_name$suffix.sh"
}
