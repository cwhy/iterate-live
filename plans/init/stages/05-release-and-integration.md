# Stage 05 — Release and End-to-End Integration

## Purpose

Produce a self-contained Elixir release and validate the full lifecycle from Wails launch to browser to clean shutdown. This stage bridges the Elixir app (Stages 02–03) and the Wails host (Stage 04) into a working integrated system.

## Tasks

### Elixir Release Configuration

- [ ] Add release config in `mix.exs`:
  ```elixir
  releases: [
    app: [
      steps: [:assemble],
      include_executables_for: [:unix],  # or [:windows] on Windows
      cookie: "desktop-app-cookie"
    ]
  ]
  ```
- [ ] Create `rel/` directory with:
  - `rel/env.sh.eex` — environment bootstrap for Unix (set `RELEASE_DISTRIBUTION=none` for desktop)
  - `rel/env.bat.eex` — Windows equivalent (if targeting)
- [ ] Validate release build: `mix release app`
- [ ] Validate release starts and stops cleanly from command line:
  ```bash
  _build/prod/rel/app/bin/app start   # should boot Phoenix
  _build/prod/rel/app/bin/app stop    # should exit cleanly
  ```

### Directory Layout Convention

- [ ] Define where the release lives relative to the Wails binary:
  ```
  AppBundle/
  ├── wails-host          # Wails binary
  └── rel/
      └── app/            # Elixir release
          └── bin/app     # release entrypoint
  ```
- [ ] Update `launcher/runtime.go` to resolve this path relative to the executable

### End-to-End Smoke Test

- [ ] Create `scripts/e2e-smoke.sh` that:
  1. Builds the Elixir release
  2. Builds the Wails host
  3. Starts the Wails app
  4. Waits for `ready` (curl-polls the URL or watches stdout)
  5. Asserts the hello page is reachable over HTTP
  6. Sends quit signal
  7. Asserts both processes exited cleanly (no orphans)
- [ ] Document any manual verification steps that can't be automated

### Build Script

- [ ] Add `scripts/build-release.sh`:
  ```bash
  cd app && MIX_ENV=prod mix deps.get && mix assets.deploy && mix release app --overwrite
  ```
- [ ] Add `make build-release` target calling this script

## Artifacts

- `mix.exs` release definition
- `rel/env.sh.eex`, `rel/env.bat.eex`
- `scripts/build-release.sh`
- `scripts/e2e-smoke.sh`
- Updated `Makefile`

## Exit Criteria

- [ ] `make build-release` produces a working release from a clean state
- [ ] Release starts and stops cleanly from the command line (without Wails)
- [ ] Full Wails → ElixirKit → Phoenix → Browser flow works end-to-end
- [ ] No orphan Elixir or BEAM processes after quit
- [ ] Smoke test script passes on the reference OS
