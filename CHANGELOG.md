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
