# Remove Wails, Add System Tray

## Summary

Replaced the Wails v2 desktop shell with a lightweight pure-Go binary that lives in the macOS menu bar using `fyne.io/systray`. The Elixir/Phoenix app was completely untouched.

## What Changed

### Removed
- `host/frontend/` — Wails webview assets (HTML, JS, CSS, wailsjs bindings)
- `host/wails.json` — Wails configuration
- `host/build/darwin/Info.dev.plist` — Wails dev plist template
- Wails Go dependency and all transitive deps
- Node.js requirement (was only needed for Wails frontend build)

### Added
- `fyne.io/systray` dependency — lightweight menu bar icon library
- `host/icon.go` — embedded tray icon using `//go:embed`
- `LSUIElement = true` in Info.plist — hides Dock icon (menu-bar-only app)
- `build-app-bundle` Makefile target — manually assembles `.app` bundle

### Modified
- `host/main.go` — replaced `wails.Run()` with `systray.Run()`
- `host/app.go` — removed `context.Context` dependency from Wails lifecycle
- `host/go.mod` — swapped Wails for systray
- `host/build/darwin/Info.plist` — static values instead of Wails Go templates
- `Makefile` — `go build` instead of `wails build`
- `scripts/package-macos.sh` — manual `.app` bundle assembly
- `.github/workflows/build.yml` — removed Wails/Node.js setup steps

### Untouched
- `host/bridge/elixirkit.go` — TCP bridge (no Wails dependency)
- `host/launcher/runtime.go` — Elixir process manager (no Wails dependency)
- `app/` — entire Elixir/Phoenix project (zero changes)

## Tray Menu

- **Open in Browser** — opens `http://localhost:4000` in system browser
- **Quit** — graceful shutdown of Elixir + host

## Why

The Wails window was never used as UI (the real UI is Phoenix in the browser). A system tray icon is a better UX for this architecture — the app lives in the menu bar, manages the Elixir process silently, and provides quick access to open the browser.
