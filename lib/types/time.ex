defmodule Timex.Ecto.Time do
  @moduledoc """
  Support for using Timex with :time fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :time

  @doc """
  Handle casting to Timex.Ecto.Time
  """
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISOtime}") do
      {:ok, %Timex.DateTime{hour: hour,
                            minute: minute,
                            second: second,
                            millisecond: millisecond}} ->
        load({hour, minute, second, millisecond * 1_000})
      {:error, _}     -> :error
    end
  end
  def cast({h, m, s} = timestamp) when is_number(h) and is_number(m) and is_number(s) do
    {:ok, timestamp}
  end
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => _, "month" => _, "day" => _,
             "hour" => h, "minute" => mm, "second" => s, "ms" => ms,
             "timezone" => _}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(%{"calendar" => _,
             "year" => _, "month" => _, "day" => _,
             "hour" => h, "minute" => mm, "second" => s, "millisecond" => ms,
             "timezone" => _}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(input) do
    case Ecto.Time.cast(input) do
      {:ok, time} -> load({time.hour, time.min, time.sec, time.usec})
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({hour, minute, second, usecs}) do
    millis = Time.from(usecs, :microseconds) |> Time.to_milliseconds
    time = %{DateTime.epoch | :hour => hour, :minute => minute, :second => second, :millisecond => millis} |> DateTime.to_timestamp(:epoch)
    {:ok, time}
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump({_mega, _sec, _micro} = timestamp) do
    %DateTime{hour: h, minute: m, second: s, millisecond: ms} = DateTime.from_timestamp(timestamp, :epoch)
    {:ok, {h, m, s, ms * 1_000}}
  end
  def dump(_), do: :error

  def autogenerate(precision \\ :sec)
  def autogenerate(:sec) do
    {_date, {h, m, s}} = :erlang.universaltime
    load({h, m, s, 0}) |> elem(1)
  end
  def autogenerate(:usec) do
    timestamp = {_,_, usec} = :os.timestamp
    {_date, {h, m, s}} = :calendar.now_to_datetime(timestamp)
    load({h, m, s, usec}) |> elem(1)
  end


end

