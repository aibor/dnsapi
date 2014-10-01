# DNS API


## About

DNS API is a simple web frontend for a PowerDNS PostgreSQL database.
It intends to provide an easy to use interface for manageing Zones
either by hand via the HTML interface or automated via the JSON
interface.


## Features

* HTML interface
* JSON interface
* HTTP Basic authentication
* User management
* Zone/Resource Record validation
* Zone management per user
* Resource Record updates via tokens instead of user credentials
* DNSSEC key management


## Requirements

* Ruby 2.0 or higher
* Rails 4.1
* pdns-server


## Installation Hints

The Ruby application server should be run as a user that is able to use
the `pdnssec` CLI tool. `pdnd_server` and the app should both use the
same database user.


## Copyright

GPLv2 license can be found in LICENSE

Copyright (C) 2014 Tobias Böhm code@aibor.de

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
