defmodule TodopocWeb.TodoLiveTest do
  use TodopocWeb.ConnCase

  import Phoenix.LiveViewTest

  test "creates, toggles, and deletes a todo from the index page", %{conn: conn} do
    {:ok, index_live, html} = live(conn, ~p"/todos")
    assert html =~ "Listing Todos"

    {:ok, form_live, _html} =
      index_live
      |> element("a", "New Todo")
      |> render_click()
      |> follow_redirect(conn)

    assert form_live
           |> form("#todo-form", todo: %{title: "Buy milk", description: "2 liters"})
           |> render_submit()

    assert_redirect(form_live, ~p"/todos")

    {:ok, index_live, html} = live(conn, ~p"/todos")
    assert html =~ "Buy milk"

    todo = Ash.read!(Todopoc.Todos.Todo) |> List.first()
    refute todo.completed

    index_live
    |> element("input[phx-value-id=\"#{todo.id}\"]")
    |> render_click()

    assert Ash.get!(Todopoc.Todos.Todo, todo.id).completed

    index_live
    |> element("a", "Delete")
    |> render_click()

    assert Ash.read!(Todopoc.Todos.Todo) == []
  end
end
