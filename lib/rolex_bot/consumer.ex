defmodule RolexBot.Consumer do
  use Nostrum.Consumer

  alias RolexBot.Roles
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
     ]},
    {"removerole", "Removes a role given by /giverole.",
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
    Api.update_status(:online, "/giverole, /removerole")
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
      interaction
      |> parse_args()
      |> Map.get("reply")

    {:msg, reply}
  end

  def do_command(%{data: %{name: "giverole"}} = interaction) do
    language = interaction |> parse_args() |> Map.get("language")

    with %{"color" => color} <- Rolex.LanguagesAgent.get_language(language),
         {:ok, role} <- Roles.create_role_if_doesnt_exist(interaction.guild_id, language, color),
         {:ok} <-
           Api.add_guild_member_role(
             interaction.guild_id,
             interaction.user.id,
             role.id
           ) do
      {:msg, "Successfully assigned role #{language}."}
    else
      nil -> "Language not found. Remember that names are case-sensitive."
      {:error, error} -> {:msg, error}
      _ -> {:msg, "Something went wrong."}
    end
  end

  def do_command(%{data: %{name: "removerole"}} = interaction) do
    language = interaction |> parse_args() |> Map.get("language")

    with l when is_map(l) <- Rolex.LanguagesAgent.get_language(language),
         role when not is_nil(role) <- Roles.find_role(interaction.guild_id, language),
         {:ok} <-
           Api.remove_guild_member_role(
             interaction.guild_id,
             interaction.user.id,
             role.id
           ) do
      {:msg, "Successfully removed role #{language}."}
    else
      nil -> "Language not found. Remember that names are case-sensitive."
      {:error, error} -> {:msg, error}
        _ -> {:msg, "Something went wrong."}
    end
  end

  defp parse_args(%{data: %{options: options}} = _interaction) do
    options
    |> Enum.map(fn %{name: name, value: value} -> {name, value} end)
    |> Map.new()
  end
end
