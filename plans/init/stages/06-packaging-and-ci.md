# Stage 06 — Packaging and CI

## Purpose

Package the integrated app into installable OS artifacts and set up CI for reproducible builds.

## Tasks

### Local Packaging

- [ ] Create `scripts/package-<os>.sh` for the reference OS:
  - **macOS**: Build `.app` bundle containing Wails binary + Elixir release, then create `.dmg`
    - Use Wails' built-in `wails build` which produces a `.app` bundle
    - Ensure the Elixir release is copied into the bundle's `Contents/Resources/rel/`
    - Set `Info.plist` with app name, bundle ID, icon
  - **Linux** (stretch): AppImage or tarball
  - **Windows** (stretch): NSIS installer or `.zip`
- [ ] Add `make package` target
- [ ] Include artifact naming convention: `app-<version>-<os>-<arch>.<ext>`
- [ ] Generate checksum file alongside the artifact

### CI Workflow

- [ ] Create `.github/workflows/build.yml`:
  - Trigger: push to main, pull requests
  - Matrix: start with one OS (macOS), expand later
  - Steps:
    1. Install OTP + Elixir (use `erlef/setup-beam` action)
    2. Install Go + Wails
    3. `make build-release`
    4. `make package`
    5. Upload artifact
  - Cache: `_build`, `deps`, Go modules
- [ ] Verify CI produces a downloadable artifact

### Build Documentation

- [ ] Write `docs/build.md`:
  - Prerequisites (OTP, Elixir, Go, Wails, Node)
  - First-time setup steps
  - Build commands reference
  - Packaging commands reference
  - CI architecture overview

## Artifacts

- `scripts/package-macos.sh` (and others as needed)
- `.github/workflows/build.yml`
- `docs/build.md`
- Updated `Makefile` with `package` target

## Exit Criteria

- [ ] `make package` produces an installable artifact on the reference OS
- [ ] The packaged app launches, opens the browser, and works like the dev flow
- [ ] CI produces a downloadable artifact for at least one platform
- [ ] Build docs are sufficient for a new contributor to set up and build
