defmodule App.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AppWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: App.PubSub},
      AppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Start ElixirKit bridge if ELIXIRKIT_PORT is set
    ElixirKit.start()

    # Publish ready event with the app URL
    if System.get_env("ELIXIRKIT_PORT") do
      url = AppWeb.Endpoint.url()
      ElixirKit.publish("ready", url)
    end

    result
  end

  @impl true
  def config_change(changed, _new, removed) do
    AppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
