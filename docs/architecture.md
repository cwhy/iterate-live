# Architecture

## Overview

Iterate Live combines three components:

1. **System Tray Host** (Go) — Menu bar app that manages the Elixir process
2. **Phoenix App** (Elixir) — LiveView web application served on localhost
3. **System Browser** — User interface rendered in the default browser

## Process Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        User's Machine                        │
│                                                              │
│  ┌────────────────┐                  ┌────────────────────┐  │
│  │  Tray Host     │                  │  Elixir Release    │  │
│  │  (menu bar)    │                  │                    │  │
│  │  ┌──────────┐  │     TCP/4       │  ┌──────────────┐  │  │
│  │  │ Bridge   │◄─┼─────────────────┼──┤ ElixirKit    │  │  │
│  │  │ Server   │  │   (ElixirKit)   │  │ GenServer    │  │  │
│  │  └──────────┘  │                  │  └──────────────┘  │  │
│  │                │                  │                    │  │
│  │  ┌──────────┐  │                  │  ┌──────────────┐  │  │
│  │  │ Launcher │──┼──────────────────┼─►│ BEAM VM      │  │  │
│  │  │          │  │   (subprocess)   │  │              │  │  │
│  │  └──────────┘  │                  │  │  Phoenix     │  │  │
│  └────────────────┘                  │  │  Endpoint    │  │  │
│          │                           │  └──────┬───────┘  │  │
│          │ opens                     └─────────┼──────────┘  │
│          ▼                                     │ HTTP        │
│  ┌────────────────────────────────────────────┐│             │
│  │            System Browser                  ││             │
│  │         http://localhost:4000 ◄────────────┘│             │
│  └────────────────────────────────────────────┘              │
└──────────────────────────────────────────────────────────────┘
```

## Lifecycle

### Startup

1. User launches the `.app` bundle (or runs the binary directly)
2. System tray icon appears in the macOS menu bar
3. Host starts a TCP listener on `127.0.0.1:0`
4. Host spawns the Elixir release with `ELIXIRKIT_PORT=<port>`
5. Elixir boots Phoenix, then `ElixirKit.Server` connects to the host
6. Phoenix endpoint starts on port 4000
7. Elixir sends `ready:http://localhost:4000` via ElixirKit
8. Host receives `ready`, opens the URL in the system browser

### Steady State

- User interacts with Phoenix LiveView in the browser
- Phoenix serves HTTP/WebSocket on localhost:4000
- ElixirKit connection remains open (heartbeat/keepalive)
- Host → Elixir: can send `open` events (deep links, file opens)
- Elixir → Host: can send custom events (future extensibility)
- System tray menu provides "Open in Browser" and "Quit"

### Shutdown

1. User clicks "Quit" in the tray menu (or kills the process)
2. Host closes the TCP connection
3. Host runs `./app stop` for graceful Elixir shutdown
4. ElixirKit GenServer detects `tcp_closed`, calls `System.stop(0)`
5. Host waits up to 5 seconds for clean exit, then force-kills if needed

## Key Components

### System Tray Host (`host/`)

| File                  | Purpose                                      |
|-----------------------|----------------------------------------------|
| `main.go`             | Systray entry point, menu setup              |
| `app.go`              | App lifecycle: start, shutdown, events       |
| `icon.go`             | Embedded tray icon (PNG)                     |
| `bridge/elixirkit.go` | TCP server accepting Elixir connection       |
| `launcher/runtime.go` | Finds and manages the Elixir release process |

### Phoenix App (`app/`)

| File                        | Purpose                                |
|-----------------------------|----------------------------------------|
| `lib/elixirkit.ex`          | Public API: `publish/2`                |
| `lib/elixirkit/server.ex`   | GenServer: TCP client, event handling  |
| `lib/app_web/live/`         | LiveView modules                       |
| `config/runtime.exs`        | Release configuration                  |

## ElixirKit Protocol

See [protocol.md](protocol.md) for the message format.

## Error Handling

### Connection Failures

- If Elixir can't connect to the host port, it logs an error and stops
- If the host can't spawn the release, it logs an error

### Orphan Prevention

- TCP connection acts as a "lifeline" — if host dies, Elixir exits
- Host tracks the Elixir PID and force-kills on timeout
- 5-second grace period allows Phoenix to drain connections

## Development vs Production

| Aspect         | Development (`make dev`)     | Production (`make run`)     |
|----------------|------------------------------|---------------------------  |
| Elixir         | `mix phx.server`             | Release binary              |
| ElixirKit      | Disabled (no port set)       | Enabled                     |
| Hot reload     | Yes                          | No                          |
| Browser        | Manual open                  | Auto-opened by host         |
| Shutdown       | Ctrl+C                       | Tray menu "Quit"            |
| System tray    | Not running                  | Menu bar icon               |
