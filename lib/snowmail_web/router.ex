defmodule SnowmailWeb.Router do
  use SnowmailWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SnowmailWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Inbox
  live_session :inbox, on_mount: SnowmailWeb.InboxAssigns do
    scope "/inbox", SnowmailWeb.InboxLive do
      pipe_through :browser

      live "/:email/:host", Index, :index
    end
  end

  # Base
  scope "/", SnowmailWeb do
    pipe_through :browser

    live "/", IndexLive.Index, :index

    scope "/emails" do
      live "/", EmailLive.Index, :index
      live "/new", EmailLive.Index, :new
      live "/:id/edit", EmailLive.Index, :edit

      live "/:id", EmailLive.Show, :show
      live "/:id/show/edit", EmailLive.Show, :edit
    end

    scope "/hosts" do
      live "/", HostLive.Index, :index
      live "/new", HostLive.Index, :new
      live "/:id/edit", HostLive.Index, :edit

      live "/:id", HostLive.Show, :show
      live "/:id/show/edit", HostLive.Show, :edit
    end

    scope "/messages" do
      live "/", MessageLive.Index, :index
      live "/new", MessageLive.Index, :new
      live "/:id/edit", MessageLive.Index, :edit

      live "/:id", MessageLive.Show, :show
      live "/:id/show/edit", MessageLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SnowmailWeb do
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

      live_dashboard "/dashboard", metrics: SnowmailWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
