CMD_DESCRIPTION="Runs command line TestSuites."

athena.usage 1 "<testsuite_directory|file> [source_directory [list]] Executes the Testuite."

target=$(athena.path 1)
msg="Running CLI tests located for '$target'"
athena.os.include_once $(athena.os.get_base_lib_dir)/functions.test.sh
athena.info "$msg"

# handling coverage
lib_dir=$(athena.arg 2)
if athena.arg_exists "$lib_dir" && athena.dir_exists_or_fail "$lib_dir" ; then
	show_list=0
	if athena.arg_exists 'list' ; then
		show_list=1
	fi

	athena.dir_exists_or_fail $target
	athena.test.show_coverage $lib_dir $target $show_list
fi
athena.test.run_suite $target
