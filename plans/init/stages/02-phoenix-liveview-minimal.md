# Stage 02 — Phoenix LiveView Minimal App

## Purpose

Build the smallest Phoenix LiveView app that compiles, runs, and serves a page. This stage is **pure Elixir/Phoenix** — no bridge code, no host launcher.

## Tasks

- [ ] Generate a new Phoenix project with LiveView enabled:
  ```bash
  mix phx.new app --live --no-mailer --no-dashboard --no-gettext
  ```
- [ ] Replace the default landing page with a minimal "Hello World" LiveView
- [ ] Configure runtime for desktop use:
  - Fixed port in dev (e.g., `4000`)
  - Port configurable via `PORT` env var in prod/release
  - Bind to `127.0.0.1` only (localhost, not public)
- [ ] Verify `mix phx.server` shows the hello page at `http://localhost:4000`
- [ ] Add one smoke test that mounts the LiveView and asserts content

## Artifacts

- `app/` — Phoenix project root (or top-level if monorepo)
  - `lib/app_web/live/home_live.ex` — minimal LiveView
  - `lib/app_web/router.ex` — route wiring
  - `config/runtime.exs` — desktop-friendly runtime config
  - `test/app_web/live/home_live_test.exs` — smoke test

## Exit Criteria

- [ ] `mix phx.server` starts and the hello page renders in a browser
- [ ] `mix test` passes with the smoke test green
- [ ] No ElixirKit or host launcher code exists yet — this is a standalone Phoenix app
