## 0.9.0 (November 9, 2016)

### Added
  - athena.docker.network functions to manage docker networks

### Fixed
  - router.sh path when using a running container

## 0.8.0 (November 7, 2016)

### Added
  - Support for using ranged or specific versions of athena
  - athena.docker.volume_exists function

### Changed
  - Created bootstrap folder that contains files required to bootstrap athena (e.g.: global variables)
  - Extracted Testing Framework to the bashUnit project
  - Replaced tests with bashUnit
  - Removed unit tests from the init command
  - Moved print_logo function to the plugin functions
  - Removed unnecessary bin directory structure

### Fixed
  - Some tests that were depending on some athena functionalities and were not explicit

## 0.7.0 (October 28, 2016)

### Added
  - Utils functions (e.g.: handling arrays) in athena.utils namespace
  - Support for specifying docker environment variables from a file
  - athena.os.print_stacktrace

### Changed
  - ATHENA_DOCKER_OPTS is now an array and supports values with spaces
  - athena.docker functions that manipulate the array use athena.utils array functions
  - Docker build args supports values with spaces
  - Stacktrace now appears whenever an error occurs
  - Run container functions now don't require docker options and arguments
  - athena.docker.run_container_with_default_router now uses athena.docker functions to set default values

### Fixed
  - Random false negatives (in LINUX) when executing unit tests with exit code assertions

## 0.6.3 (October 7, 2016)

### Added
  - athena.docker.get_ip_for_container

### Fixed
  - handling of special characters in file names

## 0.6.2 (October 5, 2016)

### Fixed
   - Removed ":" from container names when using external images

## 0.6.1 (October 4, 2016)

### Added
  - Remove plugin operations in plugins command

### Changed
  - Now athena is not automatically added to PATH, but informs on how to
  - Unit tests checks that function to test exists before trying to run
  - Renamed mock functions in unit tests to avoid overriding
  - Renamed variable in athena.plugin.handle to avoid collisions
  - Updated documentation

### Fixed
  - When updating plugin only tries to remove athena.lock if exists
  - Handling of spaces when invoking athena.plugin._router

## 0.6.0 (September 13, 2016)

### Added
  - athena.os.is_sudo
  - athena.plugin.get_prefix_for_container_name
  - athena.plugin.get_plg_hooks_dir

### Changed
  - Direct access to global variables in athena executable
  - athena.plugin.require now skips if current plugin was specified
  - Construction of container name
  - athena.docker.stop container stops the current container if now container is specified
  - Stacktrace is now redirected to STDERR
  - Improvements on the overlapping commands

### Fixed
  - athena.os.split_string calls to aliases instead of core libs

## 0.5.0 (September 7, 2016)

### Added 
- support for pre and post command hooks

### Changed
- athena.os.usage called inside container now shows athena (change in athena.os.get_executable)

## 0.4.1 (September 6, 2016)

### Fixed
- athena.plugin.require when no init command exists

### Added
- Functions for checking if current container is running

### Changed
- Updated documentation

## 0.4.0 (September 1, 2016)

### Athena

- Initial public release
