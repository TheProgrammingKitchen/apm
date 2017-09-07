defmodule ApmPx.Web.Endpoint do
  require Logger
  @moduledoc "Phoenix endpoint as created by phx.new"

  use Phoenix.Endpoint, otp_app: :apm_px

  socket "/socket", ApmPx.Web.UserSocket

  unless System.get_env("MIX_ENV") == "production" do
    Logger.info "STARTING WITH SEEDS FROM FIXTURE FILES ./data/fixutures/issues.json"
    Application.ensure_all_started(:apm_issues)
    ApmPx.Fixtures.read
    |> ApmIssues.seed # For development and testing only
    Logger.debug "SEEDED " <> inspect(ApmIssues.Registry.state())
  end

  plug Plug.Static,
    at: "/", from: :apm_px, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_apm_px_key",
    signing_salt: "eYK+NFSC"

  plug ApmPx.Web.Router

end
