import Config

if config_env() == :dev do
  DotenvParser.load_file(".env")
end

token = System.get_env("ROLEX_TOKEN")

config :nostrum,
  token: token,
  youtubedl: nil,
  streamlink: nil

