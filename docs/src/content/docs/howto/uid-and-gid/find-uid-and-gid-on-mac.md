---
title: "Find your user id and group id on MacOS"
---

# Find your user id and group id on MacOS

Devilbox maps the `devilbox` user inside containers to your macOS user.
Set `NEW_UID` and `NEW_GID` in `.env`.

## Print your IDs

Open a terminal and run:

```bash
id -u
id -g
```

Example output:

```text
501
20
```

Use the first number as `NEW_UID`; the second as `NEW_GID`.

## Edit `.env`

Run:

```bash
cp -n env-example .env
nano .env
```

Set:

```dotenv
NEW_UID=501
NEW_GID=20
```

Restart:

```bash
./dvl.sh down
./dvl.sh up
```

## Verify

```bash
./dvl.sh shell
```

Enter PHP and check ownership:

```bash
id
touch /shared/httpd/uid-check.txt
exit
ls -l data/www/uid-check.txt
rm data/www/uid-check.txt
```

The file owner should match your macOS user. If not, recheck `NEW_UID`
and `NEW_GID` against `id -u` and `id -g`; then review
[prerequisites](/getting-started/prerequisites/).
