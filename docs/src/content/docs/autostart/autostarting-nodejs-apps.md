---
title: "Autostarting NodeJS Apps"
---

# Autostarting NodeJS Apps

You can have all of your NodeJS applications spin up automtically as
soon as you `docker-compose up`. This can be achieved by makeing use of
`tool pm2` (Node.js Process
Manager) and the autostart feature.

<div class="seealso">

**Read more about how to add scripts for autostart commands:**

- `custom-scripts-per-php-version` (individually for different PHP
  versions)
- `custom-scripts-globally` (equal for all PHP versions)

</div>


## Self-built

Simply add a script ending by `.sh` to the `autostart/` directory that
will accomplish this. The following example will make use of
`tool pm2` to spin up your
NodeJS application.

### Assumption

- Path to your NodeJS project (within the Docker container):
  `/shared/httpd/my-node/src`
- Name of the JS file to startup: `index.js`

### The script

Add the following script to `autostart/`

``` bash
su -c "cd /shared/httpd/my-node/src; pm2 start index.js" -l devilbox
```

- The whole command is wrapped into `su` to ensure the application will
  be started as the user `devilbox`.
- `cd` tells it to you enter the directory where `index.js` can be found
- And finally `tool pm2` will
  take care about starting up your javascript file.

Once the Devilbox is running, you can enter the PHP container and verify
with `pm2 list` that everything is running as expected.

## Pre-built

Instead of writing multiple scripts for multiple applications, you can
also make use of the pre-shipped script that allows you to start
unlimitted NodeJS applications via
`tool pm2`.

The following script is provided in
`autostart/run-node-js-projects.sh-example` and needs to be copied to a
file ending by `.sh`

``` bash
host> cd /path/to/devilbox
host> cd autostart
host> cp run-node-js-projects.sh-example run-node-js-projects.sh
```

In that newly created file, you can simply add the full paths (path
inside the Docker containre) of your Javascript files that need to be
started. There is already one example which is not commented. Change
this to your path and add as many lines as you have projects to startup.

<div class="literalinclude" caption="autostart/run-node-js-projects.sh"
language="bash" emphasize-lines="16">

../../autostart/run-node-js-projects.sh-example

</div>

## Reverse proxy NodeJS

If you also want to know how to reverse proxy your NodeJS service and
have it available via the web server including HTTPS support have a look
at the following links:

<div class="seealso">

- `reverse-proxy-with-https`
- `example-setup-reverse-proxy-nodejs`

</div>

Imagine you have started an application within the PHP container that
creates a listening port (e.g.: NodeJS). This will now only listen on
the PHP container and you would have to adjust the docker-compose.yml
definition in order to have that port available outside to your host OS.

Alternatively, there is a simple way to reverse proxy it to the already
running web server and even make use of the already available HTTPS
feature.
