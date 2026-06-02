---
title: "Connect to other Docker container"
---

# Connect to other Docker container

Other Docker container can either be accessed by connecting back to the
host os or by adding its image directly to the Devilbox stack.


## Any Docker container on host os

1.  To connect to any other Docker container on your host os from within
    the Devilbox Docker container, you first need to make sure, you are
    able to connect to your host os from within the Devilbox Docker
    container.

    <div class="seealso">

    `connect-to-host-os`

    </div>

2.  Once you are able to connect to the host os, start any other Docker
    container and make its port that you want to access available to
    your host os by specifying `-p`. An example with e.g. an external
    `docker image grafana`
    container might look like this:

    ``` bash
    host> docker run -d --name=grafana -p 3000:3000 grafana/grafana
    ```

    You can then connect to your host os on port `3000` from within the
    Devilbox Docker container and be able to use it.

## Add Docker container to Devilbox network

The Devilbox defines its own bridge network, usually called
`devilbox-app-net`.

> [!NOTE]
> The name may vary depending on the name of the Devilbox directory. It
> assembles itself by `<Devilbox_dir_name>_app_net`.

1.  Start the Devilbox

2.  Start your container of choice

    ``` bash
    host> docker run -d --name mycontainer
    ```

3.  Attach your container to the Devilbox network

    ``` bash
    host> docker network connect devilbox_app_net mycontainer
    ```

Once you have done that, `mycontainer` is then part of the internal
Devilbox network and is able to resolve Devilbox container by its name
and vice-versa.

4.  Connect from Devilbox PHP container to `mycontainer`

    From inside the PHP container, you can then refer to your container
    by its hostname `mycontainer`

## Add Docker container to Devilbox stack

Alternatively you can also add any Docker container to the Devilbox
network by adding an image it to the Devilbox stack directly.

<div class="seealso">

`add-your-own-docker-image`

</div>
