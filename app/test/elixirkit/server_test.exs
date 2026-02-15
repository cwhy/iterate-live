defmodule ElixirKit.ServerTest do
  use ExUnit.Case, async: false

  test "connects and sends ready event" do
    # Trap exits so we don't crash when the server shuts down
    Process.flag(:trap_exit, true)

    # Start a TCP server
    {:ok, listen_socket} = :gen_tcp.listen(0, [:binary, packet: 4, active: false, reuseaddr: true])
    {:ok, port} = :inet.port(listen_socket)

    # Accept the connection in a task
    task = Task.async(fn ->
      {:ok, socket} = :gen_tcp.accept(listen_socket, 5000)
      {:ok, data} = :gen_tcp.recv(socket, 0, 5000)
      # Keep socket open to avoid triggering tcp_closed
      {socket, data}
    end)

    # Start the server (link it so we can trap exits)
    {:ok, _pid} = ElixirKit.Server.start_link(port)

    # Publish ready
    ElixirKit.publish("ready", "http://localhost:4000")

    # Give it a moment to send
    Process.sleep(50)

    # Check what we received
    {socket, data} = Task.await(task)
    assert data == "ready:http://localhost:4000"

    # Cleanup - close listen socket first, then client socket
    :gen_tcp.close(listen_socket)
    :gen_tcp.close(socket)

    # Drain any exit messages
    receive do
      {:EXIT, _, _} -> :ok
    after
      200 -> :ok
    end
  end
end
