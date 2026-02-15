defmodule AppWeb.HomeLive do
  use AppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen">
      <h1 class="text-4xl font-bold">Hello from LiveView</h1>
    </div>
    """
  end
end
