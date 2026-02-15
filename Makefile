# Makefile for iterate-live

.PHONY: dev build-release build-host build run package test clean deps

# Development - run Phoenix in dev mode (no Wails host)
dev:
	cd app && mix phx.server

# Build the Elixir release
build-release:
	cd app && MIX_ENV=prod mix deps.get && MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release app --overwrite

# Build the Wails host
build-host:
	cd host && wails build

# Build everything
build: build-release build-host

# Run the full desktop app (after building)
run:
	cd host && ./build/bin/host.app/Contents/MacOS/host

# Package for distribution 
package:
	./scripts/package-macos.sh

# Run all tests
test:
	cd app && mix test

# Clean build artifacts
clean:
	rm -rf app/_build app/deps
	rm -rf host/build

# Install dependencies
deps:
	cd app && mix deps.get
	cd host && go mod tidy
