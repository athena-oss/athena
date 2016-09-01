# How the Plugins work

Trends and technologies change fast and most likely your needs too. With this in mind, you can implement plugins using any technology or stack of technologies. `Plugins` can be solutions to handle a different set of scenarios, but more often than not, you may build them as Services, Applications, Jobs/Tasks. These `plugins` in turn have commands that allows you to manage or execute tasks of this context. As an example, your `plugin` can be a simple webserver that has commands to start and stop it.

## Structure

The directory structure is also very simple as you can see in the following schema :

```bash
plugins/example
├── bin
│   └── cmd          # location of the commands that execute the tasks
│       └── ...
├── dependencies.ini # file that contains the dependencies of this plugin
├── docker           # optional: contains the custom environments
│   └── ...
└── version.txt      # contains the version of the plugin
```

## Commands

Commands are used to execute tasks either on the host or inside the container or even on both. Some commands may require that you execute some tasks on the host before actually running inside the container, for example, if you need to prepare some directory structure on the host machine that will save the result of what was done inside the container.

In order to make this simple and generic enough, we decided to adopt the approach of having a 3-step execution that you can look at it like:

  * prepare - runs on the HOST
  * execute - runs on the CONTAINER
  * cleanup - runs on the HOST

The sequence of the execution follows the order in the previous list. The implementation intends to be very simple on the usage side but also on the architecture side. To support a command you will need to have a file inside the commands directory that must follow the name pattern :

```bash
<name_of_command>[_<type>].sh
```
As an example, imagine that you want to implement the command `run` and that this command that needs a prepare, execute and cleanup steps, then you are required to have the files `run_pre.sh`, `run.sh` and `run_post.sh`.

The purpose of splitting this into different files is to sepparate the responsabilities and make it easier to maintain.

**Note:** All of these steps are optional, altough it does not make much sense having both a prepare and cleanup steps if no container will be used, because you can achieve the same result using only the prepare step.

### Example: run (prepare step)

```bash
CMD_DESCRIPTION="Runs a task."

athena.usage 1 "<source_directory>"

# arguments are found below
source_directory="$(athena.path 1)"

# clearing arguments from the stack
athena.pop_args 1

# do something with the $source_directory
...

# mounting the directory to be used inside the container
athena.docker.mount_dir "$source_directory" "/opt/workdir"
```

### Example: run (execute step)
```
# go inside the directory
cd /opt/workdir

# do something there
...
```

### Example: run (cleanup step)
```bash
# do something with the $source_directory
...
```

Now that you know how commands work, checkout the [Shared API](../api/cli-functions-shared.md) and [Host API](../api/cli-functions-host.md), to see what functions you can use inside the commands.

## Docker

The main purpose of Athena is to provide an abstraction of the automation environments and let you use or create your own automation logic without much hassle.

The technology chosen to implement the abstraction is Docker. If *Images*, *Containers*, *Dockerfile* doesn't ring a bell, we recommend that you read a bit about it in order to have an idea on how things work, but if you already do and just want to learn more on how to build your custom containers, please have a look at the [Reference Page](https://docs.docker.com/engine/reference/builder/).

If you intend to just use existing images from DockerHub, then no worries because Athena also has support for it.

The functions that handle docker related operations are under the namespace of `athena.docker.`, read more about it on the [Handling Docker](api/cli-functions-host.md#handling-docker) page. Functions that are directly related to plugins are under `athena.plugin.`, read more about it on the [Handling Plugin](api/cli-functions-host.md#handling-plugin) page.

**Note:** There are some functions in the plugin namespace that can be wrappers to other operations for simplicity of usage, for instance, they can assume the current plugin to set some options.

### Using containers

There are two types of containers that you can use:

* **External**

  The container name can be a tag that is registered in DockerHub, e.g.: `php:7.0-apache`, `java:7`, `debian:jessie`, etc.


* **Custom** (aka your own container)

  These containers must be built using a Dockerfile that needs to be located inside the plugin's `docker` folder.

  If the *Dockerfile* is located on the root of the `docker` directory, then this is called the *default container* and is used when you have a command that needs to run inside a container and don't explicitly say which one to use.

  If you want to have multiple containers then you need to have a sub-folder inside the docker folder and there will be a *Dockerfile* and also a `version.txt` file to version this container. For the *default container*, the version of the plugin is also the version of the container.

  ```bash
  ...
  ├── docker
  │   ├── Dockerfile      # default container
  │   └── other           # other container
  │       ├── Dockerfile
  │       └── version.txt
  └── version.txt
  ```


To use a different container than the *default* container, either an external or a custom one, you must specify it on the *prepare step*, to do so you can use the following functions :

```bash
athena.plugin.use_container <container name>
```

The container name can be either the tag from DockerHub or the name of the sub-folder in the `docker` directory.

**Hint:** There is also another function that is helpful when using external containers that should run as a daemon.

```bash
athena.plugin.use_external_container_as_daemon <container name> [instance_name]
```

## Using configurable images

Docker allows you to have configurable images by using the `ARG` instruction, read more about it [here](https://docs.docker.com/engine/reference/builder/#/arg).

Using this mechanism, Athena allows you to create multiple environments using one single Dockerfile. This can be very useful because with this you can use

In order to achieve this, you need to use the `ARG` instructions in the Dockerfile and then have a file with key-value (commonly know as ini file), and when you want to use a specific configurable container, while executing a command, you just need to use the flag :

```bash
 --athena-env=<environment_file|name_of_environment>
```

The specified environment file must follow the *ini file* format and its values will be used for building the container. If a name is specified instead of a file, Athena expects for a file named `<name_of_environment>.env` to exist in the folder of the *Dockerfile*.

### Example

```bash
$ ./athena example run /path/to/dir --athena-env=/path/to/file/production.env
```

or

```bash
$ ./athena example run /path/to/dir --athena-env=production
```

## Building containers

Because we have a well defined structure, it is easy to build containers tagging them with the specifics of the location, environment and version. When executing a command that requires a container, Athena will try to find a container with the following pattern :

```bash
athena-plugin-<plugin_name>[-<custom_container>][-<environment>]-<instance_name>
```

The version is also used to find it (located in the `version.txt` file of the required container). If this container has not been built yet, Athena will do it for you, if it has, then it will use it for the execution of the command.

**Hint:** Once a specific container is built, it will only rebuild if there is an update on the version or if you specify an environment that has not been built yet.

### Example
```bash
athena-plugin-example-other-production-0:1.0.0
```

## Hooks

There is support for *hooks* in Athena. They can be used to perform any task on a given stage of a `plugin` usage. They must be located in the directory `bin/hooks` of the `plugin`.

### Pre and Post Plugin

These hooks are executed before and after any command is executed. To enable them you just need to add a file called `plugin_pre.sh` and/or `plugin_post.sh` in the *hooks* directory, add logic there and that's it, they're hooked.

## Reusing between commands

Sometimes you might to want to reuse functions or variables between commands. The way to do it is very simple as you can see bellow:

### Functions

  * **PRE and POST commands**

  Implement your functions in the `bin/lib/functions.sh`

  * **Inside containers**

  Implement them in the `bin/lib/functions.container.sh`.

### Variables

  * **PRE and POST commands**

  Add them to `bin/variables.sh`.

  * **Inside containers**

  Add them to `bin/variables.container.sh`


That's it, they are now automatically available and you can start using them.


## Custom logo

If you would like to have your own logo when executing the commands of your `plugin`, simply add a text file `.logo` to the root of your plugin with your ascii art.

## Default router

When you need to execute a command inside a container, Athena sets a default router that maps the command that you are executing to the right file.

Sometimes you might feel the need to use a particular docker image that has its own router and you actually want to preserve this behaviour. If this is the case, then you need to specify in the `pre` command file the following option :

```bash
athena.docker.set_no_default_router 1
```
