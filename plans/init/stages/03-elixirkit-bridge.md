# Stage 03 — ElixirKit Bridge (Elixir Side)

## Purpose

Integrate the ElixirKit bridge into the Phoenix app so it can communicate with a host launcher over TCP. After this stage, the Elixir app will publish `ready:<url>` when Phoenix is booted (if `ELIXIRKIT_PORT` is set) and handle incoming events.

## Background

ElixirKit's Elixir side is ~40 lines of code from Livebook. It:

1. Reads `ELIXIRKIT_PORT` from the environment
2. Opens a TCP connection back to the host on that port
3. Sends/receives `name:data` messages using Erlang's `{packet, 4}` framing (4-byte length prefix)

The Elixir app should **gracefully degrade** — if `ELIXIRKIT_PORT` is not set, the bridge is skipped and the app runs as a normal `mix phx.server`. This keeps dev workflow simple.

## Tasks

- [ ] Port ElixirKit Elixir modules from Livebook into the Phoenix app:
  - `lib/elixirkit.ex` — public API: `start/0`, `publish/2`
  - `lib/elixirkit/application.ex` — supervisor
  - `lib/elixirkit/server.ex` — GenServer with TCP connection
- [ ] Wire ElixirKit into the Phoenix application startup:
  - In `application.ex`, conditionally start ElixirKit supervisor only when `ELIXIRKIT_PORT` is present
  - After Phoenix endpoint is up, call `ElixirKit.publish("ready", url)` where `url` is the resolved listen URL
- [ ] Define the event contract:
  | Event         | Direction       | Payload                  | Description                        |
  |---------------|-----------------|---------------------------|------------------------------------|
  | `ready`       | Elixir → Host   | `http://localhost:<port>` | Phoenix is up, open browser        |
  | `open`        | Host → Elixir   | path or URL string        | User triggered open (deep link, file, second instance) |
- [ ] Handle incoming `open` events:
  - Log them for now (actual routing comes later when the app has real features)
- [ ] Add graceful degradation: when `ELIXIRKIT_PORT` is absent, log "Running without host bridge" and skip
- [ ] Test the bridge with a simple TCP mock:
  - Script or test that opens a TCP server, sets `ELIXIRKIT_PORT`, starts the app, and asserts `ready` is received

## Artifacts

- `lib/elixirkit.ex`
- `lib/elixirkit/application.ex`
- `lib/elixirkit/server.ex`
- `docs/protocol.md` — event contract documentation
- `test/elixirkit/server_test.exs` — bridge test with mock TCP

## Exit Criteria

- [ ] `ELIXIRKIT_PORT=9999 mix phx.server` connects to a listener on port 9999 and sends `ready:<url>`
- [ ] Without `ELIXIRKIT_PORT`, `mix phx.server` works exactly as before (no crash, no bridge)
- [ ] Incoming `open` events are received and logged
- [ ] Protocol contract is documented
