defmodule RedirectWeb.Router do
  use RedirectWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {RedirectWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_user do
    plug RedirectWeb.RequireUser
  end

  scope "/", RedirectWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/login", LoginLive, :index

    get "/session/:token", SessionController, :login
  end

  scope "/", RedirectWeb do
    pipe_through [:browser, :require_user]

    post "/session", SessionController, :logout
    live "/protected", ProtectedLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RedirectWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RedirectWeb.Telemetry
    end
  end
end
