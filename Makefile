SHELL := /bin/bash

.DEFAULT_GOAL := help

UID := $(shell id -u)
USERNAME := $(shell id -u -n)
GID := $(shell id -g)
GROUPNAME := $(shell id -g -n)

.PHONY: build
build: ## Build docker image for develop environment
	docker build -t slide:22 .

.PHONY: up
up: ## Start the container
	docker compose up -d

.PHONY: down
down: ## Delete the container
	docker compose down

.PHONY: yarn-install
yarn-install: ## Install packages
	docker compose run --rm node yarn

SUBDIRS := $(shell find src -maxdepth 1 -type d -print | sed '1d' | sed 's/src\///')

.PHONY: $(SUBDIRS)-dev
$(SUBDIRS)-dev: ## Running dev server
	docker compose exec node yarn workspace $(@:-dev=) dev

.PHONY: node
node: ## Enter node container
	docker compose exec node bash

.PHONY: help
help: ## Display a list of targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
