# How the Engine works

The Athena Engine is a simple and declarative Bash framework, implemented using only Bash functions and it takes care of tasks like routing, errors, messages, stacktrace, testing, versioning, validation, etc.

## Structure
The directory structure is very simple as you can see in the following schema :

```bash
.
├── athena  # executable
├── ...
├── lib # location of the library functions
│   └── ...
├── plugins # location of the plugins
│   └── ...
└── tests   # location of the
    └── ...
```

## Namespaces
Even though it is not very tipical for Bash functions to have namespaces, we defined namespacing to avoid collision of functions. The pattern is

```bash
athena.<context>.<function_name>
```

The **context** is used to group functions, for instance, all functions related to handling arguments should be grouped under the ```athena.argument.``` namespace. As an example, to check if an argument exists you can use the following function :

```bash
athena.argument.argument_exists <argument_name>
```

The context also defines the name of the file where the functions are located. The pattern for the files is :

```bash
lib/[<shared_or_not>/]functions.<context>.sh
```

## Using the functions

You can use the functions of Athena in 2 contexts, *HOST* or *SHARED*. Using on the *HOST* means that the function is being used directly on the machine that has Athena installed, on the other hand *SHARED* means that you can use it either on the host or inside the container that will provide the environment for your plugin.

* HOST only functions

  * located in the ```lib``` folder
  * loaded automatically on the host
  * can be used only on the *PRE* and *POST* commands


* SHARED functions

  * located in the ```lib/shared``` folder
  * loaded automatically on the host and on the container when the default router is being used
  * can only be used on the inner commands
