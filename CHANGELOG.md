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
