# Build Guide

## Prerequisites

Install the following tools:

| Tool    | Version | Install                                      |
|---------|---------|----------------------------------------------|
| OTP     | 27+     | `brew install erlang` or asdf               |
| Elixir  | 1.18+   | `brew install elixir` or asdf               |
| Go      | 1.23+   | `brew install go`                           |
| Node.js | 22+     | `brew install node`                         |
| Wails   | 2.9+    | `go install github.com/wailsapp/wails/v2/cmd/wails@latest` |

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

Build both the Elixir release and Wails host:

```bash
make build
```

## Run Desktop App

After building:

```bash
make run
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

GitHub Actions builds and packages on every push to `main` and on PRs. Artifacts are downloadable from the Actions tab.
