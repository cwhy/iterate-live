defmodule AppWeb.HomeLiveTest do
  use AppWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "renders hello message", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Hello from LiveView"
  end
end
