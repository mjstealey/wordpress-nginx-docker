# Console output

Example console output from the described commands in the README file.

## <a name="tldr"></a>TL;DR output

Running the commands from the top level of the repository should yeild.

```console
$ mkdir -p certs/ certs-data/ logs/nginx/ mysql/ wordpress/
$ docker-compose up -d
Creating network "wordpress-nginx-docker_default" with the default driver
Creating mysql ... done
Creating wordpress ... done
Creating nginx     ... done
```

After a few moments you should see your site running at [http://127.0.0.1](http://127.0.0.1) ready to be configured.

<img width="80%" alt="tl;dr running site" src="https://user-images.githubusercontent.com/5332509/51803325-cc65ce80-2221-11e9-8789-6dd4e802464c.png">

A deeper look into the container logs would show the full setup and chain of events between the containers.

- **Note** that the wordpress container will show a `Connection Error` until the database has finished running it's internal setup and makes port 3306 available for connections

```console
$ docker-compose logs
Attaching to nginx, wordpress, mysql
wordpress    | WordPress not found in /var/www/html - copying now...
wordpress    | Complete! WordPress has been successfully copied to /var/www/html
wordpress    |
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    |
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    |
wordpress    |
wordpress    | Warning: mysqli::__construct(): (HY000/2002): Connection refused in Standard input code on line 22
wordpress    | MySQL Connection Error: (2002) Connection refused
wordpress    | [27-Jan-2019 15:46:42] NOTICE: fpm is running, pid 1
wordpress    | [27-Jan-2019 15:46:42] NOTICE: ready to handle connections
wordpress    | 172.19.0.4 -  27/Jan/2019:15:52:24 +0000 "GET /index.php" 302
wordpress    | 172.19.0.4 -  27/Jan/2019:15:52:24 +0000 "GET /wp-admin/install.php" 200
wordpress    | 172.19.0.4 -  27/Jan/2019:15:52:26 +0000 "GET /index.php" 200
mysql        | Initializing database
mysql        |
mysql        |
mysql        | PLEASE REMEMBER TO SET A PASSWORD FOR THE MariaDB root USER !
mysql        | To do so, start the server, then issue the following commands:
mysql        |
mysql        | '/usr/bin/mysqladmin' -u root password 'new-password'
mysql        | '/usr/bin/mysqladmin' -u root -h  password 'new-password'
mysql        |
mysql        | Alternatively you can run:
mysql        | '/usr/bin/mysql_secure_installation'
mysql        |
mysql        | which will also give you the option of removing the test
mysql        | databases and anonymous user created by default.  This is
mysql        | strongly recommended for production servers.
mysql        |
mysql        | See the MariaDB Knowledgebase at http://mariadb.com/kb or the
mysql        | MySQL manual for more instructions.
mysql        |
mysql        | Please report any problems at http://mariadb.org/jira
mysql        |
mysql        | The latest information about MariaDB is available at http://mariadb.org/.
mysql        | You can find additional information about the MySQL part at:
mysql        | http://dev.mysql.com
mysql        | Consider joining MariaDB's strong and vibrant community:
mysql        | https://mariadb.org/get-involved/
mysql        |
mysql        | Database initialized
mysql        | MySQL init process in progress...
mysql        | 2019-01-27 15:46:20 0 [Note] mysqld (mysqld 10.3.12-MariaDB-1:10.3.12+maria~bionic) starting as process 105 ...
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Using Linux native AIO
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Uses event mutexes
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Compressed tables use zlib 1.2.11
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Number of pools: 1
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Using SSE2 crc32 instructions
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Initializing buffer pool, total size = 256M, instances = 1, chunk size = 128M
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: Completed initialization of buffer pool
mysql        | 2019-01-27 15:46:20 0 [Note] InnoDB: If the mysqld execution user is authorized, page cleaner thread priority can be changed. See the man page of setpriority().
mysql        | 2019-01-27 15:46:21 0 [Note] InnoDB: 128 out of 128 rollback segments are active.
mysql        | 2019-01-27 15:46:21 0 [Note] InnoDB: Creating shared tablespace for temporary tables
mysql        | 2019-01-27 15:46:21 0 [Note] InnoDB: Setting file './ibtmp1' size to 12 MB. Physically writing the file full; Please wait ...
mysql        | MySQL init process in progress...
mysql        | 2019-01-27 15:46:22 0 [Note] InnoDB: File './ibtmp1' size is now 12 MB.
mysql        | 2019-01-27 15:46:22 0 [Note] InnoDB: Waiting for purge to start
mysql        | 2019-01-27 15:46:22 0 [Note] InnoDB: 10.3.12 started; log sequence number 1630824; transaction id 21
mysql        | 2019-01-27 15:46:22 0 [Note] Plugin 'FEEDBACK' is disabled.
mysql        | 2019-01-27 15:46:22 0 [Note] InnoDB: Loading buffer pool(s) from /var/lib/mysql/ib_buffer_pool
mysql        | 2019-01-27 15:46:22 0 [Note] InnoDB: Buffer pool(s) load completed at 190127 15:46:22
mysql        | 2019-01-27 15:46:22 0 [Warning] 'user' entry 'root@fc9f819a3e8c' ignored in --skip-name-resolve mode.
mysql        | 2019-01-27 15:46:22 0 [Warning] 'user' entry '@fc9f819a3e8c' ignored in --skip-name-resolve mode.
mysql        | 2019-01-27 15:46:22 0 [Warning] 'proxies_priv' entry '@% root@fc9f819a3e8c' ignored in --skip-name-resolve mode.
mysql        | 2019-01-27 15:46:22 0 [Note] Reading of all Master_info entries succeded
mysql        | 2019-01-27 15:46:22 0 [Note] Added new Master_info '' to hash table
mysql        | 2019-01-27 15:46:22 0 [Note] mysqld: ready for connections.
mysql        | Version: '10.3.12-MariaDB-1:10.3.12+maria~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 0  mariadb.org binary distribution
mysql        | Warning: Unable to load '/usr/share/zoneinfo/leap-seconds.list' as time zone. Skipping it.
mysql        | 2019-01-27 15:46:38 10 [Warning] 'proxies_priv' entry '@% root@fc9f819a3e8c' ignored in --skip-name-resolve mode.
mysql        |
mysql        | 2019-01-27 15:46:38 0 [Note] mysqld (initiated by: unknown): Normal shutdown
mysql        | 2019-01-27 15:46:38 0 [Note] Event Scheduler: Purging the queue. 0 events
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: FTS optimize thread exiting.
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: Starting shutdown...
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: Dumping buffer pool(s) to /var/lib/mysql/ib_buffer_pool
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: Buffer pool(s) dump completed at 190127 15:46:38
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: Shutdown completed; log sequence number 1630833; transaction id 24
mysql        | 2019-01-27 15:46:38 0 [Note] InnoDB: Removed temporary tablespace data file: "ibtmp1"
mysql        | 2019-01-27 15:46:38 0 [Note] mysqld: Shutdown complete
mysql        |
mysql        |
mysql        | MySQL init process done. Ready for start up.
mysql        |
mysql        | 2019-01-27 15:46:39 0 [Note] mysqld (mysqld 10.3.12-MariaDB-1:10.3.12+maria~bionic) starting as process 1 ...
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Using Linux native AIO
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Uses event mutexes
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Compressed tables use zlib 1.2.11
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Number of pools: 1
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Using SSE2 crc32 instructions
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Initializing buffer pool, total size = 256M, instances = 1, chunk size = 128M
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Completed initialization of buffer pool
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: If the mysqld execution user is authorized, page cleaner thread priority can be changed. See the man page of setpriority().
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: 128 out of 128 rollback segments are active.
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Creating shared tablespace for temporary tables
mysql        | 2019-01-27 15:46:39 0 [Note] InnoDB: Setting file './ibtmp1' size to 12 MB. Physically writing the file full; Please wait ...
mysql        | 2019-01-27 15:46:40 0 [Note] InnoDB: File './ibtmp1' size is now 12 MB.
mysql        | 2019-01-27 15:46:40 0 [Note] InnoDB: Waiting for purge to start
mysql        | 2019-01-27 15:46:40 0 [Note] InnoDB: 10.3.12 started; log sequence number 1630833; transaction id 21
mysql        | 2019-01-27 15:46:40 0 [Note] Plugin 'FEEDBACK' is disabled.
mysql        | 2019-01-27 15:46:40 0 [Note] InnoDB: Loading buffer pool(s) from /var/lib/mysql/ib_buffer_pool
mysql        | 2019-01-27 15:46:40 0 [Note] Server socket created on IP: '::'.
mysql        | 2019-01-27 15:46:40 0 [Note] InnoDB: Buffer pool(s) load completed at 190127 15:46:40
mysql        | 2019-01-27 15:46:40 0 [Warning] 'proxies_priv' entry '@% root@fc9f819a3e8c' ignored in --skip-name-resolve mode.
mysql        | 2019-01-27 15:46:40 0 [Note] Reading of all Master_info entries succeded
mysql        | 2019-01-27 15:46:40 0 [Note] Added new Master_info '' to hash table
mysql        | 2019-01-27 15:46:40 0 [Note] mysqld: ready for connections.
mysql        | Version: '10.3.12-MariaDB-1:10.3.12+maria~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
```

## <a name="stop-and-remove"></a>`stop-and-remove.sh` output

A script to stop and remove the running WordPress site has been provided.

Example usage:

```console
$ ./stop-and-remove.sh
Do you really want to stop and remove EVERYTHING (y/n)? y
INFO: Stopping containers
Stopping nginx     ... done
Stopping wordpress ... done
Stopping mysql     ... done
INFO: Removing containers
Going to remove nginx, wordpress, mysql
Removing nginx     ... done
Removing wordpress ... done
Removing mysql     ... done
INFO: Setting file permissions to that of the user
INFO: Pruning unused docker volumes
Total reclaimed space: 0B
INFO: Pruning unused docker networks
Deleted Networks:
wordpress-nginx-docker_default

INFO: Removing directories and contents (certs/ certs-data/ logs/nginx/ mysql/ wordpress/)
INFO: Done
```
