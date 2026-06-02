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
	@echo "linkcheck        Build + run cytopia/linkcheck against ./dist"


# -------------------------------------------------------------------------------------------------
#  Targets
# -------------------------------------------------------------------------------------------------

build:
	$(DOCKER_RUN) $(NODE_IMAGE) sh -c "npm ci --cache .cache/npm --prefer-offline --no-audit --no-fund && npx astro build"

autobuild:
	docker run --rm $$(tty -s && echo "-it" || echo) -p 4321:4321 -v $(PWD):/docs -w /docs $(NODE_IMAGE) sh -c "npm ci --cache .cache/npm --prefer-offline --no-audit --no-fund && npx astro dev --host 0.0.0.0"

linkcheck: build
	docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD)/dist:/data cytopia/linkcheck -l -k -r 60 -t 30 -e html
