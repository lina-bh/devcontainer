NAME := ghcr.io/lina-bh/devcontainer
TAG := latest
TARGET := devcontainer

EXTRA_BUILD_ARGS :=

.PHONY: all
all: build

.PHONY: build
build:
	podman build --rm=false --pull=newer --tag=$(NAME):latest --layers=true --cache-from=$(NAME) --target=$(TARGET) $(EXTRA_BUILD_ARGS) .

.PHONY: push
push:
	podman push --format=oci $(NAME):$(TAG)

.PHONY: tag
tag:
	podman tag $(NAME):latest $(NAME):$(TAG)

.PHONY:
tag_HEAD:
	$(MAKE) tag TAG=$(shell git rev-parse HEAD)

.PHONY:
push_HEAD: tag_HEAD
	$(MAKE) push TAG=$(shell git rev-parse HEAD)


.PHONY: run
run:
	podman run --rm -it --pull=never $(NAME)
