defmodule FlashNotes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    FlashNotes.NoteStorage.init()

    children = [
      # Start the Telemetry supervisor
      FlashNotesWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FlashNotes.PubSub},
      # Start the Endpoint (http/https)
      FlashNotesWeb.Endpoint
      # Start a worker by calling: FlashNotes.Worker.start_link(arg)
      # {FlashNotes.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlashNotes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlashNotesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
