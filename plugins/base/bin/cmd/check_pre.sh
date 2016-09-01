CMD_DESCRIPTION="Validates a file or directory for possible issues."

athena.usage 1 "<file|directory>"

if athena.plugins.base.check "$(athena.path 1)" ; then
	athena.ok "passed check"
	athena.exit 0
fi
athena.fatal "failed check"
