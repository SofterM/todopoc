defmodule Todopoc.Todos do
  use Ash.Domain, otp_app: :todopoc, extensions: [AshJsonApi.Domain]

  resources do
    resource Todopoc.Todos.Todo
  end
end
