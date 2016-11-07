function athena.get_current_script_dir()
{
	dirname "$BASHUNIT_TESTS_DIR"
}
curr_script_dir="$(athena.get_current_script_dir)"
source "$curr_script_dir/bootstrap/variables.sh"
source "$curr_script_dir/bootstrap/host.functions.sh"
