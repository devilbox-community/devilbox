---
title: "Open a terminal on MacOS"
---

orphan  

# Open a terminal on MacOS

<div class="seealso">

`howto-open-terminal-on-win`

</div>


## Docker for Mac

Docker for Mac (the native Docker implementation) does not have any
special requirements for initial environment variable setup. Simply open
your terminal of choice from the **Launchpad** (`Terminal.app` or
`iTerm.app`).

<div class="seealso">

`install docker mac`

</div>

## Docker Toolbox

Docker Toolbox provides a launcher to open an environment prepared
terminal, but you can also do it manually with a terminal of your
choice.

### Via Launcher

1.  Open the **Launchpad** and locate the Docker Quickstart Terminal
    icon.

<figure>
<img
src="/_includes/figures/terminal/docker-toolbox-terminal-mac-quickstart-launchpad.png"
alt="Copyright docs.docker.com" />
<figcaption aria-hidden="true">Copyright docs.docker.com</figcaption>
</figure>

2.  Click the icon to launch a Docker Quickstart Terminal window.

    The terminal does a number of things to set up Docker Quickstart
    Terminal for you.

``` bash
Last login: Sat Jul 11 20:09:45 on ttys002
bash '/Applications/Docker Quickstart Terminal.app/Contents/Resources/Scripts/start.sh'
Get http:///var/run/docker.sock/v1.19/images/json?all=1&filters=%7B%22dangling%22%3A%5B%22true%22%5D%7D: dial unix /var/run/docker.sock: no such file or directory. Are you trying to connect to a TLS-enabled daemon without TLS?
Get http:///var/run/docker.sock/v1.19/images/json?all=1: dial unix /var/run/docker.sock: no such file or directory. Are you trying to connect to a TLS-enabled daemon without TLS?
-bash: lolcat: command not found

mary at meepers in ~
$ bash '/Applications/Docker Quickstart Terminal.app/Contents/Resources/Scripts/start.sh'
Creating Machine dev...
Creating VirtualBox VM...
Creating SSH key...
Starting VirtualBox VM...
Starting VM...
To see how to connect Docker to this machine, run: docker-machine env dev
Starting machine dev...
Setting environment variables for machine dev...

                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

The Docker Quick Start Terminal is configured to use Docker with the "default" VM.
```

You can now use this terminal window to apply all your Docker and
Devilbox related commands.

### Different terminal

If you rather want to use a different terminal, you can accomplish the
same behaviour.

1.  Open your terminal of choice
2.  Type the following to prepare environment variables

``` bash
$(docker-machine env default)
```

You can now use this terminal window to apply all your Docker and
Devilbox related commands.

<div class="seealso">

`install docker toolbox mac`

</div>
