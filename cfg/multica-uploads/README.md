# cfg/multica-uploads

This directory is **bind-mounted** into the `multica-api` Wave 8F1 service at:

| Mount target | Mode | Purpose |
|---|---|---|
| `/app/data/uploads` | rw | Local file storage backing `LOCAL_UPLOAD_DIR` (fallback when `MULTICA_S3_BUCKET` is unset) |

User uploads (avatars, issue attachments, workspace files) land here. The
backend serves them via signed URLs.

## Forever-persistence

This is a host-side bind mount — uploads survive:

- `docker compose down -v`
- `./dvl.sh agent disable multica`
- Image upgrades (`docker compose pull && up -d`)

To migrate to S3 later: set `MULTICA_S3_BUCKET` + `MULTICA_S3_REGION` in
`.env`, restart the stack, and copy existing files via `aws s3 sync`. The
backend reads `LOCAL_UPLOAD_DIR` only when no S3 bucket is configured.

## Backup

```bash
tar -czf multica-uploads-$(date +%F).tgz cfg/multica-uploads/
```

## Upstream reference

- Repo:    `github.com/multica-ai/multica`
- Compose: `../multica/docker-compose.selfhost.yml`
- Env:     `../multica/.env.example` (`LOCAL_UPLOAD_DIR`)
