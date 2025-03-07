defmodule Helpdesk.Support.Comment do
  use Ash.Resource,
    otp_app: :celp,
    domain: Helpdesk.Support,
    data_layer: :embedded

  attributes do
    uuid_primary_key :id

    attribute :content, :string do
      allow_nil? false
      public? true
    end

    attribute :author, :string do
      allow_nil? false
      public? true
    end
  end
end
