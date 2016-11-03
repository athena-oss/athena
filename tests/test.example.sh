function testcase_athena.example()
{
	# asserting values
	bashunit.test.assert_value "One" "One"
	bashunit.test.assert_value.expects_fail "One" "Two"

	# asserting return of functions
	bashunit.test.assert_return "_my_example_function" "pass"
	bashunit.test.assert_return.expects_fail "_my_example_function" "fail"

	# asserting output of functions
	bashunit.test.assert_output "_my_example_function" "OK" "pass"
	bashunit.test.assert_output.expects_fail "_my_example_function" "OK" "fail"

	# asserting exit codes
	bashunit.test.assert_exit_code "_my_example_function_with_exit_0"
	bashunit.test.assert_exit_code.expects_fail "_my_example_function_with_exit_1"

	# mocking
	bashunit.test.mock "_my_example_function" "_my_example_mock"
	bashunit.test.assert_output "_my_example_function" "Now i am the mock"
	bashunit.test.assert_exit_code.expects_fail "_my_example_function"

	bashunit.test.mock.returns "my_mock" 3
	bashunit.test.assert_return.expects_fail "my_mock"

	bashunit.test.mock.outputs "my_mock" "my string"
	bashunit.test.assert_output "my_mock" "my string"

	bashunit.test.mock.exits "my_mock" 0
	bashunit.test.assert_exit_code "my_mock"

	bashunit.test.mock.exits "my_mock" 1
	bashunit.test.assert_exit_code.expects_fail "my_mock"

	bashunit.test.mock.outputs "_my_example_function" "my new string"
	bashunit.test.assert_output "_my_example_function" "my new string"

	bashunit.test.mock.returns "_my_example_function" 0
	bashunit.test.assert_return "_my_example_function"


	local multiline_string=$(cat <<EOF
{
	"key": {}
}
EOF
)
	bashunit.test.assert_output "_my_example_echo" "$multiline_string" "$multiline_string"
	bashunit.test.assert_output "_my_example_echo_arguments" "$multiline_string" "$multiline_string"

	bashunit.test.assert_string_contains "my string" "my"
	bashunit.test.assert_string_contains.expects_fail "my string" "xpto"

	multiline_string="$(cat <<EOF
	my string: [xpto]
EOF
)"
	bashunit.test.assert_string_contains "$multiline_string" "xpto]"
	bashunit.test.assert_string_contains.expects_fail "$multiline_string" "xpto2]"
}

function _my_example_echo()
{
	echo -n "$1"
}

function _my_example_echo_arguments()
{
	echo -n "$@"
}

function _my_example_mock()
{
	echo "Now i am the mock"
	return 1
}

function _my_example_function()
{
	case $1 in
		"fail")
			echo "NOT OK"
			return 1
			;;
		*)
			echo "OK"
			return 0
			;;
	esac
}

function _my_example_function_with_exit_0()
{
	exit 0
}

function _my_example_function_with_exit_1()
{
	exit 1
}
