defmodule Helpdesk.Bookings.Service do
  use Ash.Resource,
    otp_app: :helpdesk,
    domain: Helpdesk.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "services"
    repo Helpdesk.Repo
  end

  actions do
    read :read do
      primary? true
      prepare build(load: [:stage_count, :stage_duration])
    end

    create :create do
      primary? true

      accept [
        :name,
        :color,
        :stages
      ]
    end

    update :update do
      primary? true

      accept [
        :name,
        :color,
        :stages
      ]
    end

    destroy :destroy do
      primary? true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :color, Helpdesk.Bookings.Enums.Colors do
      allow_nil? false
      public? true
    end

    attribute :stages, {:array, Helpdesk.Bookings.Stage}, public?: true

    timestamps()
  end

  calculations do
    calculate :stage_count, :integer, expr(fragment("array_length(stages, 1)"))

    calculate :stage_duration,
              :integer,
              expr(fragment("SELECT SUM((s->>'duration')::int) FROM unnest(stages) AS s"))
  end
end
