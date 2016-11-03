function testcase_athena.fs.get_full_path()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.get_full_path" ""
	bashunit.test.assert_exit_code.expects_fail "athena.fs.get_full_path" "/file/not/existing"

	# full path
	base=$(bashunit.test.create_tempdir)
	bashunit.test.assert_output "athena.fs.get_full_path" "$base" "$base"


	# relative path directory
	mkdir $base/test
	cd $base
	bashunit.test.assert_output "athena.fs.get_full_path" "$base/test" "./test"
	rm -r $base

	# relative path file
	tmpfile=$(bashunit.test.create_tempfile)
	base="$(dirname $tmpfile)"
	cd $base 
	bashunit.test.assert_output "athena.fs.get_full_path" "$base" "$(basename $tmpfile)"
	rm $tmpfile
}

function testcase_athena.fs.absolutepath()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.absolutepath" "/non/existing/dir"

	tmpfile=$(bashunit.test.create_tempfile)
	bashunit.test.assert_output "athena.fs.absolutepath" "$tmpfile" "$tmpfile"
	rm $tmpfile
}

function testcase_athena.fs.file_exists_or_fail()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.file_exists_or_fail" "/non/existing/file"

	tmpfile=$(bashunit.test.create_tempfile)
	bashunit.test.assert_exit_code "athena.fs.file_exists_or_fail" "$tmpfile"
	rm $tmpfile
}

function testcase_athena.fs.dir_exists_or_fail()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.dir_exists_or_fail" "/non/existing/dir"

	tmpfile=$(bashunit.test.create_tempdir)
	bashunit.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$tmpfile"
	rm -r $tmpfile

	bashunit.test.mock "athena.os.exit_with_msg" "_echo_arguments"
	bashunit.test.assert_output "athena.fs.dir_exists_or_fail" "My custom message" "/non/existing/dir" "My custom message"
}

function testcase_athena.fs.dir_exists_or_create()
{
	tmpdir="$HOME/xpto$(date +%s)"
	bashunit.test.assert_exit_code "athena.fs.dir_exists_or_create" "$tmpdir"
	bashunit.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$tmpdir"
	rm -r $tmpdir
}

function testcase_athena.fs.get_file_contents()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.get_file_contents" "/non/existing-file"

	tmpfile=$(bashunit.test.create_tempfile)
	echo "spinpans" > $tmpfile
	bashunit.test.assert_output "athena.fs.get_file_contents" "spinpans" $tmpfile
	rm $tmpfile
}

function testcase_athena.fs.file_contains_string()
{
	tmpfile=$(bashunit.test.create_tempfile)
	echo "spinpans" > $tmpfile
	bashunit.test.assert_exit_code "athena.fs.file_contains_string" $tmpfile "spinpans"
	bashunit.test.assert_exit_code.expects_fail "athena.fs.file_contains_string" $tmpfile "other"
	rm $tmpfile
}

function testcase_athena.fs.dir_contains_files()
{
	bashunit.test.assert_exit_code.expects_fail "athena.fs.dir_contains_files" "/path/to/non/existent/dir"
	tmpdir=$(bashunit.test.create_tempdir)
	bashunit.test.assert_exit_code.expects_fail "athena.fs.dir_contains_files" "$tmpdir"
	bashunit.test.assert_return.expects_fail "athena.fs.dir_contains_files" "$tmpdir" "*.sh"

	touch "$tmpdir/test.sh"
	bashunit.test.assert_return "athena.fs.dir_contains_files" "$tmpdir" "*.sh"
	bashunit.test.assert_return "athena.fs.dir_contains_files" "$tmpdir" "test?(_pre|_post).sh"

	rm -r $tmpdir
}

function testcase_athena.fs.get_cache_dir()
{
	local home=$HOME
	local tmpdir=$(bashunit.test.create_tempdir)
	HOME=$tmpdir
	bashunit.test.mock.returns "athena.fs.dir_exists_or_create" 0
	bashunit.test.assert_output "athena.fs.get_cache_dir" "$tmpdir/.athena"

	HOME="$tmpdir/nonexistingpath"
	bashunit.test.assert_exit_code.expects_fail "athena.fs.dir_exists_or_fail" "$HOME"
	bashunit.test.unmock "athena.fs.dir_exists_or_create"
	bashunit.test.assert_output "athena.fs.get_cache_dir" "$tmpdir/nonexistingpath/.athena"
	bashunit.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$HOME"

	HOME=$home
}

function _echo_arguments()
{
	echo -n "$@"
}
