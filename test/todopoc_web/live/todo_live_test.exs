defmodule TodopocWeb.TodoLiveTest do
  use TodopocWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  defp todo_fixture(user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{title: "some title", description: "some description", status: :pending})

    Todopoc.Todos.Todo
    |> Ash.Changeset.for_create(:create, attrs, actor: user)
    |> Ash.create!()
  end

  test "lists only the current user's todos", %{conn: conn, user: user} do
    todo = todo_fixture(user, %{title: "my own todo"})
    other_todo = todo_fixture(Todopoc.AccountsFixtures.user_fixture(), %{title: "someone else's todo"})

    {:ok, _index_live, html} = live(conn, ~p"/todos")

    assert html =~ "Listing Todos"
    assert html =~ todo.title
    refute html =~ other_todo.title
  end

  test "creates, edits, and deletes a todo", %{conn: conn} do
    {:ok, index_live, _html} = live(conn, ~p"/todos")

    assert {:ok, form_live, _} =
             index_live
             |> element("a", "New Todo")
             |> render_click()
             |> follow_redirect(conn, ~p"/todos/new")

    assert render(form_live) =~ "New Todo"

    assert {:ok, index_live, html} =
             form_live
             |> form("#todo-form",
               todo: %{title: "Buy milk", description: "2 liters", status: "pending"}
             )
             |> render_submit()
             |> follow_redirect(conn, ~p"/todos")

    assert html =~ "Todo created successfully"
    assert html =~ "Buy milk"

    assert {:ok, form_live, _html} =
             index_live
             |> element("a", "Edit")
             |> render_click()
             |> follow_redirect(conn)

    assert {:ok, index_live, html} =
             form_live
             |> form("#todo-form", todo: %{status: "done"})
             |> render_submit()
             |> follow_redirect(conn, ~p"/todos")

    assert html =~ "Todo updated successfully"
    assert html =~ "done"

    index_live
    |> element("a", "Delete")
    |> render_click()

    refute render(index_live) =~ "Buy milk"
  end

  test "cannot read another user's todo directly", %{conn: conn} do
    other_todo = todo_fixture(Todopoc.AccountsFixtures.user_fixture())

    assert_raise Ash.Error.Invalid, fn ->
      live(conn, ~p"/todos/#{other_todo.id}")
    end
  end
end
