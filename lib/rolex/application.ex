defmodule Rolex.Application do
  use Application

  def start(_type, _args) do
    children = [
      RolexBot.Consumer,
    ]

    opts = [strategy: :one_for_one, name: Rolex.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
