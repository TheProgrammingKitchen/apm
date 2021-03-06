defmodule ApmPx.PageControllerTest do
  require Logger
  use ApmPx.Web.ConnCase
  use TestHelper

  test "GET / prints a welcome message", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to APM"
  end

  test "GET / when not logged in", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "You&#39;re not logged in"
  end

  test "GET / when logged in", %{conn: conn} do
    session = conn |> login_as("some user", "admin") |> get( "/" )
    assert html_response(session, 200) =~ "You&#39;re logged in"
  end

  test "Show README.md on the landing page when logged in", %{conn: conn} do
    session = conn |> login_as("some user", "admin") |> get( "/" )
    assert html_response(session, 200) =~ "Jira sux"
    assert html_response(session, 200) =~ "Project Page"
  end

  test "Not show README.md on the landing page when not logged in", %{conn: conn} do
    conn = get conn, "/"
    refute html_response(conn, 200) =~ "Jira sux" end

end
