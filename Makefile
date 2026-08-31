CONTAINER_NAME   = unicore-connector
VERSION          = 0.0.1
UNICORE-VERSION  = 11.2.0
PATCH            = ""
CONTAINER_REPO   = ghcr.io/unicore-eu
CONTAINER        = $(CONTAINER_REPO)/$(CONTAINER_NAME)
CONTAINER_TAG    = $(CONTAINER):$(VERSION)
CONTAINER_LATEST = $(CONTAINER):latest
DOWNLOAD_URL     = "https://github.com/UNICORE-EU/server-bundle/releases/download/$(UNICORE-VERSION)$(PATCH)"

PORT = 8080

.DEFAULT_GOAL := build

.PHONY: prepare build build-latest run clean realclean

unicore-servers.tgz:
	@echo "Downloading $(DOWNLOAD_URL)/unicore-servers-$(UNICORE-VERSION)$(PATCH).tgz ..."
	@wget --quiet $(DOWNLOAD_URL)/unicore-servers-$(UNICORE-VERSION)$(PATCH).tgz -O unicore-servers.tgz
	@tar xf unicore-servers.tgz
	@mv unicore-servers-$(UNICORE-VERSION)$(PATCH) unicore-servers

prepare: unicore-servers.tgz
	@rm -rf unicore/
	@mkdir -p unicore/gateway/conf unicore/unicorex/conf unicore/certs	
	@cp -r unicore-servers/gateway/lib unicore-servers/gateway/bin unicore/gateway
	@cp -r unicore-servers/unicorex/lib unicore-servers/unicorex/bin unicore/unicorex
	@cp config/gateway/* unicore/gateway/conf/
	@cp config/unicorex/* unicore/unicorex/conf/
	@cp config/*.sh unicore/

build: prepare Dockerfile docker-entrypoint.sh
	docker build -t $(CONTAINER_TAG) .

build-latest: prepare Dockerfile docker-entrypoint.sh
	docker build -t $(CONTAINER_LATEST) .

run: build
	docker run -p ${PORT}:8080 --mount type=bind,src=./local,dst=/local -d --rm $(CONTAINER):${VERSION}

clean:
	@find -name "*~" -delete

realclean: clean
	@rm -rf *.tgz unicore-servers unicore/certs unicore/gateway unicore/unicorex
