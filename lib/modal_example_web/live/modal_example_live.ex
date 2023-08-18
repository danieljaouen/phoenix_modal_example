defmodule ModalExampleWeb.ModalExampleLive do
  alias Phoenix.HTML.Form

  use ModalExampleWeb, :live_view

  @form1_initial_values %{"email" => "", "completed" => false}
  @form2_initial_values %{
    "full_name" => "",
    "address1" => "",
    "address2" => "",
    "city" => "",
    "state" => "",
    "zip" => "",
    "completed" => false
  }

  def mount(_params, _session, socket) do
    form1_map = @form1_initial_values
    form2_map = @form2_initial_values

    form1 = to_form(form1_map)
    form2 = to_form(form2_map)

    seen_params = %{}

    {
      :ok,
      assign(
        socket,
        form1: form1,
        form2: form2,
        page: 1,
        seen_params: seen_params
      )
    }
  end

  def handle_params(params, _url, socket) do
    page = Map.get(params, "page")

    [form1, form2] =
      if !page do
        [to_form(@form1_initial_values), to_form(@form2_initial_values)]
      else
        [socket.assigns.form1, socket.assigns.form2]
      end

    page = page || "1"

    if page == "3" && !socket.assigns.form1["completed"].value do
      {
        :noreply,
        socket
        |> assign(form1: form1, form2: form2, page: "1")
        |> put_flash(:error, "You must complete the first form before continuing")
        |> push_patch(to: ~p"/?page=1")
      }
    else
      {
        :noreply,
        assign(
          socket,
          form1: form1,
          form2: form2,
          page: page
        )
      }
    end
  end

  def get_seen_params(params, socket) do
    seen_params = socket.assigns.seen_params

    new_seen_params =
      params
      |> Map.delete("_target")

    new_seen_params =
      Enum.into(
        Enum.map(
          seen_params,
          &{"#{elem(&1, 0)}", params[&1]}
        ),
        new_seen_params
      )

    new_seen_params =
      Enum.into(
        Enum.map(
          new_seen_params,
          fn {k, _v} ->
            {"#{k}",
             if params[k] do
               params[k]
             else
               seen_params[k]
             end}
          end
        ),
        %{}
      )

    seen_params =
      Enum.into(
        Enum.map(
          seen_params,
          fn {k, _v} ->
            {"#{k}",
             if params[k] do
               params[k]
             else
               new_seen_params[k]
             end}
          end
        ),
        %{}
      )

    Map.merge(seen_params, new_seen_params)
  end

  def handle_event("validate1", params, socket) do
    form2 = socket.assigns.form2

    seen_params = get_seen_params(params, socket)

    form1 = validate_form1(to_form(seen_params), params)

    {
      :noreply,
      assign(
        socket,
        form1: form1,
        form2: form2,
        seen_params: seen_params
      )
    }
  end

  def handle_event("validate_form1", params, socket) do
    form1 = to_form(params)
    form2 = socket.assigns.form2
    seen_params = socket.assigns.seen_params

    {
      :noreply,
      assign(
        socket,
        form1: form1,
        form2: form2,
        seen_params: seen_params
      )
    }
  end

  def handle_event("validate2", params, socket) do
    form1 = socket.assigns.form1

    seen_params = get_seen_params(params, socket)

    form2 = validate_form2(to_form(seen_params), params)

    {
      :noreply,
      assign(
        socket,
        form1: form1,
        form2: form2,
        seen_params: seen_params
      )
    }
  end

  def handle_event("validate_form2", params, socket) do
    form1 = socket.assigns.form1
    form2 = to_form(params)
    seen_params = socket.assigns.seen_params

    {
      :noreply,
      assign(
        socket,
        form1: form1,
        form2: form2,
        seen_params: seen_params
      )
    }
  end

  def handle_event("save1", params, socket) do
    form2 = socket.assigns.form2
    page = socket.assigns.page
    seen_params = socket.assigns.seen_params

    IO.inspect(params)
    form1 = validate_form1(to_form(params), params)

    if length(form1.errors) != 0 do
      # If there are errors, we want to show the user
      {
        :noreply,
        assign(
          socket,
          form1: form1,
          form2: form2,
          page: page,
          seen_params: seen_params
        )
      }
    else
      page = "3"

      {
        :noreply,
        push_patch(
          assign(socket, form1: form1, form2: form2, page: page),
          to: ~p"/?page=3"
        )
      }
    end
  end

  def handle_event("save2", params, socket) do
    form1 = socket.assigns.form1
    page = socket.assigns.page
    seen_params = socket.assigns.seen_params

    IO.inspect(params)
    form2 = validate_form2(to_form(params), params)

    if length(form2.errors) != 0 do
      # If there are errors, we want to show the user
      {
        :noreply,
        assign(
          socket,
          form1: form1,
          form2: form2,
          page: page,
          seen_params: seen_params
        )
      }
    else
      page = "1"
      save_form(form1, form2)
      socket = assign(socket, form1: form1, form2: form2, page: page)

      {
        :noreply,
        redirect(socket, to: ~p"/")
      }
    end
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

  def validate(form, _params) do
    form
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
