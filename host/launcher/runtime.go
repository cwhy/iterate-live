package launcher

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"syscall"
	"time"
)

type Runtime struct {
	cmd     *exec.Cmd
	exePath string
}

func New() (*Runtime, error) {
	exePath, err := findRelease()
	if err != nil {
		return nil, err
	}
	return &Runtime{exePath: exePath}, nil
}

func findRelease() (string, error) {
	// Get the directory of the current executable
	exe, err := os.Executable()
	if err != nil {
		return "", err
	}
	exeDir := filepath.Dir(exe)

	// Look for the release relative to the executable
	var relPath string
	if runtime.GOOS == "darwin" {
		// Inside .app bundle: Contents/MacOS/host -> Contents/Resources/rel/app/bin/app
		relPath = filepath.Join(exeDir, "..", "Resources", "rel", "app", "bin", "app")
	} else {
		// Linux/Windows: alongside the executable
		relPath = filepath.Join(exeDir, "rel", "app", "bin", "app")
	}

	// For development, also check relative to working directory
	if _, err := os.Stat(relPath); os.IsNotExist(err) {
		cwd, _ := os.Getwd()
		devPath := filepath.Join(cwd, "..", "app", "_build", "prod", "rel", "app", "bin", "app")
		if _, err := os.Stat(devPath); err == nil {
			return devPath, nil
		}
		return "", fmt.Errorf("release not found at %s or %s", relPath, devPath)
	}

	return relPath, nil
}

func (r *Runtime) Start(elixirKitPort int) error {
	r.cmd = exec.Command(r.exePath, "start")
	r.cmd.Env = append(os.Environ(),
		fmt.Sprintf("ELIXIRKIT_PORT=%d", elixirKitPort),
		"RELEASE_DISTRIBUTION=none",
	)
	r.cmd.Stdout = os.Stdout
	r.cmd.Stderr = os.Stderr

	return r.cmd.Start()
}

func (r *Runtime) Stop() error {
	if r.cmd == nil || r.cmd.Process == nil {
		return nil
	}

	// Try graceful shutdown first
	stopCmd := exec.Command(r.exePath, "stop")
	stopCmd.Run()

	// Wait with timeout
	done := make(chan error, 1)
	go func() {
		done <- r.cmd.Wait()
	}()

	select {
	case <-done:
		return nil
	case <-time.After(5 * time.Second):
		// Force kill
		r.cmd.Process.Signal(syscall.SIGKILL)
		return fmt.Errorf("had to force kill")
	}
}
