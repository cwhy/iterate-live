# Architecture

## Overview

Iterate Live combines three components:

1. **Wails Host** (Go) — Native desktop shell that manages the Elixir process
2. **Phoenix App** (Elixir) — LiveView web application served on localhost
3. **System Browser** — User interface rendered in the default browser

## Process Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        User's Machine                        │
│                                                              │
│  ┌────────────────┐                  ┌────────────────────┐  │
│  │  Wails Host    │                  │  Elixir Release    │  │
│  │                │                  │                    │  │
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

1. User launches the `.app` bundle
2. Wails host starts, creates a TCP listener on `127.0.0.1:0`
3. Host spawns the Elixir release with `ELIXIRKIT_PORT=<port>`
4. Elixir boots Phoenix, then `ElixirKit.Server` connects to the host
5. Phoenix endpoint starts on port 4000
6. Elixir sends `ready:http://localhost:4000` via ElixirKit
7. Host receives `ready`, opens the URL in the system browser

### Steady State

- User interacts with Phoenix LiveView in the browser
- Phoenix serves HTTP/WebSocket on localhost:4000
- ElixirKit connection remains open (heartbeat/keepalive)
- Host → Elixir: can send `open` events (deep links, file opens)
- Elixir → Host: can send custom events (future extensibility)

### Shutdown

1. User quits the app (Cmd+Q, menu, or closing the host window)
2. Host calls `runtime.Stop()` which runs `./app stop`
3. Elixir release initiates graceful shutdown
4. Host closes the TCP connection
5. ElixirKit GenServer detects `tcp_closed`, calls `System.stop(0)`
6. Host waits up to 5 seconds for clean exit, then force-kills if needed

## Key Components

### Wails Host (`host/`)

| File                  | Purpose                                      |
|-----------------------|----------------------------------------------|
| `main.go`             | Wails entry point, window creation           |
| `app.go`              | App lifecycle: Startup, Shutdown, events     |
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
- If the host can't spawn the release, it shows an error dialog

### Orphan Prevention

- TCP connection acts as a "lifeline" — if host dies, Elixir exits
- Host tracks the Elixir PID and force-kills on timeout
- 5-second grace period allows Phoenix to drain connections

## Development vs Production

| Aspect         | Development (`make dev`)     | Production (`make run`)     |
|----------------|------------------------------|-----------------------------|
| Elixir         | `mix phx.server`             | Release binary              |
| ElixirKit      | Disabled (no port set)       | Enabled                     |
| Hot reload     | Yes                          | No                          |
| Browser        | Manual open                  | Auto-opened by host         |
| Shutdown       | Ctrl+C                       | Host manages lifecycle      |
