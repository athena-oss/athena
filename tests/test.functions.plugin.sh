function testcase_athena.plugin.run_command()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_command"
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1"
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1" "/no/real/path"

	local tmpdir
	tmpdir=$(athena.test.create_tempdir)
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1" "$tmpdir"

	echo "echo hello" > "$tmpdir/cmd1_pre.sh"
	athena.test.assert_output "athena.plugin.run_command" "hello" "cmd1" "$tmpdir"

	rm "$tmpdir/cmd1_pre.sh"
	touch "$tmpdir/cmd1.sh"
	athena.test.mock.outputs "athena.plugin.run_container" "ola"
	athena.test.assert_output "athena.plugin.run_command" "ola" "cmd1" "$tmpdir"

	rm "$tmpdir/cmd1.sh"
	echo "echo hallo" > "$tmpdir/cmd1_post.sh"
	athena.test.assert_output "athena.plugin.run_command" "hallo" "cmd1" "$tmpdir"

	rm -r $tmpdir
}

function testcase_athena.plugin.run_container()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_container" ""

	athena.test.mock "athena.docker.exec" "_my_plugin_echo"
	athena.argument.set_arguments one two three
	athena.test.mock.outputs "athena.docker.get_options" "--env varA=valA"
	athena.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	athena.test.mock.outputs "athena.plugin.get_image_version" "1.2.3"
	athena.test.mock.outputs "athena.plugin.get_container_name" "mycontainer"
	athena.test.mock.returns "athena.color.print_debug" 0
	athena.test.mock.returns "athena.os._bootstrap" 0
	athena.test.mock.returns "athena.docker.handle_run_type" 0

	athena.test.mock.returns "athena.docker.image_exists" 1
	athena.test.assert_exit_code.expects_fail "athena.plugin.run_container" "command"

	athena.os.enable_verbose_mode
	athena.test.mock.returns "athena.docker.image_exists" 0
	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.assert_output "athena.plugin.run_container" "-i mycontainer /opt/shared/router.sh command one two three" "command"

	athena.test.mock "athena.docker.run" "_my_plugin_echo"

	# using default router and container running
	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.mock.returns "athena.docker.is_default_router_to_be_used" 0
	athena.test.mock.returns "athena.color.print_debug" 0
	athena.test.mock.outputs "athena.docker.exec" "already running default router"
	athena.test.assert_output "athena.plugin.run_container" "already running default router" "mycommand"

	# using default router
	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock.returns "athena.docker.is_default_router_to_be_used" 0
	athena.test.mock.returns "athena.color.print_info" 0
	athena.test.mock.outputs "athena.docker.run_container_with_default_router" "starting container with default router"
	athena.test.assert_output "athena.plugin.run_container" "starting container with default router" "mycommand"

	# not using default router and container running
	athena.test.mock.returns "athena.docker.is_default_router_to_be_used" 1
	athena.test.mock.returns "athena.docker.is_container_running" 0
	athena.test.mock.returns "athena.color.print_debug" 0
	athena.test.mock.outputs "athena.docker.exec" "already running not default router"
	athena.test.assert_output "athena.plugin.run_container" "already running not default router" "mycommand"
	# not using default router
	athena.test.mock.returns "athena.docker.is_default_router_to_be_used" 1
	athena.test.mock.returns "athena.docker.is_container_running" 1
	athena.test.mock.outputs "athena.docker.run_container" "starting new container"
	athena.test.assert_output "athena.plugin.run_container" "starting new container" "mycommand"
}

function testcase_athena.plugin.get_shared_lib_dir()
{
	local curr_shared_lib_dir=$ATHENA_BASE_SHARED_LIB_DIR
	ATHENA_BASE_SHARED_LIB_DIR="/path/to/shared/lib/dir"
	athena.test.assert_output "athena.plugin.get_shared_lib_dir" "/path/to/shared/lib/dir"
	ATHENA_BASE_SHARED_LIB_DIR=$curr_shared_lib_dir
}

function testcase_athena.plugin.get_plugins_dir()
{
	local curr_plgs_dir=$ATHENA_PLGS_DIR
	ATHENA_PLGS_DIR="test"
	athena.test.assert_output "athena.plugin.get_plugins_dir" "test"
	ATHENA_PLGS_DIR=$curr_plgs_dir
}

function testcase_athena.plugin.use_external_container_as_daemon()
{
	local curr_athena_instance=$(athena.os.get_instance)

	local curr_is_no_default_router
	if athena.docker.is_default_router_to_be_used ; then
		curr_is_no_default_router=0
	else
		curr_is_no_default_router=1
	fi
	athena.docker.set_options
	athena.plugin.use_external_container_as_daemon "mycontainer"
	athena.test.assert_output "athena.docker.get_options" "-d"
	athena.test.assert_output "athena.docker.is_default_router_to_be_used"
	athena.test.assert_output "athena.plugin.get_container_to_use" "mycontainer"

	athena.plugin.use_external_container_as_daemon "mycontainer" "myinstance"
	athena.test.assert_return "athena.docker.has_option" "-d"
	athena.test.assert_output "athena.docker.is_default_router_to_be_used"
	athena.test.assert_output "athena.plugin.get_container_to_use" "mycontainer"

	athena.test.assert_output "athena.os.get_instance" "myinstance"

	athena.docker.set_options
	athena.os.set_instance "$curr_athena_instance"
	athena.docker.set_no_default_router $curr_is_no_default_router
}

function testcase_athena.plugin.use_container()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.use_container" ""

	local curr_plg_container_to_use=$ATHENA_PLG_CONTAINER_TO_USE
	athena.plugin.use_container "xpto"
	athena.test.assert_value "$ATHENA_PLG_CONTAINER_TO_USE" "xpto"
	ATHENA_PLG_CONTAINER_TO_USE=$curr_plg_container_to_use
}

function testcase_athena.plugin.get_container_to_use()
{
	local curr_plg_container_to_use=$ATHENA_PLG_CONTAINER_TO_USE

	athena.plugin.use_container "xpto"
	athena.test.assert_output "athena.plugin.get_container_to_use" "xpto"

	ATHENA_PLG_CONTAINER_TO_USE=
	athena.test.assert_exit_code.expects_fail "athena.plugin.get_container_to_use"

	ATHENA_PLG_CONTAINER_TO_USE=$curr_plg_container_to_use
}

function testcase_athena.plugin.plugin_exists()
{
	athena.test.assert_exit_code "athena.plugin.plugin_exists" "base"
	athena.test.assert_exit_code.expects_fail "athena.plugin.plugin_exists" "base" "<0.0.0"
	athena.test.assert_exit_code.expects_fail "athena.plugin.plugin_exists" "spinpans$(date +%s)"
}

function testcase_athena.plugin.validate_plugin_name()
{
	athena.test.assert_exit_code "athena.plugin.validate_plugin_name" "base"
	athena.test.assert_exit_code.expects_fail "athena.plugin.validate_plugin_name" ""
}

function testcase_athena.plugin.set_environment()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.set_environment"
	athena.test.assert_exit_code "athena.plugin.set_environment" "default"
}

function testcase_athena.plugin.get_environment()
{
	local curr_athena_plg_environment=$ATHENA_PLG_ENVIRONMENT
	ATHENA_PLG_ENVIRONMENT=
	athena.test.assert_exit_code.expects_fail "athena.plugin.get_environment"

	athena.plugin.set_environment "production"
	athena.test.assert_exit_code "athena.plugin.get_environment"
	athena.test.assert_output "athena.plugin.get_environment" "production"
	ATHENA_PLG_ENVIRONMENT=$curr_athena_plg_environment
}

function testcase_athena.plugin.is_environment_specified()
{
	local curr_athena_plg_environment="$ATHENA_PLG_ENVIRONMENT"
	ATHENA_PLG_ENVIRONMENT=
	athena.test.assert_return.expects_fail "athena.plugin.is_environment_specified"
	athena.plugin.set_environment "production"
	athena.test.assert_return "athena.plugin.is_environment_specified"
	ATHENA_PLG_ENVIRONMENT="$curr_athena_plg_environment"
}

function testcase_athena.plugin.set_image_version()
{
	local curr_athena_plg_image_version="$ATHENA_PLG_IMAGE_VERSION"
	athena.plugin.set_image_version "1.9.1"
	athena.test.assert_value "1.9.1" "$ATHENA_PLG_IMAGE_VERSION"
	athena.test.assert_exit_code.expects_fail "athena.plugin.set_image_version" ""
	athena.test.assert_exit_code.expects_fail "athena.plugin.set_image_version" "a.1.2"
	ATHENA_PLG_IMAGE_VERSION="$curr_athena_plg_image_version"
}

function testcase_athena.plugin.get_image_version()
{
	local curr_athena_plg_image_version="$ATHENA_PLG_IMAGE_VERSION"
	athena.plugin.set_image_version "1.9.1"
	athena.test.assert_output "athena.plugin.get_image_version" "1.9.1"
	ATHENA_PLG_IMAGE_VERSION="$curr_athena_plg_image_version"
}

function testcase_athena.plugin.get_tag_name()
{
	local curr_athena_plg_environment="$ATHENA_PLG_ENVIRONMENT"
	ATHENA_PLG_ENVIRONMENT=
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_image_name "myname"
	athena.plugin.set_plugin "myplugin"
	athena.test.mock.returns "athena.plugin.get_container_to_use" 0
	athena.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin"

	athena.test.mock.outputs "athena.plugin.get_container_to_use" "mycontainer"
	athena.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-mycontainer"

	ATHENA_PLG_ENVIRONMENT="test"
	athena.plugin.set_image_name "myname"
	athena.plugin.set_plugin "myplugin"
	athena.test.mock.returns "athena.plugin.get_container_to_use" 0
	athena.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-test"


	athena.test.mock.outputs "athena.plugin.get_container_to_use" "mycontainer"
	athena.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-mycontainer-test"

	athena.plugin.set_plugin "$curr_plugin"
	ATHENA_PLG_ENVIRONMENT="$curr_athena_plg_environment"
}

function testcase_athena.plugin.set_plugin()
{
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_plugin "myplugin"
	athena.test.assert_value "myplugin" "$ATHENA_PLUGIN"
	athena.plugin.set_plugin "$curr_plugin"
}

function testcase_athena.plugin.get_plugin()
{
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_plugin "myplugin"
	athena.test.assert_output "athena.plugin.get_plugin" "myplugin"
	athena.plugin.set_plugin "$curr_plugin"
}

function testcase_athena.plugin.set_container_name()
{
	local curr_container_name=$(athena.plugin.get_container_name)
	athena.plugin.set_container_name "mycontainer"
	athena.test.assert_value "mycontainer" "$ATHENA_CONTAINER_NAME"
	athena.plugin.set_container_name "$curr_container_name"
}

function testcase_athena.plugin.get_container_name()
{
	local curr_plugin=$(athena.plugin.get_plugin)
	local curr_container_name=$ATHENA_CONTAINER_NAME
	athena.plugin.set_container_name "mycontainer"
	athena.test.assert_output "athena.plugin.get_container_name" "mycontainer"

	ATHENA_CONTAINER_NAME=
	ATHENA_PLG_CONTAINER_TO_USE=
	athena.plugin.set_plugin "myplugin"
	athena.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-$(athena.os.get_instance)"
	ATHENA_CONTAINER_NAME=$curr_container_name
	athena.plugin.set_plugin "$curr_plugin"
	athena.plugin.set_container_name "$curr_container_name"

	ATHENA_CONTAINER_NAME=
	athena.plugin.use_container "myspinpanscontainer"
	athena.plugin.set_plugin "myplugin"
	athena.plugin.use_container "myspinpanscontainer"
	athena.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainer-$(athena.os.get_instance)"
	athena.test.mock.outputs "athena.plugin.get_environment" "myenv"
	athena.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainer-myenv-$(athena.os.get_instance)"

	athena.plugin.use_container "myspinpanscontainer:other"
	athena.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainerother-myenv-$(athena.os.get_instance)"
}

function testcase_athena.plugin.get_plg_version()
{
	tmpdir=$(athena.test.create_tempdir)
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"
	echo "1.2.3" > $tmpdir/version.txt
	athena.test.assert_output "athena.plugin.get_plg_version" "1.2.3"
	rm -r $tmpdir
}

function testcase_athena.plugin.get_plg_dir()
{
	curr_plgs_dir=$ATHENA_PLGS_DIR
	athena.test.assert_exit_code.expects_fail "athena.plugin.get_plg_dir" "mynonexistingplugin"

	tmpdir=$(athena.test.create_tempdir)
	mkdir -p "$tmpdir/plugins/myplugin"
	ATHENA_PLGS_DIR="$tmpdir/plugins"
	athena.test.assert_output "athena.plugin.get_plg_dir" "$tmpdir/plugins/myplugin" "myplugin"

	# testing not passing any plugin which should show
	# the current plugin dir
	mkdir -p "$tmpdir/plugins/myplugin2"
	athena.test.mock.outputs "athena.plugin.get_plg" "myplugin2"
	athena.test.assert_output "athena.plugin.get_plg_dir" "$tmpdir/plugins/myplugin2"

	rm -r $tmpdir
	ATHENA_PLGS_DIR=$curr_plgs_dir
}

function testcase_athena.plugin.get_plg_bin_dir()
{
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "/my/plugin/path"
	athena.test.assert_output "athena.plugin.get_plg_bin_dir" "/my/plugin/path/bin"
}

function testcase_athena.plugin.get_plg_hooks_dir()
{
	athena.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	athena.test.assert_output "athena.plugin.get_plg_hooks_dir" "/my/plugin/path/hooks"
}

function testcase_athena.plugin.get_plg_lib_dir()
{
	athena.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	athena.test.assert_output "athena.plugin.get_plg_lib_dir" "/my/plugin/path/lib"
}

function testcase_athena.plugin.get_plg_cmd_dir()
{
	local curr_plg_cmd_dir=$ATHENA_PLG_CMD_DIR
	ATHENA_PLG_CMD_DIR="/my/plugin/path/cmd"
	athena.test.assert_output "athena.plugin.get_plg_cmd_dir" "/my/plugin/path/cmd"

	ATHENA_PLG_CMD_DIR=
	athena.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	athena.test.assert_output "athena.plugin.get_plg_cmd_dir" "/my/plugin/path/cmd"
	ATHENA_PLG_CMD_DIR=$curr_plg_cmd_dir
}

function testcase_athena.plugin.set_plg_cmd_dir()
{
	local curr_plg_cmd_dir=$ATHENA_PLG_CMD_DIR
	ATHENA_PLG_CMD_DIR="/my/plugin/path/cmd"
	athena.plugin.set_plg_cmd_dir "/my/plugin/path/cmd2"
	athena.test.assert_value "/my/plugin/path/cmd2" "$ATHENA_PLG_CMD_DIR"
	ATHENA_PLG_CMD_DIR=$curr_plg_cmd_dir
}

function testcase_athena.plugin.get_plg_docker_dir()
{
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "/my/plugin/path"
	athena.test.assert_output "athena.plugin.get_plg_docker_dir" "/my/plugin/path/docker"
}

function testcase_athena.plugin.get_image_name()
{
	athena.test.assert_output "athena.plugin.get_image_name" "$ATHENA_PLG_IMAGE_NAME"
}

function testcase_athena.plugin.set_image_name()
{
	curr_image_name=$ATHENA_PLG_IMAGE_NAME
	athena.plugin.set_image_name "myimagename"
	athena.test.assert_value "$ATHENA_PLG_IMAGE_NAME" "myimagename"
	ATHENA_PLG_IMAGE_NAME=$curr_image_name
}

function testcase_athena.plugin.set_environment_build_file()
{
	curr_plg_docker_env_build_file=$ATHENA_PLG_DOCKER_ENV_BUILD_FILE
	athena.plugin.set_environment_build_file "myfile"
	athena.test.assert_value "$ATHENA_PLG_DOCKER_ENV_BUILD_FILE" "myfile"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=$curr_plg_docker_env_build_file
}

function testcase_athena.plugin.get_environment_build_file()
{
	curr_plg_docker_env_build_file=$ATHENA_PLG_DOCKER_ENV_BUILD_FILE
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=""
	athena.test.assert_return.expects_fail "athena.plugin.get_environment_build_file"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE="xpto"
	athena.test.assert_output "athena.plugin.get_environment_build_file" "xpto"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=$curr_plg_docker_env_build_file
}

function testcase_athena.os.is_git_installed()
{
	athena.test.mock.returns "athena.os._which_git" 1
	athena.test.assert_exit_code.expects_fail "athena.os.is_git_installed"

	athena.test.mock.returns "athena.os._which_git" 0
	athena.test.assert_return "athena.os.is_git_installed"
}

function testcase_athena.plugin.check_dependencies()
{
	tmpdir=$(athena.test.create_tempdir)

	mkdir "$tmpdir/myplugin"
	mkdir "$tmpdir/other"
	echo "4.0.0" > "$tmpdir/other/version.txt"
	athena.test.mock.outputs "athena.plugin.get_plugins_dir" "$tmpdir"
	cat << EOF > $tmpdir/myplugin/dependencies.ini
other=4.0.0
EOF
	athena.test.assert_return "athena.plugin.check_dependencies" "myplugin"
	athena.test.assert_exit_code.expects_fail "athena.plugin.check_dependencies" "myplugin2"

	cat << EOF > $tmpdir/myplugin/dependencies.ini
other=5.0.0
EOF
	echo "2.0.0" > "$tmpdir/other/version.txt"
	athena.test.assert_exit_code.expects_fail "athena.plugin.check_dependencies" "myplugin"
	rm "$tmpdir/myplugin/dependencies.ini"
	athena.test.assert_return "athena.plugin.check_dependencies" "myplugin"

	rm -r $tmpdir
}

function testcase_athena.plugin.get_subplg_version()
{
	tmpdir=$(athena.test.create_tempdir)
	mkdir -p "$tmpdir/plg/other"
	echo "1.2.3" > "$tmpdir/plg/other/version.txt"
	athena.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir/plg"

	athena.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version"
	athena.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version" "plg"
	athena.test.assert_output "athena.plugin.get_subplg_version" "1.2.3" "plg" "other"

	rm "$tmpdir/plg/other/version.txt"
	athena.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version" "plg other"

	rm -r $tmpdir
}

function testcase_athena.plugin.handle_environment()
{
	athena.test.mock.returns "athena.plugin.get_environment" 1
	athena.test.assert_return "athena.plugin.handle_environment"

	athena.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	tmpdir=$(athena.test.create_tempdir)
	athena.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	athena.test.mock.returns "athena.plugin.get_container_to_use" 1
	touch "$tmpdir/production.env"
	athena.test.mock.outputs "athena.plugin.get_environment" "production"
	athena.plugin.handle_environment
	athena.test.assert_output "athena.plugin.get_environment_build_file" "$tmpdir/production.env"

	rm "$tmpdir/production.env"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle_environment"

	mkdir "$tmpdir/other"
	athena.test.mock.outputs "athena.plugin.get_container_to_use" "other"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle_environment"
	touch "$tmpdir/other/production.env"
	athena.plugin.handle_environment
	athena.test.assert_output "athena.plugin.get_environment_build_file" "$tmpdir/other/production.env"

	# testing that environment specified is a file
	env_file="$tmpdir/myenv.env"
	touch $env_file
	athena.test.mock.outputs "athena.plugin.get_environment" "$env_file"
	athena.plugin.handle_environment
	athena.test.unmock "athena.plugin.get_environment"
	athena.test.assert_output "athena.plugin.get_environment" "myenv"
	athena.test.assert_output "athena.plugin.get_environment_build_file" "$env_file"

	rm -r $tmpdir
}

function testcase_athena.plugin.build()
{
	athena.test.mock "athena.docker.build_container" "_my_plugin_echo"
	athena.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	athena.test.mock.outputs "athena.plugin.get_plg_docker_dir" "mydockerdir"
	athena.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	athena.test.mock.outputs "athena.plugin.get_image_version" "1.0.0"

	athena.test.assert_output "athena.plugin.build" "mytag 1.0.0 mydockerdir"
}


function testcase_athena.plugin.handle_container()
{
	tmpdir=$(athena.test.create_tempdir)

	athena.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	athena.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	athena.test.mock.returns "athena.plugin.get_container_to_use" 1

	athena.test.assert_return "athena.plugin.handle_container"

	athena.test.mock.outputs "athena.plugin.build" "i am building"
	touch "$tmpdir/Dockerfile"
	athena.test.assert_output "athena.plugin.handle_container" "i am building"

	# try external
	athena.test.mock.outputs "athena.plugin.get_container_to_use" "othercontainer"
	athena.test.assert_return "athena.plugin.handle_container"

	mkdir "$tmpdir/othercontainer"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	touch "$tmpdir/othercontainer/version.txt"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	echo "1.2.3" > "$tmpdir/othercontainer/version.txt"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	touch "$tmpdir/othercontainer/Dockerfile"
	athena.test.mock "athena.docker.build_from_plugin" "_my_plugin_echo"
	athena.test.mock.returns "athena.plugin.set_plugin" 0
	athena.test.assert_exit_code "athena.plugin.handle_container"
	athena.test.assert_output "athena.plugin.handle_container" "myplugin othercontainer 1.2.3"

	athena.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	athena.test.mock.outputs "athena.os.get_instance" "myinstance"
	athena.test.mock.outputs "athena.plugin.get_container_to_use" "othercontainer"
	athena.test.mock.returns "athena.docker.build_from_plugin" 0
	athena.plugin.handle_container
	athena.test.assert_output "athena.plugin.get_container_name" "athena-plugin-myplugin-othercontainer-myinstance"

	rm -r $tmpdir
}

function testcase_athena.plugin.init()
{
	tmpdir=$(athena.test.create_tempdir)
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"

	athena.test.mock.returns "athena.plugin._init_plugin" 1
	athena.test.assert_return.expects_fail "athena.plugin.init"

	athena.test.mock.returns "athena.plugin._init_plugin" 0
	athena.test.assert_return "athena.plugin.init"

	touch $tmpdir/athena.lock
	athena.test.assert_return "athena.plugin.init"

	rm -r $tmpdir
}

function testcase_athena.plugin.validate_usage()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"

	athena.argument.set_arguments "somearg"
	athena.test.mock.returns "athena.plugin.init" 0
	athena.test.assert_return "athena.plugin.validate_usage" "myplugin"

	athena.argument.set_arguments ""
	athena.test.mock.outputs "athena.plugin.print_available_cmds" ""
	athena.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"
}

function testcase_athena.plugin.require()
{
	curr_plgs_dir=$ATHENA_PLGS_DIR
	tmpdir=$(athena.test.create_tempdir)
	ATHENA_PLGS_DIR=$tmpdir
	local plg="myplugin"
	mkdir -p "$tmpdir/$plg/bin/lib"
	athena.test.mock.returns "athena.plugin.init" 0

	echo "echo -n hello" > "$tmpdir/$plg/bin/variables.sh"
	echo "echo -n olleh" > "$tmpdir/$plg/bin/lib/functions.sh"

	athena.test.assert_output "athena.plugin.require" "ollehhello" "$plg"
	athena.test.assert_exit_code.expects_fail "athena.plugin.require" "myotherplguin"

	athena.test.mock.outputs "athena.plugin.get_plugin" "spinpans"
	athena.test.assert_return.expects_fail "athena.plugin.require" "spinpans"

	rm -r $tmpdir
	ATHENA_PLGS_DIR=$curr_plgs_dir
}

function testcase_athena.plugin.print_available_cmds()
{
	local athena_cmd
	local expected
	# asserting other plugin output
	if which athena 1>/dev/null 2>/dev/null ;then
		athena_cmd="athena"
	else
		athena_cmd="$0"
	fi
	expected=$(cat << EOF
usage: $athena_cmd myplugin <command> [arg...]

These are the available commands for plugin [myplugin]:
	cmd1 My description.

EOF
)
	athena.test.mock.outputs "athena.plugin.get_available_cmds" "cmd1_My_description."
	athena.test.assert_output "athena.plugin.print_available_cmds" "$expected" "myplugin"

	# asserting base plugin output
	expected=$(cat << EOF
usage: $athena_cmd base <command> [arg...]

These are the available commands for plugin [base]:
	cmd1 My description.

You can also use any of the other available plugins:
	$athena_cmd test1 <command> [arg...]


EOF
)
	tmpdir=$(athena.test.create_tempdir)
	mkdir "$tmpdir/test1"

	athena.test.mock.outputs "athena.plugin.get_plugins_dir" "$tmpdir"
	athena.test.mock.outputs "athena.plugin.get_available_cmds" "cmd1_My_description."

	athena.test.assert_output "athena.plugin.print_available_cmds" "$expected" "base"

	rm -r $tmpdir
}

function testcase_athena.plugin.get_available_cmds()
{
	tmpdir=$(athena.test.create_tempdir)
	athena.test.mock.outputs "athena.plugin.get_plg_cmd_dir" "$tmpdir"
	echo "CMD_DESCRIPTION=\"My cmd1 description.\"" > "$tmpdir/cmd1.sh"

	athena.test.assert_output "athena.plugin.get_available_cmds" "cmd1:My_cmd1_description."
	rm -r $tmpdir
}

function testcase_athena.plugin.init()
{
	tmpdir=$(athena.test.create_tempdir)
	athena.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"
	athena.test.mock.outputs "athena.plugin.get_plg_cmd_dir" "$tmpdir"
	touch $tmpdir/init_pre.sh

	athena.test.mock.returns "athena.plugin._init_plugin" 1
	athena.test.assert_exit_code.expects_fail "athena.plugin.init"

	athena.test.mock.returns "athena.plugin._init_plugin" 0
	athena.test.assert_return "athena.plugin.init"

	touch $tmpdir/athena.lock
	athena.test.assert_return "athena.plugin.init"

	rm -r $tmpdir
}

function testcase_athena.plugin.validate_usage()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"

	athena.argument.set_arguments "somearg"
	athena.test.mock.returns "athena.plugin.init" 0
	athena.test.assert_return "athena.plugin.validate_usage" "myplugin"

	athena.argument.set_arguments ""
	athena.test.mock.outputs "athena.plugin.print_available_cmds" ""
	athena.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"
}

function testcase_athena.plugin._router()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin._router"

	athena.test.mock.outputs "athena.plugin.handle" "run-handle"
	athena.test.mock.returns "athena.os._print_logo" 0
	athena.test.mock.returns "athena.plugin.validate_usage" 0
	athena.test.assert_output "athena.plugin._router" "run-handle" "myplugin"

	athena.test.mock.returns "athena.plugin.handle" 0
	athena.test.mock.outputs "athena.os.set_command" "ipsos"
	athena.test.assert_output "athena.plugin._router" "ipsos" "myplugin" "" "" "" "" one two three

	athena.test.unmock "athena.os.set_command"
	athena.test.mock.outputs "athena.argument.remove_argument" "removing argument"
	athena.test.assert_output "athena.plugin._router" "removing argument" "myplugin" "" "" "" "" one two three

	athena.test.mock.returns "athena.argument.remove_argument" 0
	athena.plugin._router "myplugin" "" "" "" "" one two three
	athena.test.assert_output "athena.os.get_command" "one"

	local tmpdir=$(athena.test.create_tempdir)

	# testing hooks
	echo "echo -n hello-pre" > "$tmpdir/plugin_pre.sh"
	athena.test.assert_output "athena.plugin._router" "hello-pre" "myplugin" "" "" "" "$tmpdir"

	rm "$tmpdir/plugin_pre.sh"
	echo "echo -n hello-post" > "$tmpdir/plugin_post.sh"
	athena.test.assert_output "athena.plugin._router" "hello-post" "myplugin" "" "" "" "$tmpdir"

	rm -r $tmpdir
}

function testcase_athena.plugin.handle()
{
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle"
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd" "/non/existing/dir"

	local tmpdir=$(athena.test.create_tempdir)
	athena.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd1" "$tmpdir"

	athena.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"

	touch  "$tmpdir/cmd1_pre.sh"

	echo "echo functions.sh" > "$tmpdir/functions.sh"
	athena.test.assert_output "athena.plugin.handle" "functions.sh" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/functions.sh"

	echo "echo variables.sh" > "$tmpdir/variables.sh"
	athena.test.assert_output "athena.plugin.handle" "variables.sh" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/variables.sh"

	# testing hooks
	echo "echo -n hello-pre" > "$tmpdir/command_pre.sh"
	athena.test.assert_output "athena.plugin.handle" "hello-pre" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/command_pre.sh"

	echo "echo -n hello-post" > "$tmpdir/command_post.sh"
	athena.test.assert_output "athena.plugin.handle" "hello-post" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/command_post.sh"

	# testing multiple cmd dirs
	local tmpdir2=$(athena.test.create_tempdir)
	echo "echo -n cmd1_pre" > "$tmpdir/cmd1_pre.sh"
	echo "echo -n cmd_pre" > "$tmpdir2/cmd_pre.sh"
	athena.test.assert_output "athena.plugin.handle" "cmd_pre" "cmd" "$tmpdir:$tmpdir2" "$tmpdir" "$tmpdir" "$tmpdir"

	rm -r "$tmpdir"
	rm -r "$tmpdir2"
}

function testcase_athena.plugin.get_prefix_for_container_name()
{
	athena.test.assert_output "athena.plugin.get_prefix_for_container_name" "athena-plugin-specified" "specified"
	athena.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	athena.test.assert_output "athena.plugin.get_prefix_for_container_name" "athena-plugin-myplugin"
}

# aux functions
function _my_plugin_echo()
{
	echo -n "$@"
}
