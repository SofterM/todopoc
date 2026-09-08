defmodule TodopocWeb.TodoLive.Index do
  use TodopocWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Todos
        <:actions>
          <.button variant="primary" navigate={~p"/todos/new"}>
            <.icon name="hero-plus" /> New Todo
          </.button>
        </:actions>
      </.header>

      <.table
        id="todos"
        rows={@streams.todos}
        row_click={fn {_id, todo} -> JS.navigate(~p"/todos/#{todo}") end}
      >
        <:col :let={{_id, todo}} label="Id">{todo.id}</:col>

        <:col :let={{_id, todo}} label="Title">{todo.title}</:col>

        <:col :let={{_id, todo}} label="Description">{todo.description}</:col>

        <:col :let={{_id, todo}} label="Status">{todo.status}</:col>

        <:col :let={{_id, todo}} label="Due date">{todo.due_date}</:col>

        <:action :let={{_id, todo}}>
          <div class="sr-only">
            <.link navigate={~p"/todos/#{todo}"}>Show</.link>
          </div>

          <.link navigate={~p"/todos/#{todo}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, todo}}>
          <.link
            phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    actor = socket.assigns.current_scope.user

    {:ok,
     socket
     |> assign(:page_title, "Listing Todos")
     |> stream(:todos, Ash.read!(Todopoc.Todos.Todo, actor: actor))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    actor = socket.assigns.current_scope.user
    todo = Ash.get!(Todopoc.Todos.Todo, id, actor: actor)
    Ash.destroy!(todo, actor: actor)

    {:noreply, stream_delete(socket, :todos, todo)}
  end
end
