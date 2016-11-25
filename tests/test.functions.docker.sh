function testcase_athena.docker.run_container()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.run_container"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.run_container" "one"
	bashunit.test.mock "athena.docker.run" "_my_docker_echo"

	athena.docker.set_options
	athena.docker.add_env "A" "B"
	athena.argument.set_arguments
	bashunit.test.assert_output "athena.docker.run_container" "--name container_name --env A=B tag:version" "container_name" "tag:version"
	athena.argument.set_arguments one two three
	bashunit.test.assert_output "athena.docker.run_container" "--name container_name --env A=B tag:version one two three" "container_name" "tag:version"
}

function testcase_athena.docker.run_container_with_default_router()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router" "one"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.run_container_with_default_router" "one" "two"
	bashunit.test.mock "athena.docker.run" "_my_docker_echo"
	bashunit.test.mock.outputs "athena.docker.get_ip" "127.0.0.1"
	bashunit.test.mock.outputs "athena.os.get_host_ip" "127.0.0.1"
	bashunit.test.mock.outputs "athena.plugin.get_shared_lib_dir" "/path/to/shared/dir"
	bashunit.test.mock.returns "athena.fs.dir_exists_or_fail" 0
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "/path/to/plugin/dir"
	bashunit.test.mock.outputs "athena.plugin.get_bootstrap_dir" "/path/to/bootstrap/dir"

	athena.docker.set_options
	athena.docker.add_option "OTHER_OPTIONS"
	athena.argument.set_arguments one two three
	bashunit.test.assert_output "athena.docker.run_container_with_default_router" \
		"OTHER_OPTIONS --env ATHENA_PLUGIN=base --env ATHENA_BASE_SHARED_LIB_DIR=/opt/shared --env BIN_DIR=/opt/athena/bin --env CMD_DIR=/opt/athena/bin/cmd --env LIB_DIR=/opt/athena/bin/lib --env ATHENA_DOCKER_IP=127.0.0.1 --env ATHENA_DOCKER_HOST_IP=127.0.0.1 -v /path/to/shared/dir:/opt/shared -v /path/to/plugin/dir:/opt/athena -v /path/to/bootstrap/dir:/opt/bootstrap --name mycontainer mytag:version /opt/bootstrap/router.sh mycommand one two three" \
		"mycontainer" "mytag:version" "mycommand"
}

function testcase_athena.docker.add_option()
{
	athena.docker.set_options
	athena.docker.add_option --env A=B
	bashunit.test.assert_output "athena.docker.get_options" "--env A=B"
	athena.docker.add_option --env C=D
	bashunit.test.assert_output "athena.docker.get_options" "--env A=B --env C=D"
	athena.docker.add_option --env 'E="F with spaces"'
	bashunit.test.assert_output "athena.docker.get_options" '--env A=B --env C=D --env E="F with spaces"'
	athena.docker.set_options
	bashunit.test.assert_return "athena.docker.add_option" "one"
}

function testcase_athena.docker.is_default_router_to_be_used()
{
	local curr_no_default_router=$ATHENA_DOCKER_NO_DEFAULT_ROUTER

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=0
	bashunit.test.assert_return "athena.docker.is_default_router_to_be_used"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=1
	bashunit.test.assert_return.expects_fail "athena.docker.is_default_router_to_be_used"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=$curr_no_default_router
}

function testcase_athena.docker.has_option()
{
	athena.docker.set_options -d
	bashunit.test.assert_return "athena.docker.has_option" "-d"

	athena.docker.set_options "--env A=B"
	bashunit.test.assert_return.expects_fail "athena.docker.has_option" "-d"
	bashunit.test.assert_return "athena.docker.has_option" "--env A=B"

	athena.docker.set_options "-daemon"
	bashunit.test.assert_return.expects_fail "athena.docker.has_option" "--env A=B"
	bashunit.test.assert_return "athena.docker.has_option" "-daemon"

	athena.docker.set_options "--env A=\"something with spaces\""
	bashunit.test.assert_return "athena.docker.has_option" "--env A=\"something with spaces\""
}

function testcase_athena.docker.set_options()
{
	athena.docker.set_options "-d --env A=B"
	bashunit.test.assert_value "$(athena.docker.get_options)" "-d --env A=B"

	athena.docker.set_options ""
	bashunit.test.assert_value "$(athena.docker.get_options)" ""
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
	bashunit.test.assert_return "athena.docker.has_option" "-d"

	athena.docker.set_options ""
	bashunit.test.assert_return.expects_fail "athena.docker.has_option" "-d"

	athena.docker.set_options "$curr_extra_opts"
}

function testcase_athena.docker.add_env()
{
	athena.docker.set_options
	athena.docker.add_env "A" "C"
	bashunit.test.assert_value "--env A=C" "${ATHENA_DOCKER_OPTS[*]}"
	athena.docker.set_options
	athena.docker.add_env "B" "\"value with spaces\""
	bashunit.test.assert_value "--env B=\"value with spaces\"" "${ATHENA_DOCKER_OPTS[*]}"
}

function testcase_athena.docker.add_daemon()
{
	athena.docker.set_options
	athena.docker.add_daemon
	bashunit.test.assert_value "-d" "${ATHENA_DOCKER_OPTS[@]}"
}

function testcase_athena.docker.add_autoremove()
{
	athena.docker.set_options
	athena.docker.add_autoremove
	bashunit.test.assert_value "--rm=true" "${ATHENA_DOCKER_OPTS[@]}"
}

function testcase_athena.docker.handle_run_type()
{
	athena.docker.set_options
	athena.docker.add_daemon
	athena.docker.handle_run_type
	bashunit.test.assert_return.expects_fail "athena.argument.string_contains" "${ATHENA_DOCKER_OPTS[@]}" "--rm=true"

	athena.docker.set_options --rm
	athena.docker.handle_run_type
	bashunit.test.assert_return.expects_fail "athena.argument.string_contains" "${ATHENA_DOCKER_OPTS[@]}" "--rm=true"

	athena.docker.set_options
	athena.docker.handle_run_type
	bashunit.test.assert_return "athena.argument.string_contains" "${ATHENA_DOCKER_OPTS[@]}" "--rm=true"
}

function testcase_athena.docker.mount_dir()
{
	local tmp_dir="$(bashunit.test.create_tempdir)"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir" "$tmp_dir"

	athena.docker.set_options
	athena.docker.mount_dir "$tmp_dir" "$tmp_dir"
	bashunit.test.assert_value "-v $tmp_dir:$tmp_dir" "$(athena.docker.get_options)"

	rm -r "$tmp_dir"
}

function testcase_athena.docker.mount_dir_from_plugin()
{
	athena.docker.set_options
	local tmp_dir="$(bashunit.test.create_tempdir)"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "$tmp_dir"

	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "$tmp_dir"

	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"

	local plg_dir="$(bashunit.test.create_tempdir)"
	mkdir -p "$plg_dir/plg"
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "$plg_dir/plg"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"

	mkdir -p "$plg_dir/plg/xpto"
	bashunit.test.assert_return "athena.docker.mount_dir_from_plugin" "xpto" "$tmp_dir"

	athena.docker.mount_dir_from_plugin "xpto" "$tmp_dir"
	bashunit.test.assert_value "-v $plg_dir/plg/xpto:${tmp_dir}" "$(athena.docker.get_options)"
	rm -r "$plg_dir"
	rm -r "$tmp_dir"
}

function testcase_athena.docker.set_no_default_router()
{
	local curr_no_default_router=$ATHENA_DOCKER_NO_DEFAULT_ROUTER

	athena.docker.set_no_default_router
	bashunit.test.assert_value "$ATHENA_DOCKER_NO_DEFAULT_ROUTER" "1"

	ATHENA_DOCKER_NO_DEFAULT_ROUTER=$curr_no_default_router
}

function testcase_athena.docker.image_exists()
{
	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_return.expects_fail "athena.docker.image_exists" "mytag" "1.0.0"
	bashunit.test.mock.outputs "athena.docker" "mytag 1.0.0"
	bashunit.test.assert_return "athena.docker.image_exists" "mytag" "1.0.0"

}

function testcase_athena.docker.is_container_running()
{
	bashunit.test.mock.outputs "athena.docker" "mycontainer"
	bashunit.test.assert_return "athena.docker.is_container_running" "mycontainer"

	bashunit.test.mock.outputs "athena.docker" ""
	bashunit.test.assert_return.expects_fail "athena.docker.is_container_running" "mycontainer"

	bashunit.test.mock "athena.docker" "_my_docker_fake_docker_exec"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.is_container_running" "rm was called" "mycontainer"
}

function testcase_athena.docker.is_current_container_running()
{
	bashunit.test.mock.outputs "athena.plugin.get_container_name" "mycontainer123"
	bashunit.test.mock "athena.docker.is_container_running" "_my_docker_echo"
	bashunit.test.assert_output "athena.docker.is_current_container_running" "mycontainer123"
}

function testcase_athena.docker.is_current_container_not_running_or_fail()
{
	bashunit.test.mock.returns "athena.docker.is_current_container_running" 0
	bashunit.test.assert_exit_code.expects_fail "athena.docker.is_current_container_not_running_or_fail"
	bashunit.test.mock.returns "athena.docker.is_current_container_running" 1
	bashunit.test.assert_return "athena.docker.is_current_container_not_running_or_fail"
}

function testcase_athena.docker.stop_container()
{
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_return.expects_fail "athena.docker.stop_container" "mycontainer"

	bashunit.test.mock.returns "athena.docker" 0
	bashunit.test.assert_return "athena.docker.stop_container" "mycontainer"

	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.mock.returns "athena.docker" 1
	local output=$(athena.docker.stop_container "mycontainer" 2>&1 | tr -d '\n')
	local expected=$(athena.color.print_info "Stopping mycontainer" 2>&1 | tr -d '\n')
	bashunit.test.assert_value "$expected" "$output"

	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.mock.returns "athena.docker" 0
	output=$(athena.docker.stop_container "mycontainer" 2>&1 | tr -d '\n')
	local line1=$(athena.color.print_info "Stopping mycontainer" 2>&1 | tr -d '\n')
	local line2=$(athena.color.print_info "mycontainer is now stopped" 2>&1 | tr -d '\n')
	expected="$line1$line2"
	bashunit.test.assert_value "$expected" "$output"
}

function testcase_athena.docker.get_build_args()
{
	local tmpfile
	tmpfile="$(bashunit.test.create_tempfile)"
	echo "varA=valA" > "$tmpfile"
	echo "varB=valB" >> "$tmpfile"
	bashunit.test.mock.outputs "athena.plugin.get_environment_build_file" "$tmpfile"
	local -a myargs=()
	local -a expected=(--build-arg varA=valA --build-arg varB=valB)
	athena.docker.get_build_args "myargs"
	bashunit.test.assert_array "expected" "myargs"
	echo > "$tmpfile"

	local -a myargs=()
	local -a expected=()
	athena.docker.get_build_args "myargs"
	bashunit.test.assert_array "expected" "myargs"

	echo "varA=valA" > "$tmpfile"
	echo 'varB="valB with whitespaces"' >> "$tmpfile"

	local -a myargs=()
	local -a expected=(--build-arg varA=valA --build-arg 'varB="valB with whitespaces"')
	athena.docker.get_build_args "myargs"
	bashunit.test.assert_array "expected" "myargs"

	rm "$tmpfile"
}

function testcase_athena.docker.stop_all_containers()
{
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.outputs "athena.os.get_instance" "myinstance"
	bashunit.test.mock.outputs "athena._get_list_of_docker_containers" "container1 container2-myinstance"
	bashunit.test.mock "athena.docker.stop_container" "_my_docker_fake_stop_container"
	bashunit.test.assert_output "athena.docker.stop_all_containers" "stopping container2-myinstance"

	local output
	output=$(athena.docker.stop_all_containers "arg1" "--global")
	bashunit.test.assert_return "athena.argument.string_contains" "$output" "stopping container1"
	bashunit.test.assert_return "athena.argument.string_contains" "$output" "stopping container2-myinstance"
}

function testcase_athena.docker.remove_container_and_image()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.remove_container_and_image"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.remove_container_and_image" "tag"
	bashunit.test.mock.outputs "athena.docker.get_tag_and_version" "mycontainer1"
	bashunit.test.mock "athena.docker.rm" "_my_docker_echo"
	bashunit.test.mock "athena.docker.rmi" "_my_docker_echo"
	bashunit.test.mock.outputs "athena.docker.images" "mycontainer1 1.0.0"

	bashunit.test.assert_output "athena.docker.remove_container_and_image" "mycontainer1-f mycontainer1:1.0.0" "mycontainer1" "1.0.0"
}

function testcase_athena.docker.build_from_plugin()
{
	tmpdir=$(bashunit.test.create_tempdir)
	mkdir "$tmpdir/mysubplg"
	echo > "$tmpdir/mysubplg/Dockerfile"

	bashunit.test.mock "athena.docker.build_container" "_my_docker_echo"
	bashunit.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	bashunit.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	bashunit.test.mock.returns "athena.plugin.set_plugin" 0

	bashunit.test.assert_output "athena.docker.build_from_plugin" "mytag 1.2.3 $tmpdir/mysubplg" "plg" "mysubplg" "1.2.3"

	rm -r $tmpdir
}

function testcase_athena.docker.cleanup()
{
	bashunit.test.mock.outputs "athena.plugin.get_container_name" "mycontainer"
	bashunit.test.mock.returns "athena.docker.inspect" 0
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock.exits "athena.docker.rm" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.cleanup"

	bashunit.test.mock.exits "athena.docker.rm" 0
	bashunit.test.assert_exit_code "athena.docker.cleanup"

	bashunit.test.mock.exits "athena.docker.inspect" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.cleanup"

	bashunit.test.mock.returns "athena.docker.inspect" 0
	bashunit.test.mock.exits "athena.docker.is_container_running" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.cleanup"

}

function testcase_athena.docker._validate_if_build_args_exist()
{
	local tmpfile
	tmpfile="$(bashunit.test.create_tempfile)"
	echo "ARG varA=valA" > "$tmpfile"
	echo "ARG varB" >> "$tmpfile"

	local tmpfile_build_args
	tmpfile_build_args="$(bashunit.test.create_tempfile)"

	echo "varA=valA" > $tmpfile_build_args
	echo "varB=valB" >> $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo "varA=valA" > $tmpfile_build_args
	echo 'varB="valB with whitespaces"' >> $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo "varB=valB" > $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	echo " varB=valB" > $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"
	echo "	varB=valB" > $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"
	echo "	  varB=valB" > $tmpfile_build_args
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	bashunit.test.mock.outputs "athena.os.exit_with_msg" "exit_with_msg was called"

	echo "varA=valA" > $tmpfile_build_args
	bashunit.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	echo > $tmpfile_build_args
	bashunit.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	echo "varA=varB" > $tmpfile_build_args
	echo "somethin=else" >> $tmpfile_build_args
	bashunit.test.assert_output "athena.docker._validate_if_build_args_exist" "exit_with_msg was called" "$tmpfile" "$tmpfile_build_args"

	echo "RUN echo {ANDROID_TARGET}.conf" > "$tmpfile"
	echo "varA=valA" > $tmpfile_build_args
	bashunit.test.unmock "athena.os.exit_with_msg"
	bashunit.test.assert_exit_code "athena.docker._validate_if_build_args_exist" "$tmpfile" "$tmpfile_build_args"

	rm "$tmpfile"
}

function testcase_athena.docker.build_container()
{
	bashunit.test.mock "athena.docker.build" "_my_docker_echo"
	bashunit.test.mock.returns "athena.color.print_info" 0
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.returns "athena.docker.image_exists" 1

	bashunit.test.mock.returns "athena.docker._validate_if_build_args_exist" 0
	bashunit.test.assert_output "athena.docker.build_container" "-t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"

	bashunit.test.mock.exits "athena.docker._validate_if_build_args_exist" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.build_container" "-t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"

	bashunit.test.mock.returns "athena.docker._validate_if_build_args_exist" 0
	local tmpfile=$(bashunit.test.create_tempfile)
	bashunit.test.mock.outputs "athena.docker.get_build_args_file" "$tmpfile"
	echo "myarg1=val1" > $tmpfile
	echo "myarg2=val2" >> $tmpfile
	bashunit.test.assert_output "athena.docker.build_container" "--build-arg myarg1=val1 --build-arg myarg2=val2 -t mytag:1.2.3 -f /path/to/docker/Dockerfile /path/to/docker" "mytag" "1.2.3" "/path/to/docker"
	rm $tmpfile
}

function testcase_athena.docker.wait_for_string_in_container_logs()
{
	bashunit.test.mock.outputs "athena.docker.logs" "mymessage"
	bashunit.test.mock "athena.color.print_info" "_my_docker_echo"
	bashunit.test.assert_output "athena.docker.wait_for_string_in_container_logs" "mycomponent is UP" "mycomponent" "mymessage"

	# NOTE: no tests for the waiting need to be done
}

function testcase_athena.docker.get_ip()
{
	local curr_is_mac=$ATHENA_IS_MAC
	bashunit.test.mock.outputs "athena._get_docker_ip_for_mac" "IP for mac"
	bashunit.test.mock.outputs "athena._get_docker_ip_for_linux" "IP for linux"

	ATHENA_IS_MAC=0
	bashunit.test.assert_output "athena.docker.get_ip" "IP for linux"

	ATHENA_IS_MAC=1
	bashunit.test.assert_output "athena.docker.get_ip" "IP for mac"

	ATHENA_IS_MAC=$curr_is_mac
}

function testcase_athena.docker.get_options()
{
	athena.docker.set_options --env varA=valA
	bashunit.test.assert_output "athena.docker.get_options" "--env varA=valA"

	local docker_opts
	athena.docker.get_options "docker_opts"
	bashunit.test.assert_array ATHENA_DOCKER_OPTS docker_opts
}

function testcase_athena.docker.add_envs_with_prefix()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.add_envs_with_prefix" ""

	bashunit.test.mock "athena.docker.add_option" "_my_docker_echo"

	export mocked_env1="val1"
	export mocked_env2="val2"
	bashunit.test.assert_output "athena.docker.add_envs_with_prefix" "--env mocked_env1=val1--env mocked_env2=val2" "mocked_env"
	bashunit.test.assert_output "athena.docker.add_envs_with_prefix" "" "otherprefix"
	unset mocked_env1
	unset mocked_env2
}

function testcase_athena.docker.add_envs_from_file()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.add_envs_from_file"
	bashunit.test.assert_exit_code.expects_fail "athena.docker.add_envs_from_file" "/path/to/unexisting/file"

	local tmpfile=$(bashunit.test.create_tempfile)
	local content=$(cat <<EOF
ENV1=myenv1value
ENV2=myenv2value
EOF
)
	echo "$content" > "$tmpfile"
	athena.docker.set_options
	athena.docker.add_envs_from_file "$tmpfile"
	bashunit.test.assert_output "athena.docker.get_options" "--env ENV1=myenv1value --env ENV2=myenv2value"
local content=$(cat <<EOF
ENV3="myenv3value with spaces"
ENV4="myenv4value also with spaces"
EOF
)
	echo "$content" > "$tmpfile"
	athena.docker.set_options
	athena.docker.add_envs_from_file "$tmpfile"
	bashunit.test.assert_output "athena.docker.get_options" '--env ENV3="myenv3value with spaces" --env ENV4="myenv4value also with spaces"'

	rm $tmpfile
}

function testcase_athena.docker.print_or_follow_container_logs()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.print_or_follow_container_logs" ""

	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.assert_output "athena.docker.print_or_follow_container_logs" "" "mycontainer"

	bashunit.test.mock "athena.color.print_info" "_void"
	bashunit.test.mock "athena.docker" "_my_docker_echo"
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.assert_output "athena.docker.print_or_follow_container_logs" "logs mycontainer" "mycontainer"
	bashunit.test.assert_output "athena.docker.print_or_follow_container_logs" "logs -f mycontainer" "mycontainer" "-f"

	local containers="container1 container2 container3"
	local expected_output=$(cat <<EOF
logs container1
logs container2
logs container3
EOF
)
	bashunit.test.mock "athena.docker" "_echo_all_arguments_in_newline"
	bashunit.test.assert_output "athena.docker.print_or_follow_container_logs" "$expected_output" "$containers"

	expected_output=$(cat <<EOF
logs -f container1
logs -f container2
logs -f container3
EOF
)
	bashunit.test.assert_output "athena.docker.print_or_follow_container_logs" "$expected_output" "$containers" "-f"
}

function testcase_athena.docker.get_ip_for_container()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.get_ip_for_container"

	bashunit.test.mock.outputs "athena.docker.inspect" "172.0.0.1"
	bashunit.test.assert_output "athena.docker.get_ip_for_container" "172.0.0.1" "mycontainer"

	bashunit.test.mock.returns "athena.docker.inspect" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.get_ip_for_container" "mycontainer"
}

function testcase_athena.docker.volume_exists()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.volume_exists"

	local myoutput=
	bashunit.test.mock "athena.docker" "_save_args_to_var"
	athena.docker.volume_exists "somevolumename"
	bashunit.test.assert_value "$myoutput" "volume inspect somevolumename"

	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_return.expects_fail "athena.docker.volume_exists" "somevolumename"

	bashunit.test.mock.returns "athena.docker" 0
	bashunit.test.assert_return "athena.docker.volume_exists" "somevolumename"
}

function testcase_athena.docker.volume_create()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.volume_create"

	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.volume_create" "somerandomvolume"

	bashunit.test.mock.returns "athena.docker" 0
	bashunit.test.assert_return "athena.docker.volume_create" "somerandomvolume"
}

function testcase_athena.docker.volume_exists_or_create()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.volume_exists_or_create"

	bashunit.test.mock.returns "athena.docker.volume_exists" 0
	bashunit.test.assert_return "athena.docker.volume_exists_or_create" "somerandomvolume"

	bashunit.test.mock.returns "athena.docker.volume_exists" 1
	bashunit.test.mock.returns "athena.docker.volume_create" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.volume_exists_or_create" "somerandomvolume"

	bashunit.test.mock.returns "athena.docker.volume_exists" 0
	bashunit.test.assert_return "athena.docker.volume_exists_or_create" "somerandomvolume"
}

function testcase_athena.docker.network_exists()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.network_exists"

	local myoutput=
	bashunit.test.mock "athena.docker" "_save_args_to_var"
	athena.docker.network_exists "some_network_name"
	bashunit.test.assert_value "$myoutput" "network inspect some_network_name"

	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_return.expects_fail "athena.docker.network_exists" "some_network_name"

	bashunit.test.mock.returns "athena.docker" 0
	bashunit.test.assert_return "athena.docker.network_exists" "some_network_name"
}

function testcase_athena.docker.network_create()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.network_create"

	local myoutput=
	bashunit.test.mock "athena.docker" "_save_args_to_var"
	athena.docker.network_create "some_network_name" -d bridge --dns 1.2.3
	bashunit.test.assert_value "$myoutput" "network create -d bridge --dns 1.2.3 some_network_name"

	athena.docker.network_create "some_network_name"
	bashunit.test.assert_value "$myoutput" "network create some_network_name"

	bashunit.test.mock.returns "athena.docker" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.network_create" "somerandomnetwork"

	bashunit.test.mock.returns "athena.docker" 0
	bashunit.test.assert_return "athena.docker.network_create" "somerandomnetwork"
}

function testcase_athena.docker.network_exists_or_create()
{
	bashunit.test.assert_exit_code.expects_fail "athena.docker.network_exists_or_create"

	bashunit.test.mock.returns "athena.docker.network_exists" 0
	bashunit.test.assert_return "athena.docker.network_exists_or_create" "somerandomnetwork"

	bashunit.test.mock.returns "athena.docker.network_exists" 1
	bashunit.test.mock.returns "athena.docker.network_create" 1
	bashunit.test.assert_exit_code.expects_fail "athena.docker.network_exists_or_create" "somerandomnetwork"
}

function testcase_athena.docker.is_auto_cleanup_active()
{
	ATHENA_DOCKER_AUTO_CLEANUP=1
	bashunit.test.assert_return "athena.docker.is_auto_cleanup_active"

	ATHENA_DOCKER_AUTO_CLEANUP=0
	bashunit.test.assert_return.expects_fail "athena.docker.is_auto_cleanup_active"
}

function testcase_athena.docker.disable_auto_cleanup()
{
	ATHENA_DOCKER_AUTO_CLEANUP=1
	athena.docker.disable_auto_cleanup
	bashunit.test.assert_return.expects_fail "athena.docker.is_auto_cleanup_active"
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
function _save_args_to_var()
{
	myoutput="$@"
}
