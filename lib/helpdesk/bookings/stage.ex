defmodule Helpdesk.Bookings.Stage do
  use Ash.Resource,
    otp_app: :helpdesk,
    domain: Helpdesk.Bookings,
    data_layer: :embedded

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :duration, :integer do
      allow_nil? false
      public? true
    end

    attribute :is_idle, :boolean do
      default false
      public? true
    end
  end
end
