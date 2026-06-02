---
title: "Find Docker Toolbox IP address"
---

orphan  

# Find Docker Toolbox IP address


## Get IP address

1.  Open an environment prepared Terminal

2.  Enter the following command to get the IP address of the Docker
    Toolbox virtual machine:

    ``` bash
    host> docker-machine ip default

    192.168.99.100
    ```

The above example outputs `192.168.99.100`, but this might be a
different IP address on your machine.

<div class="seealso">

- `howto-open-terminal-on-mac`
- `howto-open-terminal-on-win`

</div>

## What to do with it

The Docker Toolbox IP address is the address where the Devilbox intranet
as well as all of its projects will be available at.

- Use it to access the intranet via your browser
  (`http://192.168.99.100` in this example)
- Use it for manual DNS entries

<div class="seealso">

- `howto-add-project-hosts-entry-on-mac`
- `howto-add-project-hosts-entry-on-win`

</div>
