defmodule ElixirKit do
  @moduledoc """
  Bridge to communicate with the host launcher via TCP.
  """

  def start do
    case System.get_env("ELIXIRKIT_PORT") do
      nil ->
        IO.puts("[ElixirKit] No ELIXIRKIT_PORT set, running standalone")
        :ignore

      port_str ->
        port = String.to_integer(port_str)
        ElixirKit.Server.start_link(port)
    end
  end

  def publish(event, data) do
    ElixirKit.Server.publish(event, data)
  end
end
