#!/bin/bash

# includes
source $ATHENA_BASE_SHARED_LIB_DIR/bootstrap.functions.sh

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
operation_file="$CMD_DIR/$ATHENA_COMMAND.sh"
if [ -f $operation_file ]; then
	source $operation_file
	athena.os.exit $?
fi

athena.os.exit_with_msg "Unrecognized operation '$ATHENA_COMMAND'."
