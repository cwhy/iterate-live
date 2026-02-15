# Stage 01 — Scope and Baseline

## Purpose

Lock down the exact MVP behavior, architecture, and tool versions before writing any code.

## Architecture Overview

The app follows the **Livebook Desktop** pattern:

```
┌─────────────────┐       TCP (ElixirKit)       ┌──────────────────────┐
│  Wails (Go)     │◄──────────────────────────► │  Elixir Release      │
│  Host Launcher  │   ELIXIRKIT_PORT env var    │  Phoenix + LiveView  │
│                 │                             │                      │
│  • Start release│   ready:<url>  ──────────►  │  • Web UI served at  │
│  • Open browser │   open:<path>  ◄──────────  │    http://localhost:N│
│  • Tray/menu    │                             │                      │
│  • Stop on quit │                             │                      │
└─────────────────┘                             └──────────────────────┘
         │
         ▼
   System Browser
   (user's default)
```

- **Wails (Go)** is the native host launcher. It manages the Elixir process lifecycle and provides tray/menu/deep-link integration. No embedded webview is used as the primary UI surface.
- **ElixirKit** is the TCP bridge protocol between Go and Elixir. The host opens a local TCP port, the Elixir side connects back using `ELIXIRKIT_PORT`.
- **Phoenix LiveView** serves the actual UI in the user's system browser.

## MVP Behavior

1. User launches the Wails app (double-click `.app` / `.exe`)
2. Wails allocates a local TCP port, sets `ELIXIRKIT_PORT`, and starts the Elixir release
3. Elixir boots Phoenix, connects back to Wails via ElixirKit, and publishes `ready:<url>`
4. Wails receives `ready`, opens the system browser to the URL
5. When the user quits (menu/tray), Wails sends a shutdown signal and waits for clean Elixir exit

### Non-Goals for MVP

- No embedded webview as the primary UI
- No multi-user / remote access (single user, localhost only)
- No auto-update mechanism
- No code signing (deferred)
- No mobile targets

## Tasks

- [ ] Write `docs/scope.md` with the behavior above and explicit non-goals
- [ ] Pin versions in a `versions.env` file:
  - OTP / Elixir (e.g., OTP 27, Elixir 1.18)
  - Phoenix / LiveView
  - Go / Wails v2 (or v3 if stable)
  - Node.js (for Phoenix asset build)
- [ ] Choose initial target OS for first green run (recommended: **macOS**)
- [ ] Create `Makefile` or `justfile` skeleton with placeholder targets:
  - `dev`, `build-release`, `package`

## Artifacts

- `docs/scope.md`
- `versions.env`
- `Makefile` (skeleton)

## Exit Criteria

- [ ] MVP behavior is written down and agreed upon
- [ ] All toolchain versions are pinned
- [ ] One reference OS is selected for first end-to-end run
