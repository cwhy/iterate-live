# Stage 07 — Template Cleanup and Handoff

## Purpose

Turn the working implementation into a clean, reusable starter template for future Elixir desktop apps.

## Tasks

### Code Cleanup

- [ ] Remove any spike-only code, dead branches, or TODO hacks
- [ ] Ensure consistent naming: app name, module names, config keys should all be easy to find-and-replace for a new project
- [ ] Review and clean up dependencies — remove anything unused

### Template Structure

- [ ] Organize the repository for easy cloning:
  ```
  iterate-live/
  ├── app/                    # Elixir/Phoenix project
  │   ├── lib/
  │   │   ├── app_web/        # Phoenix LiveView UI
  │   │   └── elixirkit/      # Bridge modules
  │   ├── config/
  │   ├── rel/
  │   └── mix.exs
  ├── host/                   # Wails/Go project
  │   ├── bridge/
  │   ├── launcher/
  │   ├── main.go
  │   └── wails.json
  ├── scripts/                # Build & packaging scripts
  ├── docs/                   # Architecture, build, protocol docs
  ├── Makefile
  └── README.md
  ```
- [ ] Add a "New Project Checklist" section for bootstrapping from this template:
  - Rename app (Elixir module + Wails app name)
  - Set bundle ID and icon
  - Configure port range
  - First build and run

### Documentation

- [ ] Write/update `README.md` — optimized for "clone and run":
  - What this is (one paragraph)
  - Quick start (3-command setup)
  - How it works (architecture diagram from Stage 01)
  - Development workflow
  - Building and packaging
- [ ] Write `docs/architecture.md`:
  - Process diagram (Wails ↔ ElixirKit ↔ Phoenix)
  - Event protocol reference
  - Lifecycle: startup, steady state, shutdown
  - Error handling and failure modes
- [ ] Write `docs/troubleshooting.md`:
  - "Port already in use"
  - "Release won't start" (missing ERTS, wrong OTP version)
  - "Browser doesn't open" (ready event timing)
  - "Orphan BEAM process" (shutdown didn't complete)

## Artifacts

- Clean, template-ready codebase
- `README.md`
- `docs/architecture.md`
- `docs/troubleshooting.md`

## Exit Criteria

- [ ] A new project can be bootstrapped from this template by cloning + renaming
- [ ] `make dev` works on a fresh clone after installing prerequisites
- [ ] Documentation is sufficient for someone new to the repo to understand, build, and run
- [ ] No leftover spike code or broken references
