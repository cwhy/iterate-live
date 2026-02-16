# Minimal Desktop Elixir App Plan

## Goal

Create a minimal, reusable template for desktop Elixir apps using:

- **Elixir + Phoenix LiveView** — serves the UI in the system browser
- **Wails (Go)** — native host launcher (tray, menus, process lifecycle)
- **ElixirKit** — lightweight TCP bridge protocol between Go and Elixir
- Reproducible build and packaging for macOS (expandable to Linux/Windows)

## Architecture

```
┌─────────────────┐       TCP (ElixirKit)       ┌──────────────────────┐
│  Wails (Go)     │◄──────────────────────────►  │  Elixir Release      │
│  Host Launcher  │   ELIXIRKIT_PORT env var      │  Phoenix + LiveView  │
│                 │                               │                      │
│  • Start release│   ready:<url>  ──────────►    │  • Web UI served at  │
│  • Open browser │   open:<path>  ◄──────────    │    http://localhost:N│
│  • Tray/menu    │                               │                      │
│  • Stop on quit │                               │                      │
└─────────────────┘                               └──────────────────────┘
         │
         ▼
   System Browser
```

The user's default browser is the primary UI surface — no embedded webview.

## Stage Index

1. [Stage 01 — Scope and Baseline](stages/01-scope-and-baseline.md)
2. [Stage 02 — Phoenix LiveView Minimal App](stages/02-phoenix-liveview-minimal.md)
3. [Stage 03 — ElixirKit Bridge (Elixir Side)](stages/03-elixirkit-bridge.md)
4. [Stage 04 — Wails Host Launcher](stages/04-wails-host-launcher.md)
5. [Stage 05 — Release and End-to-End Integration](stages/05-release-and-integration.md)
6. [Stage 06 — Packaging and CI](stages/06-packaging-and-ci.md)
7. [Stage 07 — Template Cleanup and Handoff](stages/07-template-cleanup-and-handoff.md)

## Stage Dependencies

```
01 ──► 02 ──► 03 ──► 05 ──► 06 ──► 07
                      │
              04 ─────┘
```

- Stages **02** and **04** can be developed in parallel after Stage 01
- Stage **03** depends on Stage 02 (needs the Phoenix app)
- Stage **05** merges Stages 03 + 04 into an integrated system
- Stages **06** and **07** are sequential after the system works end-to-end
