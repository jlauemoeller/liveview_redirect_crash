defmodule RedirectWeb.SessionController do
  use RedirectWeb, :controller
  alias Phoenix.Token

  def login(conn, %{"token" => token} = params) do
    case verify_login_token(token) do
      {:ok, user_id} ->
        conn
        |> put_session(:current_user_id, user_id)
        |> put_session(:live_socket_id, "user_sockets:#{user_id}")
        |> configure_session(renew: true)
        |> redirect(to: Map.get(params, "continue_at", "/"))

      {:error, _} ->
        conn
        |> put_flash(:warn, "Login failed")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def logout(conn, _) do
    conn
    |> get_session(:live_socket_id)
    |> RedirectWeb.Endpoint.broadcast("disconnect", %{})

    conn
    |> configure_session(drop: true)
    |> delete_session(:current_user_id)
    |> delete_session(:live_socket_id)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp verify_login_token(token) do
    Token.verify(RedirectWeb.Endpoint, "salty", token, max_age: 30)
  end
end
