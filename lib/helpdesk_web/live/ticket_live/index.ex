defmodule HelpdeskWeb.TicketLive.Index do
  use HelpdeskWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Tickets
      <:actions>
        <.link patch={~p"/tickets/new"}>
          <.button>New Ticket</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="tickets"
      rows={@streams.tickets}
      row_click={fn {_id, ticket} -> JS.navigate(~p"/tickets/#{ticket}") end}
    >
      <:col :let={{_id, ticket}} label="Subject">{ticket.subject}</:col>

      <:col :let={{_id, ticket}} label="Num Comments">{length(ticket.comments || [])}</:col>

      <:action :let={{_id, ticket}}>
        <div class="sr-only">
          <.link navigate={~p"/tickets/#{ticket}"}>Show</.link>
        </div>

        <.link patch={~p"/tickets/#{ticket}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, ticket}}>
        <.link
          phx-click={JS.push("delete", value: %{id: ticket.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="ticket-modal"
      show
      on_cancel={JS.patch(~p"/tickets")}
    >
      <.live_component
        module={HelpdeskWeb.TicketLive.FormComponent}
        id={(@ticket && @ticket.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        ticket={@ticket}
        patch={~p"/tickets"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:tickets, Ash.read!(Helpdesk.Support.Ticket, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticket")
    |> assign(:ticket, Ash.get!(Helpdesk.Support.Ticket, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticket")
    |> assign(:ticket, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tickets")
    |> assign(:ticket, nil)
  end

  @impl true
  def handle_info({HelpdeskWeb.TicketLive.FormComponent, {:saved, ticket}}, socket) do
    {:noreply, stream_insert(socket, :tickets, ticket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ticket = Ash.get!(Helpdesk.Support.Ticket, id, actor: socket.assigns.current_user)
    Ash.destroy!(ticket, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :tickets, ticket)}
  end
end
