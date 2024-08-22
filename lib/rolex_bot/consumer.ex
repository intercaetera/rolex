defmodule RolexBot.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  # Interaction argument type
  @string 3
  # Flag bitset
  @ephemeral 64
  # Interaction response type
  @channel_message 4

  @commands [
    {"ping", "Pong!",
     [
       %{
         type: @string,
         name: "reply",
         description: "reply with",
         required: false
       }
     ]},
    {"giverole",
     "Gives you a role signifying you're interested in a specific programming language.",
     [
       %{
         type: @string,
         name: "language",
         description: "Language name",
         required: true
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
        {:msg, msg} -> "Reply: #{msg}"
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
      interaction
      |> parse_args()
      |> Map.get("reply")

    {:msg, reply}
  end

  def do_command(%{data: %{name: "giverole"}} = interaction) do
    language = interaction |> parse_args() |> Map.get("language")

    case Rolex.Languages.get_language(language) do
      nil -> {:msg, "Language not found."}
      %{"color" => color} -> {:msg, "The colour for your language is #{color}" }
    end
  end

  defp parse_args(%{data: %{options: options}} = _interaction) do
    options
    |> Enum.map(fn %{name: name, value: value} -> {name, value} end)
    |> Map.new()
  end
end
