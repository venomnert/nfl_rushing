defmodule NflRushing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias NflRushing.Boundary.DataManager


  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NflRushingWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NflRushing.PubSub},
      # Start the Endpoint (http/https)
      NflRushingWeb.Endpoint,
      # Start a worker by calling: NflRushing.Worker.start_link(arg)
      {DataManager, %{}}
    ]

    opts = [strategy: :one_for_one, name: NflRushing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    NflRushingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
