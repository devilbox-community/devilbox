---
title: "Use external databases"
---

# Use external databases


## Why

Some people or companies might have concerns with dockerized databases
and rather rely on good old host-based database setups. There could
already be a database cluster in your network or you rather want to use
AWS RDS or other cloud-based solutions.

There are many reasons for having an external database.

## Database on host os

> [!NOTE]
> If the local database is listening on an IP address that is reachable
> over your current LAN, you can directly skip to:
> `use-external-databases-database-on-network`

In order to use an already existing database that is running on the host
os, you need to make sure the following is met:

1.  Be able to connect to the host os from inside the container

    <div class="seealso">

    `connect-to-host-os`

    </div>

2.  Configure your application to use the IP/CNAME of the host os

3.  When starting the Devilbox, explicitly specify the service to use
    and exclude the databases:

    ``` bash
    # Explicitly specify services to start (otherwise all will start)
    # Omit the database
    host> docker-compose up -d php httpd bind redis
    ```

    <div class="seealso">

    `start-the-devilbox`

    </div>

## Database on network

In order to use an already existing database that is running on the
network, you need to make sure the following is met:

1.  Configure your application to use the IP/CNAME of the database host

2.  When starting the Devilbox, explicitly specify the service to use
    and exclude the databases:

    ``` bash
    # Explicitly specify services to start (otherwise all will start)
    # Omit the database
    host> docker-compose up -d php httpd bind redis
    ```

    <div class="seealso">

    `start-the-devilbox`

    </div>

## Database on internet

In order to use an already existing database that is running on the
network, you need to make sure the following is met:

1.  Configure your application to use the IP/CNAME of the database host

2.  When starting the Devilbox, explicitly specify the service to use
    and exclude the databases:

    ``` bash
    # Explicitly specify services to start (otherwise all will start)
    # Omit the database
    host> docker-compose up -d php httpd bind redis
    ```

    <div class="seealso">

    `start-the-devilbox`

    </div>
