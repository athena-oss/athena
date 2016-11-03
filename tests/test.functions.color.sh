function testcase_athena.color.print_info()
{
	expected=$(printf "\033[94m[INFO]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_info" "$expected" "test"
}

function testcase_athena.color.print_error()
{
	expected=$(printf "\033[31m[ERROR]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_error" "$expected" "test"
}

function testcase_athena.color.print_ok()
{
	expected=$(printf "\033[32m[OK]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_ok" "$expected" "test"
}

function testcase_athena.color.print_warn()
{
	expected=$(printf "\033[43m[WARN]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_warn" "$expected" "test"
}

function testcase_athena.color.print_fatal()
{
	expected=$(printf "\033[31m[FATAL]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_fatal" "$expected" "test"
	bashunit.test.assert_exit_code.expects_fail "athena.color.print_fatal" "$expected" "test"
}

function testcase_athena.color.print_debug()
{
	if athena.os.is_debug_active ; then
		current_debug_mode=1
	else
		current_debug_mode=0
	fi

	athena.os.set_debug 1
	expected=$(printf "\033[36m[DEBUG]\033[m test\n")
	bashunit.test.assert_output "athena.color.print_debug" "$expected" "test"

	athena.os.set_debug 0
	bashunit.test.assert_output "athena.color.print_debug" "" "test"
	athena.os.set_debug $current_debug_mode
}

function testcase_athena.color.print_color()
{
	bashunit.test.assert_output "athena.color.print_color" "test" "other" "test"
}
