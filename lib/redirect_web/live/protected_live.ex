defmodule RedirectWeb.ProtectedLive do
  use RedirectWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
      <h1>Protected</h1>
      <%= link "Logout", to: Routes.session_path(RedirectWeb.Endpoint, :logout), method: :post %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
