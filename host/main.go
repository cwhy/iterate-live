package main

import (
	"log"

	"fyne.io/systray"
)

func main() {
	app := NewApp()
	systray.Run(app.OnReady, app.OnExit)
}

// onReady sets up the system tray icon and menu items.
func (a *App) OnReady() {
	systray.SetIcon(iconData)
	systray.SetTooltip("Iterate Live")

	mOpen := systray.AddMenuItem("Open in Browser", "Open the app in your browser")
	systray.AddSeparator()
	mQuit := systray.AddMenuItem("Quit", "Quit Iterate Live")

	// Start the Elixir app in the background
	go func() {
		if err := a.start(); err != nil {
			log.Printf("[Host] Failed to start: %v", err)
		}
	}()

	// Handle menu clicks
	go func() {
		for {
			select {
			case <-mOpen.ClickedCh:
				a.OpenBrowser()
			case <-mQuit.ClickedCh:
				systray.Quit()
			}
		}
	}()
}

// onExit performs graceful shutdown when the tray app quits.
func (a *App) OnExit() {
	a.Shutdown()
}
