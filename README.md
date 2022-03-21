# Docker syslog-ng on Alpine Linux
A small Alpine container running syslog-ng with `/var/log/messages`, SQL or syslog destinations.

## Usage
Basic usage with the local destination:

```
docker run -d --name syslog-ng -e 'ENABLE_LOCAL=true' -p 514:514/udp -p 601:601/tcp -p 6514:6514/tcp moonbuggy2000/syslog-ng-alpine
```

Destinations can be enabled or disabled with environment variables specified with `-e`.

### Environment variables
*   `ENABLE_LOCAL` - set `true` to log to `/var/log/messages*` in container (default: `false`)
*   `SQL_HOST` - the IP or domain of the destination SQL server
*   `SQL_PORT` - the port the destination SQL server runs on (default: `3306`)
*   `SQL_USER` - the user name used to access the destination SQL server
*   `SQL_PASSWORD` - the password for the destination SQL server
*   `SYSLOG_HOST` - the IP or domain of the destination syslog server
*   `SYSLOG_PORT` - the port the destination SQL server runs on (default: `514`)
*   `SYSLOG_FORMAT` - accepts `RFC3164` or `RFC5424` (default: `RFC3164`)
*   `SYSLOG_TRANSPORT` - accepts `TCP` or `UDP` (default: `UDP`)
*   `TZ` - set timezone

The SQL and syslog destinations are enabled automatically when any `SQL_*` and/or `SYSLOG_*` environment variable is set, otherwise they are disabled by default.

### Persisting data
If you're using the local destination you could mount `/var/log/` as a volume (e.g. add `-v syslog-ng_messages:/var/log/` to the run command). The local destination creates two log files, `/var/log/messages` and `/var/log/messages-kv.log`. The former logs RFC3164-style messages, the latter includes all the name-value pairs in an RFC5424-style message.

The configuration files for destinations are in `/etc/syslog-ng/conf.d/`, however the `d_sql.conf` and `d_local.conf` files are created and/or deleted as the container starts up, depending on how environment variables are set. If you want to make persistent changes to these destinations you'll need to modify the templates their configuration files are created from, in `/etc/syslog-ng/templates/`. You can safely add _new_ configuration files directly to `/etc/syslog-ng/conf.d/`, however.

The configuration for sources is in `/etc/syslog-ng/syslog-ng.conf`. This file is not modified at container statup so you can make persistent changes there if it's mounted as part of a volume.

## Links
GitHub: <https://github.com/moonbuggy/docker-syslog-ng-alpine>

Docker Hub: <https://hub.docker.com/r/moonbuggy2000/syslog-ng-alpine>
