use Mix.Config

IO.puts "RUN CONFIG FROM " <> __DIR__

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apm_px, ApmPx.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
config :apm_px, log_level: :warn
config :apm_issues, log_level: :warn

# Hound testing
config :hound, driver: "phantomjs"


