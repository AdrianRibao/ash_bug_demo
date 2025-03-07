defmodule HelpdeskWeb.TicketLive.FormComponent do
  use HelpdeskWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage ticket records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ticket-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:subject]} type="text" label="Subject" />

        <.label for="comments">Comments</.label>

        <.inputs_for :let={comment} field={@form[:comments]}>
          <div class="flex flex-col md:flex-row gap-4 items-start md:items-end border-b border-gray-200 pb-4 mb-4 last:border-b-0">
            <div class="flex-1">
              <.input field={comment[:content]} label="Content" />
            </div>
            <div class="flex-1">
              <.input field={comment[:author]} label="Author" />
            </div>
            <div class="flex items-center gap-2 mt-4 md:mt-0">
              <.button
                type="button"
                phx-click="remove-form"
                phx-value-path={comment.name}
                phx-target={@myself}
                class="ml-2"
              >
                <.icon name="hero-x-mark" />
              </.button>
            </div>
          </div>
        </.inputs_for>
        <.button
          type="button"
          phx-click="add-form"
          phx-value-path={@form.name <> "[comments]"}
          phx-target={@myself}
        >
          <.icon name="hero-plus" />
        </.button>

        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("add-form", %{"path" => path}, socket) do
    form =
      AshPhoenix.Form.add_form(socket.assigns.form, path, params: %{})

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("remove-form", %{"path" => path}, socket) do
    form =
      AshPhoenix.Form.remove_form(socket.assigns.form, path)

    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, ticket_params))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: ticket_params) do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        socket =
          socket
          |> put_flash(:info, "Ticket #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{ticket: ticket}} = socket) do
    form =
      if ticket do
        AshPhoenix.Form.for_update(ticket, :update,
          as: "ticket",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Helpdesk.Support.Ticket, :create,
          as: "ticket",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
