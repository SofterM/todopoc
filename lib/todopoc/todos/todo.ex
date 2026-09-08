defmodule Todopoc.Todos.Todo do
  use Ash.Resource,
    otp_app: :todopoc,
    domain: Todopoc.Todos,
    extensions: [AshJsonApi.Resource],
    data_layer: AshSqlite.DataLayer

  json_api do
    type "todo"

    routes do
      base "/todos"

      get :read
      index :read
      post :create
      patch :update
      patch :toggle, route: "/:id/toggle"
      delete :destroy
    end
  end

  sqlite do
    table "todos"
    repo Todopoc.Repo
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:title, :description, :completed],
      update: [:title, :description, :completed]
    ]

    update :toggle do
      accept []
      require_atomic? false

      change fn changeset, _context ->
        Ash.Changeset.change_attribute(
          changeset,
          :completed,
          !Ash.Changeset.get_data(changeset, :completed)
        )
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :completed, :boolean do
      allow_nil? false
      public? true
      default false
    end

    timestamps()
  end
end
