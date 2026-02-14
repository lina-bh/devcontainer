.POSIX:
.EXPORT_ALL_VARIABLES:

REGISTRY := ghcr.io/lina-bh
TARGET := toolbox
DOCKER := buildah
EXTRA_BUILD_ARGS :=

NAME := $(REGISTRY)/$(TARGET)
TAG := $(shell git diff-index --quiet HEAD -- && git rev-parse HEAD || printf 'latest')

.PHONY: all
all:

.PHONY: build
build:
	$(DOCKER) build --rm=false --pull=newer --tag=$(NAME):latest --layers=true --cache-from=$(NAME) --file=Containerfile.$(TARGET) $(EXTRA_BUILD_ARGS) .
	$(DOCKER) tag $(NAME):latest $(NAME):$(TAG)

.PHONY: push
push:
	$(DOCKER) push --format=oci $(NAME):$(TAG)
	$(DOCKER) push --format=oci $(NAME):latest

.PHONY: ci
ci:
	$(MAKE) build push TARGET=toolbox
	$(MAKE) build push TARGET=devcontainer EXTRA_BUILD_ARGS='$(EXTRA_BUILD_ARGS) --build-arg=TAG=$(TAG)'

.PHONY: toolbox
toolbox:
	$(MAKE) build TARGET=toolbox

.PHONY: devcontainer
devcontainer:
	$(MAKE) build TARGET=devcontainer EXTRA_BUILD_ARGS='$(EXTRA_BUILD_ARGS) --build-arg=TAG=$(TAG)'
