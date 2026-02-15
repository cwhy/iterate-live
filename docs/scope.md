# Scope

## MVP Behavior

1. User launches the app (double-click `.app` / `.exe`)
2. Wails allocates a local TCP port, sets `ELIXIRKIT_PORT`, starts the Elixir release
3. Elixir boots Phoenix, connects back to Wails via ElixirKit, publishes `ready:<url>`
4. Wails receives `ready`, opens the system browser to the URL
5. User quits (menu/tray) → Wails sends shutdown signal, waits for clean Elixir exit

## Non-Goals (MVP)

- No embedded webview as primary UI
- No multi-user / remote access (localhost only)
- No auto-update mechanism
- No code signing
- No mobile targets

## Target OS

- Primary: macOS (arm64)
- Stretch: Linux, Windows