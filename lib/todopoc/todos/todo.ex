defmodule Todopoc.Todos.Todo do
  use Ash.Resource,
    otp_app: :todopoc,
    domain: Todopoc.Todos,
    extensions: [AshJsonApi.Resource],
    data_layer: AshSqlite.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  json_api do
    type "todo"

    routes do
      base "/todos"

      get :read
      index :read
      post :create
      patch :update
      delete :destroy
    end
  end

  sqlite do
    table "todos"
    repo Todopoc.Repo
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if expr(user_id == ^actor(:id))
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:title, :description, :status, :due_date]

      change fn changeset, context ->
        Ash.Changeset.force_change_attribute(changeset, :user_id, context.actor.id)
      end
    end

    update :update do
      primary? true
      accept [:title, :description, :status, :due_date]
    end
  end

  attributes do
    integer_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :status, :atom do
      constraints one_of: [:pending, :in_progress, :done, :cancelled]
      default :pending
      allow_nil? false
      public? true
    end

    attribute :due_date, :date do
      public? true
    end

    attribute :user_id, :integer do
      allow_nil? false
      public? true
    end

    timestamps()
  end
end
