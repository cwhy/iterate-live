package bridge

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"strings"
	"sync"
)

type ElixirKit struct {
	listener net.Listener
	conn     net.Conn
	port     int
	mu       sync.Mutex
	OnEvent  func(event, data string)
}

func New() (*ElixirKit, error) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return nil, err
	}

	port := listener.Addr().(*net.TCPAddr).Port

	return &ElixirKit{
		listener: listener,
		port:     port,
	}, nil
}

func (e *ElixirKit) Port() int {
	return e.port
}

func (e *ElixirKit) Accept() error {
	conn, err := e.listener.Accept()
	if err != nil {
		return err
	}
	e.mu.Lock()
	e.conn = conn
	e.mu.Unlock()

	go e.readLoop()
	return nil
}

func (e *ElixirKit) readLoop() {
	for {
		// Read 4-byte length prefix (big-endian)
		lenBuf := make([]byte, 4)
		if _, err := io.ReadFull(e.conn, lenBuf); err != nil {
			return
		}
		length := binary.BigEndian.Uint32(lenBuf)

		// Read payload
		payload := make([]byte, length)
		if _, err := io.ReadFull(e.conn, payload); err != nil {
			return
		}

		// Parse event:data
		parts := strings.SplitN(string(payload), ":", 2)
		if len(parts) == 2 && e.OnEvent != nil {
			e.OnEvent(parts[0], parts[1])
		}
	}
}

func (e *ElixirKit) Publish(event, data string) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	if e.conn == nil {
		return fmt.Errorf("not connected")
	}

	payload := []byte(fmt.Sprintf("%s:%s", event, data))
	lenBuf := make([]byte, 4)
	binary.BigEndian.PutUint32(lenBuf, uint32(len(payload)))

	if _, err := e.conn.Write(lenBuf); err != nil {
		return err
	}
	if _, err := e.conn.Write(payload); err != nil {
		return err
	}
	return nil
}

func (e *ElixirKit) Close() {
	if e.conn != nil {
		e.conn.Close()
	}
	if e.listener != nil {
		e.listener.Close()
	}
}