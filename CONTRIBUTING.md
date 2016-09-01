# Contributing to Athena

Athena is the first [OLX](http://www.olx.com/) open source project that is both under very active development and is also being used to automate stuff at [OLX](http://www.olx.com/). We're still working the details to make contributing to this project as easy and transparent as possible. Hopefully with the help of this document and your feedback we will eventually make it.

## Our Development Process

Some of our core contributers will be working directly on GitHub. These changes will be public from the beginning.

### `master` changes fast

We move fast and most likely things will break. Every time there is a commit our CI server will run the tests and hopefully they will pass all times. We will do our best to properly communicate the changes that can affect the application API and always version appropriately in order to make easier for you to use a specific version.

### Pull Requests

The core contributors will be monitoring for pull requests. When we get one, we will pull it in and apply it to our codebase and run our test suite to ensure nothing breaks. Then one of the core contributors needs to verify that all is working appropriately. When the API changes we may need to fix internal uses, which could cause some delay. We'll do our best to provide updates and feedback throughout the process.

*Before* submitting a pull request, please make sure the following is done:

1. Fork the repo and create your branch from `master`.
2. If you've added code that should be tested, add tests!
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`athena cli tests`).


## Bugs

### Where to Find Known Issues

We will be using GitHub Issues for our public bugs. We will keep a close eye on this and try to make it clear when we have an internal fix in progress. Before filing a new task, try to make sure your problem doesn't already exist.

### Reporting New Issues

The best way to get your bug fixed is to provide a reduced test case.

## How to Get in Touch

Mailing list - [Athena in Google Groups](https://groups.google.com/a/olx.com/d/forum/athena)

## Development best practices

### Common

* Global Variables :
	- **SHOULD** be avoided and used only to store global state
	- **MUST** be handled using getters and setters
	- **MUST** be named in uppercase, e.g.: ```MY_VARIABLE_NAME```
	- **MUST** be prefixed with ATHENA_ when defined in Athena engine and prefixed with ```ATHENA_PLG_${PLUGIN_NAME}_``` when defined in a plugin, e.g.:
		- ```ATHENA_MY_VARIABLE_NAME```
		- ```ATHENA_PLG_SELENIUM_MY_VARIABLE_NAME```

* Local variables :
	- **MUST** be declared with the local keyword
	- **MUST** be named in lowercase


* CLI functions:
	* **MUST** be tested  and documented
	* Documentation **MUST** follow the following format :
  ```
	# Description
	# USAGE: <name_of_function> [<arguments>]
	# RETURN: <type_of_return>
  ```
	* when used as a core athena function **MUST** follow the naming schema ```athena[.${context}.]${function_name}```
	* when used as a global plugin function **MUST** follow the naming schema ```athena.plugins.${plugin_name}.${function_name}```
	* **MUST** always return 0 when success and not 0 when fail


* Plugin Commands

  * **MUST** NOT have a shebang line
  * Arguments **MUST** only be accessed or setted using the functions in ```athena.argument``` library



### Plugins

  * Library functions **MUST** be located ```${PLUGIN}/bin/lib``` and when multiple contexts are handled **MUST** follow the naming schema ```${PLUGIN}/bin/lib/functions.${CONTEXT}.sh```, e.g.: ```java/bin/lib/functions.api.sh```

  * Library functions **MUST** follow the following name schema : ```athena.plugins.${plugin_name}.${function_name}```


  * Folders that are supposed to be mounted in the docker container **MUST** be located in ```${PLUGIN}/mnt/${context}```, e.g.: ```java/mnt/api```

  * Source code used per context **MUST** follow a recommended standard, e.g.: PHP **MUST** follow PSR-2, JAVA **MUST** follow Google (https://google.github.io/styleguide/javaguide.html) or other widely adopted

  * External libraries **MUST** not be “shipped” with the plugin and **MUST** have a **License** that allows us to use it as we see fit, e.g.: Apache 2.0 License

  * Documentation **MUST** be provided

  * Examples on HOW TO USE **MUST** be provided

  * The init command **MUST** NOT be used directly


## License

By contributing to Athena, you agree that your contributions will be licensed under the [Apache License Version 2.0 (APLv2)](LICENSE).
