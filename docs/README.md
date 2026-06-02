# Devilbox Documentation

The Devilbox documentation is built with Astro Starlight and published through GitHub Pages.

## Documentation

The canonical documentation site is: https://devilbox.nntoan.com

## Local setup

You can build the documentation locally before pushing to ensure everything looks fine.

### Requirements

- Docker
- Node.js/npm when running the build directly instead of the Makefile container workflow

### How to check for broken links

```sh
cd docs/
make linkcheck
make linkcheck2
```

### How to build and error-check

```sh
cd docs/
make build
```

### How to build continuously

```sh
cd docs/
make autobuild
```

### How to view

When using `make autobuild`, the documentation is served at http://127.0.0.1:4321/.

## Production domain

`docs/public/CNAME` configures GitHub Pages to serve the site at `devilbox.nntoan.com`. After the DNS record has propagated and GitHub has provisioned the certificate, enable **Enforce HTTPS** in repository Settings → Pages.

TODO: configure the ReadTheDocs admin redirect to https://devilbox.nntoan.com.
