---
title: "Enable and configure MailHog"
description: "Enable MailHog in Devilbox with the maintained compose override snippet."
---

# Enable and configure MailHog

MailHog catches outgoing application email during development and shows it in a
browser UI, avoiding accidental delivery to real recipients.

## How it works

Devilbox keeps optional integrations as override snippets in the `compose/`
directory. To enable MailHog, copy its snippet into the project root as
`docker-compose.override.yml`, then start the stack.

## Enable

```bash
cp compose/docker-compose.override.yml-mailhog docker-compose.override.yml
./dvl.sh up
```

## Configuration

The snippet defines service `mailhog` with image
`${MAILHOG_IMAGE:-mailhog/mailhog}:${MAILHOG_SERVER:-latest}`, hostname
`mailhog`, IP `172.16.238.252`, and UI port
`${HOST_PORT_MAILHOG:-8025}:8025`. It does not mount volumes.

| Variable | Default | Purpose |
|---|---|---|
| `MAILHOG_IMAGE` | `mailhog/mailhog` | MailHog image repository. |
| `MAILHOG_SERVER` | `latest` | MailHog image tag. |
| `HOST_PORT_MAILHOG` | `8025` | Host port for the MailHog Web UI. |

Configure PHP to send mail to MailHog's SMTP listener:

```ini
[mail function]
sendmail_path = '/usr/local/bin/mhsendmail --smtp-addr="mailhog:1025"'
```

Place that in the php.ini directory for your selected PHP version, for example
`cfg/php-ini-8.3/mailhog.ini`.

## Usage

Open the mailbox UI:

```bash
open http://localhost:8025
```

Send a test email from inside PHP:

```bash
./dvl.sh exec php -r 'mail("dev@example.test", "Devilbox test", "Hello from MailHog");'
```

Point an application SMTP client at host `mailhog`, port `1025`, without TLS or
authentication.

## Disable

```bash
./dvl.sh down
rm docker-compose.override.yml
./dvl.sh up
```

Remove the MailHog php.ini file if PHP should return to its previous mail
transport.

## Troubleshooting

- If messages do not appear, confirm PHP is using the php.ini file for the
  active PHP version.
- If the UI does not load, check whether another process already uses host port
  `8025` and adjust `HOST_PORT_MAILHOG`.
- If an app uses SMTP directly, verify it points to `mailhog:1025` from inside
  the Docker network, not `localhost`.

## See also

- [Add your own Docker image](/advanced/add-your-own-docker-image/)
- [Docker Compose override file](/configuration-files/docker-compose-override-yml/)
