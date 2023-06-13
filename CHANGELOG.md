
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [4.4.1] - 2023-02-15
  
Here we would have the update steps for 1.2.4 for people to follow.
 
### Added

- Redundancy and Time-window retention checks implemented
- Added loading by command line and override by default parameters
- Added dimention check: this test verify the space available to
  proceed with the backup. If it isn't enough, the backup will be
  skipped.

### Changed

- Variable names changed. Now them are the prefix MDBCK_.
  That allows to identify the variable list to match the script's
  internal parameters with the external configuration file.

### Fixed
 
- Backup directory check improved
