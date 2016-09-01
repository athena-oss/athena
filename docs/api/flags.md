# Global CLI flags

These are flags that can be used with any command of any `plugin`.

## Enabling debug messages

To enable the debug messages append your command with :

```bash
--athena-dbg
```

## Disabling the logo

To disable the logo when invoking the commands append your command with :

```bash
--athena-no-logo
```

## Specifying the environment

In case your plugin supports multiple environments for the same container append your command with :

```bash
--athena-env=<name|file_with_environment_config>
```

## Overriding the container's dns nameserver

```bash
--athena-dns=<nameserver_ip>
```
