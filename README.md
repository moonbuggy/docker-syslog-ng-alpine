# Docker syslog-ng on Alpine Linux

A small Alpine container running syslog-ng configured to log to `/var/log/messages` and optionally to an SQL database.


## Usage

Basic usage with the default local destination:

```
docker run -d --name syslog-ng -p 514:514/udp -p 601:601/tcp -p 6514:6514/tcp moonbuggy2000/syslog-ng-alpine
```

Destinations can be enabled or disabled with environment variables specified with `-e`.


### Environment variables

* `ENABLE_LOCAL` - set `True` to log to `/var/log/messages` in container (default: `False`)
* `SQL_HOST` - the IP or domain of the destination SQL server
* `SQL_PORT` - the port the destination SQL server runs on (defaults to `3306` if not specified)
* `SQL_USER` - the user name used to access the destination SQL server
* `SQL_PASSWORD` - the password for the destination SQL server

The SQL destination is enabled automatically when any `SQL_*` environment variable is set, otherwise it is disabled by default.


### Persisting data

If you're using the local destination you could mount `/var/log/messages` as a volume (e.g. add `-v syslog-ng_messages:/var/log/messages` to the run command).

The configuration files for destinations are in `/etc/syslog-ng/conf.d/`, however the `d_sql.conf` and `d_local.conf` files are created and deleted as the container starts up, depending on how environment variables are set. If you want to make persistent changes to destinations you'll need to modify the templates these configuration files are created from and these are in `/etc/syslog-ng/templates/`. You can safely add new configuration files for other destinations directly to `/etc/syslog-ng/conf.d/`

The configuration for sources are in `/etc/syslog-ng/syslog-ng.conf`. This file is not modified at container statup so you can make persistent changes there if it's mounted as part of a volume.
