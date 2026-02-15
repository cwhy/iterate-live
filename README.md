# Iterate Live

A template for building desktop applications with Phoenix LiveView. Uses a lightweight Go host that lives in the macOS menu bar to launch an Elixir release, then opens the system browser to the Phoenix app running on localhost.

## Quick Start

```bash
# Install dependencies
make deps

# Run in development (Phoenix only, hot reload)
make dev

# Build and run as desktop app
make build && make run
```

## How It Works

```
┌─────────────────┐       TCP        ┌─────────────────┐
│  Tray Host (Go) │◄────────────────►│  Elixir/Phoenix │
│   (menu bar)    │   ElixirKit      │    (Release)    │
└────────┬────────┘                  └────────┬────────┘
         │                                    │
         │ opens                              │ serves
         ▼                                    ▼
┌─────────────────────────────────────────────────────┐
│                   System Browser                    │
│                http://localhost:4000                │
└─────────────────────────────────────────────────────┘
```

1. App launches as a macOS menu bar icon (no Dock icon)
2. Host starts and listens on a random TCP port
3. Host launches the Elixir release with `ELIXIRKIT_PORT` set
4. Phoenix boots and connects back via ElixirKit
5. Elixir sends `ready:http://localhost:4000`
6. Host opens the system browser
7. On quit (tray menu), host closes TCP connection → Elixir exits cleanly

## Project Structure

```
iterate-live/
├── app/                    # Elixir/Phoenix project
│   ├── lib/
│   │   ├── app_web/        # Phoenix LiveView UI
│   │   ├── elixirkit.ex    # Bridge public API
│   │   └── elixirkit/      # Bridge GenServer
│   └── mix.exs
├── host/                   # Go system tray host
│   ├── bridge/             # TCP server (Go side)
│   ├── launcher/           # Elixir process manager
│   ├── main.go             # Systray entry point
│   ├── app.go              # App lifecycle
│   └── icon.go             # Embedded tray icon
├── scripts/                # Build & packaging
├── docs/                   # Documentation
└── Makefile
```

## Commands

| Command                | Description                              |
|------------------------|------------------------------------------|
| `make dev`             | Run Phoenix in dev mode (hot reload)     |
| `make build`           | Build Elixir release + Go host + .app    |
| `make run`             | Run the host binary directly             |
| `make package`         | Create distributable `.dmg`              |
| `make test`            | Run tests                                |
| `make clean`           | Remove build artifacts                   |

## Using as a Template

To start a new project from this template:

1. Clone/copy this repository
2. Rename `app` module in `app/mix.exs` and `app/lib/`
3. Update the bundle ID in `host/build/darwin/Info.plist`
4. Replace the icon at `host/build/appicon.png`
5. Run `make build && make run`

## Documentation

- [Build Guide](docs/build.md) — Prerequisites and build commands
- [Architecture](docs/architecture.md) — How the pieces fit together
- [Protocol](docs/protocol.md) — ElixirKit message format
- [Troubleshooting](docs/troubleshooting.md) — Common issues

## Requirements

- Erlang/OTP 27+
- Elixir 1.18+
- Go 1.23+

See [docs/build.md](docs/build.md) for installation instructions.
