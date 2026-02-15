defmodule ElixirKit.Server do
  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def publish(event, data) do
    GenServer.cast(__MODULE__, {:publish, event, data})
  end

  @impl true
  def init(port) do
    case :gen_tcp.connect(~c"127.0.0.1", port, [:binary, packet: 4, active: true]) do
      {:ok, socket} ->
        Logger.info("[ElixirKit] Connected to host on port #{port}")
        {:ok, %{socket: socket}}

      {:error, reason} ->
        Logger.error("[ElixirKit] Failed to connect: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:publish, event, data}, state) do
    message = "#{event}:#{data}"
    :gen_tcp.send(state.socket, message)
    Logger.info("[ElixirKit] Sent #{event}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, _socket, data}, state) do
    case String.split(data, ":", parts: 2) do
      [event, payload] ->
        Logger.info("[ElixirKit] Received #{event}: #{payload}")
        handle_event(event, payload)

      _ ->
        Logger.warning("[ElixirKit] Invalid message: #{inspect(data)}")
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("[ElixirKit] Connection closed, shutting down")
    # Use spawn to avoid blocking the GenServer termination
    spawn(fn ->
      # Give processes time to clean up
      Process.sleep(100)
      System.stop(0)
    end)
    {:stop, :shutdown, state}
  end

  defp handle_event("open", path) do
    Logger.info("[ElixirKit] Open requested: #{path}")
    # TODO: handle open events when app has real features
  end

  defp handle_event(event, _payload) do
    Logger.warning("[ElixirKit] Unknown event: #{event}")
  end
end
