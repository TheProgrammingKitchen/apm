use Mix.Config

# Configures the endpoint
config :apm_px, ApmPx.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/AhSfgTcZwZCeM0RvyMRks6lMgYLfEK3x4dQLBYw50mSHWpc3FWuGwAhLCaKtLLM",
  render_errors: [view: ApmPx.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ApmPx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  level: :warn,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
