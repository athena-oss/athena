CMD_DESCRIPTION="Print information about docker containers and images related to athena."

function _list_running_containers()
{
	local docker_ip
	local containers
	docker_ip=${ATHENA_DOCKER_IP:-$(athena.docker.get_ip)}
	containers=$(athena.docker.list_athena_containers)

	if [ -z "$containers" ]; then
		athena.info "No containers are UP!"
		return 0
	fi

	local name
	local ports
	local image
	local status
	athena.info "Running containers [image|container|status]:"
	echo
	echo  "$containers" | tr ' ' '\n' | grep -v "^$" | while read container; do
		name=$(echo $container | awk -F':' '{ print $1 }')
		ports=$(echo $container | awk -F':' '{ print $2 }' | tr ',' '\n' | awk -F"->" '{ print $1}' | tr '\n' ',' | sed 's#,$##g')
		image=$(echo $container | awk -F':' '{ print $3 }')
		athena.docker.is_container_running $name
		if [ $? -eq 0 ]; then
			status=$(athena.print "green" "[UP]")
		else
			status=$(athena.print "red" "[DOWN]")
		fi
		if [[ "$container" =~ .*-\>.* ]]; then
			if [[ "$container" =~ .*-node-.* ]]; then
				printf " * ${image}_${name}_${status}_To access it use vnc://$docker_ip:$ports. Password is 'secret'.\n"
			else
				printf " * ${image}_${name}_${status}_To access it use http://$docker_ip:$ports\n"
			fi
		else
			printf " * ${image}_${name}_${status}\n"
		fi
	done | column -t -s_
	echo
	echo
}

function _list_images()
{
	local images
	images=$(athena.docker images | grep "$ATHENA_PLG_IMAGE_NAME")
	if [ -z "$images" ]; then
		athena.info "No custom images were found!"
		return
	fi

	athena.info "Images [image|version|hash|date|size]:"
	echo
	echo "$images" | while read img
	do
		echo " * $img"
	done
	echo
	athena.print "red" "[NOTE] " "If you wish to remove any of the previous images please use the command:"
	echo
	echo "$SUDO docker rmi <name_of_image>:<version>"
}

_list_running_containers
_list_images
