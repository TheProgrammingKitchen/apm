defmodule ApmPx.Web.Router do
  @moduledoc """
  Routes requested url to controllers and functions
  """
  use ApmPx.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ApmPx.Web do
    pipe_through :browser # Use the default browser stack

    # session
    get "/"       , PageController   , :index
    post "/login" , SessionController, :login
    post "/logout", SessionController, :logout

    # issues
    get "/issues"          , IssuesController , :index
    post "/issues"         , IssuesController , :create
    get "/issues/fake"     , FakerController , :new_fake, as: :new_fake
    post "/issues/fake"    , FakerController , :fake, as: :fake
    post "/issues/:id"     , IssuesController , :update
    get "/issues/new"      , IssuesController , :new
    get "/issues/:id"      , IssuesController , :show
    get "/issues/:parent_id/new", IssuesController , :new, as: :new_child
    delete "/issues/:id"   , IssuesController , :delete
    get "/issues/:id/edit" , IssuesController , :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApmPx do
  #   pipe_through :api
  # end
end
