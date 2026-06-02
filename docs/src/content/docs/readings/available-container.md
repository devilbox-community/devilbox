---
title: "Available container"
---

# Available container

> [!NOTE]
> `start-the-devilbox` Find out how to start some or all container.

The following tables give you an overview about all container that can
be started. When doing a selective start, use the `Name` value to
specify the container to start up.

## Core container

These container are well integrated into the Devilbox intranet and are
considered core container:

| Container                 | Name  | Hostname | IP Address     |
|---------------------------|-------|----------|----------------|
| DNS                       | bind  | bind     | 172.16.238.100 |
| PHP                       | php   | php      | 172.16.238.10  |
| Apache, Nginx             | httpd | httpd    | 172.16.238.11  |
| MySQL, MariaDB, PerconaDB | mysql | mysql    | 172.16.238.12  |
| PostgreSQL                | pgsql | pgsql    | 172.16.238.13  |
| Redis                     | redis | redis    | 172.16.238.14  |
| Memcached                 | memcd | memcd    | 172.16.238.15  |
| MongoDB                   | mongo | mongo    | 172.16.238.16  |

## Additional container

Additional container that are not yet integrated into the Devilbox
intranet are also available. Those container come via
`docker-compose.override.yml` and must explicitly be enabled. They are
disabled by default to prevent accidentally starting too many container
and making your computer unresponsive.

| Container                           | Name      | Hostname  | IP Address     |
|-------------------------------------|-----------|-----------|----------------|
| PHP Community                       | php       | php       | 172.16.238.10  |
| Blackfire                           | blackfire | blackfire | 172.16.238.200 |
| MailHog                             | mailhog   | mailhog   | 172.16.238.201 |
| Ngrok                               | ngrok     | ngrok     | 172.16.238.202 |
| RabbitMQ                            | rabbit    | rabbit    | 172.16.238.210 |
| Solr                                | solr      | solr      | 172.16.238.220 |
| Varnish                             | varnish   | varnish   | 172.16.238.230 |
| HAProxy (SSL offloader for Varnish) | haproxy   | haproxy   | 172.16.238.231 |
| ELK: Elastic Search                 | elastic   | elastic   | 172.16.238.240 |
| ELK: Logstash                       | logstash  | logstash  | 172.16.238.241 |
| ELK: Kibana                         | kibana    | kibana    | 172.16.238.242 |
| Python Flask                        | flask1    | flask1    | 172.16.238.250 |

<div class="seealso">

\* `custom-container-enable-all-additional-container` \*
`custom-container-enable-blackfire` \* `custom-container-enable-mailhog`
\* `custom-container-enable-rabbitmq` \* `custom-container-enable-solr`

</div>
