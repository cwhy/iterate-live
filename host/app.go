package main

import (
	"context"
	"fmt"
	"log"

	"host/bridge"
	"host/launcher"

	"github.com/pkg/browser"
)

type App struct {
	ctx      context.Context
	bridge   *bridge.ElixirKit
	runtime  *launcher.Runtime
	readyURL string
}

func NewApp() *App {
	return &App{}
}

func (a *App) Startup(ctx context.Context) {
	a.ctx = ctx

	// Run the actual startup in a goroutine to not block Wails
	go func() {
		if err := a.start(); err != nil {
			log.Printf("[Host] Failed to start: %v", err)
		}
	}()
}

func (a *App) start() error {
	// 1. Start ElixirKit TCP listener
	var err error
	a.bridge, err = bridge.New()
	if err != nil {
		return fmt.Errorf("failed to start bridge: %w", err)
	}
	log.Printf("[Host] ElixirKit listening on port %d", a.bridge.Port())

	// Set up event handler
	a.bridge.OnEvent = a.handleEvent

	// 2. Start Elixir release
	a.runtime, err = launcher.New()
	if err != nil {
		return fmt.Errorf("failed to find release: %w", err)
	}

	if err := a.runtime.Start(a.bridge.Port()); err != nil {
		return fmt.Errorf("failed to start release: %w", err)
	}
	log.Println("[Host] Elixir release started")

	// 3. Wait for connection from Elixir
	if err := a.bridge.Accept(); err != nil {
		return fmt.Errorf("failed to accept connection: %w", err)
	}
	log.Println("[Host] Elixir connected")

	return nil
}

func (a *App) handleEvent(event, data string) {
	log.Printf("[Host] Received event: %s = %s", event, data)

	switch event {
	case "ready":
		a.readyURL = data
		log.Printf("[Host] Opening browser to %s", data)
		browser.OpenURL(data)
	}
}

func (a *App) OpenBrowser() {
	if a.readyURL != "" {
		browser.OpenURL(a.readyURL)
	}
}

func (a *App) Shutdown(ctx context.Context) {
	log.Println("[Host] Shutting down...")
	if a.bridge != nil {
		a.bridge.Close()
	}
	if a.runtime != nil {
		a.runtime.Stop()
	}
	log.Println("[Host] Shutdown complete")
}
