CMD_DESCRIPTION="Removes all custom docker images related to athena."

athena.print "red" "[Warning] " "Are you sure that you want to remove all athena custom images/containers (y/N)?"
read answer
if [[ "$answer" = "y" ]]; then
	athena.docker images | grep "$ATHENA_PLG_IMAGE_NAME" | while read img
	do
		image=$(echo $img | awk '{ print $1 }')
		version=$(echo $img | awk '{ print $2 }')
		athena.info "Deleting '$image:$version'..."
		athena.docker.remove_container_and_image $image $version
		if [ $? -ne 0 ]; then
			athena.error "Failed to remove '$img'."
		fi
	done
fi
