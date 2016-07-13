defimpl Ecto.DataType, for: DateTime do
  use Timex

  def cast(%DateTime{} = datetime, type) when type in [:date, Timex.Ecto.Date] do
    Timex.Ecto.Date.dump(datetime)
  end
  def cast(%DateTime{} = datetime, type) when type in [:datetime, Timex.Ecto.DateTime] do
    Timex.Ecto.DateTime.dump(datetime)
  end
  def cast(%DateTime{} = datetime, type) when type in [:time, Timex.Ecto.Time] do
    datetime
    |> Timex.to_unix
    |> Duration.from_seconds
    |> Timex.Ecto.Time.dump
  end
  def cast(%DateTime{} = datetime, Timex.Ecto.DateTimeWithTimezone) do
    Timex.Ecto.DateTimeWithTimezone.dump(datetime)
  end
  def cast(_, _) do
    :error
  end

  def dump(datetime), do: Timex.Ecto.DateTime.dump(datetime)
end

defimpl Ecto.DataType, for: NaiveDateTime do
  use Timex

  def cast(%NaiveDateTime{} = datetime, type) when type in [:date, Timex.Ecto.Date] do
    Timex.Ecto.Date.dump(datetime)
  end
  def cast(%NaiveDateTime{} = datetime, type) when type in [:datetime, Timex.Ecto.DateTime] do
    Timex.Ecto.DateTime.dump(datetime)
  end
  def cast(%NaiveDateTime{} = datetime, type) when type in [:time, Timex.Ecto.Time] do
    datetime
    |> Timex.to_unix
    |> Duration.from_seconds
    |> Timex.Ecto.Time.dump
  end
  def cast(%NaiveDateTime{} = datetime, Timex.Ecto.DateTimeWithTimezone) do
    Timex.Ecto.DateTimeWithTimezone.dump(datetime)
  end
  def cast(_, _) do
    :error
  end

  def dump(datetime), do: Timex.Ecto.DateTime.dump(datetime)
end

defimpl Ecto.DataType, for: Date do
  use Timex

  def cast(%Date{} = date, type) when type in [:date, Timex.Ecto.Date] do
    Timex.Ecto.Date.dump(date)
  end
  def cast(%Date{} = date, type) when type in [:datetime, Timex.Ecto.DateTime] do
    Timex.Ecto.DateTime.dump(Timex.to_datetime(date))
  end
  def cast(%Date{} = date, type) when type in [:time, Timex.Ecto.Time] do
    date
    |> Timex.to_unix
    |> Duration.from_seconds
    |> Timex.Ecto.Time.dump
  end
  def cast(%Date{} = date, Timex.Ecto.DateTimeWithTimezone) do
    Timex.Ecto.DateTimeWithTimezone.dump(Timex.to_datetime(date))
  end
  def cast(_, _) do
    :error
  end

  def dump(date), do: Timex.Ecto.Date.dump(date)
end
