function testcase_athena.utils.add_to_array()
{
	local myarray=()
	athena.utils.add_to_array "myarray" "xpto"
	local -a expected_array=(xpto)
	athena.test.assert_array expected_array myarray
	myarray=()
	expected_array=()
	athena.test.assert_array expected_array myarray
	expected_array=(one two three)
	athena.utils.add_to_array "myarray" one two three
	athena.test.assert_array expected_array myarray

	myarray=()
	athena.test.assert_return "athena.utils.add_to_array" "myarray" "one"
}

function testcase_athena.utils.preprend_to_array()
{
	local myarray=(two)
	athena.utils.prepend_to_array "myarray" "one"
	local -a expected_array=(one two)
	athena.test.assert_array expected_array myarray

	athena.utils.prepend_to_array "myarray" "other with spaces"
	local -a expected_array=("other with spaces" one two)
	athena.test.assert_array expected_array myarray
}

function testcase_athena.utils.set_array()
{
	local myarray=()
	athena.utils.set_array "myarray" one two three
	local -a expected_array=(one two three)
	athena.test.assert_array expected_array myarray

	local -a expected_array=()
	athena.utils.set_array "myarray"
	athena.test.assert_array expected_array myarray

	myarray=()
	athena.utils.set_array "myarray" one four "other spaced"
	local -a expected_array=(one four "other spaced")
	athena.test.assert_array expected_array myarray

	myarray=()
	athena.utils.set_array "myarray" one four --myarg="other spaced"
	local -a expected_array=(one four --myarg="other spaced")
	athena.test.assert_array expected_array myarray
}

function testcase_athena.utils.get_array()
{
	local -a myarray=(one four two)
	local -a expected_array=()
	athena.utils.get_array "myarray" "expected_array"
	athena.test.assert_array expected_array myarray
	athena.test.assert_output "athena.utils.get_array" "one four two" "myarray"
}

function testcase_athena.utils.array_pop()
{
	local -a myarray=(one two three)
	local -a expected_array=(two three)
	athena.utils.array_pop "myarray"
	athena.test.assert_array expected_array myarray

	myarray=(one two three)
	local -a expected_array=(three)
	athena.utils.array_pop "myarray" 2
	athena.test.assert_array expected_array myarray
}

function testcase_athena.utils.in_array()
{
	local -a myarray=(one two three)
	athena.test.assert_return "athena.utils.in_array" "myarray" "three"
	athena.test.assert_return.expects_fail "athena.utils.in_array" "myarray" "thr"
	athena.test.assert_return "athena.utils.in_array" "myarray" "thr" 0
}
