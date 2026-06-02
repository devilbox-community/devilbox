---
title: "Find your user id and group id on Windows"
---

orphan  

# Find your user id and group id on Windows


## Docker for Windows

On Docker for Windows it is **not necessary** to change uid and gid in
your `.env` file.

> [!NOTE]
> Docker for Windows is internally using network shares (SMB) to mount
> Docker volumes. This does not require to syncronize file and
> directoriy permissions via uid and gid.

## Docker Toolbox

On Docker Toolbox it is important that you open up a Docker environment
prepared terminal window.

<div class="seealso">

- `howto-open-terminal-on-win`

</div>

### Find your user id (`uid`)

Type the following command to retrieve the correct `uid`.

``` bash
host> id -u
```

### Find your group id (`gid`)

Type the following command to retrieve the correct `gid`.

``` bash
host> id -g
```
