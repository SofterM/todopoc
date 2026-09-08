defmodule Todopoc.Repo do
  use Ecto.Repo,
    otp_app: :todopoc,
    adapter: Ecto.Adapters.SQLite3
end
