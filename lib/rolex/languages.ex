defmodule Rolex.Languages do
  # use Agent

  # def start_link(_initial_value) do
  #   Agent.start_link(fn -> load_languages() end, name: __MODULE__)
  # end

  def get_language(_name) do
    %{}
    # Agent.get(__MODULE__, fn state -> Map.get(state, name) end)
  end

  # def load_languages() do
  #   File.read!("priv/colors.json")
  #   |> Jason.decode!()
  # end
end
