ifneq (,)
.error This Makefile requires GNU Make.
endif

# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help build autobuild linkcheck
NODE_IMAGE := node:lts-alpine
DOCKER_RUN := docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/docs -w /docs


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------

help:
	@echo "build            Build static documentation site (Astro Starlight) into ./dist"
	@echo "autobuild        Continuously rebuild and serve at http://0.0.0.0:4321"
	@echo "linkcheck        Build + run lychee link checker against ./dist"


# -------------------------------------------------------------------------------------------------
#  Targets
# -------------------------------------------------------------------------------------------------

build:
	$(DOCKER_RUN) $(NODE_IMAGE) sh -c "rm -rf dist .astro && npm ci --cache .cache/npm --prefer-offline --no-audit --no-fund && npx astro build"

build-ci:
	rm -rf dist .astro 2>/dev/null || true
	npm ci --cache .cache/npm --prefer-offline --no-audit --no-fund && npx astro build --sitemap false

autobuild:
	docker run --rm $$(tty -s && echo "-it" || echo) -p 4321:4321 -v $(PWD):/docs -w /docs $(NODE_IMAGE) sh -c "npm ci --cache .cache/npm --prefer-offline --no-audit --no-fund && npx astro dev --host 0.0.0.0"

linkcheck: build
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD)/dist:/data lycheeverse/lychee \
		--root-dir /data \
		--no-progress \
		--max-retries 2 \
		--max-concurrency 4 \
		--accept 200,201,301,302,304,429 \
		--exclude '^https?://github\.com/' \
		/data
