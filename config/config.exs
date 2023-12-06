# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_api,
  ecto_repos: [MyApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :my_api, MyApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: MyApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MyApi.PubSub,
  live_view: [signing_salt: "SxYjffj8"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :my_api, MyApiWeb.Auth.Guardian,
  issuer: "my_api",
  secret_key: System.get_env("GUARDIAN_SECRET")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :guardian, Guardian.DB,
  repo: MyApi.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
