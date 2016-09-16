function testcase_athena.docker.run_container()
{
	athena.test.assert_exit_code.expects_fail "athena.docker.run_container"
	athena.test.assert_exit_code.expects_fail "athena.docker.run_container" "one"
	athena.test.mock "athena.docker.run" "_my_docker_echo"
	athena.test.assert_output "athena.docker.run_container" "--name container_name --env A=B tag:version" "container_name" "tag:version" "--env A=B"
	athena.test.assert_output "athena.docker.run_container" "--name container_name --env A=B tag:version one two three" "container_name" "tag:version" "--env A=B" "one two three"
}

function testcase_athena.docker.run_container_with_default_router()
{
	athena.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router"
	athena.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router" "one"
	athena.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router" "one" "two"
	athena.test.mock "athena.docker.run" "_my_docker_echo"
	athena.test.mock.outputs "athena.docker.get_ip" "127.0.0.1"
	athena.test.mock.outputs "athena.os.get_host_ip" "127.0.0.1"
	athena.test.mock.outputs "athena.plugin.get_shared_lib_dir" "/path/to/shared/dir"
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "/path/to/plugin/dir"
	athena.test.assert_output "athena.docker.run_container_with_default_router" \
		"--name mycontainer --env ATHENA_PLUGIN=base --env ATHENA_BASE_SHARED_LIB_DIR=/opt/shared --env BIN_DIR=/opt/athena/bin --env CMD_DIR=/opt/athena/bin/cmd --env LIB_DIR=/opt/athena/bin/lib --env ATHENA_DOCKER_IP=127.0.0.1 --env ATHENA_DOCKER_HOST_IP=127.0.0.1 -v /path/to/shared/dir:/opt/shared -v /path/to/plugin/dir:/opt/athena OTHER_OPTIONS mytag:version /opt/shared/router.sh mycommand one two three" \
		"mycontainer" "mytag:version" "mycommand" "OTHER_OPTIONS" one two three
}

function testcase_athena.docker.add_option()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS=
	athena.docker.add_option "--env A=B"
	athena.test.assert_value "--env A=B" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.is_default_router_to_be_used()
{
	local curr_no_default_router=$ATHENA_DOCKER_NO_DEFAULT_ROUTER

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=0
	athena.test.assert_return "athena.docker.is_default_router_to_be_used"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=1
	athena.test.assert_return.expects_fail "athena.docker.is_default_router_to_be_used"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=$curr_no_default_router
}

function testcase_athena.docker.has_option()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"

	athena.docker.set_options "-d"
	athena.test.assert_return "athena.docker.has_option" "-d"

	athena.docker.set_options "--env A=B"
	athena.test.assert_return.expects_fail "athena.docker.has_option" "-d"

	athena.docker.set_options "-daemon"
	athena.test.assert_return.expects_fail "athena.docker.has_option" "-d"

	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.set_options()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"

	athena.docker.set_options "-d --env A=B"
	athena.test.assert_value "$(athena.docker.get_options)" "-d --env A=B"

	athena.docker.set_options ""
	athena.test.assert_value "$(athena.docker.get_options)" ""

	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.container_has_started()
{
	local curr_container_has_started=$ATHENA_CONTAINER_STARTED

	ATHENA_CONTAINER_STARTED=$curr_container_has_started
}

function testcase_athena.docker.is_running_as_daemon()
{
	local curr_extra_opts
	curr_extra_opts=$(athena.docker.get_options)

	athena.docker.add_daemon
	athena.test.assert_return "athena.docker.has_option" "-d"

	athena.docker.set_options ""
	athena.test.assert_return.expects_fail "athena.docker.has_option" "-d"

	athena.docker.set_options "$curr_extra_opts"
}

function testcase_athena.docker.add_env()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS=
	athena.docker.add_env "A" "C"
	athena.test.assert_value "--env A=C" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.add_daemon()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS=
	athena.docker.add_daemon
	athena.test.assert_value "-d" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.add_autoremove()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS=
	athena.docker.add_autoremove
	athena.test.assert_value "--rm=true" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.handle_run_type()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS=
	athena.docker.add_daemon
	athena.docker.handle_run_type
	athena.test.assert_return.expects_fail "athena.argument.string_contains" $ATHENA_DOCKER_OPTS "--rm=true"

	ATHENA_DOCKER_OPTS="--rm"
	athena.docker.handle_run_type
	athena.test.assert_return.expects_fail "athena.argument.string_contains" $ATHENA_DOCKER_OPTS "--rm=true"

	ATHENA_DOCKER_OPTS=
	athena.docker.handle_run_type
	athena.test.assert_return "athena.argument.string_contains" $ATHENA_DOCKER_OPTS "--rm=true"

	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.mount_dir()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	local tmp_dir="$(athena.test.create_tempdir)"
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir"
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir" "$tmp_dir"

	ATHENA_DOCKER_OPTS=
	athena.docker.mount_dir "$tmp_dir" "$tmp_dir"
	athena.test.assert_value "-v $tmp_dir:$tmp_dir" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"

	rm -r "$tmp_dir"
}

function testcase_athena.docker.mount_dir_from_plugin()
{
	local curr_extra_opts="$ATHENA_DOCKER_OPTS"
	local tmp_dir="$(athena.test.create_tempdir)"
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin"
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "$tmp_dir"

	athena.test.mock.outputs "athena.plugin.get_plg_dir" "$tmp_dir"

	ATHENA_DOCKER_OPTS=
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"

	local plg_dir="$(athena.test.create_tempdir)"
	mkdir -p "$plg_dir/plg"
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "$plg_dir/plg"
	athena.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"

	mkdir -p "$plg_dir/plg/xpto"
	athena.test.assert_exit_code "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"


	athena.docker.mount_dir_from_plugin "xpto" "$tmp_dir"
	athena.test.assert_value "-v $plg_dir/plg/xpto:${tmp_dir}" "$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
	rm -r "$plg_dir"
	rm -r "$tmp_dir"
}

function testcase_athena.docker.set_no_default_router()
{
	local curr_no_default_router=$ATHENA_DOCKER_NO_DEFAULT_ROUTER

	athena.docker.set_no_default_router
	athena.test.assert_value "$ATHENA_DOCKER_NO_DEFAULT_ROUTER" "1"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=$curr_no_default_router
}

function testcase_athena.docker.image_exists()
{
	athena.test.mock.returns "athena.docker" 1
	athena.test.assert_return.expects_fail "athena.docker.image_exists" "mytag" "1.0.0"
	athena.test.mock.outputs "athena.docker" "mytag 1.0.0"
	athena.test.assert_return "athena.docker.image_exists" "mytag" "1.0.0"

}

function testcase_athena.docker.is_container_running()
{
	athena.test.mock.outputs "athena.docker" "mycontainer"
	athena.test.assert_return "athena.docker.is_container_running" "mycontainer"

	athena.test.mock.outputs "athena.docker" ""
	athena.test.assert_return.expects_fail "athena.docker.is_container_running" "mycontainer"

	athena.test.mock "athena.docker" "_my_docker_fake_docker_exec"
	athena.test.assert_exit_code.expects_fail "athena.docker.is_container_running" "rm was called" "mycontainer"
}

function testcase_athena.docker.is_current_container_running()
{
	athena.test.mock.outputs "athena.plugin.get_container_name" "mycontainer123"
	athena.test.mock "athena.docker.is_container_running" "_my_docker_echo"
	athena.test.assert_output "athena.docker.is_current_container_running" "mycontainer123"
}

function testcase_athena.docker.is_current_container_not_running_or_fail()
{
	athena.test.mock.returns "athena.docker.is_current_container_running" 0
	athena.test.assert_exit_code.expects_fail "athena.docker.is_current_container_not_running_or_fail"
	athena.test.mock.returns "athena.docker.is_current_container_running" 1
	athena.test.assert_return "athena.docker.is_current_container_not_running_or_fail"
}

function testcase_athena.docker.stop_container()
{
	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock.returns "athena.docker" 1
	athena.test.assert_return.expects_fail "athena.docker.stop_container" "mycontainer"

	athena.test.mock.returns "athena.docker" 0
	athena.test.assert_return "athena.docker.stop_container" "mycontainer"

	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.mock.returns "athena.docker" 1
	local output=$(athena.docker.stop_container "mycontainer" | tr -d '\n')
	local expected=$(athena.color.print_info "Stopping mycontainer" | tr -d '\n')
	athena.test.assert_value "$expected" "$output"

	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.mock.returns "athena.docker" 0
	output=$(athena.docker.stop_container "mycontainer" | tr -d '\n')
	local line1=$(athena.color.print_info "Stopping mycontainer" | tr -d '\n')
	local line2=$(athena.color.print_info "mycontainer is now stopped" | tr -d '\n')
	expected="$line1$line2"
	athena.test.assert_value "$expected" "$output"
}

function testcase_athena.docker.get_build_args()
{
	local tmpfile
	tmpfile="$(athena.test.create_tempfile)"
	echo "varA=valA" > "$tmpfile"
	echo "varB=valB" >> "$tmpfile"
	athena.test.mock.outputs "athena.plugin.get_environment_build_file" "$tmpfile"
	athena.test.assert_output "athena.docker.get_build_args" "--build-arg varA=valA --build-arg varB=valB"

	echo > "$tmpfile"
	athena.test.assert_output "athena.docker.get_build_args" ""

	echo "varA=valA" > "$tmpfile"
	echo 'varB="valB with whitespaces"' >> "$tmpfile"
	athena.test.assert_output "athena.docker.get_build_args" '--build-arg varA=valA --build-arg varB="valB with whitespaces"'

	rm "$tmpfile"
}

function testcase_athena.docker.stop_all_containers()
{
	athena.test.mock.returns "athena.color.print_debug" 0
	athena.test.mock.outputs "athena.os.get_instance" "myinstance"
	athena.test.mock.outputs "athena._get_list_of_docker_containers" "container1 container2-myinstance"
	athena.test.mock "athena.docker.stop_container" "_my_docker_fake_stop_container"
	athena.test.assert_output "athena.docker.stop_all_containers" "stopping container2-myinstance"

	local output
	output=$(athena.docker.stop_all_containers "arg1" "--global")
	athena.test.assert_return "athena.argument.string_contains" "$output" "stopping container1"
	athena.test.assert_return "athena.argument.string_contains" "$output" "stopping container2-myinstance"
}

function testcase_athena.docker.remove_container_and_image()
{
	athena.test.assert_exit_code.expects_fail "athena.docker.remove_container_and_image"
	athena.test.assert_exit_code.expects_fail "athena.docker.remove_container_and_image" "tag"
	athena.test.mock.outputs "athena.docker.get_tag_and_version" "mycontainer1"
	athena.test.mock "athena.docker.rm" "_my_docker_echo"
	athena.test.mock "athena.docker.rmi" "_my_docker_echo"
	athena.test.mock.outputs "athena.docker.images" "mycontainer1 1.0.0"

	athena.test.assert_output "athena.docker.remove_container_and_image" "mycontainer1-f mycontainer1:1.0.0" "mycontainer1" "1.0.0"
}

function testcase_athena.docker.build_from_plugin()
{
	tmpdir=$(athena.test.create_tempdir)
	mkdir "$tmpdir/mysubplg"
	echo > "$tmpdir/mysubplg/Dockerfile"

	athena.test.mock "athena.docker.build_container" "_my_docker_echo"
	athena.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	athena.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	athena.test.mock.returns "athena.plugin.set_plugin" 0

	athena.test.assert_output "athena.docker.build_from_plugin" "mytag 1.2.3 $tmpdir/mysubplg" "plg" "mysubplg" "1.2.3"

	rm -r $tmpdir
}

function testcase_athena.docker.cleanup()
{
	athena.test.mock.outputs "athena.plugin.get_container_name" "mycontainer"
	athena.test.mock.returns "athena.docker.inspect" 0
	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock.exits "athena.docker.rm" 1
	athena.test.assert_exit_code.expects_fail "athena.docker.cleanup"

	athena.test.mock.exits "athena.docker.rm" 0
	athena.test.assert_exit_code "athena.docker.cleanup"

	athena.test.mock.exits "athena.docker.inspect" 1
	athena.test.assert_exit_code.expects_fail "athena.docker.cleanup"

	athena.test.mock.returns "athena.docker.inspect" 0
	athena.test.mock.exits "athena.docker.is_container_running" 1
	athena.test.assert_exit_code.expects_fail "athena.docker.cleanup"

}

function testcase_athena.docker._validate_if_build_args_exist()
{
	local tmpfile
	tmpfile="$(athena.test.create_tempfile)"
	echo "ARG varA=valA" > "$tmpfile"
	echo "ARG varB" >> "$tmpfile"

	local tmpfile_build_args
	tmpfile_build_args="$(athena.test.create_tempfile)"

	echo "varA=valA" > $tmpfile_build_args
	echo "varB=valB" >> $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo "varA=valA" > $tmpfile_build_args
	echo 'varB="valB with whitespaces"' >> $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo "varB=valB" > $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo " varB=valB" > $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"
	echo "	varB=valB" > $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"
	echo "	  varB=valB" > $tmpfile_build_args
	athena.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	athena.test.mock.outputs "athena.os.exit_with_msg" "exit_with_msg was called"

	echo "varA=valA" > $tmpfile_build_args
	athena.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	echo > $tmpfile_build_args
	athena.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	echo "varA=varB" > $tmpfile_build_args
	echo "somethin=else" >> $tmpfile_build_args
	athena.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	rm "$tmpfile"
}

function testcase_athena.docker.build_container()
{
	athena.test.mock "athena.docker.build" "_my_docker_echo"
	athena.test.mock.returns "athena.color.print_info" 0
	athena.test.mock.returns "athena.color.print_debug" 0
	athena.test.mock.returns "athena.docker.image_exists" 1

	athena.test.mock.returns "athena.docker._validate_if_build_args_exist" 0
	athena.test.assert_output "athena.docker.build_container" "-t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"

	athena.test.mock.exits "athena.docker._validate_if_build_args_exist" 1
	athena.test.assert_exit_code.expects_fail "athena.docker.build_container" "-t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"

	athena.test.mock.returns "athena.docker._validate_if_build_args_exist" 0
	athena.test.mock.outputs "athena.docker.get_build_args" "--build-arg myarg1=val1 --build-arg myarg2=val2"
	athena.test.assert_output "athena.docker.build_container" "--build-arg myarg1=val1 --build-arg myarg2=val2 -t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"
}

function testcase_athena.docker.wait_for_string_in_container_logs()
{
	athena.test.mock.outputs "athena.docker.logs" "mymessage"
	athena.test.mock "athena.color.print_info" "_my_docker_echo"
	athena.test.assert_output "athena.docker.wait_for_string_in_container_logs" "mycomponent is UP" "mycomponent" "mymessage"

	# NOTE: no tests for the waiting need to be done
}

function testcase_athena.docker.get_ip()
{
	local curr_is_mac=$ATHENA_IS_MAC
	athena.test.mock.outputs "athena._get_docker_ip_for_mac" "IP for mac"
	athena.test.mock.outputs "athena._get_docker_ip_for_linux" "IP for linux"

	ATHENA_IS_MAC=0
	athena.test.assert_output "athena.docker.get_ip" "IP for linux"

	ATHENA_IS_MAC=1
	athena.test.assert_output "athena.docker.get_ip" "IP for mac"

	ATHENA_IS_MAC=$curr_is_mac
}

function testcase_athena.docker.get_options()
{
	local curr_docker_opts="$ATHENA_DOCKER_OPTS"
	ATHENA_DOCKER_OPTS="--env varA=valA"
	athena.test.assert_output "athena.docker.get_options" "--env varA=valA"
	ATHENA_DOCKER_OPTS="$curr_extra_opts"
}

function testcase_athena.docker.add_envs_with_prefix()
{
	athena.test.assert_exit_code.expects_fail "athena.docker.add_envs_with_prefix" ""

	athena.test.mock "athena.docker.add_option" "_my_docker_echo"

	export mocked_env1="val1"
	export mocked_env2="val2"
	athena.test.assert_output "athena.docker.add_envs_with_prefix" "--env mocked_env1=val1--env mocked_env2=val2" "mocked_env"
	athena.test.assert_output "athena.docker.add_envs_with_prefix" "" "otherprefix"
	unset mocked_env1
	unset mocked_env2
}

function testcase_athena.docker.print_or_follow_container_logs()
{
	athena.test.assert_exit_code.expects_fail "athena.docker.print_or_follow_container_logs" ""

	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.assert_output "athena.docker.print_or_follow_container_logs" "" "mycontainer"

	athena.test.mock "athena.color.print_info" "_void"
	athena.test.mock "athena.docker" "_my_docker_echo"
	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.assert_output "athena.docker.print_or_follow_container_logs" "logs mycontainer" "mycontainer"
	athena.test.assert_output "athena.docker.print_or_follow_container_logs" "logs -f mycontainer" "mycontainer" "-f"

	local containers="container1 container2 container3"
	local expected_output=$(cat <<EOF
logs container1
logs container2
logs container3
EOF
)
	athena.test.mock "athena.docker" "_echo_all_arguments_in_newline"
	athena.test.assert_output "athena.docker.print_or_follow_container_logs" "$expected_output" "$containers"

	expected_output=$(cat <<EOF
logs -f container1
logs -f container2
logs -f container3
EOF
)
	athena.test.assert_output "athena.docker.print_or_follow_container_logs" "$expected_output" "$containers" "-f"
}

# aux functions
function _void()
{
	return
}
function _echo_all_arguments_in_newline()
{
	echo "$@"
}
function _my_docker_echo()
{
	echo -n "$@"
}
function _my_docker_fake_stop_container()
{
	echo -n "stopping $@"
}
function _my_docker_fake_docker_exec()
{
	case $1 in
		"ps")
			if [[ $2 = "-a" ]]; then
				echo "mycontainer not down"
			else
				echo
			fi
			;;
		"rm")
			exit 1
			;;
	esac
}
