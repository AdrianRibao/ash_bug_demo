defmodule HelpdeskWeb.ServiceLive.Show do
  use HelpdeskWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Service {@service.id}
      <:subtitle>This is a service record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/services/#{@service}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit service</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@service.id}</:item>

      <:item title="Name">{@service.name}</:item>

      <:item title="Color">{@service.color}</:item>

      <:item title="Stages">{@service.stages}</:item>
    </.list>

    <.back navigate={~p"/services"}>Back to services</.back>

    <.modal
      :if={@live_action == :edit}
      id="service-modal"
      show
      on_cancel={JS.patch(~p"/services/#{@service}")}
    >
      <.live_component
        module={HelpdeskWeb.ServiceLive.FormComponent}
        id={@service.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        service={@service}
        patch={~p"/services/#{@service}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :service,
       Ash.get!(Helpdesk.Bookings.Service, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Service"
  defp page_title(:edit), do: "Edit Service"
end
