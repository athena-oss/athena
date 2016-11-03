function testcase_athena.os.is_command_set()
{
	local old_command="test_command"

	athena.os.set_command "SOMETHING"
	bashunit.test.assert_exit_code "athena.os.is_command_set"

	ATHENA_COMMAND=
	bashunit.test.assert_exit_code.expects_fail "athena.os.is_command_set"
	athena.os.set_command "$old_command"
}

function testcase_athena.os.set_command()
{
	bashunit.test.assert_return "athena.os.set_command" "test"
	bashunit.test.assert_exit_code.expects_fail "athena.os.set_command" ""
}

function testcase_athena.os.get_command()
{
	athena.os.set_command "test"
	bashunit.test.assert_output "athena.os.get_command" "test"
	bashunit.test.assert_return "athena.os.get_command"

	bashunit.test.mock.exits "athena.os.is_command_set" 1
	bashunit.test.assert_exit_code.expects_fail "athena.os.get_command"
}

function testcase_athena.os.enable_error_mode()
{
	curr_error_mode=$ATHENA_OUTPUT_MODE
	athena.os.enable_error_mode
	bashunit.test.assert_value "$ATHENA_OUTPUT_MODE" "1"
	ATHENA_OUTPUT_MODE=$curr_error_mode
}

function testcase_athena.os.enable_quiet_mode()
{
	curr_error_mode=$ATHENA_OUTPUT_MODE
	athena.os.enable_quiet_mode
	bashunit.test.assert_value "$ATHENA_OUTPUT_MODE" "2"
	ATHENA_OUTPUT_MODE=$curr_error_mode
}

function testcase_athena.os.enable_verbose_mode()
{
	curr_error_mode=$ATHENA_OUTPUT_MODE
	athena.os.enable_verbose_mode
	bashunit.test.assert_value "$ATHENA_OUTPUT_MODE" "0"
	ATHENA_OUTPUT_MODE=$curr_error_mode
}

function testcase_athena.os.exec()
{
	curr_error_mode=$ATHENA_OUTPUT_MODE

	athena.os.enable_verbose_mode
	output=$(athena.os.exec "echo" "hello")
	bashunit.test.assert_value "hello" "$output"

	athena.os.enable_quiet_mode
	output=$(athena.os.exec "echo" "hello")
	bashunit.test.assert_value "" "$output"

	ATHENA_OUTPUT_MODE=$curr_error_mode
}

function testcase_athena.os.is_mac()
{
	curr_is_mac=$ATHENA_IS_MAC
	ATHENA_IS_MAC=1
	bashunit.test.assert_return "athena.os.is_mac"
	ATHENA_IS_MAC=0
	bashunit.test.assert_return.expects_fail "athena.os.is_mac"
	ATHENA_IS_MAC=$curr_is_mac
}

function testcase_athena.os.is_linux()
{
	curr_is_linux=$ATHENA_IS_LINUX
	ATHENA_IS_LINUX=1
	bashunit.test.assert_return "athena.os.is_linux"
	ATHENA_IS_LINUX=0
	bashunit.test.assert_return.expects_fail "athena.os.is_linux"
	ATHENA_IS_LINUX=$curr_is_linux
}

function testcase_athena.os.is_sudo()
{
	curr_is_sudo=$ATHENA_SUDO
	ATHENA_SUDO="sudo"
	bashunit.test.assert_return "athena.os.is_sudo"
	ATHENA_SUDO=""
	bashunit.test.assert_return.expects_fail "athena.os.is_sudo"
	ATHENA_SUDO=curr_is_sudo
}

function testcase_athena.os.get_host_ip()
{
	curr_is_mac=$ATHENA_IS_MAC
	bashunit.test.mock.outputs "athena.os._get_host_ip_for_mac" "IP from MAC"
	bashunit.test.mock.outputs "athena.os._get_host_ip_for_linux" "IP from LINUX"

	ATHENA_IS_MAC=1
	bashunit.test.assert_output "athena.os.get_host_ip" "IP from MAC"

	ATHENA_IS_MAC=0
	bashunit.test.assert_output "athena.os.get_host_ip" "IP from LINUX"

	ATHENA_IS_MAC=$curr_is_mac
}

function testcase_athena.os.get_instance()
{
	curr_athena_instance=$ATHENA_INSTANCE
	ATHENA_INSTANCE="myinstance"
	bashunit.test.assert_output "athena.os.get_instance" "myinstance"
	ATHENA_INSTANCE=$curr_athena_instance
}

function testcase_athena.os.set_instance()
{
	curr_athena_instance=$ATHENA_INSTANCE
	bashunit.test.assert_exit_code.expects_fail "athena.os.set_instance"
	athena.os.set_instance "myinstance"
	bashunit.test.assert_output "athena.os.get_instance" "myinstance"
	ATHENA_INSTANCE=$curr_athena_instance
}

function testcase_athena.os.function_exists()
{
	bashunit.test.assert_exit_code.expects_fail "athena.os.function_exists" ""
	bashunit.test.assert_return.expects_fail "athena.os.function_exists" "my-non-existing-function"

	bashunit.test.mock.exits "_my_os_function" 1
	bashunit.test.assert_return "athena.os.function_exists" "_my_os_function"
}

function testcase_athena.os.function_exists_or_fail()
{
	bashunit.test.assert_exit_code.expects_fail "athena.os.function_exists_or_fail" ""
	bashunit.test.assert_exit_code.expects_fail "athena.os.function_exists_or_fail" "my-non-existing-function"

	bashunit.test.mock.exits "_my_os_function" 1
	bashunit.test.assert_return "athena.os.function_exists_or_fail" "_my_os_function"
}

function testcase_athena.os.return()
{
	athena.os.return "one" "var1"
	bashunit.test.assert_value "one" "$var1"

	bashunit.test.mock "athena.get_value" "_my_os_mock"
	athena.get_value
	bashunit.test.assert_value "teste" "$value"

	bashunit.test.assert_exit_code.expects_fail "_my_os_spinpans"

	bashunit.test.assert_value "hello" "$(_my_os_athena.get_val)"

	_my_os_athena.mynamespace.get_valtwo
	bashunit.test.assert_value "hellofromtheoutside" "$valtwo"
}

function testcase_athena.os.include_once()
{
	bashunit.test.assert_exit_code.expects_fail "athena.os.include_once" ""
	bashunit.test.assert_exit_code.expects_fail "athena.os.include_once" "/non/existing/file"

	tmpfile=$(bashunit.test.create_tempfile)
	bashunit.test.assert_exit_code "athena.os.include_once" "$tmpfile"
	rm "$tmpfile"

	tmpfile=/tmp/bashunit.test.file.$RANDOM.$$@$RANDOM
	touch "$tmpfile"
	bashunit.test.assert_exit_code "athena.os.include_once" "$tmpfile"
	rm "$tmpfile"
}

function testcase_athena.os.exit()
{
	bashunit.test.assert_exit_code "athena.os.exit" 0
	bashunit.test.assert_exit_code.expects_fail "athena.os.exit" 1
	bashunit.test.assert_exit_code.expects_fail "athena.os.exit"
}

function testcase_athena.os.exit_with_msg()
{
	bashunit.test.assert_exit_code.expects_fail "athena.os.exit_with_msg" "my msg"
}

function testcase_athena.os.handle_exit()
{
	curr_container_started=$ATHENA_CONTAINER_STARTED
	bashunit.test.assert_exit_code.expects_fail "athena.os.handle_exit" ABRT

	bashunit.test.mock.outputs "athena.docker.cleanup" "cleanup"
	bashunit.test.mock.returns "athena._print_time" 0

	ATHENA_CONTAINER_STARTED=1
	bashunit.test.assert_output "athena.os.handle_exit" "cleanup" EXIT

	ATHENA_CONTAINER_STARTED=0
	bashunit.test.assert_output "athena.os.handle_exit" "" EXIT

	bashunit.test.mock.outputs "athena.docker.stop_container" "stop_container"
	bashunit.test.mock.returns "athena.color.print_debug" 0

	ATHENA_CONTAINER_STARTED=1
	bashunit.test.assert_output "athena.os.handle_exit" "stop_container" INT

	ATHENA_CONTAINER_STARTED=0
	bashunit.test.assert_output "athena.os.handle_exit" "" INT

	bashunit.test.mock.outputs "athena.color.print_debug" "other"
	bashunit.test.assert_output "athena.os.handle_exit" "other" OTHER

	bashunit.test.assert_output "athena.os.handle_exit" "" ERR
	ATHENA_CONTAINER_STARTED=$curr_container_started
}

function testcase_athena.os.register_exit_handler()
{
	bashunit.test.mock "athena.os._trap" "_my_os_trap"

	bashunit.test.assert_output "athena.os.register_exit_handler" "myfunc sig1 sig1" "myfunc" "sig1"

	bashunit.test.assert_exit_code.expects_fail "athena.os.register_exit_handler"
}

function testcase_athena.os.override_exit_handler()
{
	bashunit.test.mock.outputs "athena.color.print_debug" "overriden"
	bashunit.test.mock.returns "athena.os._trap" 0
	bashunit.test.mock.returns "athena.os.register_exit_handler" 0

	bashunit.test.assert_output "athena.os.override_exit_handler" "overriden"
}

function testcase_athena.os.set_exit_handler()
{
	bashunit.test.mock.outputs "athena.os.register_exit_handler" "setted"
	bashunit.test.assert_output "athena.os.set_exit_handler" "setted"
}

function testcase_athena.os.set_debug()
{
	curr_is_debug_mode=$ATHENA_IS_DEBUG
	athena.os.set_debug 1
	bashunit.test.assert_value "$ATHENA_IS_DEBUG" "1"


	athena.os.set_debug 0
	bashunit.test.assert_value "$ATHENA_IS_DEBUG" "0"

	ATHENA_IS_DEBUG=$curr_is_debug_mode
}

function testcase_athena.os.is_debug_active()
{
	curr_is_debug_mode=$ATHENA_IS_DEBUG

	athena.os.set_debug 1
	bashunit.test.assert_return "athena.os.is_debug_active"

	athena.os.set_debug 0
	bashunit.test.assert_return.expects_fail "athena.os.is_debug_active"

	ATHENA_IS_DEBUG=$curr_is_debug_mode
}

function testcase_athena.os._process_flags()
{
	athena.argument.set_arguments "--athena-env=xpto"
	athena.os._process_flags
	bashunit.test.assert_return.expects_fail "athena.argument.string_contains" "$ATHENA_ARGS" "--athena-env"

	athena.argument.set_arguments "--athena-dbg"
	athena.os._process_flags
	bashunit.test.assert_return "athena.os.is_debug_active"
	bashunit.test.assert_return.expects_fail "athena.argument.string_contains" "$ATHENA_ARGS" "--athena-dbg"
}

function testcase_athena.os.get_base_dir()
{
	curr_base_dir=$ATHENA_BASE_DIR
	ATHENA_BASE_DIR="/my/path/to/somewhere/"
	bashunit.test.assert_output "athena.os.get_base_dir" "$ATHENA_BASE_DIR"
	ATHENA_BASE_DIR=$curr_base_dir
}

function testcase_athena.os.get_base_lib_dir()
{
	curr_base_lib_dir=$ATHENA_BASE_LIB_DIR
	ATHENA_BASE_LIB_DIR="/my/path/to/somewhere/"
	bashunit.test.assert_output "athena.os.get_base_lib_dir" "$ATHENA_BASE_LIB_DIR"
	ATHENA_BASE_LIB_DIR=$curr_base_lib_dir
}

function testcase_athena.os.get_prefix()
{
	curr_prefix=$ATHENA_PREFIX
	ATHENA_PREFIX="myprefix"
	bashunit.test.assert_output "athena.os.get_prefix" "$ATHENA_PREFIX"
	ATHENA_PREFIX=$curr_prefix
}

function testcase_athena.os._set_no_logo()
{
	curr_no_logo=$ATHENA_NO_LOGO
	athena.os._set_no_logo 1
	bashunit.test.assert_value "$ATHENA_NO_LOGO" 1

	athena.os._set_no_logo 0
	bashunit.test.assert_value "$ATHENA_NO_LOGO" 0
	ATHENA_NO_LOGO=$curr_no_logo
}

function testcase_athena.os.split_string()
{
	local test_string="something:with:colons:   as separator"
	local -a test_string_as_array=(something with colons "   as separator")
	local -a test_result
	athena.os.split_string "$test_string" ":" test_result
	bashunit.test.assert_array test_result test_string_as_array

	test_string_as_array=("$test_string")
	athena.os.split_string "$test_string" "/" test_result
	bashunit.test.assert_array test_result test_string_as_array
}

function testcase_athena.os.call_with_args()
{
	athena.argument.set_arguments one two three

	bashunit.test.assert_exit_code.expects_fail "athena.os.call_with_args" 1
	bashunit.test.assert_exit_code.expects_fail "athena.os.call_with_args" 1 'this wont exist as command or function'
	bashunit.test.assert_exit_code "athena.os.call_with_args" 'echo'

	bashunit.test.assert_output "athena.os.call_with_args" "one two three" "echo"
	bashunit.test.assert_output "athena.os.call_with_args" "two" "_my_os_call_with_args_and_return_second_element"
	athena.argument.set_arguments one "who let the dogs out" two three
	bashunit.test.assert_output "athena.os.call_with_args" "who let the dogs out" "_my_os_call_with_args_and_return_second_element"
}

#### aux functions
function _my_os_call_with_args_and_return_second_element()
{
	echo -n "${2}"
}

function _my_os_athena.mynamespace.get_valtwo()
{
	athena.os.return "hellofromtheoutside"
}
function _my_os_mock()
{
	athena.os.return "teste"
}

function _my_os_trap()
{
	echo "$@"
}

function _my_os_spinpans()
{
	athena.os.return "good morning"
}

function _my_os_athena.get_val()
{
	athena.os.return "hello"
}


