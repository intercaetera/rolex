defmodule Rolex.Application do
  use Application

  def start(_type, _args) do
    children = [
      {RolexBot.Consumer, name: RolexBot.Consumer, restart: :permanent},
      Rolex.LanguagesAgent
    ]

    opts = [strategy: :one_for_one, name: Rolex.Supervisor, max_restarts: 10, max_seconds: 60]

    Supervisor.start_link(children, opts)
  end
end
