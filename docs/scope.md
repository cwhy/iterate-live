# Scope

## MVP Behavior

1. User launches the app (double-click `.app` or run binary)
2. App appears as a menu bar icon (system tray) — no Dock icon
3. Host allocates a local TCP port, sets `ELIXIRKIT_PORT`, starts the Elixir release
4. Elixir boots Phoenix, connects back to host via ElixirKit, publishes `ready:<url>`
5. Host receives `ready`, opens the system browser to the URL
6. User quits via tray menu → Host sends shutdown signal, waits for clean Elixir exit

## Non-Goals (MVP)

- No embedded webview as primary UI
- No multi-user / remote access (localhost only)
- No auto-update mechanism
- No code signing
- No mobile targets

## Target OS

- Primary: macOS (arm64)
- Stretch: Linux, Windows