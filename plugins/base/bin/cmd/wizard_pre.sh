CMD_DESCRIPTION="Wizard for creating plugins or commands."

athena.usage 1 "start [<name_of_the_plugin>]"

# arguments are found below
name_of_the_plugin="$(athena.arg 2)"

if [ -n "$name_of_the_plugin" ]; then
	athena.plugins.base.wizard.commands "$name_of_the_plugin"
else
	athena.plugins.base.wizard.plugin
fi
