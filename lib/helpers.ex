defmodule Timex.Ecto.Helpers do
  def millisecond_to_microsecond(ms) do
    Timex.DateTime.Helpers.construct_microseconds(ms*1_000)
  end
end
