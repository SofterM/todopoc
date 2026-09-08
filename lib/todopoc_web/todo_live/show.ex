defmodule TodopocWeb.TodoLive.Show do
  use TodopocWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Todo {@todo.id}
        <:subtitle>This is a todo record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/todos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/todos/#{@todo}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Todo
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@todo.id}</:item>

        <:item title="Title">{@todo.title}</:item>

        <:item title="Description">{@todo.description}</:item>

        <:item title="Status">{@todo.status}</:item>

        <:item title="Due date">{@todo.due_date}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    actor = socket.assigns.current_scope.user

    {:ok,
     socket
     |> assign(:page_title, "Show Todo")
     |> assign(:todo, Ash.get!(Todopoc.Todos.Todo, id, actor: actor))}
  end
end
