defmodule ModalExampleWeb.ModalExampleLive do
  use ModalExampleWeb, :live_view

  def render(assigns) do
    ~L"""
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
