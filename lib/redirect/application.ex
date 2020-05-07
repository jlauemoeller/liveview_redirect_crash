defmodule Redirect.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RedirectWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Redirect.PubSub},
      # Start the Endpoint (http/https)
      RedirectWeb.Endpoint
      # Start a worker by calling: Redirect.Worker.start_link(arg)
      # {Redirect.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Redirect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RedirectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
