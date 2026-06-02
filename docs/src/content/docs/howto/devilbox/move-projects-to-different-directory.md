---
title: "Move projects to a different directory"
---

orphan  

# Move projects to a different directory

No matter if your projects are already in a different location or if you
want to move them out of the Devilbox git directory now, you can do that
in a few simple steps.


## Projects in an absolute path

So let’s assume all of your projects are already in place under
`/home/user/workspace/web/`. Now you decide to use the Devilbox, but
still want to keep your projects where they are at the moment.

All you have to do is to adjust the path of `env-httpd-datadir` in the
`.env` file.

``` bash
# Navigate to Devilbox git directory
host> cd path/to/devilbox

# Open the .env file with your favourite editor
host> vim .env
```

Now Adjust the value of `env-httpd-datadir`

``` bash
HOST_PATH_HTTPD_DATADIR=/home/user/workspace/web
```

That's it, whenever you start up the Devilbox,
`/home/user/workspace/web/` will be mounted into the PHP and the web
server container into `/shared/httpd/`.

## Projects adjacent to Devilbox directory

Consider the following directory setup:

``` bash
|
+- devilbox/
|
+- projects/
   |
   + project1/
   | |
   | + htdocs/
   |
   + project2/
     |
     + htdocs/
```

Independently of where the Devilbox directory is located, you can
achieve this structure via relative path settings.

All you have to to is to adjust the path of `env-httpd-datadir` in the
`.env` file.

``` bash
# Navigate to Devilbox git directory
host> cd path/to/devilbox

# Open the .env file with your favourite editor
host> vim .env
```

Now Adjust the value of `env-httpd-datadir`

``` bash
HOST_PATH_HTTPD_DATADIR=../projects
```

That's it, whenever you start up the Devilbox, your project directory
will be mounted into the PHP and the web server container into
`/shared/httpd/`.
