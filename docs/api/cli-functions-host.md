* [Using CLI Functions](#using-cli-functions)
  * [Handling *docker*](#handling-docker)
    * [`athena.docker`](#athenadocker)
    * [`athena.docker.add_autoremove`](#athenadockeraddautoremove)
    * [`athena.docker.add_daemon`](#athenadockeradddaemon)
    * [`athena.docker.add_env`](#athenadockeraddenv)
    * [`athena.docker.add_envs_from_file`](#athenadockeraddenvsfromfile)
    * [`athena.docker.add_envs_with_prefix`](#athenadockeraddenvswithprefix)
    * [`athena.docker.add_option`](#athenadockeraddoption)
    * [`athena.docker.build`](#athenadockerbuild)
    * [`athena.docker.build_container`](#athenadockerbuildcontainer)
    * [`athena.docker.build_from_plugin`](#athenadockerbuildfromplugin)
    * [`athena.docker.cleanup`](#athenadockercleanup)
    * [`athena.docker.container_has_started`](#athenadockercontainerhasstarted)
    * [`athena.docker.exec`](#athenadockerexec)
    * [`athena.docker.get_build_args`](#athenadockergetbuildargs)
    * [`athena.docker.get_build_args_file`](#athenadockergetbuildargsfile)
    * [`athena.docker.get_ip`](#athenadockergetip)
    * [`athena.docker.get_ip_for_container`](#athenadockergetipforcontainer)
    * [`athena.docker.get_options`](#athenadockergetoptions)
    * [`athena.docker.get_tag_and_version`](#athenadockergettagandversion)
    * [`athena.docker.handle_run_type`](#athenadockerhandleruntype)
    * [`athena.docker.has_option`](#athenadockerhasoption)
    * [`athena.docker.image_exists`](#athenadockerimageexists)
    * [`athena.docker.images`](#athenadockerimages)
    * [`athena.docker.inspect`](#athenadockerinspect)
    * [`athena.docker.is_container_running`](#athenadockeriscontainerrunning)
    * [`athena.docker.is_current_container_not_running_or_fail`](#athenadockeriscurrentcontainernotrunningorfail)
    * [`athena.docker.is_current_container_running`](#athenadockeriscurrentcontainerrunning)
    * [`athena.docker.is_default_router_to_be_used`](#athenadockerisdefaultroutertobeused)
    * [`athena.docker.is_running_as_daemon`](#athenadockerisrunningasdaemon)
    * [`athena.docker.list_athena_containers`](#athenadockerlistathenacontainers)
    * [`athena.docker.logs`](#athenadockerlogs)
    * [`athena.docker.mount`](#athenadockermount)
    * [`athena.docker.mount_dir`](#athenadockermountdir)
    * [`athena.docker.mount_dir_from_plugin`](#athenadockermountdirfromplugin)
    * [`athena.docker.print_or_follow_container_logs`](#athenadockerprintorfollowcontainerlogs)
    * [`athena.docker.remove_container_and_image`](#athenadockerremovecontainerandimage)
    * [`athena.docker.rm`](#athenadockerrm)
    * [`athena.docker.rmi`](#athenadockerrmi)
    * [`athena.docker.run`](#athenadockerrun)
    * [`athena.docker.run_container`](#athenadockerruncontainer)
    * [`athena.docker.run_container_with_default_router`](#athenadockerruncontainerwithdefaultrouter)
    * [`athena.docker.set_no_default_router`](#athenadockersetnodefaultrouter)
    * [`athena.docker.set_options`](#athenadockersetoptions)
    * [`athena.docker.stop_all_containers`](#athenadockerstopallcontainers)
    * [`athena.docker.stop_container`](#athenadockerstopcontainer)
    * [`athena.docker.wait_for_string_in_container_logs`](#athenadockerwaitforstringincontainerlogs)
    * [`athena.plugin.build`](#athenapluginbuild)
  * [Handling *plugin*](#handling-plugin)
    * [`athena.plugin.build`](#athenapluginbuild)
    * [`athena.plugin.check_dependencies`](#athenaplugincheckdependencies)
    * [`athena.plugin.get_available_cmds`](#athenaplugingetavailablecmds)
    * [`athena.plugin.get_container_name`](#athenaplugingetcontainername)
    * [`athena.plugin.get_container_to_use`](#athenaplugingetcontainertouse)
    * [`athena.plugin.get_environment`](#athenaplugingetenvironment)
    * [`athena.plugin.get_environment_build_file`](#athenaplugingetenvironmentbuildfile)
    * [`athena.plugin.get_image_name`](#athenaplugingetimagename)
    * [`athena.plugin.get_image_version`](#athenaplugingetimageversion)
    * [`athena.plugin.get_plg`](#athenaplugingetplg)
    * [`athena.plugin.get_plg_bin_dir`](#athenaplugingetplgbindir)
    * [`athena.plugin.get_plg_cmd_dir`](#athenaplugingetplgcmddir)
    * [`athena.plugin.get_plg_dir`](#athenaplugingetplgdir)
    * [`athena.plugin.get_plg_docker_dir`](#athenaplugingetplgdockerdir)
    * [`athena.plugin.get_plg_hooks_dir`](#athenaplugingetplghooksdir)
    * [`athena.plugin.get_plg_lib_dir`](#athenaplugingetplglibdir)
    * [`athena.plugin.get_plg_version`](#athenaplugingetplgversion)
    * [`athena.plugin.get_plugin`](#athenaplugingetplugin)
    * [`athena.plugin.get_plugins_dir`](#athenaplugingetpluginsdir)
    * [`athena.plugin.get_prefix_for_container_name`](#athenaplugingetprefixforcontainername)
    * [`athena.plugin.get_shared_lib_dir`](#athenaplugingetsharedlibdir)
    * [`athena.plugin.get_subplg_version`](#athenaplugingetsubplgversion)
    * [`athena.plugin.get_tag_name`](#athenaplugingettagname)
    * [`athena.plugin.handle`](#athenapluginhandle)
    * [`athena.plugin.handle_container`](#athenapluginhandlecontainer)
    * [`athena.plugin.handle_environment`](#athenapluginhandleenvironment)
    * [`athena.plugin.init`](#athenaplugininit)
    * [`athena.plugin.is_environment_specified`](#athenapluginisenvironmentspecified)
    * [`athena.plugin.plugin_exists`](#athenapluginpluginexists)
    * [`athena.plugin.print_available_cmds`](#athenapluginprintavailablecmds)
    * [`athena.plugin.require`](#athenapluginrequire)
    * [`athena.plugin.run_command`](#athenapluginruncommand)
    * [`athena.plugin.run_container`](#athenapluginruncontainer)
    * [`athena.plugin.set_container_name`](#athenapluginsetcontainername)
    * [`athena.plugin.set_environment`](#athenapluginsetenvironment)
    * [`athena.plugin.set_environment_build_file`](#athenapluginsetenvironmentbuildfile)
    * [`athena.plugin.set_image_name`](#athenapluginsetimagename)
    * [`athena.plugin.set_image_version`](#athenapluginsetimageversion)
    * [`athena.plugin.set_plg_cmd_dir`](#athenapluginsetplgcmddir)
    * [`athena.plugin.set_plugin`](#athenapluginsetplugin)
    * [`athena.plugin.use_container`](#athenapluginusecontainer)
    * [`athena.plugin.use_external_container_as_daemon`](#athenapluginuseexternalcontainerasdaemon)
    * [`athena.plugin.validate_plugin_name`](#athenapluginvalidatepluginname)
    * [`athena.plugin.validate_usage`](#athenapluginvalidateusage)
    * [`athena.plugin.validate_version`](#athenapluginvalidateversion)
    * [`athena.plugin.validate_version_format`](#athenapluginvalidateversionformat)
  * [Handling *test*](#handling-test)
    * [`athena.test.assert_array`](#athenatestassertarray)
    * [`athena.test.assert_exit_code`](#athenatestassertexitcode)
    * [`athena.test.assert_exit_code.expects_fail`](#athenatestassertexitcodeexpectsfail)
    * [`athena.test.assert_output`](#athenatestassertoutput)
    * [`athena.test.assert_output.expects_fail`](#athenatestassertoutputexpectsfail)
    * [`athena.test.assert_return`](#athenatestassertreturn)
    * [`athena.test.assert_return.expects_fail`](#athenatestassertreturnexpectsfail)
    * [`athena.test.assert_string_contains`](#athenatestassertstringcontains)
    * [`athena.test.assert_string_contains.expects_fail`](#athenatestassertstringcontainsexpectsfail)
    * [`athena.test.assert_value`](#athenatestassertvalue)
    * [`athena.test.assert_value.expects_fail`](#athenatestassertvalueexpectsfail)
    * [`athena.test.create_tempdir`](#athenatestcreatetempdir)
    * [`athena.test.create_tempfile`](#athenatestcreatetempfile)
    * [`athena.test.mock`](#athenatestmock)
    * [`athena.test.mock.exits`](#athenatestmockexits)
    * [`athena.test.mock.outputs`](#athenatestmockoutputs)
    * [`athena.test.mock.returns`](#athenatestmockreturns)
    * [`athena.test.run_suite`](#athenatestrunsuite)
    * [`athena.test.show_coverage`](#athenatestshowcoverage)
    * [`athena.test.unmock`](#athenatestunmock)

# Using CLI Functions
 
## Handling *docker*
 
### <a name="athenadocker"></a>`athena.docker`
 
This is a wrapper function for executing docker, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker <args>`
 
**RETURN:** `--`
 
### <a name="athenadockeraddautoremove"></a>`athena.docker.add_autoremove`
 
This function adds the --rm flag (automatically remove the container when it exits) to the docker run option string ($ATHENA_DOCKER_OPTS).
 
**USAGE:**  `athena.docker.add_autoremove`
 
**RETURN:** `--`
 
### <a name="athenadockeradddaemon"></a>`athena.docker.add_daemon`
 
This function adds the daemon flag to the docker run option string ($ATHENA_DOCKER_OPTS).
 
**USAGE:**  `athena.docker.add_daemon`
 
**RETURN:** `--`
 
### <a name="athenadockeraddenv"></a>`athena.docker.add_env`
 
This function adds an environment variable to the docker run option string ($ATHENA_DOCKER_OPTS).
 
**USAGE:**  `athena.docker.add_env <variable name> <variable value>`
 
**RETURN:** `--`
 
### <a name="athenadockeraddenvsfromfile"></a>`athena.docker.add_envs_from_file`
 
This function adds environment variables from the given file (ini format).
 
**USAGE:**  `athena.docker.add_envs_from_file <filename>`
 
**RETURN:** `--`
 
### <a name="athenadockeraddenvswithprefix"></a>`athena.docker.add_envs_with_prefix`
 
This function adds environment variables with the given prefix to the docker run option string.
 
**USAGE:**  `athena.docker.add_envs_with_prefix <prefix>`
 
**RETURN:** `--`
 
### <a name="athenadockeraddoption"></a>`athena.docker.add_option`
 
This function adds the given option to the docker run option string ($ATHENA_DOCKER_OPTS).
 
**USAGE:**  `athena.docker.add_option <your option>`
 
**RETURN:** `--`
 
### <a name="athenadockerbuild"></a>`athena.docker.build`
 
This is a wrapper function for executing docker build, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.build <args>`
 
**RETURN:** `--`
 
### <a name="athenadockerbuildcontainer"></a>`athena.docker.build_container`
 
This function builds a docker image using the given tag name, version and docker directory (Dockerfile must exists in the given directory). If a docker image with tag:version already exists nothing is done. If not the function checks if it is in the right directory, loads build environment variables if provided (see athena.docker.get_build_args), and builds the docker image. If the function is called in a wrong directory or the build is unsuccessful execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.docker.build_container <tag name> <version> <docker directory>`
 
**RETURN:** `--`
 
### <a name="athenadockerbuildfromplugin"></a>`athena.docker.build_from_plugin`
 
This function builds a docker image for a plugin. Plugin name, sub-plugin name, and version must be provided. If no valid docker directory or Dockerfile is found execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.docker.build_from_plugin <plugin name> <sub-plugin name> <plugin version>`
 
**RETURN:** `--`
 
### <a name="athenadockercleanup"></a>`athena.docker.cleanup`
 
This function cleans up the container for the current plugin in case is not running.
 
**USAGE:**  `athena.docker.cleanup`
 
**RETURN:** `--`
 
### <a name="athenadockercontainerhasstarted"></a>`athena.docker.container_has_started`
 
This function checks if container has started
 
**USAGE:**  `athena.docker.container_has_started`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenadockerexec"></a>`athena.docker.exec`
 
This is a wrapper function for executing docker exec, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.exec <args>`
 
**RETURN:** `--`
 
### <a name="athenadockergetbuildargs"></a>`athena.docker.get_build_args`
 
This function generates and stores, in the given array, the build arguments from the build args file returned by athena.docker.get_build_args_file or does nothing if no file was found.
 
**USAGE:**  `athena.docker.get_build_args <array_name>`
 
**RETURN:** `string | 1 (false)`
 
### <a name="athenadockergetbuildargsfile"></a>`athena.docker.get_build_args_file`
 
This function checks if a docker build environment file is defined in the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable. If not it returns 1. If defined it checks if the file exists and returns the name of the file.
 
**USAGE:**  `athena.docker.get_build_args_file`
 
**RETURN:** `string | 1 (false)`
 
### <a name="athenadockergetip"></a>`athena.docker.get_ip`
 
This function returns the ip address of the docker machine. It checks for the 'docker-machine' and 'boot2docker' commands to do this (default on Mac). If not found it searches for the docker0 device (default on Linux) and returns the localhost ip if found. If no docker0 device is available the function assumes to run inside a docker container and checks if a docker daemon is running in this container. If so localhost is returned. If not it returns the default route ip address.
 
**USAGE:**  `athena.docker.get_ip`
 
**RETURN:** `string`
 
### <a name="athenadockergetipforcontainer"></a>`athena.docker.get_ip_for_container`
 
This function returns the container internal ip provided by docker.
 
**USAGE:**  `athena.docker.get_ip_for_container <container_name>`
 
**RETURN:** `string`
 
### <a name="athenadockergetoptions"></a>`athena.docker.get_options`
 
This function outputs the extra options to be passed for running docker. As an alternative you can also assign to a given array name.
 
**USAGE:**  `athena.docker.get_options [array_name]`
 
**RETURN:** `string`
 
### <a name="athenadockergettagandversion"></a>`athena.docker.get_tag_and_version`
 
### <a name="athenadockerhandleruntype"></a>`athena.docker.handle_run_type`
 
This function checks if either the daemon or the autoremove flag is set in the docker run option string ($ATHENA_DOCKER_OPTS). If one of both is set it returns the error code 0. If none is set it sets the autoremove flag (--rm) and returns the error code 1.
 
**USAGE:**  `athena.docker.handle_run_type`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenadockerhasoption"></a>`athena.docker.has_option`
 
This function checks if the given option is already set.
 
**USAGE:**  `athena.docker.has_option <option> [strict]`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenadockerimageexists"></a>`athena.docker.image_exists`
 
This function checks if a docker image with the given tag name and version exists.
 
**USAGE:**  `athena.docker.image_exists <image name> <version>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenadockerimages"></a>`athena.docker.images`
 
This is a wrapper function for executing docker images, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.images <args>`
 
**RETURN:** `--`
 
### <a name="athenadockerinspect"></a>`athena.docker.inspect`
 
This is a wrapper function for executing docker inspect, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.inspect <args>`
 
**RETURN:** `--`
 
### <a name="athenadockeriscontainerrunning"></a>`athena.docker.is_container_running`
 
This function checks if a docker container with the given name is running. If no container with the given name is running all stopped containers with this name are removed (to avoid collisions).
 
**USAGE:**  `athena.docker.is_container_running <container name>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenadockeriscurrentcontainernotrunningorfail"></a>`athena.docker.is_current_container_not_running_or_fail`
 
This function checks if the container assigned for running is already running and if it is then exits with an error message.
 
**USAGE:**  `athena.docker.is_current_container_not_running_or_fail [msg]`
 
**RETURN:** `0 (false)`
 
### <a name="athenadockeriscurrentcontainerrunning"></a>`athena.docker.is_current_container_running`
 
This function checks if the container assigned for running is already running.
 
**USAGE:**  `athena.docker.is_current_container_running`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenadockerisdefaultroutertobeused"></a>`athena.docker.is_default_router_to_be_used`
 
This function checks if the default router should be used.
 
**USAGE:**  `athena.docker.is_default_router_to_be_used`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenadockerisrunningasdaemon"></a>`athena.docker.is_running_as_daemon`
 
This function checks if docker option -d is already set.
 
**USAGE:**  `athena.docker.is_running_as_daemon`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenadockerlistathenacontainers"></a>`athena.docker.list_athena_containers`
 
This function returns a list of athena custom containers.
 
**USAGE:**  `athena.docker.list_athena_containers`
 
**RETURN:** `string`
 
### <a name="athenadockerlogs"></a>`athena.docker.logs`
 
This is a wrapper function for executing docker logs, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.logs <args>`
 
**RETURN:** `--`
 
### <a name="athenadockermount"></a>`athena.docker.mount`
 
This function adds the given volume to the docker run option string ($ATHENA_DOCKER_OPTS). If source or target directory are not specified it stops execution and throws an error message and if source is neither a file or a directory also stops the execution.
 
**USAGE:**  `athena.docker.mount <source> <target>`
 
**RETURN:** `--`
 
### <a name="athenadockermountdir"></a>`athena.docker.mount_dir`
 
This function adds the given volume to the docker run option string ($ATHENA_DOCKER_OPTS). If source or target directory are not specified it stops execution and throws an error message or if source is not a directory also stops.
 
**USAGE:**  `athena.docker.mount_dir <source directory> <target directory>`
 
**RETURN:** `--`
 
### <a name="athenadockermountdirfromplugin"></a>`athena.docker.mount_dir_from_plugin`
 
This function adds the given volume to the docker run option from a relative path to the current plugin.
 
**USAGE:**  `athena,docker.mount_dir_from_plugin <relative_path_from_plugin> <target_directory>`
 
**RETURN:** `--`
 
### <a name="athenadockerprintorfollowcontainerlogs"></a>`athena.docker.print_or_follow_container_logs`
 
Either print or follow the output of one or more container logs.
 
**USAGE:**  `athena.docker.print_or_follow_container_logs <containers> [-f]`
 
**RETURN:** `--`
 
### <a name="athenadockerremovecontainerandimage"></a>`athena.docker.remove_container_and_image`
 
This function removes a docker container and the associated image.
 
**USAGE:**  `athena.docker.remove_container_and_image <tag name> <version>`
 
**RETURN:** `--`
 
### <a name="athenadockerrm"></a>`athena.docker.rm`
 
This is a wrapper function for executing docker rm, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.rm <args>`
 
**RETURN:** `--`
 
### <a name="athenadockerrmi"></a>`athena.docker.rmi`
 
This is a wrapper function for executing docker rmi, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.rmi <args>`
 
**RETURN:** `--`
 
### <a name="athenadockerrun"></a>`athena.docker.run`
 
This is a wrapper function for executing docker run, which helps with mocking and tweaking.
 
**USAGE:**  `athena.docker.run <args>`
 
**RETURN:** `--`
 
### <a name="athenadockerruncontainer"></a>`athena.docker.run_container`
 
This function runs a container.
 
**USAGE:**  `athena.docker.run_container <container_name> <tag_name>`
 
**RETURN:** `--`
 
### <a name="athenadockerruncontainerwithdefaultrouter"></a>`athena.docker.run_container_with_default_router`
 
This function runs a container using the default router. The ATHENA_COMMAND and ATHENA_ARGS will be set dynamically within the router inside the container so that even executing something inside an already running container will have the correct COMMAND being executed with the correct ARGS.
 
**USAGE:**  `athena.docker.run_container_with_default_router <container_name> <tag_name> <command>`
 
**RETURN:** `--`
 
### <a name="athenadockersetnodefaultrouter"></a>`athena.docker.set_no_default_router`
 
This function specifies that the default router should not be used.
 
**USAGE:**  `athena.docker.set_no_default_router [value]`
 
**RETURN:** `--`
 
### <a name="athenadockersetoptions"></a>`athena.docker.set_options`
 
This function sets the options to be passed to docker.
 
**USAGE:**  `athena.docker.set_options <options>`
 
**RETURN:** `--`
 
### <a name="athenadockerstopallcontainers"></a>`athena.docker.stop_all_containers`
 
This function stops and removes docker containers which run in this instance with the given name. If '--global' is set as additional argument all (regardless the instance) docker containers with the given name are stopped/removed. Since the containers are stopped/removed in parallel the function waits until all containers were stopped and removed successfully. OPTION: --global
 
**USAGE:**  `athena.docker.stop_all_containers <name_to_filter> [<option>]`
 
**RETURN:** `--`
 
### <a name="athenadockerstopcontainer"></a>`athena.docker.stop_container`
 
This function stops a docker container with the given name if running or the current container f container name is not specified. In any case (running or already stopped) the containers with the given name will be removed including associated volumes.
 
**USAGE:**  `athena.docker.stop_container [container name]`
 
**RETURN:** `--`
 
### <a name="athenadockerwaitforstringincontainerlogs"></a>`athena.docker.wait_for_string_in_container_logs`
 
This function checks if a certain string can be found in the container logs. If not the container is considered to be not running and the function keeps rechecking every second. If 300 seconds are reached it stops execution and throws an error message.
 
**USAGE:**  `athena.docker.wait_for_string_in_container_logs <container> <log message>`
 
**RETURN:** `0 (true)`
 
### <a name="athenapluginbuild"></a>`athena.plugin.build`
 
This function gets the name ($ATHENA_PLUGIN), docker directory (see athena.plugin.get_plg_docker_dir), tag name (see athena.plugin.get_tag_name), and version ($ATHENA_PLG_IMAGE_VERSION) of the current plugin and builds a docker image from these resources. If no valid Dockerfile exists or the build is unsuccessful execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.build`
 
**RETURN:** `--`
 
## Handling *plugin*
 
### <a name="athenapluginbuild"></a>`athena.plugin.build`
 
This function builds the container for the current plugin.
 
**USAGE:**  `athena.plugin.build`
 
**RETURN:** `--`
 
### <a name="athenaplugincheckdependencies"></a>`athena.plugin.check_dependencies`
 
This function checks if the given plugin has dependencies (i.e. it checks the content of dependencies.ini). It checks each specified dependency by name and version. If a plugin specified as dependency is not installed or has the wrong version number the error code 1 is returned. If all dependencies are installed the error code 0 is returned.
 
**USAGE:**  `athena.plugin.check_dependencies <plugin name>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenaplugingetavailablecmds"></a>`athena.plugin.get_available_cmds`
 
This function prints the usage info list of all commands found for this plugin (in $ATHENA_PLG_CMD_DIR).
 
**USAGE:**  `athena.plugin.get_available_cmds`
 
**RETURN:** `--`
 
### <a name="athenaplugingetcontainername"></a>`athena.plugin.get_container_name`
 
This function returns a generic container name generated from the current plugin and instance settings (i.e. $ATHENA_PLUGIN and $ATHENA_INSTANCE variables will be considered for the container name generation).
 
**USAGE:**  `athena.plugin.get_container_name`
 
**RETURN:** `string`
 
### <a name="athenaplugingetcontainertouse"></a>`athena.plugin.get_container_to_use`
 
This function checks if a container was set for running (in the $ATHENA_PLG_CONTAINER_TO_USE variable). If so the container name is returned. If not the error code 1 is returned.
 
**USAGE:**  `athena.plugin.get_container_to_use`
 
**RETURN:** `string`
 
### <a name="athenaplugingetenvironment"></a>`athena.plugin.get_environment`
 
This function returns the value of the current plugin environment as set in the $ATHENA_PLG_ENVIRONMENT variable. If $ATHENA_PLG_ENVIRONMENT is not set error code 1 is returned.
 
**USAGE:**  `athena.plugin.get_environment`
 
**RETURN:** `string`
 
### <a name="athenaplugingetenvironmentbuildfile"></a>`athena.plugin.get_environment_build_file`
 
This function returns the current docker build environment file name as set in the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable. If $ATHENA_PLG_DOCKER_ENV_BUILD_FILE is not set error code 1 is returned.
 
**USAGE:**  `athena.plugin.get_environment_build_file`
 
**RETURN:** `string`
 
### <a name="athenaplugingetimagename"></a>`athena.plugin.get_image_name`
 
This function returns the value of the current plugin image name as set in the $ATHENA_PLG_IMAGE_NAME variable.
 
**USAGE:**  `athena.plugin.get_image_name`
 
**RETURN:** `string`
 
### <a name="athenaplugingetimageversion"></a>`athena.plugin.get_image_version`
 
This function returns the value of the current plugin image version as set in $ATHENA_PLG_IMAGE_VERSION variable.
 
**USAGE:**  `athena.plugin.get_image_version`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplg"></a>`athena.plugin.get_plg`
 
This function returns the name of the current plugin as set in the $ATHENA_PLUGIN variable.
 
**USAGE:**  `athena.plugin.get_plg`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplgbindir"></a>`athena.plugin.get_plg_bin_dir`
 
This function returns the plugin binary directory name and checks if the plugin root exists. If not, execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_bin_dir [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplgcmddir"></a>`athena.plugin.get_plg_cmd_dir`
 
This function returns the plugin command directory name and checks if the plugin root exists. If not execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_cmd_dir [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplgdir"></a>`athena.plugin.get_plg_dir`
 
This function returns the plugin root directory name and checks if it exists. If it does not exist execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_dir [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplgdockerdir"></a>`athena.plugin.get_plg_docker_dir`
 
This function returns the plugin docker directory name and checks if the plugin root exists. If not execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_docker_dir <plugin name>`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplghooksdir"></a>`athena.plugin.get_plg_hooks_dir`
 
This function returns the plugin hooks directory and checks if the plugin root root exists. If not, execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_hooks_dir [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplglibdir"></a>`athena.plugin.get_plg_lib_dir`
 
This function returns the plugin library directory name and checks if the plugin root exists. If not, execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.get_plg_lib_dir [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplgversion"></a>`athena.plugin.get_plg_version`
 
This function returns the version of a plugin as set in its version.txt.
 
**USAGE:**  `athena.plugin.get_plg_version [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetplugin"></a>`athena.plugin.get_plugin`
 
This function wraps the athena.plugin.get_plg function.
 
**USAGE:**  `athena.plugin.get_plugin`
 
**RETURN:** `string`
 
### <a name="athenaplugingetpluginsdir"></a>`athena.plugin.get_plugins_dir`
 
This function returns the directory name where plugins are installed (i.e. the value of the $ATHENA_PLGS_DIR variable).
 
**USAGE:**  `athena.plugin.get_plugins_dir`
 
**RETURN:** `string`
 
### <a name="athenaplugingetprefixforcontainername"></a>`athena.plugin.get_prefix_for_container_name`
 
This function returns the prefix for creating a container name.
 
**USAGE:**  `athena.plugin.get_prefix_for_container_name [plugin name]`
 
**RETURN:** `string`
 
### <a name="athenaplugingetsharedlibdir"></a>`athena.plugin.get_shared_lib_dir`
 
This function returns the shared lib directory.
 
**USAGE:**  `athena.plugin.get_shared_lib_dir`
 
**RETURN:** `string`
 
### <a name="athenaplugingetsubplgversion"></a>`athena.plugin.get_subplg_version`
 
This function returns the version of a sub-plugin as set in its version.txt.
 
**USAGE:**  `athena.plugin.get_subplg_version <plugin name> <sub-plugin name>`
 
**RETURN:** `string`
 
### <a name="athenaplugingettagname"></a>`athena.plugin.get_tag_name`
 
This function generates and returns a tag name from current plugin settings (i.e. $ATHENA_PLG_IMAGE_NAME, $ATHENA_PLUGIN, and $ATHENA_PLG_ENVIRONMENT variables will be considered for the tag name generation).
 
**USAGE:**  `athena.plugin.get_tag_name`
 
**RETURN:** `string`
 
### <a name="athenapluginhandle"></a>`athena.plugin.handle`
 
This function handles the routing of the plugin.
 
**USAGE:**  `athena.plugin.handle <command> <command_dir> <lib_dir> <bin_dir> <hooks_dir>`
 
**RETURN:** `0 (sucessfull), 1 (failed)`
 
### <a name="athenapluginhandlecontainer"></a>`athena.plugin.handle_container`
 
This function checks if the name, docker directory, and container of the current plugin are set. If no container is set it checks if a Dockerfile is available in the docker directory and will run athena.docker.build with it. If no Dockerfile is available it will return doing nothing (some plugins might not need a container). If a container was already set it will check if its docker directory (e.g. of a given sub-plugin) with version.txt exists, sets image version ($ATHENA_PLG_IMAGE_VERSION) and plugin name ($ATHENA_PLUGIN) accordingly, and builds the docker image for it. If no valid docker directory is found execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.handle_container`
 
**RETURN:** `--`
 
### <a name="athenapluginhandleenvironment"></a>`athena.plugin.handle_environment`
 
This function checks if the name, environment, and container of the current plugin are set. If so it checks if a build environment file exists and sets the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable pointing to it. If not execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.handle_environment`
 
**RETURN:** `--`
 
### <a name="athenaplugininit"></a>`athena.plugin.init`
 
This function checks if the given plugin was initialised (i.e. if athena.lock is set in the plugin directory). If not it checks the plugin dependencies (using athena.plugin.check_dependencies) and then runs the plugin init script if successful. If the required plugins (dependencies) are not installed it stops execution and throws an error message.
 
**USAGE:**  `athena.plugin.init <plugin_name>`
 
**RETURN:** `--`
 
### <a name="athenapluginisenvironmentspecified"></a>`athena.plugin.is_environment_specified`
 
This function checks if the current plugin environment ($ATHENA_PLG_ENVIRONMENT) is set. If set error code 0 is returned. If not error code 1 is returned.
 
**USAGE:**  `athena.plugin.is_environment_specified`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenapluginpluginexists"></a>`athena.plugin.plugin_exists`
 
This function checks if the plugin root directory of the given plugin exists. If not execution is stopped and an error message is thrown. If a version is given as second argument it checks if it complies with the found plugin version. If not an error message is thrown.
 
**USAGE:**  `athena.plugin.plugin_exists <plugin name> <version>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenapluginprintavailablecmds"></a>`athena.plugin.print_available_cmds`
 
This function prints the usage screen of the given plugin including all commands found in the plugin directory ($ATHENA_PLG_CMD_DIR).
 
**USAGE:**  `athena.plugin.print_available_cmds <plugin_name>`
 
**RETURN:** `--`
 
### <a name="athenapluginrequire"></a>`athena.plugin.require`
 
This function checks if the plugin root directory of the given plugin name exists. If not it stops execution and throws an error message. If it exists it sources 'bin/variables.sh' and 'bin/lib/functions.sh' if available in the plugin.
 
**USAGE:**  `athena.plugin.require <plugin name> <version>`
 
**RETURN:** `--`
 
### <a name="athenapluginruncommand"></a>`athena.plugin.run_command`
 
This function runs the given command from the plugin.
 
**USAGE:**  `athena.plugin.run_command <command_name> <plugin_cmd_dir>`
 
**RETURN:** `int`
 
### <a name="athenapluginruncontainer"></a>`athena.plugin.run_container`
 
This functions runs the given container.
 
**USAGE:**  `athena.plugin.run_container <command>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenapluginsetcontainername"></a>`athena.plugin.set_container_name`
 
This function sets the current container name in the $ATHENA_CONTAINER_NAME variable to the given value.
 
**USAGE:**  `athena.plugin.set_container_name <container name>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetenvironment"></a>`athena.plugin.set_environment`
 
This function sets the current plugin environment in the $ATHENA_PLG_ENVIRONMENT variable to the given value. If no plugin environment is provided execution will be stopped.
 
**USAGE:**  `athena.plugin.set_environment <plugin environment>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetenvironmentbuildfile"></a>`athena.plugin.set_environment_build_file`
 
This function sets the current docker build environment file name in the $ATHENA_PLG_DOCKER_ENV_BUILD_FILE variable to the given value.
 
**USAGE:**  `athena.plugin.set_environment_build_file <docker build environment file name>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetimagename"></a>`athena.plugin.set_image_name`
 
This function sets the current plugin image name in the $ATHENA_PLG_IMAGE_NAME variable to the given value.
 
**USAGE:**  `athena.plugin.set_image_name <image name>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetimageversion"></a>`athena.plugin.set_image_version`
 
This function sets the current plugin image version in the $ATHENA_PLG_IMAGE_VERSION variable to the given value.
 
**USAGE:**  `athena.plugin.set_image_version <image version>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetplgcmddir"></a>`athena.plugin.set_plg_cmd_dir`
 
This functions sets the plg cmd dir(s). The parameter should be one or more directories separated by colons.
 
**USAGE:**  `athena.plugin.set_plg_cmd_dir <dir(s)>`
 
**RETURN:** `--`
 
### <a name="athenapluginsetplugin"></a>`athena.plugin.set_plugin`
 
This function sets the current plugin in the $ATHENA_PLUGIN variable to the given value.
 
**USAGE:**  `athena.plugin.set_plugin <plugin name>`
 
**RETURN:** `--`
 
### <a name="athenapluginusecontainer"></a>`athena.plugin.use_container`
 
This function sets the container that will be used for running (i.e. assigning the given value to $ATHENA_PLG_CONTAINER_TO_USE variable). If no value is provided it stops the execution and throws an error message.
 
**USAGE:**  `athena.plugin.use_container <container name>`
 
**RETURN:** `--`
 
### <a name="athenapluginuseexternalcontainerasdaemon"></a>`athena.plugin.use_external_container_as_daemon`
 
This function uses an external container as a daemon and disables the default router.
 
**USAGE:**  `athena.plugin.use_external_container_as_daemon <container name> [instance_name]`
 
**RETURN:** `--`
 
### <a name="athenapluginvalidatepluginname"></a>`athena.plugin.validate_plugin_name`
 
This function checks if the given argument (e.g. <plugin name>) is not empty. If the given string is empty execution is stopped and an error message is thrown.
 
**USAGE:**  `athena.plugin.validate_plugin_name <$VARIABLE>`
 
**RETURN:** `--`
 
### <a name="athenapluginvalidateusage"></a>`athena.plugin.validate_usage`
 
This function checks the number of arguments in the given list. If no argument is given it shows the available commands of the given plugin and exits. If another argument than 'init' or 'cleanup' is given it checks if the plugin was initialised.
 
**USAGE:**  `athena.plugin.validate_usage <plugin_name> <argument1> <argument2> ...`
 
**RETURN:** `--`
 
### <a name="athenapluginvalidateversion"></a>`athena.plugin.validate_version`
 
This function validates a given version against the accepted one. Semantic Version 2.0 is used in for the validation algorithm.
 
**USAGE:**  `athena.plugin.validate_version <version_to_validate> <version_accepted>`
 
**RETURN:** `0 (true), 1 (false)`
 
### <a name="athenapluginvalidateversionformat"></a>`athena.plugin.validate_version_format`
 
This function validates if the given version follows Semantic Versioning 2.0.
 
**USAGE:**  `athena.plugin.validate_version <version>`
 
**RETURN:** `0 (true) 1 (false)`
 
## Handling *test*
 
### <a name="athenatestassertarray"></a>`athena.test.assert_array`
 
This function asserts if two arrays are equal. It takes the name of the array variables to look them up.
 
**USAGE:**  `athena.assert_value <name_of_array> <name_of_expected_array>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertexitcode"></a>`athena.test.assert_exit_code`
 
This function asserts if the function exits with 0.
 
**USAGE:**  `athena.test.assert_exit_code <function> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertexitcodeexpectsfail"></a>`athena.test.assert_exit_code.expects_fail`
 
This function asserts if the function does not exit with 0.
 
**USAGE:**  `athena.test.assert_exit_code <function> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertoutput"></a>`athena.test.assert_output`
 
This function asserts the output of a function call.
 
**USAGE:**  `athena.assert_output <function> <expected> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertoutputexpectsfail"></a>`athena.test.assert_output.expects_fail`
 
This function asserts if the output of a function call is not the same as the expected.
 
**USAGE:**  `athena.assert_output.expects_fail <function> <expected> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertreturn"></a>`athena.test.assert_return`
 
This function asserts the return of a function call.
 
**USAGE:**  `athena.assert_return <function> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertreturnexpectsfail"></a>`athena.test.assert_return.expects_fail`
 
This function asserts if a function call fails.
 
**USAGE:**  `athena.assert_return.expects_fail <function> <arguments>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertstringcontains"></a>`athena.test.assert_string_contains`
 
Assert <string> contains <sub-string>
 
**USAGE:**  `athena.test.assert_string_contains <string> <sub-string>`
 
### <a name="athenatestassertstringcontainsexpectsfail"></a>`athena.test.assert_string_contains.expects_fail`
 
Assert <string> does not contain <sub-string>
 
**USAGE:**  `athena.test.assert_string_contains.expects_fail <string> <sub-string>`
 
### <a name="athenatestassertvalue"></a>`athena.test.assert_value`
 
This function asserts if two values are equal.
 
**USAGE:**  `athena.assert_value <value> <expected>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestassertvalueexpectsfail"></a>`athena.test.assert_value.expects_fail`
 
This function asserts if two values are not supposed to be equal.
 
**USAGE:**  `athena.assert_value.expects_fail <value> <not_expected>`
 
**RETURN:** `0 (true) 1 (false)`
 
### <a name="athenatestcreatetempdir"></a>`athena.test.create_tempdir`
 
This function creates a temporary directory in the home dir, by making use of mktemp command.
 
**USAGE:**  `athena.test.create_tempdir`
 
**RETURN:** `string`
 
### <a name="athenatestcreatetempfile"></a>`athena.test.create_tempfile`
 
This function creates a temporary file in the home dir, by making use of mktemp command.
 
**USAGE:**  `athena.test.create_tempfile`
 
**RETURN:** `string`
 
### <a name="athenatestmock"></a>`athena.test.mock`
 
This function mocks and existing function by overriding it. Also it saves the function to be mocked as ATHENA_MOCK_<func_name>, so that it can be restored afterwards by callin athena.test.unmock.
 
**USAGE:**  `athena.test.mock <function_name> <mock_function_name>`
 
**RETURN:** `--`
 
### <a name="athenatestmockexits"></a>`athena.test.mock.exits`
 
This function creates a mock of the specified function with the given exit code.
 
**USAGE:**  `athena.test.mock.exits <function_name> <return>`
 
**RETURN:** `--`
 
### <a name="athenatestmockoutputs"></a>`athena.test.mock.outputs`
 
This function creates a mock of the specified function with the given output.
 
**USAGE:**  `athena.test.mock.outputs <function_name> <return>`
 
**RETURN:** `--`
 
### <a name="athenatestmockreturns"></a>`athena.test.mock.returns`
 
This function creates a mock of the specified function with the given return.
 
**USAGE:**  `athena.test.mock.returns <function_name> <return>`
 
**RETURN:** `--`
 
### <a name="athenatestrunsuite"></a>`athena.test.run_suite`
 
This function executes the suite of tests located in the given directory. The exit code will be zero in case all tests succeed and 1 if any fail.
 
**USAGE:**  `athena.test.run_suite <directory|file>`
 
**RETURN:** `--`
 
### <a name="athenatestshowcoverage"></a>`athena.test.show_coverage`
 
This function outputs the coverage for the given source and tests directory. It is also possible to output the list of functions that don't have tests for it.
 
**USAGE:**  `athena.test.show_coverage <source_dir> <tests_dir> [<show_untested_functions>]`
 
**RETURN:** `--`
 
### <a name="athenatestunmock"></a>`athena.test.unmock`
 
This function unmocks the previous mocked function by restoring its source code.
 
**USAGE:**  `athena.test.unmock <function_name>`
 
**RETURN:** `--`
