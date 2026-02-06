# Changelog
All notable changes are recorded here.

### Format

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

Entries should have the imperative form, just like commit messages. Start each entry with words like
add, fix, increase, force etc.. Not added, fixed, increased, forced etc.

Line wrap the file at 100 chars.                                              That is over here -> |

### Categories each change fall into

* **Added**: for new features.
* **Changed**: for changes in existing functionality.
* **Deprecated**: for soon-to-be removed features.
* **Removed**: for now removed features.
* **Fixed**: for any bug fixes.
* **Security**: in case of vulnerabilities.


## [Unreleased]
### Security
- Use Go 1.24.13


## [1.0.6] - 2025-02-03
### Added
- Add `api-address` flag to configure the address used to connect to the gRPC API.
### Changed
- Use Go 1.23.5 for release builds.
### Security
- Update third-party dependencies.


## [1.0.5] - 2024-10-08
### Added
- Add support for using ML-KEM-1024 in exchange.
### Changed
- Change default value for argument `kem` into `cme-mlkem`.


## [1.0.4] - 2024-10-01
### Changed
- Prevent upgrading an already upgraded tunnel.


## [1.0.3] - 2024-07-04
### Changed
- Use Go 1.22.5 for release builds.
### Security
- Resolve issues in stdlib by using updated version of Go.


## [1.0.2] - 2024-06-11
### Added
- Add build target for Linux ARMv5, ARMv6, ARMv6 and Windows ARM64.


## [1.0.1] - 2024-04-16
### Security
- Update dependencies


## [1.0.0] - 2024-03-22
### Added
- Core functionality with some configurability.
