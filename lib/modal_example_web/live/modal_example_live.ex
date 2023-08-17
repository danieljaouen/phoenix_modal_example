defmodule ModalExampleWeb.ModalExampleLive do
  use ModalExampleWeb, :live_view

  def render(assigns) do
    ~L"""
    <div class="begin-modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Welcome to the Multi-Part Modal Example!</h2>
        <div class="modal-footer">
          <button phx-click="close-modal">Next</button>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, modal_open: false)}
  end

  def handle_event("open-modal", _, socket) do
    {:noreply, assign(socket, modal_open: true)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, modal_open: false)}
  end
end
