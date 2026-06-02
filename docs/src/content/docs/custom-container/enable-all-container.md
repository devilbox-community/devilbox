---
title: "Enable all additional container"
---

# Enable all additional container

Besides providing basic LAMP/MEAN stack container, which are well
integrated into the Devilbox intranet, the Devilbox also ships
additional pre-configured container that can easily be enabled.

<div class="seealso">

`docker-compose-override-yml-how-does-it-work`

</div>


## Available additional container

The following table shows you the currently additional available
container:

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

## Enable all additional container

Copy `docker-compose.override.yml-all` into the root of the Devilbox git
directory.

``` bash
host> cp compose/docker-compose.override.yml-all docker-compose.override.yml
```

That's it, if you `docker-compose up`, all container will be started.
This however is not adviced as it will eat up a lot of resources. You
are better off by selectively specifying the container you want to run.

<div class="seealso">

`start-the-devilbox`

</div>

## Configure additional container

The additional container also provide many configuration options just as
the default ones do. That includes, but is not limited to:

- Image version
- Exposed ports
- Mount points
- And various container specific settings

In order to fully customize each container, refer to their own
documentation section:

<div class="seealso">

\* `custom-container-enable-php-community` \*
`custom-container-enable-blackfire` \*
`custom-container-enable-elk-stack` \* `custom-container-enable-mailhog`
\* `custom-container-enable-ngrok` \*
`custom-container-enable-python-flask` \*
`custom-container-enable-rabbitmq` \* `custom-container-enable-solr` \*
`custom-container-enable-varnish`

</div>
