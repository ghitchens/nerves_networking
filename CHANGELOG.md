# Changelog

## v0.5.0 (2016-02-27)
* New Features
  * support for proper resolver (dns) setup
  * if hostname is not passed, first try to use the second part of the node name, then the default "nerves"
* Bug Fixes
  * fixed flags being passed to udhcpc for hostname


## v0.4.0-dev (2015-10-29)

* new testing framework
* lots of new tests
* public API now requires interface

## v0.3.0-dev (2015-10-14)

* Move from Cellulose to Nerves Project
* Scope as Nerves.IO.Ethernet
* Add support for ExDoc
* Clean up README.md
* Add package support
* Separated out SSDP config support into separate project
* Separated out configuration storage support to separate project
* Added an almost-insignificant test

## v0.2.0-dev (2015-05-03)

- Added Ethernet.Storage behaviour
- Removed dependency on `cellulose/persistent_storage`
- Updated README.md

## v0.1.0-dev (2015-04-25)

- extracted from proprietary "echo" project
- added GenEvent-based notifier to breakout Hub dependency
