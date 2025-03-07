defmodule HelpdeskWeb.ServiceLive.Index do
  use HelpdeskWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Services
      <:actions>
        <.link patch={~p"/services/new"}>
          <.button>New Service</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="services"
      rows={@streams.services}
      row_click={fn {_id, service} -> JS.navigate(~p"/services/#{service}") end}
    >
      <:col :let={{_id, service}} label="Id">{service.id}</:col>

      <:col :let={{_id, service}} label="Name">{service.name}</:col>

      <:col :let={{_id, service}} label="Color">{service.color}</:col>

      <:col :let={{_id, service}} label="# Stages">{length(service.stages)}</:col>

      <:action :let={{_id, service}}>
        <div class="sr-only">
          <.link navigate={~p"/services/#{service}"}>Show</.link>
        </div>

        <.link patch={~p"/services/#{service}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, service}}>
        <.link
          phx-click={JS.push("delete", value: %{id: service.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="service-modal"
      show
      on_cancel={JS.patch(~p"/services")}
    >
      <.live_component
        module={HelpdeskWeb.ServiceLive.FormComponent}
        id={(@service && @service.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        service={@service}
        patch={~p"/services"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :services,
       Ash.read!(Helpdesk.Bookings.Service, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Service")
    |> assign(
      :service,
      Ash.get!(Helpdesk.Bookings.Service, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Service")
    |> assign(:service, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Services")
    |> assign(:service, nil)
  end

  @impl true
  def handle_info({HelpdeskWeb.ServiceLive.FormComponent, {:saved, service}}, socket) do
    {:noreply, stream_insert(socket, :services, service)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    service = Ash.get!(Helpdesk.Bookings.Service, id, actor: socket.assigns.current_user)
    Ash.destroy!(service, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :services, service)}
  end
end
