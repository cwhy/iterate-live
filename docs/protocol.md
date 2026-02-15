# ElixirKit Protocol

## Overview

ElixirKit is a TCP-based protocol for communication between the Wails host launcher and the Elixir release. It uses Erlang's `{packet, 4}` framing (4-byte big-endian length prefix).

## Connection

1. Host (Wails/Go) listens on a random local TCP port (`127.0.0.1:0`)
2. Host sets `ELIXIRKIT_PORT` environment variable and starts the Elixir release
3. Elixir connects back to the host on that port

## Message Format

```
[4 bytes: length][payload]
```

Payload format: `event:data`

## Events

| Event   | Direction     | Payload                   | Description                                      |
|---------|---------------|---------------------------|--------------------------------------------------|
| `ready` | Elixir → Host | `http://localhost:<port>` | Phoenix is up, host should open browser          |
| `open`  | Host → Elixir | path or URL string        | User triggered open (deep link, file, 2nd instance) |

## Graceful Degradation

If `ELIXIRKIT_PORT` is not set, the Elixir app runs as a normal Phoenix server without the bridge. This allows standard `mix phx.server` development workflow.

## Shutdown

When the host closes the TCP connection, the Elixir app interprets this as a shutdown signal and exits cleanly.
