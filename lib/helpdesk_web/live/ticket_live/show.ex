defmodule HelpdeskWeb.TicketLive.Show do
  use HelpdeskWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Ticket {@ticket.id}
      <:subtitle>This is a ticket record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/tickets/#{@ticket}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit ticket</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@ticket.id}</:item>

      <:item title="Comments">{@ticket.comments}</:item>
    </.list>

    <.back navigate={~p"/tickets"}>Back to tickets</.back>

    <.modal
      :if={@live_action == :edit}
      id="ticket-modal"
      show
      on_cancel={JS.patch(~p"/tickets/#{@ticket}")}
    >
      <.live_component
        module={HelpdeskWeb.TicketLive.FormComponent}
        id={@ticket.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        ticket={@ticket}
        patch={~p"/tickets/#{@ticket}"}
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
     |> assign(:ticket, Ash.get!(Helpdesk.Support.Ticket, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Ticket"
  defp page_title(:edit), do: "Edit Ticket"
end
