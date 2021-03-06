defmodule RedirectWeb.PageLive do
  use RedirectWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
      <h1>Landing Page</h1>
      <%= live_redirect "Protected", to: Routes.protected_path(@socket, :index) %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
