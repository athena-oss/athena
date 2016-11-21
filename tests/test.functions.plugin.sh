function testcase_athena.plugin.run_command()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_command"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1" "/no/real/path"

	local tmpdir
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_command" "cmd1" "$tmpdir"

	echo "echo hello" > "$tmpdir/cmd1_pre.sh"
	bashunit.test.assert_output "athena.plugin.run_command" "hello" "cmd1" "$tmpdir"

	rm "$tmpdir/cmd1_pre.sh"
	touch "$tmpdir/cmd1.sh"
	bashunit.test.mock.outputs "athena.plugin.run_container" "ola"
	bashunit.test.assert_output "athena.plugin.run_command" "ola" "cmd1" "$tmpdir"

	rm "$tmpdir/cmd1.sh"
	echo "echo hallo" > "$tmpdir/cmd1_post.sh"
	bashunit.test.assert_output "athena.plugin.run_command" "hallo" "cmd1" "$tmpdir"

	rm -r $tmpdir
}

function testcase_athena.plugin.run_container()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_container" ""

	bashunit.test.mock "athena.docker.exec" "_my_plugin_echo"
	athena.argument.set_arguments one two three
	bashunit.test.mock.outputs "athena.docker.get_options" "--env varA=valA"
	bashunit.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	bashunit.test.mock.outputs "athena.plugin.get_image_version" "1.2.3"
	bashunit.test.mock.outputs "athena.plugin.get_container_name" "mycontainer"
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.returns "athena.os._bootstrap" 0
	bashunit.test.mock.returns "athena.docker.handle_run_type" 0

	bashunit.test.mock.returns "athena.docker.image_exists" 1
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.run_container" "command"

	athena.os.enable_verbose_mode
	bashunit.test.mock.returns "athena.docker.image_exists" 0
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.assert_output "athena.plugin.run_container" "-i mycontainer /opt/bootstrap/router.sh command one two three" "command"

	bashunit.test.mock "athena.docker.run" "_my_plugin_echo"

	# using default router and container running
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.mock.returns "athena.docker.is_default_router_to_be_used" 0
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.outputs "athena.docker.exec" "already running default router"
	bashunit.test.assert_output "athena.plugin.run_container" "already running default router" "mycommand"

	# using default router
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock.returns "athena.docker.is_default_router_to_be_used" 0
	bashunit.test.mock.returns "athena.color.print_info" 0
	bashunit.test.mock.outputs "athena.docker.run_container_with_default_router" "starting container with default router"
	bashunit.test.assert_output "athena.plugin.run_container" "starting container with default router" "mycommand"

	# not using default router and container running
	bashunit.test.mock.returns "athena.docker.is_default_router_to_be_used" 1
	bashunit.test.mock.returns "athena.docker.is_container_running" 0
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.outputs "athena.docker.exec" "already running not default router"
	bashunit.test.assert_output "athena.plugin.run_container" "already running not default router" "mycommand"
	# not using default router
	bashunit.test.mock.returns "athena.docker.is_default_router_to_be_used" 1
	bashunit.test.mock.returns "athena.docker.is_container_running" 1
	bashunit.test.mock.outputs "athena.docker.run_container" "starting new container"
	bashunit.test.assert_output "athena.plugin.run_container" "starting new container" "mycommand"
}

function testcase_athena.plugin.get_shared_lib_dir()
{
	local curr_shared_lib_dir=$ATHENA_BASE_SHARED_LIB_DIR
	ATHENA_BASE_SHARED_LIB_DIR="/path/to/shared/lib/dir"
	bashunit.test.assert_output "athena.plugin.get_shared_lib_dir" "/path/to/shared/lib/dir"
	ATHENA_BASE_SHARED_LIB_DIR=$curr_shared_lib_dir
}

function testcase_athena.plugin.get_plugins_dir()
{
	local curr_plgs_dir=$ATHENA_PLGS_DIR
	ATHENA_PLGS_DIR="test"
	bashunit.test.assert_output "athena.plugin.get_plugins_dir" "test"
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
	bashunit.test.assert_output "athena.docker.get_options" "-d"
	bashunit.test.assert_output "athena.docker.is_default_router_to_be_used"
	bashunit.test.assert_output "athena.plugin.get_container_to_use" "mycontainer"

	athena.plugin.use_external_container_as_daemon "mycontainer" "myinstance"
	bashunit.test.assert_return "athena.docker.has_option" "-d"
	bashunit.test.assert_output "athena.docker.is_default_router_to_be_used"
	bashunit.test.assert_output "athena.plugin.get_container_to_use" "mycontainer"

	bashunit.test.assert_output "athena.os.get_instance" "myinstance"

	athena.docker.set_options
	athena.os.set_instance "$curr_athena_instance"
	athena.docker.set_no_default_router $curr_is_no_default_router
}

function testcase_athena.plugin.use_container()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.use_container" ""

	local curr_plg_container_to_use=$ATHENA_PLG_CONTAINER_TO_USE
	athena.plugin.use_container "xpto"
	bashunit.test.assert_value "$ATHENA_PLG_CONTAINER_TO_USE" "xpto"
	ATHENA_PLG_CONTAINER_TO_USE=$curr_plg_container_to_use
}

function testcase_athena.plugin.get_container_to_use()
{
	local curr_plg_container_to_use=$ATHENA_PLG_CONTAINER_TO_USE

	athena.plugin.use_container "xpto"
	bashunit.test.assert_output "athena.plugin.get_container_to_use" "xpto"

	ATHENA_PLG_CONTAINER_TO_USE=
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_container_to_use"

	ATHENA_PLG_CONTAINER_TO_USE=$curr_plg_container_to_use
}

function testcase_athena.plugin.plugin_exists()
{
	bashunit.test.assert_exit_code "athena.plugin.plugin_exists" "base"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.plugin_exists" "base" "<0.0.0"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.plugin_exists" "spinpans$(date +%s)"
}

function testcase_athena.plugin.validate_plugin_name()
{
	bashunit.test.assert_exit_code "athena.plugin.validate_plugin_name" "base"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.validate_plugin_name" ""
}

function testcase_athena.plugin.set_environment()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.set_environment"
	bashunit.test.assert_exit_code "athena.plugin.set_environment" "default"
}

function testcase_athena.plugin.get_environment()
{
	local curr_athena_plg_environment=$ATHENA_PLG_ENVIRONMENT
	ATHENA_PLG_ENVIRONMENT=
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_environment"

	athena.plugin.set_environment "production"
	bashunit.test.assert_exit_code "athena.plugin.get_environment"
	bashunit.test.assert_output "athena.plugin.get_environment" "production"
	ATHENA_PLG_ENVIRONMENT=$curr_athena_plg_environment
}

function testcase_athena.plugin.is_environment_specified()
{
	local curr_athena_plg_environment="$ATHENA_PLG_ENVIRONMENT"
	ATHENA_PLG_ENVIRONMENT=
	bashunit.test.assert_return.expects_fail "athena.plugin.is_environment_specified"
	athena.plugin.set_environment "production"
	bashunit.test.assert_return "athena.plugin.is_environment_specified"
	ATHENA_PLG_ENVIRONMENT="$curr_athena_plg_environment"
}

function testcase_athena.plugin.set_image_version()
{
	local curr_athena_plg_image_version="$ATHENA_PLG_IMAGE_VERSION"
	athena.plugin.set_image_version "1.9.1"
	bashunit.test.assert_value "1.9.1" "$ATHENA_PLG_IMAGE_VERSION"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.set_image_version" ""
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.set_image_version" "a.1.2"
	ATHENA_PLG_IMAGE_VERSION="$curr_athena_plg_image_version"
}

function testcase_athena.plugin.get_image_version()
{
	local curr_athena_plg_image_version="$ATHENA_PLG_IMAGE_VERSION"
	athena.plugin.set_image_version "1.9.1"
	bashunit.test.assert_output "athena.plugin.get_image_version" "1.9.1"
	ATHENA_PLG_IMAGE_VERSION="$curr_athena_plg_image_version"
}

function testcase_athena.plugin.get_tag_name()
{
	local curr_athena_plg_environment="$ATHENA_PLG_ENVIRONMENT"
	ATHENA_PLG_ENVIRONMENT=
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_image_name "myname"
	athena.plugin.set_plugin "myplugin"
	bashunit.test.mock.returns "athena.plugin.get_container_to_use" 0
	bashunit.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin"

	bashunit.test.mock.outputs "athena.plugin.get_container_to_use" "mycontainer"
	bashunit.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-mycontainer"

	ATHENA_PLG_ENVIRONMENT="test"
	athena.plugin.set_image_name "myname"
	athena.plugin.set_plugin "myplugin"
	bashunit.test.mock.returns "athena.plugin.get_container_to_use" 0
	bashunit.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-test"


	bashunit.test.mock.outputs "athena.plugin.get_container_to_use" "mycontainer"
	bashunit.test.assert_output "athena.plugin.get_tag_name" "myname-myplugin-mycontainer-test"

	athena.plugin.set_plugin "$curr_plugin"
	ATHENA_PLG_ENVIRONMENT="$curr_athena_plg_environment"
}

function testcase_athena.plugin.set_plugin()
{
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_plugin "myplugin"
	bashunit.test.assert_value "myplugin" "$ATHENA_PLUGIN"
	athena.plugin.set_plugin "$curr_plugin"
}

function testcase_athena.plugin.get_plugin()
{
	local curr_plugin=$(athena.plugin.get_plugin)
	athena.plugin.set_plugin "myplugin"
	bashunit.test.assert_output "athena.plugin.get_plugin" "myplugin"
	athena.plugin.set_plugin "$curr_plugin"
}

function testcase_athena.plugin.set_container_name()
{
	local curr_container_name=$(athena.plugin.get_container_name)
	athena.plugin.set_container_name "mycontainer"
	bashunit.test.assert_value "mycontainer" "$ATHENA_CONTAINER_NAME"
	athena.plugin.set_container_name "$curr_container_name"
}

function testcase_athena.plugin.get_container_name()
{
	local curr_container_name=$ATHENA_CONTAINER_NAME
	athena.plugin.set_container_name "mycontainer"
	bashunit.test.assert_output "athena.plugin.get_container_name" "mycontainer"

	ATHENA_CONTAINER_NAME=
	ATHENA_PLG_CONTAINER_TO_USE=
	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	bashunit.test.mock.returns "athena.plugin.get_environment" 1
	bashunit.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-$(athena.os.get_instance)"

	athena.plugin.use_container "myspinpanscontainer"
	bashunit.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainer-$(athena.os.get_instance)"
	bashunit.test.mock.outputs "athena.plugin.get_environment" "myenv"
	bashunit.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainer-myenv-$(athena.os.get_instance)"

	athena.plugin.use_container "myspinpanscontainer:other"
	bashunit.test.assert_output "athena.plugin.get_container_name" "athena-plugin-$(athena.plugin.get_plugin)-myspinpanscontainerother-myenv-$(athena.os.get_instance)"
}

function testcase_athena.plugin.get_plg_version()
{
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"
	echo "1.2.3" > $tmpdir/version.txt
	bashunit.test.assert_output "athena.plugin.get_plg_version" "1.2.3"
	rm -r $tmpdir
}

function testcase_athena.plugin.get_plg_dir()
{
	curr_plgs_dir=$ATHENA_PLGS_DIR
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_plg_dir" "mynonexistingplugin"

	tmpdir=$(bashunit.test.create_tempdir)
	mkdir -p "$tmpdir/plugins/myplugin"
	ATHENA_PLGS_DIR="$tmpdir/plugins"
	bashunit.test.assert_output "athena.plugin.get_plg_dir" "$tmpdir/plugins/myplugin" "myplugin"

	# testing not passing any plugin which should show
	# the current plugin dir
	mkdir -p "$tmpdir/plugins/myplugin2"
	bashunit.test.mock.outputs "athena.plugin.get_plg" "myplugin2"
	bashunit.test.assert_output "athena.plugin.get_plg_dir" "$tmpdir/plugins/myplugin2"

	rm -r $tmpdir
	ATHENA_PLGS_DIR=$curr_plgs_dir
}

function testcase_athena.plugin.get_plg_bin_dir()
{
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "/my/plugin/path"
	bashunit.test.assert_output "athena.plugin.get_plg_bin_dir" "/my/plugin/path/bin"
}

function testcase_athena.plugin.get_plg_hooks_dir()
{
	bashunit.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	bashunit.test.assert_output "athena.plugin.get_plg_hooks_dir" "/my/plugin/path/hooks"
}

function testcase_athena.plugin.get_plg_lib_dir()
{
	bashunit.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	bashunit.test.assert_output "athena.plugin.get_plg_lib_dir" "/my/plugin/path/lib"
}

function testcase_athena.plugin.get_plg_cmd_dir()
{
	local curr_plg_cmd_dir=$ATHENA_PLG_CMD_DIR
	ATHENA_PLG_CMD_DIR="/my/plugin/path/cmd"
	bashunit.test.assert_output "athena.plugin.get_plg_cmd_dir" "/my/plugin/path/cmd"

	ATHENA_PLG_CMD_DIR=
	bashunit.test.mock.outputs "athena.plugin.get_plg_bin_dir" "/my/plugin/path"
	bashunit.test.assert_output "athena.plugin.get_plg_cmd_dir" "/my/plugin/path/cmd"
	ATHENA_PLG_CMD_DIR=$curr_plg_cmd_dir
}

function testcase_athena.plugin.set_plg_cmd_dir()
{
	local curr_plg_cmd_dir=$ATHENA_PLG_CMD_DIR
	ATHENA_PLG_CMD_DIR="/my/plugin/path/cmd"
	athena.plugin.set_plg_cmd_dir "/my/plugin/path/cmd2"
	bashunit.test.assert_value "/my/plugin/path/cmd2" "$ATHENA_PLG_CMD_DIR"
	ATHENA_PLG_CMD_DIR=$curr_plg_cmd_dir
}

function testcase_athena.plugin.get_plg_docker_dir()
{
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "/my/plugin/path"
	bashunit.test.assert_output "athena.plugin.get_plg_docker_dir" "/my/plugin/path/docker"
}

function testcase_athena.plugin.get_image_name()
{
	bashunit.test.assert_output "athena.plugin.get_image_name" "$ATHENA_PLG_IMAGE_NAME"
}

function testcase_athena.plugin.set_image_name()
{
	curr_image_name=$ATHENA_PLG_IMAGE_NAME
	athena.plugin.set_image_name "myimagename"
	bashunit.test.assert_value "$ATHENA_PLG_IMAGE_NAME" "myimagename"
	ATHENA_PLG_IMAGE_NAME=$curr_image_name
}

function testcase_athena.plugin.set_environment_build_file()
{
	curr_plg_docker_env_build_file=$ATHENA_PLG_DOCKER_ENV_BUILD_FILE
	athena.plugin.set_environment_build_file "myfile"
	bashunit.test.assert_value "$ATHENA_PLG_DOCKER_ENV_BUILD_FILE" "myfile"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=$curr_plg_docker_env_build_file
}

function testcase_athena.plugin.get_environment_build_file()
{
	curr_plg_docker_env_build_file=$ATHENA_PLG_DOCKER_ENV_BUILD_FILE
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=""
	bashunit.test.assert_return.expects_fail "athena.plugin.get_environment_build_file"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE="xpto"
	bashunit.test.assert_output "athena.plugin.get_environment_build_file" "xpto"
	ATHENA_PLG_DOCKER_ENV_BUILD_FILE=$curr_plg_docker_env_build_file
}

function testcase_athena.os.is_git_installed()
{
	bashunit.test.mock.returns "athena.os._which_git" 1
	bashunit.test.assert_exit_code.expects_fail "athena.os.is_git_installed"

	bashunit.test.mock.returns "athena.os._which_git" 0
	bashunit.test.assert_return "athena.os.is_git_installed"
}

function testcase_athena.plugin.check_dependencies()
{
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.returns "athena.color.print_debug" 0
	mkdir "$tmpdir/myplugin"
	mkdir "$tmpdir/other"
	echo "4.0.0" > "$tmpdir/other/version.txt"
	bashunit.test.mock.outputs "athena.plugin.get_plugins_dir" "$tmpdir"
	cat << EOF > $tmpdir/myplugin/dependencies.ini
other=4.0.0
EOF
	bashunit.test.assert_return "athena.plugin.check_dependencies" "myplugin"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.check_dependencies" "myplugin2"

	cat << EOF > $tmpdir/myplugin/dependencies.ini
other=5.0.0
EOF
	echo "2.0.0" > "$tmpdir/other/version.txt"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.check_dependencies" "myplugin"
	rm "$tmpdir/myplugin/dependencies.ini"
	bashunit.test.assert_return "athena.plugin.check_dependencies" "myplugin"

	rm -r $tmpdir
}

function testcase_athena.plugin.get_subplg_version()
{
	tmpdir=$(bashunit.test.create_tempdir)
	mkdir -p "$tmpdir/plg/other"
	echo "1.2.3" > "$tmpdir/plg/other/version.txt"
	bashunit.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir/plg"

	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version" "plg"
	bashunit.test.assert_output "athena.plugin.get_subplg_version" "1.2.3" "plg" "other"

	rm "$tmpdir/plg/other/version.txt"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.get_subplg_version" "plg other"

	rm -r $tmpdir
}

function testcase_athena.plugin.handle_environment()
{
	bashunit.test.mock.returns "athena.plugin.get_environment" 1
	bashunit.test.assert_return "athena.plugin.handle_environment"

	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	bashunit.test.mock.returns "athena.plugin.get_container_to_use" 1
	touch "$tmpdir/production.env"
	bashunit.test.mock.outputs "athena.plugin.get_environment" "production"
	athena.plugin.handle_environment
	bashunit.test.assert_output "athena.plugin.get_environment_build_file" "$tmpdir/production.env"

	rm "$tmpdir/production.env"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle_environment"

	mkdir "$tmpdir/other"
	bashunit.test.mock.outputs "athena.plugin.get_container_to_use" "other"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle_environment"
	touch "$tmpdir/other/production.env"
	athena.plugin.handle_environment
	bashunit.test.assert_output "athena.plugin.get_environment_build_file" "$tmpdir/other/production.env"

	# testing that environment specified is a file
	env_file="$tmpdir/myenv.env"
	touch $env_file
	bashunit.test.mock.outputs "athena.plugin.get_environment" "$env_file"
	athena.plugin.handle_environment
	bashunit.test.unmock "athena.plugin.get_environment"
	bashunit.test.assert_output "athena.plugin.get_environment" "myenv"
	bashunit.test.assert_output "athena.plugin.get_environment_build_file" "$env_file"

	rm -r $tmpdir
}

function testcase_athena.plugin.build()
{
	bashunit.test.mock "athena.docker.build_container" "_my_plugin_echo"
	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	bashunit.test.mock.outputs "athena.plugin.get_plg_docker_dir" "mydockerdir"
	bashunit.test.mock.outputs "athena.plugin.get_tag_name" "mytag"
	bashunit.test.mock.outputs "athena.plugin.get_image_version" "1.0.0"

	bashunit.test.assert_output "athena.plugin.build" "mytag 1.0.0 mydockerdir"
}


function testcase_athena.plugin.handle_container()
{
	tmpdir=$(bashunit.test.create_tempdir)

	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	bashunit.test.mock.outputs "athena.plugin.get_plg_docker_dir" "$tmpdir"
	bashunit.test.mock.returns "athena.plugin.get_container_to_use" 1

	bashunit.test.assert_return "athena.plugin.handle_container"

	bashunit.test.mock.outputs "athena.plugin.build" "i am building"
	touch "$tmpdir/Dockerfile"
	bashunit.test.assert_output "athena.plugin.handle_container" "i am building"

	# try external
	bashunit.test.mock.outputs "athena.plugin.get_container_to_use" "othercontainer"
	bashunit.test.assert_return "athena.plugin.handle_container"

	mkdir "$tmpdir/othercontainer"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	touch "$tmpdir/othercontainer/version.txt"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	echo "1.2.3" > "$tmpdir/othercontainer/version.txt"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle_container"

	touch "$tmpdir/othercontainer/Dockerfile"
	bashunit.test.mock "athena.docker.build_from_plugin" "_my_plugin_echo"
	bashunit.test.mock.returns "athena.plugin.set_plugin" 0
	bashunit.test.assert_exit_code "athena.plugin.handle_container"
	bashunit.test.assert_output "athena.plugin.handle_container" "myplugin othercontainer 1.2.3"

	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	bashunit.test.mock.outputs "athena.os.get_instance" "myinstance"
	bashunit.test.mock.outputs "athena.plugin.get_container_to_use" "othercontainer"
	bashunit.test.mock.returns "athena.plugin.get_environment" 1
	bashunit.test.mock.returns "athena.docker.build_from_plugin" 0
	athena.plugin.handle_container
	bashunit.test.assert_output "athena.plugin.get_container_name" "athena-plugin-myplugin-othercontainer-myinstance"

	rm -r $tmpdir
}

function testcase_athena.plugin.init()
{
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"

	bashunit.test.mock.returns "athena.plugin._init_plugin" 1
	bashunit.test.assert_return.expects_fail "athena.plugin.init"

	bashunit.test.mock.returns "athena.plugin._init_plugin" 0
	bashunit.test.assert_return "athena.plugin.init"

	touch $tmpdir/athena.lock
	bashunit.test.assert_return "athena.plugin.init"

	rm -r $tmpdir
}

function testcase_athena.plugin.validate_usage()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"
	bashunit.test.mock.returns "athena.color.print_debug" 0
	athena.argument.set_arguments "somearg"

	bashunit.test.mock.returns "athena.plugin.init" 0
	bashunit.test.assert_return "athena.plugin.validate_usage" "myplugin"

	athena.argument.set_arguments ""
	bashunit.test.mock.outputs "athena.plugin.print_available_cmds" ""
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"
}

function testcase_athena.plugin.require()
{
	curr_plgs_dir=$ATHENA_PLGS_DIR
	tmpdir=$(bashunit.test.create_tempdir)
	ATHENA_PLGS_DIR=$tmpdir
	local plg="myplugin"
	mkdir -p "$tmpdir/$plg/bin/lib"
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.returns "athena.plugin.init" 0

	echo "echo -n hello" > "$tmpdir/$plg/bin/variables.sh"
	echo "echo -n olleh" > "$tmpdir/$plg/bin/lib/functions.sh"

	bashunit.test.assert_output "athena.plugin.require" "ollehhello" "$plg"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.require" "myotherplguin"

	bashunit.test.mock.outputs "athena.plugin.get_plugin" "spinpans"
	bashunit.test.assert_return.expects_fail "athena.plugin.require" "spinpans"

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
	bashunit.test.mock.outputs "athena.plugin.get_available_cmds" "cmd1_My_description."
	bashunit.test.assert_output "athena.plugin.print_available_cmds" "$expected" "myplugin"

	# asserting base plugin output
	expected=$(cat << EOF
usage: $athena_cmd base <command> [arg...]

These are the available commands for plugin [base]:
	cmd1 My description.

You can also use any of the other available plugins:
	$athena_cmd test1 <command> [arg...]


EOF
)
	tmpdir=$(bashunit.test.create_tempdir)
	mkdir "$tmpdir/test1"

	bashunit.test.mock.outputs "athena.plugin.get_plugins_dir" "$tmpdir"
	bashunit.test.mock.outputs "athena.plugin.get_available_cmds" "cmd1_My_description."

	bashunit.test.assert_output "athena.plugin.print_available_cmds" "$expected" "base"

	rm -r $tmpdir
}

function testcase_athena.plugin.get_available_cmds()
{
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.outputs "athena.plugin.get_plg_cmd_dir" "$tmpdir"
	echo "CMD_DESCRIPTION=\"My cmd1 description.\"" > "$tmpdir/cmd1.sh"

	bashunit.test.assert_output "athena.plugin.get_available_cmds" "cmd1:My_cmd1_description."
	rm -r $tmpdir
}

function testcase_athena.plugin.init()
{
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.mock.returns "athena.color.print_debug" 0
	bashunit.test.mock.returns "athena.color.print_info" 0
	bashunit.test.mock.outputs "athena.plugin.get_plg_dir" "$tmpdir"
	bashunit.test.mock.outputs "athena.plugin.get_plg_cmd_dir" "$tmpdir"
	touch $tmpdir/init_pre.sh

	bashunit.test.mock.returns "athena.plugin._init_plugin" 1
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.init"

	bashunit.test.mock.returns "athena.plugin._init_plugin" 0
	bashunit.test.assert_return "athena.plugin.init"

	touch $tmpdir/athena.lock
	bashunit.test.assert_return "athena.plugin.init"

	rm -r $tmpdir
}

function testcase_athena.plugin.validate_usage()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"

	athena.argument.set_arguments "somearg"
	athena.os.set_command "test_command"
	bashunit.test.mock.returns "athena.plugin.init" 0
	bashunit.test.assert_return "athena.plugin.validate_usage" "myplugin"

	athena.argument.set_arguments ""
	bashunit.test.mock.outputs "athena.plugin.print_available_cmds" ""
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.validate_usage"
}

function testcase_athena.plugin._router()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin._router"

	bashunit.test.mock.outputs "athena.plugin.handle" "run-handle"
	bashunit.test.mock.returns "athena.plugin._print_logo" 0
	bashunit.test.mock.returns "athena.plugin.validate_usage" 0
	bashunit.test.assert_output "athena.plugin._router" "run-handle" "myplugin"

	bashunit.test.mock.returns "athena.plugin.handle" 0
	bashunit.test.mock.outputs "athena.os.set_command" "ipsos"
	bashunit.test.assert_output "athena.plugin._router" "ipsos" "myplugin" "" "" "" "" one two three

	bashunit.test.unmock "athena.os.set_command"
	bashunit.test.mock.outputs "athena.argument.remove_argument" "removing argument"
	bashunit.test.assert_output "athena.plugin._router" "removing argument" "myplugin" "" "" "" "" one two three

	bashunit.test.mock.returns "athena.argument.remove_argument" 0
	athena.plugin._router "myplugin" "" "" "" "" one two three
	bashunit.test.assert_output "athena.os.get_command" "one"

	local tmpdir=$(bashunit.test.create_tempdir)

	# testing hooks
	echo "echo -n hello-pre" > "$tmpdir/plugin_pre.sh"
	bashunit.test.assert_output "athena.plugin._router" "hello-pre" "myplugin" "" "" "" "$tmpdir"

	rm "$tmpdir/plugin_pre.sh"
	echo "echo -n hello-post" > "$tmpdir/plugin_post.sh"
	bashunit.test.assert_output "athena.plugin._router" "hello-post" "myplugin" "" "" "" "$tmpdir"

	rm -r $tmpdir
}

function testcase_athena.plugin.handle()
{
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle"
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd" "/non/existing/dir"

	local tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd1" "$tmpdir"

	bashunit.test.assert_exit_code.expects_fail "athena.plugin.handle" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"

	touch  "$tmpdir/cmd1_pre.sh"

	echo "echo functions.sh" > "$tmpdir/functions.sh"
	bashunit.test.assert_output "athena.plugin.handle" "functions.sh" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/functions.sh"

	echo "echo variables.sh" > "$tmpdir/variables.sh"
	bashunit.test.assert_output "athena.plugin.handle" "variables.sh" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/variables.sh"

	# testing hooks
	echo "echo -n hello-pre" > "$tmpdir/command_pre.sh"
	bashunit.test.assert_output "athena.plugin.handle" "hello-pre" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/command_pre.sh"

	echo "echo -n hello-post" > "$tmpdir/command_post.sh"
	bashunit.test.assert_output "athena.plugin.handle" "hello-post" "cmd1" "$tmpdir" "$tmpdir" "$tmpdir" "$tmpdir"
	rm "$tmpdir/command_post.sh"

	# testing multiple cmd dirs
	local tmpdir2=$(bashunit.test.create_tempdir)
	echo "echo -n cmd1_pre" > "$tmpdir/cmd1_pre.sh"
	echo "echo -n cmd_pre" > "$tmpdir2/cmd_pre.sh"
	bashunit.test.assert_output "athena.plugin.handle" "cmd_pre" "cmd" "$tmpdir:$tmpdir2" "$tmpdir" "$tmpdir" "$tmpdir"

	rm -r "$tmpdir"
	rm -r "$tmpdir2"
}

function testcase_athena.plugin.get_prefix_for_container_name()
{
	bashunit.test.assert_output "athena.plugin.get_prefix_for_container_name" "athena-plugin-specified" "specified"
	bashunit.test.mock.outputs "athena.plugin.get_plugin" "myplugin"
	bashunit.test.assert_output "athena.plugin.get_prefix_for_container_name" "athena-plugin-myplugin"
}

# aux functions
function _my_plugin_echo()
{
	echo -n "$@"
}
