defmodule SandboxWeb.Router do
  use SandboxWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Sandbox.Plug.Authentication)
    plug(Sandbox.Plug.Metrics)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SandboxWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", SandboxWeb do
    pipe_through(:api)

    resources("/accounts", AccountController, only: [:index, :show]) do
      resources("/transactions", TransactionController, only: [:index, :show])
    end
  end

  scope "/metrics", SandboxWeb do
    pipe_through :browser

    live("/", MetricsView)
  end

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
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: SandboxWeb.Telemetry)
    end
  end
end
