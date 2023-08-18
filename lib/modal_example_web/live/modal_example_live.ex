defmodule ModalExampleWeb.ModalExampleLive do
  alias Phoenix.HTML.Form

  use ModalExampleWeb, :live_view

  def mount(_params, _session, socket) do
    form1_map = %{"email" => "", "completed" => false}

    form2_map = %{
      "full_name" => "",
      "address1" => "",
      "address2" => "",
      "city" => "",
      "state" => "",
      "zip" => "",
      "completed" => false
    }

    form1 = to_form(form1_map)
    form2 = to_form(form2_map)

    {
      :ok,
      assign(
        socket,
        form1: form1,
        form2: form2,
        page: 1
      )
    }
  end

  def handle_event("save", params, socket) do
    form1 = socket.assigns.form1
    form2 = socket.assigns.form2

    form1 =
      if Map.get(params, "email") do
        validate_form1(to_form(params), params)
      else
        form1
      end

    form2 =
      if !Map.get(params, "email") do
        validate_form2(to_form(params), params)
      else
        form2
      end

    {:noreply, assign(socket, form1: form1, form2: form2)}
  end

  def handle_event("validate", params, socket) do
    form1 = socket.assigns.form1
    form2 = socket.assigns.form2

    form1 =
      if Map.get(params, "email") do
        validate_form1(to_form(params), params)
      else
        form1
      end

    form2 =
      if !Map.get(params, "email") do
        validate_form2(to_form(params), params)
      else
        form2
      end

    {:noreply, assign(socket, form1: form1, form2: form2)}
  end

  def handle_params(params, url, socket) do
    page = Map.get(params, "page") || "1"

    if url =~ ~p"/submit" do
      save_form(socket.assigns.form1, socket.assigns.form2)

      {
        :noreply,
        socket
        |> push_patch(to: ~p"/")
      }
    else
      {
        :noreply,
        assign(
          socket,
          page: page
        )
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

  defp save_form(form1, form2) do
    IO.inspect(form1)
    IO.inspect(form2)
  end

  def check_field_isnt_blank(field) do
    fn form -> form[field].value == "" end
  end

  def check_email_regex(form) do
    !String.match?(form[:email].value, ~r/@/)
  end

  def validate_form1(form1, params) do
    form1
    |> validate(params)
    |> put_error("email", "Email is required", check_field_isnt_blank("email"))
    |> put_error("email", "Email is invalid", &check_email_regex/1)
  end

  def validate_form2(form2, params) do
    form2
    |> validate(params)
    |> put_error("full_name", "Full name is required", check_field_isnt_blank("full_name"))
    |> put_error("address1", "Address is required", check_field_isnt_blank("address1"))
    |> put_error("city", "City is required", check_field_isnt_blank("city"))
    |> put_error("state", "State is required", check_field_isnt_blank("state"))
    |> put_error("zip", "Zip is required", check_field_isnt_blank("zip"))
  end

  def validate(_form, params) do
    to_form(params)
  end

  def put_error(form, field, message, condition) do
    # if the string is null, then the form is invalid
    # if the string does not match, then the form is invalid
    if condition.(form) do
      %Form{form | errors: form.errors ++ ["#{field}": {message, %{}}]}
    else
      form
    end
  end
end
