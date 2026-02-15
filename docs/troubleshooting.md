# Troubleshooting

## Port Already in Use

**Symptom:** Phoenix fails to start with "address already in use"

**Cause:** Another process is using port 4000

**Solutions:**
```bash
# Find what's using the port
lsof -i :4000

# Kill the process
kill -9 <PID>

# Or use a different port (in config/runtime.exs)
```

## Browser Doesn't Open

**Symptom:** App starts but no browser window appears

**Causes:**
1. Elixir release didn't send `ready` event
2. Host received `ready` but browser open failed

**Debug:**
```bash
# Run the host binary directly and watch logs
cd host && go build -o build/bin/iterate-live . && ./build/bin/iterate-live

# Look for:
# - "[Host] ElixirKit listening on port XXXX"
# - "[Host] Elixir connected"
# - "[Host] Opening browser to http://localhost:4000"
```

**Solutions:**
- Check that Phoenix started successfully (look for Bandit/Cowboy logs)
- Verify `ElixirKit.publish("ready", url)` is called in `application.ex`
- Try opening `http://localhost:4000` manually

## Release Won't Start

**Symptom:** Host starts but Elixir release fails

**Causes:**
1. Release not built (`make build-release` not run)
2. Wrong OTP version (release was built with different ERTS)
3. Release path not found

**Debug:**
```bash
# Try running the release directly
./app/_build/prod/rel/app/bin/app start

# Check the release exists
ls -la app/_build/prod/rel/app/bin/
```

**Solutions:**
- Run `make clean && make build` to rebuild everything
- Ensure OTP version matches between build and runtime
- Check `launcher/runtime.go` for the expected path

## Orphan BEAM Process

**Symptom:** After quitting, `beam.smp` processes remain running

**Cause:** Shutdown didn't complete cleanly

**Solutions:**
```bash
# Find and kill orphan processes
pgrep -f "beam.smp" | xargs kill

# Or more aggressive
pkill -9 -f "beam.smp"
```

**Prevention:**
- Always quit via the tray menu, not force-kill
- The host has a 5-second timeout before force-killing

## ElixirKit Connection Failed

**Symptom:** Logs show "Failed to connect" from ElixirKit

**Causes:**
1. `ELIXIRKIT_PORT` not set (normal in dev mode)
2. Host TCP server not ready when Elixir tries to connect
3. Port blocked by firewall

**Debug:**
```bash
# Check if port is set
echo $ELIXIRKIT_PORT

# In dev mode, this is expected to be empty
# ElixirKit gracefully degrades when not set
```

## Build Failures

### Elixir/Phoenix

```bash
# Clear build artifacts and retry
cd app
rm -rf _build deps
mix deps.get
MIX_ENV=prod mix release app
```

### Go Host

```bash
# Clear and retry
cd host
rm -rf build/bin
CGO_ENABLED=1 go build -o build/bin/iterate-live .
```

### Asset Compilation

```bash
# Clear Node artifacts
cd app/assets
rm -rf node_modules
npm install
cd ..
mix assets.deploy
```

## macOS Code Signing

**Symptom:** "App is damaged and can't be opened" or Gatekeeper blocks

**Cause:** App is not code-signed

**Workaround (development only):**
```bash
# Remove quarantine attribute
xattr -cr /path/to/IterateLive.app

# Or allow in System Preferences > Security & Privacy
```

**Production:** Sign with an Apple Developer certificate (not covered in MVP)

## Logs Location

| Component | Log Location                          |
|-----------|---------------------------------------|
| Phoenix   | stdout/stderr (visible in host logs)  |
| Go Host   | stdout when run from terminal         |
| Release   | `app/_build/prod/rel/app/tmp/log/`    |
