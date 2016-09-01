function testcase_athena.example()
{
	# asserting values
	athena.test.assert_value "One" "One"
	athena.test.assert_value.expects_fail "One" "Two"

	# asserting return of functions
	athena.test.assert_return "_my_function" "pass"
	athena.test.assert_return.expects_fail "_my_function" "fail"

	# asserting output of functions
	athena.test.assert_output "_my_function" "OK" "pass"
	athena.test.assert_output.expects_fail "_my_function" "OK" "fail"

	# asserting exit codes
	athena.test.assert_exit_code "_my_function_with_exit_0"
	athena.test.assert_exit_code.expects_fail "_my_function_with_exit_1"

	# mocking
	athena.test.mock "_my_function" "_my_mock"
	athena.test.assert_output "_my_function" "Now i am the mock"
	athena.test.assert_exit_code.expects_fail "_my_function"

	athena.test.mock.returns "my_mock" 3
	athena.test.assert_return.expects_fail "my_mock"

	athena.test.mock.outputs "my_mock" "my string"
	athena.test.assert_output "my_mock" "my string"

	athena.test.mock.exits "my_mock" 0
	athena.test.assert_exit_code "my_mock"

	athena.test.mock.exits "my_mock" 1
	athena.test.assert_exit_code.expects_fail "my_mock"

	athena.test.mock.outputs "_my_function" "my new string"
	athena.test.assert_output "_my_function" "my new string"

	athena.test.mock.returns "_my_function" 0
	athena.test.assert_return "_my_function"


	local multiline_string=$(cat <<EOF
{
	"key": {}
}
EOF
)
	athena.test.assert_output "_my_echo" "$multiline_string" "$multiline_string"
	athena.test.assert_output "_my_echo_arguments" "$multiline_string" "$multiline_string"

	athena.test.assert_string_contains "my string" "my"
	athena.test.assert_string_contains.expects_fail "my string" "xpto"

	multiline_string="$(cat <<EOF
	my string: [xpto]
EOF
)"
	athena.test.assert_string_contains "$multiline_string" "xpto]"
	athena.test.assert_string_contains.expects_fail "$multiline_string" "xpto2]"
}

function _my_echo()
{
	echo -n "$1"
}

function _my_echo_arguments()
{
	echo -n "$@"
}

function _my_mock()
{
	echo "Now i am the mock"
	return 1
}

function _my_function()
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

function _my_function_with_exit_0()
{
	exit 0
}

function _my_function_with_exit_1()
{
	exit 1
}
