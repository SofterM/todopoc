defmodule TodopocWeb.TodoLive.Form do
  use TodopocWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage todo records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="todo-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" /><.input
          field={@form[:description]}
          type="text"
          label="Description"
        /><.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={Ash.Resource.Info.attribute(Todopoc.Todos.Todo, :status).constraints[:one_of]}
        />
        <.input field={@form[:due_date]} type="date" label="Due date" />

        <.button phx-disable-with="Saving..." variant="primary">Save Todo</.button>
        <.button navigate={return_path(@return_to, @todo)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    actor = socket.assigns.current_scope.user

    todo =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Todopoc.Todos.Todo, id, actor: actor)
      end

    action = if is_nil(todo), do: "New", else: "Edit"
    page_title = action <> " " <> "Todo"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(todo: todo)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, todo_params))}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: todo_params) do
      {:ok, todo} ->
        socket =
          socket
          |> put_flash(:info, "Todo #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, todo))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp assign_form(%{assigns: %{todo: todo, current_scope: current_scope}} = socket) do
    actor = current_scope.user

    form =
      if todo do
        AshPhoenix.Form.for_update(todo, :update, as: "todo", actor: actor)
      else
        AshPhoenix.Form.for_create(Todopoc.Todos.Todo, :create, as: "todo", actor: actor)
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _todo), do: ~p"/todos"
  defp return_path("show", todo), do: ~p"/todos/#{todo.id}"
end
