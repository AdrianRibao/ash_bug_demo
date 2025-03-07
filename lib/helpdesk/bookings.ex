defmodule Helpdesk.Bookings do
  use Ash.Domain, otp_app: :celp, extensions: [AshPhoenix]

  resources do
    resource Helpdesk.Bookings.Service do
      define :create_service, action: :create, args: [:name, :color, :stages]
      define :read_services, action: :read
      define :get_service_by_id, action: :read, get_by: :id
      define :update_service, action: :update
      define :destroy_service, action: :destroy
    end
  end
end
