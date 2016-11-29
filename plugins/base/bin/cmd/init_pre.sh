CMD_DESCRIPTION="Initialise plugin for the first time."

echo
echo "======================== SELF-CHECK ========================="
if ! which git 1>/dev/null 2>/dev/null ; then
	athena.fatal "git is not installed! Please install git."
fi
athena.ok "git is installed."

if ! which docker 1>/dev/null 2>/dev/null ; then
	athena.fatal "docker is not installed! Please install docker."
fi
athena.ok "docker is installed."

ip=$(athena.docker.get_ip)
if athena.os.is_mac && [[ "$ip" != "127.0.0.1" ]]; then
	# this means docker-machine is being used instead of the native version (docker for mac)
	if [ -z "$DOCKER_MACHINE_NAME" ]; then
		msg=$(printf "docker environment is not setted! Please start docker-machine and run 'eval \$(docker-machine env default)'.")
		athena.fatal "$msg"
	fi
fi

if ! athena.docker ps 1>/dev/null; then
	athena.fatal "docker is not running! Please start docker daemon."
fi
athena.ok "docker is running."

athena.plugins.base.check "$(athena.plugin.get_plg_cmd_dir)"
if [ $? -ne 0 ]; then
	athena.fatal "problem found with system!"
fi
athena.ok "all called functions exist (athena built-in only)."

echo "============================================================="
athena.print "green" "All systems are GO. Enjoy!"
athena.os._check_athena_in_path "$SHELL"
echo "============================================================="
