defmodule Rolex.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api


  @string 3 # Interaction argument type
  @ephemeral 64 # Flag bitset
  @channel_message 4 # Interaction response type

  @commands [
    {"ping", "Pong!",
     [
       %{
         type: @string,
         name: "reply",
         description: "reply with",
         required: false
       }
     ]}
  ]

  defp create_guild_commands(guild_id) do
    Enum.each(@commands, fn {name, description, options} ->
      Api.create_guild_application_command(guild_id, %{
        name: name,
        description: description,
        options: options
      })
    end)
  end

  def handle_event({:READY, %{guilds: guilds}, _ws}) do
    guilds
    |> Enum.map(fn guild -> guild.id end)
    |> Enum.each(&create_guild_commands/1)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws}) do
    message =
      case do_command(interaction) do
        {:msg, nil} -> ":white_check_mark:"
        {:msg, msg} -> msg
        _ -> ":white_check_mark:"
      end

    Api.create_interaction_response(interaction, %{
      type: @channel_message,
      data: %{content: message, flags: @ephemeral}
    })
  end

  def handle_event(_event) do
    :noop
  end

  def do_command(%{data: %{name: "ping"}} = interaction) do
    reply =
      (interaction.data.options || [])
      |> Enum.find(%{}, fn o -> o.name == "reply" end)
      |> Map.get(:value)

    {:msg, reply}
  end
end
