# cassandra-backup.sh

Script to take a cassandra snapshot using nodetool

## Notice

This script was tested in:

* Linux
  * Debian GNU/Linux 7
* Cassandra
  * ReleaseVersion: 1.2.19

## Prerequisities

* none

## How to use it

```
# Parameters:
#
#   cassandra-backup.sh --help
#
#    Parameter           Short Description                                                        Default
#    ------------------- ----- ------------------------------------------------------------------ -------------------
#    --username             -u [OPTIONAL] Cassandra username                                      cassandra
#    --password             -p [OPTIONAL] Cassandra password                                      ******
#    --host                 -H [OPTIONAL] Cassandra hostname                                      ${HOSTNAME}
#    --help                 -h [OPTIONAL] help
#
#   Ex.: cassandra-backup.sh --username cassandra --password senha
```

* Schedule the cassandra-backup.sh on crontab or cron.d. 

Example:
```
$ cat /etc/cron.d/cassandra-backup
0 2 * * * cassandra /scripts/cassandra/backup/cassandra-backup.sh > /dev/null 2>&1
```

## License

This project is licensed under the MIT License - see the [License.md](License.md) file for details
