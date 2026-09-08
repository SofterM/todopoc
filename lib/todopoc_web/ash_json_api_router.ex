defmodule TodopocWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Todopoc.Todos],
    open_api: "/open_api"
end
