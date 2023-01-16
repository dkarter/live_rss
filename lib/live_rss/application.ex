defmodule LiveRSS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveRSSWeb.Telemetry,
      # Start the Ecto repository
      LiveRSS.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveRSS.PubSub},
      # Start the Endpoint (http/https)
      LiveRSSWeb.Endpoint,

      # keeps track of all running feed monitor processes
      {Registry, keys: :unique, name: LiveRSS.FeedMonitorRegistry},

      # DynamicSupervisor in charge of managing feed monitors
      LiveRSS.FeedMonitorSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveRSS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveRSSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
