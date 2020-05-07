defmodule RedirectWeb.LoginLive do
  use RedirectWeb, :live_view

  alias Phoenix.Token

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    continuation = Map.get(params, "continue_at", Routes.page_path(socket, :index))

    {:noreply,
      socket
      |> assign(:continue_at, continuation)
    }
  end

  @impl true
  def handle_event("login", _event, %{assigns: %{continue_at: continuation}} = socket) do
    token = generate_login_token(42)

    {:noreply,
      redirect(socket, to: Routes.session_path(socket, :login, token, continue_at: continuation))
    }
  end

  def generate_login_token(user_id) do
    Token.sign(RedirectWeb.Endpoint, "salty", user_id)
  end
end
