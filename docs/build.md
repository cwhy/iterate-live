# Build Guide

## Prerequisites

Install the following tools:

| Tool    | Version | Install                                      |
|---------|---------|----------------------------------------------|
| OTP     | 27+     | `brew install erlang` or asdf               |
| Elixir  | 1.18+   | `brew install elixir` or asdf               |
| Go      | 1.23+   | `brew install go`                           |

## First-Time Setup

```bash
make deps
```

## Development

Run Phoenix in dev mode (hot reload, no desktop shell):

```bash
make dev
```

Then open http://localhost:4000

## Build

Build both the Elixir release and Go host:

```bash
make build
```

This compiles the Go binary, builds the Elixir release, and assembles the macOS `.app` bundle.

## Run Desktop App

Run the host binary directly (for quick testing without the app bundle):

```bash
make run
```

Or launch the assembled app bundle:

```bash
open host/build/bin/IterateLive.app
```

## Package for Distribution

Creates a `.dmg` in `dist/`:

```bash
make package
```

## Tests

```bash
make test
```

## Clean

Remove all build artifacts:

```bash
make clean
```

## CI

GitHub Actions builds and packages on every push to `trunk` and on PRs. Artifacts are downloadable from the Actions tab.
