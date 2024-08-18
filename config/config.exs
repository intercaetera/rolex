import Config

if config_env() in [:dev, :test] do
  import_config ".env.exs"
end

token = System.get_env("ROLEX_TOKEN") ||
  raise """
  Missing ROLEX_TOKEN environment variable
  """

config :nostrum,
  token: token,
  youtubedl: nil,
  streamlink: nil

