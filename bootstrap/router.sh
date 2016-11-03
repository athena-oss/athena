#!/bin/bash

ATHENA_IS_INSIDE_CONTAINER=1

# includes
source /opt/bootstrap/shared.functions.sh

athena.os.set_command "$1"
shift

athena.argument.set_arguments "$@"

if [ -f "$LIB_DIR/functions.container.sh" ]; then
	source "$LIB_DIR/functions.container.sh"
fi

if [ -f "$BIN_DIR/variables.container.sh" ]; then
	source "$BIN_DIR/variables.container.sh"
fi

# routing
declare -a cmd_dirs
athena.os.split_string "$CMD_DIR" ":" cmd_dirs

for cmd_dir in "${cmd_dirs[@]}"; do
  operation_file="$cmd_dir/$ATHENA_COMMAND.sh"
  if [ -f $operation_file ]; then
    source $operation_file
    athena.os.exit $?
  fi
done

athena.os.exit_with_msg "Unrecognized operation '$ATHENA_COMMAND'."
