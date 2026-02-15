# Makefile for iterate-live

.PHONY: dev build-release build-host build-app-bundle build run package test clean deps

# Development - run Phoenix in dev mode (no host)
dev:
	cd app && mix phx.server

# Build the Elixir release
build-release:
	cd app && MIX_ENV=prod mix deps.get && MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release app --overwrite

# Build the Go host binary
build-host:
	cd host && CGO_ENABLED=1 go build -o build/bin/iterate-live .

# Assemble macOS .app bundle
build-app-bundle: build-host build-release
	@echo "==> Assembling IterateLive.app bundle"
	@mkdir -p host/build/bin/IterateLive.app/Contents/MacOS
	@mkdir -p host/build/bin/IterateLive.app/Contents/Resources
	@cp host/build/bin/iterate-live host/build/bin/IterateLive.app/Contents/MacOS/iterate-live
	@cp host/build/darwin/Info.plist host/build/bin/IterateLive.app/Contents/Info.plist
	@cp host/build/appicon.png host/build/bin/IterateLive.app/Contents/Resources/appicon.png
	@cp -R app/_build/prod/rel/app host/build/bin/IterateLive.app/Contents/Resources/rel/app
	@echo "==> IterateLive.app ready at host/build/bin/IterateLive.app"

# Build everything
build: build-app-bundle

# Run the desktop app (after building)
run:
	cd host && ./build/bin/iterate-live

# Package for distribution
package:
	./scripts/package-macos.sh

# Run all tests
test:
	cd app && mix test

# Clean build artifacts
clean:
	rm -rf app/_build app/deps
	rm -rf host/build/bin

# Install dependencies
deps:
	cd app && mix deps.get
	cd host && go mod tidy
