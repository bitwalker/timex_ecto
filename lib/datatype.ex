defimpl Ecto.DataType, for: Timex.DateTime do
  use Timex

  def cast(%DateTime{} = datetime, type) when type in [:date, Timex.Ecto.Date] do
    Timex.Ecto.Date.dump(datetime)
  end
  def cast(%DateTime{} = datetime, type) when type in [:datetime, Timex.Ecto.DateTime] do
    Timex.Ecto.DateTime.dump(datetime)
  end
  def cast(%DateTime{} = datetime, type) when type in [:time, Timex.Ecto.Time] do
    datetime
    |> Date.to_timestamp
    |> Timex.Ecto.Time.dump
  end
  def cast(%DateTime{} = datetime, Timex.Ecto.DateTimeWithTimezone) do
    Timex.Ecto.DateTimeWithTimezone.dump(datetime)
  end
  def cast(_, _) do
    :error
  end
end
