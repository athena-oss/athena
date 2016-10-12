function testcase_athena.fs.get_full_path()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.get_full_path" ""
	athena.test.assert_exit_code.expects_fail "athena.fs.get_full_path" "/file/not/existing"

	# full path
	base=$(athena.test.create_tempdir)
	athena.test.assert_output "athena.fs.get_full_path" "$base" "$base"


	# relative path directory
	mkdir $base/test
	cd $base
	athena.test.assert_output "athena.fs.get_full_path" "$base/test" "./test"
	rm -r $base

	# relative path file
	tmpfile=$(athena.test.create_tempfile)
	base="$(dirname $tmpfile)"
	cd $base 
	athena.test.assert_output "athena.fs.get_full_path" "$base" "$(basename $tmpfile)"
	rm $tmpfile
}

function testcase_athena.fs.absolutepath()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.absolutepath" "/non/existing/dir"

	tmpfile=$(athena.test.create_tempfile)
	athena.test.assert_output "athena.fs.absolutepath" "$tmpfile" "$tmpfile"
	rm $tmpfile
}

function testcase_athena.fs.file_exists_or_fail()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.file_exists_or_fail" "/non/existing/file"

	tmpfile=$(athena.test.create_tempfile)
	athena.test.assert_exit_code "athena.fs.file_exists_or_fail" "$tmpfile"
	rm $tmpfile
}

function testcase_athena.fs.dir_exists_or_fail()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.dir_exists_or_fail" "/non/existing/dir"

	tmpfile=$(athena.test.create_tempdir)
	athena.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$tmpfile"
	rm -r $tmpfile

	athena.test.mock "athena.os.exit_with_msg" "_echo_arguments"
	athena.test.assert_output "athena.fs.dir_exists_or_fail" "My custom message" "/non/existing/dir" "My custom message"
}

function testcase_athena.fs.dir_exists_or_create()
{
	tmpdir="$HOME/xpto$(date +%s)"
	athena.test.assert_exit_code "athena.fs.dir_exists_or_create" "$tmpdir"
	athena.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$tmpdir"
	rm -r $tmpdir
}

function testcase_athena.fs.get_file_contents()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.get_file_contents" "/non/existing-file"

	tmpfile=$(athena.test.create_tempfile)
	echo "spinpans" > $tmpfile
	athena.test.assert_output "athena.fs.get_file_contents" "spinpans" $tmpfile
	rm $tmpfile
}

function testcase_athena.fs.file_contains_string()
{
	tmpfile=$(athena.test.create_tempfile)
	echo "spinpans" > $tmpfile
	athena.test.assert_exit_code "athena.fs.file_contains_string" $tmpfile "spinpans"
	athena.test.assert_exit_code.expects_fail "athena.fs.file_contains_string" $tmpfile "other"
	rm $tmpfile
}

function testcase_athena.fs.get_path_from_string_or_argument()
{
	tmpdir=$(athena.test.create_tempdir)

	touch $tmpdir/file1.txt
	touch $tmpdir/file2.txt

	athena.argument.set_arguments "$tmpdir/file1.txt" "--path=$tmpdir/file2.txt"

	athena.test.assert_output "athena.fs.get_path_from_string_or_argument" "$tmpdir/file1.txt" "1"
	athena.test.assert_output "athena.fs.get_path_from_string_or_argument" "$tmpdir/file2.txt" "--path"
	athena.test.assert_exit_code.expects_fail "athena.fs.get_path_from_string_or_argument" "3"

	rm -r $tmpdir
}

function testcase_athena.fs.dir_contains_files()
{
	athena.test.assert_exit_code.expects_fail "athena.fs.dir_contains_files" "/path/to/non/existent/dir"
	tmpdir=$(athena.test.create_tempdir)
	athena.test.assert_exit_code.expects_fail "athena.fs.dir_contains_files" "$tmpdir"
	athena.test.assert_return.expects_fail "athena.fs.dir_contains_files" "$tmpdir" "*.sh"

	touch "$tmpdir/test.sh"
	athena.test.assert_return "athena.fs.dir_contains_files" "$tmpdir" "*.sh"
	athena.test.assert_return "athena.fs.dir_contains_files" "$tmpdir" "test?(_pre|_post).sh"

	rm -r $tmpdir
}

function testcase_athena.fs.get_cache_dir()
{
	local home=$HOME
	local tmpdir=$(athena.test.create_tempdir)
	HOME=$tmpdir
	athena.test.mock.returns "athena.fs.dir_exists_or_create" 0
	athena.test.assert_output "athena.fs.get_cache_dir" "$tmpdir/.athena"

	HOME="$tmpdir/nonexistingpath"
	athena.test.assert_exit_code.expects_fail "athena.fs.dir_exists_or_fail" "$HOME"
	athena.test.unmock "athena.fs.dir_exists_or_create"
	athena.test.assert_output "athena.fs.get_cache_dir" "$tmpdir/nonexistingpath/.athena"
	athena.test.assert_exit_code "athena.fs.dir_exists_or_fail" "$HOME"

	HOME=$home
}

function _echo_arguments()
{
	echo -n "$@"
}
