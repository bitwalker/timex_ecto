use Mix.Config

{username, 0} = System.cmd("whoami", [])

config :timex_ecto, EctoTest.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "timex",
  username: String.trim_trailing(username, "\n"),
  pool: Ecto.Adapters.SQL.Sandbox
