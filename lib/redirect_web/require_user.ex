defmodule RedirectWeb.RequireUser do

  alias RedirectWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    case Plug.Conn.get_session(conn, :current_user_id) do
      nil ->
        login = Routes.login_path(RedirectWeb.Endpoint, :index, %{continue_at: conn.request_path})

        conn
        |> Phoenix.Controller.redirect(to: login)
        |> Plug.Conn.halt

      _ ->
        conn
    end
  end
end
