defmodule TodopocWeb.Router do
  use TodopocWeb, :router

  import TodopocWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TodopocWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :fetch_current_scope_for_api_user
    plug :require_authenticated_api_user
    plug :set_ash_actor
  end

  scope "/api/json" do
    pipe_through [:api, :api_auth]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      default_model_expand_depth: 4

    forward "/", TodopocWeb.AshJsonApiRouter
  end

  scope "/", TodopocWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", TodopocWeb do
    pipe_through :api

    post "/login", ApiSessionController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todopoc, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TodopocWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TodopocWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TodopocWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/todos", TodoLive.Index, :index
      live "/todos/new", TodoLive.Form, :new
      live "/todos/:id", TodoLive.Show, :show
      live "/todos/:id/edit", TodoLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", TodopocWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{TodopocWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  defp set_ash_actor(conn, _opts) do
    Ash.PlugHelpers.set_actor(conn, conn.assigns.current_scope.user)
  end
end
