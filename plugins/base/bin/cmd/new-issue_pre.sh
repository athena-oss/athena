CMD_DESCRIPTION="Prints the GitHub issue Markdown template."

function _itemized_plugins_name_and_version()
{
	for dir_name in $(ls $ATHENA_PLGS_DIR); do
		local version="$(cat $ATHENA_PLGS_DIR/$dir_name/version.txt)"
		echo "${dir_name},${version}"
	done
}

# check that docker is up or exit with a message
athena.docker >/dev/null

echo "**Athena Environment**"
echo "\`\`\`"
echo "OS: $(uname -a)"
echo "Athena version: $ATHENA_PLG_IMAGE_VERSION"
echo "Plugins: " ; _itemized_plugins_name_and_version | awk -F, '{ print " - " $1 " [" $2 "]" }'
echo "Images: " ; athena.docker images | grep "$ATHENA_PLG_IMAGE_NAME" | awk -F" " '{ print " - " $1 " ["$2"] " $3 }'
echo "Running containers: " ; athena.docker.list_athena_containers | awk -F "->" '{ print " - " $1 }'
echo "\`\`\`"
