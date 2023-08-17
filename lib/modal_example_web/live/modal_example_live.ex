defmodule ModalExampleWeb.ModalExampleLive do
  use ModalExampleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, modal_open: false)}
  end

  def handle_params(params, url, socket) do
    if url =~ ~p"/submit" do
      # save_form(socket.form)
      {
        :noreply,
        socket
        |> push_patch(to: ~p"/")
      }
    else
      {
        :noreply,
        socket
      }
    end
  end

  def show_modal_1(js \\ %JS{}) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal-2")
    |> JS.hide(transition: "fade-out", to: "#modal-3")
    |> JS.show(transition: "fade-in", to: "#modal-1")
  end

  def show_modal_2(js \\ %JS{}) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal-1")
    |> JS.hide(transition: "fade-out", to: "#modal-3")
    |> JS.show(transition: "fade-in", to: "#modal-2")
  end

  def show_modal_3(js \\ %JS{}) do
    js
    |> JS.hide(transition: "fade-out", to: "#modal-1")
    |> JS.hide(transition: "fade-out", to: "#modal-2")
    |> JS.show(transition: "fade-in", to: "#modal-3")
  end
end
