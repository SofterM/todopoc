defmodule TodopocWeb.PageController do
  use TodopocWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
