defmodule HelpdeskWeb.ServiceLive.FormComponent do
  use HelpdeskWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage service records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="service-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:color]}
          type="select"
          label={gettext("Color")}
          options={
            Enum.map(Helpdesk.Bookings.Enums.Colors.values(), fn color ->
              {String.capitalize(to_string(color)), color}
            end)
          }
        />
        <.label for="stages">{gettext("Stages")}</.label>
        <.inputs_for :let={stage} field={@form[:stages]}>
          <div class="flex flex-col md:flex-row gap-4 items-start md:items-end border-b border-gray-200 pb-4 mb-4 last:border-b-0">
            <div class="flex-1">
              <.input field={stage[:name]} label={gettext("Stage name")} />
            </div>
            <div class="flex-1">
              <.input field={stage[:duration]} label={gettext("Stage duration")} />
            </div>
            <div class="flex items-center gap-2 mt-4 md:mt-0">
              <.input field={stage[:is_idle]} type="checkbox" label={gettext("Is idle")} />
              <.button
                type="button"
                phx-click="remove-form"
                phx-value-path={stage.name}
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
          phx-value-path={@form.name <> "[stages]"}
          phx-target={@myself}
        >
          <.icon name="hero-plus" />
        </.button>

        <:actions>
          <.button phx-disable-with="Saving...">Save Service</.button>
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
  def handle_event("validate", %{"service" => service_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, service_params))}
  end

  def handle_event("save", %{"service" => service_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: service_params) do
      {:ok, service} ->
        notify_parent({:saved, service})

        socket =
          socket
          |> put_flash(:info, "Service #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{service: service}} = socket) do
    form =
      if service do
        AshPhoenix.Form.for_update(service, :update,
          as: "service",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Helpdesk.Bookings.Service, :create,
          as: "service",
          actor: socket.assigns.current_user
        )
        |> AshPhoenix.Form.add_form("service[stages]")
      end

    assign(socket, form: to_form(form))
  end
end
