defmodule Helpdesk.Bookings.Enums.Colors do
  @moduledoc """
  Colors for workers.
  """
  use Gettext, backend: HelpdeskWeb.Gettext

  use Ash.Type.Enum,
    values: [
      red: gettext("A bright red color"),
      green: gettext("A fresh green color"),
      blue: gettext("A classic blue color"),
      yellow: gettext("A sunny yellow color"),
      orange: gettext("A warm orange color"),
      purple: gettext("A royal purple color"),
      black: gettext("A solid black color"),
      white: gettext("A pure white color"),
      gray: gettext("A neutral gray color"),
      brown: gettext("A natural brown color"),
      pink: gettext("A soft pink color")
    ]
end
