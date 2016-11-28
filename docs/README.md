# ![image](img/athena_logo.png)

*Automate, Automate, Automate!*

The key to optimize work is to *automate* as much as possible. Whether you are developing software, setting up infrastructure or even testing, if there is a chance to do it just take it.

Most of the times the boring and frequent tasks can be automated. There are a lot of different tools and technologies that can help you with that, but sometimes starting is simply an hassle by itself and one might end up giving up and doing it *"manually"*.

This is where **Athena** jumps in. The idea is quite simple, we minimize the start process by :

 * automating the wiring of the dependencies and tools
 * implement a plugin architecture to allow freedom and scalability
 * throw in a wizard that takes care of the boring stuff

Once that part is done, you can reuse it as much as you can and you can even share with other people or teams.

Seems cool, right?

Well, it might also seem too easy or too abstract so let's dig into it.

## How does it work?

**Athena** aims to be of simple usage and architecture and consists of 2 pillars:

 * the `Engine`: a declarative framework based in `bash` ( *say that again ???* Don't run away yet because it has proper [unit tests](tests/). To know more about it, have a look at the [bashUnit](https://github.com/athena-oss/bashunit) Testing Framework for `bash`. It has all of the common features an xUnit Framework gives, including Mocking.)

 * the `Plugins`: they are typically *Services*, *Applications*, *Jobs*, etc. They can use any technology or any stack of technologies and they form the ecosystem that helps you handle different scenarios. To support the automation environments, the virtualisation technology used is [docker](https://www.docker.com/).


As an example, you can use **Athena** to setup a webserver, test your website and handle the deployment. This example could be achieved by creating 3 `plugins`: `webserver`, `test` and `deploy` or you could simply create just one : `app`.

Hopefully the ecosystem will continue to grow and become big enough so that most of the scenarios will be already handled and you can use an existing `plugin`, build your own from scratch or even base yours on another one.

## Why did we choose `bash`?

We wanted to make it simple and having the minimum dependencies possible. Using bash became a natural choice because that's where you usually start when you automate with scripts.

`bash` already has support for a lot of stuff, but the issue is that is not very declarative or at least does not have a very developer-like syntax, and this is why **Athena** was born. A simple, declarative and developer-friendly framework with testing support.

## Why should you use it?

Besides having a very straightforward and simple architecture, which makes it easy to debug, it provides you built-in support for solving the following topics :
  * Version validation
  * Error handling
  * Proper display of messages
  * Stacktrace
  * Testing
  * Routing
  * Support for Multiple and configurable environments
  * Hooks
  * Standardized way of building stuff
  * etc...

With this already taken care of you will only need to focus on your specific problem.

## Table of contents

* [Quick start](#quick-start)
* [Examples](#examples)
* [Contributing](#contributing)
* [Versioning](#versioning)
* [License](#license)


## Quick start

Prerequisites
 * You have a `bash` shell.
 * You have [Git](https://git-scm.com/) installed.
 * You have [Docker](https://www.docker.com/) installed.

There are three quick start options available:

**On Linux**

 * Using a `debian package` from the [releases](https://github.com/athena-oss/athena/releases) :

```bash
$ sudo dpkg -i <downloaded_debian_package>
```

* Using `apt-get` :

```bash
$ sudo add-apt-repository ppa:athena-oss/athena
$ sudo apt-get update
$ sudo apt-get install athena
```

**On MAC OSX**

* Using [Homebrew](http://brew.sh/) :

```bash
$ brew tap athena-oss/tap
$ brew install athena
```

**Note:** You might be required to allow Docker to access folders managed by Homebrew. In order to do this, go to Docker `Preferences > File Sharing` and add the folder `/usr/local/Cellar`.

**Alternative**

* [Download the latest release](https://github.com/athena-oss/athena/releases/latest)
* Clone the repo: `git clone https://github.com/athena-oss/athena.git`

Go to the [Documentation Website](http://athena-oss.github.io/athena) or download the [Documentation PDF](https://github.com/athena-oss/athena/raw/gh-pages/documentation.pdf) to find out more about using Athena.

## Examples

Inside Examples section you'll find a variaty of ways to use Athena.

### running a file/directory validator
```bash
CMD_DESCRIPTION="Validates a file or directory for possible issues."

athena.usage 1 "<file|directory>"

if athena.plugins.base.check "$(athena.path 1)" ; then
  athena.ok "check passed"
  athena.exit 0
fi
athena.fatal "check failed"
```

### running a php webserver
```bash
CMD_DESCRIPTION="Starts the webserver."

athena.usage 2 "<source_directory> <port>"

# arguments are found below
source_directory="$(athena.path 1)"
port="$(athena.int 2)"

# clearing arguments from the stack
athena.pop_args 2

# options for container are found below
athena.plugin.use_external_container_as_daemon "php:7.0-apache"

# mounts the specified dir into the container
athena.docker.mount_dir "$source_directory" "/var/www/html"

# maps the specified host port to the port 80 of the container
athena.docker.add_option "-p $port:80"
```

## Plugins

Here is a list of some of the available plugins :

* [PHP Plugin](https://github.com/athena-oss/plugin-php) - Plugin for Test Automation using PHP as a development language.
* [Selenium Plugin](https://github.com/athena-oss/plugin-selenium) - Plugin to handle browser automation using Selenium.
* [Proxy Plugin](https://github.com/athena-oss/plugin-proxy) - Plugin to handle a proxy server using Browsermob-proxy.
* [Appium Plugin](https://github.com/athena-oss/plugin-appium) - Plugin to handle mobile automation using Appium.
* [AVD Plugin](https://github.com/athena-oss/plugin-avd) - Plugin to manage Android Virtual Devices.
* [Gradle Plugin](https://github.com/athena-oss/plugin-gradle) - Plugin for running gradle tasks.

## Contributing

Checkout our guidelines on how to contribute in [CONTRIBUTING](guides/contributing.md).

## Versioning

Releases are managed using github's release feature. We use [Semantic Versioning](http://semver.org) for all
the releases. Every change made to the code base will be referred to in the release notes (except for
cleanups and refactorings).

## License

Licensed under the [Apache License Version 2.0 (APLv2)](/LICENSE.html).
