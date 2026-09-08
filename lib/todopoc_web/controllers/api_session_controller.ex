defmodule TodopocWeb.ApiSessionController do
  use TodopocWeb, :controller

  alias Todopoc.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.generate_user_session_token(user)

      conn
      |> put_status(:created)
      |> json(%{data: %{token: Base.url_encode64(token, padding: false), email: user.email}})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{errors: %{detail: "Invalid email or password"}})
    end
  end
end
