defmodule RolexBot.Roles do
  alias Nostrum.Api

  def create_role_if_doesnt_exist(guild_id, language, color) do
    case find_role(guild_id, language) do
      %Nostrum.Struct.Guild.Role{} = role ->
        {:ok, role}

      nil ->
        Api.create_guild_role(
          guild_id,
          [
            name: language,
            permissions: 0,
            color: color_to_int(color),
            mentionable: true
          ]
        )
    end
  end

  defp color_to_int("#" <> color), do: String.to_integer(color, 16)

  def find_role(guild_id, role_to_find) do
    with {:ok, roles} <- Api.get_guild_roles(guild_id) do
      Enum.find(roles, fn role -> role.name == role_to_find end)
    end
  end
end
