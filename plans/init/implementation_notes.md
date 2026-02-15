# Implementation Notes

## Completed (2026-02-15)

### Stage 01 - Scope and Baseline
- Created `docs/scope.md` with MVP behavior
- Created `versions.env` with toolchain versions
- Created `Makefile` skeleton

### Stage 02 - Phoenix LiveView Minimal App
- Generated Phoenix project in `app/`
- Created `HomeLive` at `app/lib/app_web/live/home_live.ex`
- Removed database dependency (commented out `App.Repo` in application.ex)
- Fixed test config to not require database
- Smoke test passes

### Stage 03 - ElixirKit Bridge (Elixir Side)
- Created `app/lib/elixirkit.ex` - public API
- Created `app/lib/elixirkit/server.ex` - GenServer with TCP connection
- Graceful degradation when `ELIXIRKIT_PORT` not set
- Created `docs/protocol.md` with event contract
- Test at `app/test/elixirkit/server_test.exs`

### Stage 04 - Wails Host Launcher
- Initialized Wails project in `host/`
- Created `host/bridge/elixirkit.go` - TCP server (Go side)
- Created `host/launcher/runtime.go` - Elixir release process manager
- Created `host/app.go` - App lifecycle (Startup, Shutdown, event handling)
- Updated `host/main.go` - Wails entry point
- Simplified frontend to show "App Host" message

### Stage 05 - Release and Integration
- Added release config to `app/mix.exs`
- Simplified `app/config/runtime.exs` for desktop (no DATABASE_URL)
- Removed colocated hooks import from `app/assets/js/app.js`
- Full lifecycle works: Wails → Elixir → Browser → Clean shutdown

### Stage 06 - Packaging and CI
- Created `scripts/package-macos.sh` to build `.dmg`
- Copies Elixir release into `.app` bundle's `Contents/Resources/rel/app/`
- Created `.github/workflows/build.yml` for CI
- Created `docs/build.md` with prerequisites and commands

### Stage 07 - Template Cleanup and Handoff
- Reviewed code for TODOs (only intentional template placeholder remains)
- Created comprehensive `README.md`
- Created `docs/architecture.md`
- Created `docs/troubleshooting.md`

## Key Files

```
iterate-live/
├── app/                          # Elixir/Phoenix project
│   ├── lib/
│   │   ├── app_web/live/home_live.ex
│   │   ├── elixirkit.ex
│   │   └── elixirkit/server.ex
│   ├── config/runtime.exs        # Desktop-friendly config
│   └── mix.exs                   # Has release config
├── host/                         # Wails/Go project
│   ├── bridge/elixirkit.go
│   ├── launcher/runtime.go
│   ├── app.go
│   └── main.go
├── scripts/
│   └── package-macos.sh          # DMG packaging
├── docs/
│   ├── scope.md
│   ├── protocol.md
│   ├── build.md
│   ├── architecture.md
│   └── troubleshooting.md
├── .github/workflows/build.yml   # CI pipeline
├── Makefile
├── README.md
└── versions.env
```

## Commands

```bash
# Development (Phoenix only, no host)
make dev

# Build everything
make build

# Run desktop app
make run

# Package for distribution
make package

# Run tests
make test
```

## Known Issues / Notes

1. **Release path in dev**: The launcher looks for the release at `../app/_build/prod/rel/app/bin/app` relative to the host working directory. This works when running from the `host/` directory.

2. **Wails window**: Currently shows a minimal "App Host" window. Could be made into a tray app in the future.

3. **Port allocation**: Phoenix uses port 4000 by default. Could be made dynamic by having the Elixir side pick a random port.

4. **Secret key**: Using a fixed secret key for desktop app since it's localhost only. This is fine for single-user desktop apps.

5. **Database removed**: The Ecto/Repo was removed for MVP. If database is needed later, re-add it with SQLite for a desktop app.
