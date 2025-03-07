defmodule Helpdesk.Bookings.ServiceTest do
  use ExUnit.Case
  alias Helpdesk.Bookings

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Helpdesk.Repo)
  end

  describe "Test service code api" do
    test "Test service creation" do
      {:ok, service} =
        Bookings.create_service(
          "Service 1",
          :red,
          [
            %{
              name: "Stage 1",
              duration: 30
            },
            %{
              name: "Stage 2",
              duration: 30
            }
          ]
        )

      assert length(service.stages) == 2

      stage_names = Enum.map(service.stages, & &1.name)
      assert stage_names == ["Stage 1", "Stage 2"]
    end

    test "Test service update" do
      {:ok, service} =
        Bookings.create_service(
          "Haircut",
          :red,
          [
            %{
              name: "Stage 1",
              duration: 30
            },
            %{
              name: "Stage 2",
              duration: 30
            }
          ]
        )

      [stage | _] = service.stages

      # Change the stage name
      stage =
        %{
          id: stage.id,
          name: "Stage 1 modified",
          duration: 30,
          is_idle: false
        }

      params =
        %{name: service.name, color: service.color, stages: [stage]}

      service
      |> Ash.Changeset.for_update(:update, params)
      |> Ash.update!()
    end
  end
end
