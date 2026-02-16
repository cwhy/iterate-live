package main

import _ "embed"

// iconData contains the tray icon bytes (PNG format).
// The icon should be a template image suitable for the macOS menu bar (~22x22px).
//
//go:embed assets/tray-icon.png
var iconData []byte
