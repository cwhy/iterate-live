# Stage 04 — Wails Host Launcher

## Purpose

Build the Go/Wails desktop app that acts as the host launcher. It manages the Elixir release lifecycle and communicates over the ElixirKit TCP bridge. The system browser is the primary UI — Wails provides the native shell (tray, menus, process management) but **not** an embedded webview as the main surface.

## Architecture

```
Wails App (Go)
├── main.go              — Wails app entry point
├── bridge/
│   └── elixirkit.go     — TCP server implementing ElixirKit protocol
├── launcher/
│   └── runtime.go       — Start/stop Elixir release process
└── app.go               — App lifecycle: wire bridge + launcher + tray
```

## Tasks

### ElixirKit TCP Server (Go side)

- [ ] Implement `bridge/elixirkit.go`:
  - Listen on a random local TCP port (`127.0.0.1:0`)
  - Accept one connection (from the Elixir release)
  - Read/write messages using **4-byte big-endian length prefix** + `name:data` payload (matching Erlang `{packet, 4}`)
  - Expose Go channels or callbacks: `OnEvent(name, data)` and `Publish(name, data)`
  - Handle connection close as shutdown signal

### Elixir Release Launcher

- [ ] Implement `launcher/runtime.go`:
  - Locate the Elixir release binary relative to the Wails app bundle
  - Set environment: `ELIXIRKIT_PORT=<allocated-port>`, plus any required release env vars
  - Start the release as a child process (`os/exec`)
  - Capture stdout/stderr for logging
  - Provide `Stop()` that sends shutdown and waits with timeout, then force-kills

### Wails App Lifecycle

- [ ] In `app.go`, wire the full lifecycle:
  1. Start ElixirKit TCP listener → get port
  2. Start Elixir release with `ELIXIRKIT_PORT`
  3. Wait for `ready:<url>` event
  4. Open system browser to URL (`pkg/browser` or `open` command)
  5. (Optional) Show tray icon with "Open in Browser" and "Quit" menu items
  6. On quit: signal Elixir to stop, wait for clean exit, then exit Wails

### Wails Configuration

- [ ] Initialize Wails project: `wails init -n app-host -t vanilla`
- [ ] Configure Wails **without** a primary webview window (or with a hidden/minimal window):
  - The goal is tray-only or headless — the browser is the UI
  - If Wails v2 requires a window, use a minimal hidden window
- [ ] Add `open` event forwarding: when the OS sends an open-file or open-URL event to the Wails app, publish `open:<path>` to Elixir

### Dev Workflow

- [ ] Add a `make dev` target that:
  - Builds the Elixir release (from Stage 03)
  - Runs the Wails app in dev mode
  - The Wails app starts the release and connects
- [ ] Ensure `wails dev` workflow is documented

## Artifacts

- `host/` — Wails project root
  - `main.go`
  - `app.go`
  - `bridge/elixirkit.go`
  - `launcher/runtime.go`
- Updated `Makefile` with `dev` target

## Exit Criteria

- [ ] Running the Wails app starts the Elixir release
- [ ] `ready` event is received and system browser opens to the Phoenix hello page
- [ ] Quitting the Wails app cleanly stops the Elixir release (no orphan processes)
- [ ] Tray icon (if implemented) shows "Open in Browser" and "Quit"
- [ ] The entire flow works with one command: `make dev`
