CMD_DESCRIPTION="Stops all athena related containers."

athena.info "Do you want to stop all containers (Y/n)?"
read answer
if [[ "$answer" = "n" ]]; then
	return 1
fi

athena.docker.list_athena_containers | while read container
do
	name=$(echo $container | awk -F':' '{ print $1 }')
	athena.docker.stop_container $name
done
