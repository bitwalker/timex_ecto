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
      {:ok, %NaiveDateTime{hour: hour,
                           minute: minute,
                           second: second,
                           microsecond: {us,_}}} ->
        load({hour, minute, second, us})
      {:error, _}     -> :error
    end
  end
  def cast({h, m, s} = timestamp) when is_number(h) and is_number(m) and is_number(s) do
    {:ok, Duration.from_erl(timestamp)}
  end
  def cast(%Duration{} = d) do
    {:ok, d}
  end
  # Support embeds_one/embeds_many
  def cast(%{"megaseconds" => m, "seconds" => s, "microseconds" => us}) do
    clock = Duration.to_clock({m,s,us})
    load(clock)
  end
  def cast(%{"hour" => h, "minute" => mm, "second" => s, "ms" => ms}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(%{"hour" => h, "minute" => mm, "second" => s, "millisecond" => ms}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(%{"hour" => h, "minute" => mm, "second" => s, "microsecond" => {us, _}}) do
    load({h, mm, s, us})
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
  def load({_hour, _minute, _second, _usecs} = clock) do
    d = Duration.from_clock(clock)
    {:ok, d}
  end

  def load(%{:__struct__ => Postgrex.Interval, :days => days, :months => months, :secs => seconds}) do
    d = Duration.from_clock({ ((months * 30) + days) * 24, 0, seconds, 0 })
    {:ok, d}
  end

  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%Duration{} = d) do
    {:ok, Duration.to_clock(d)}
  end
  def dump({_mega, _sec, _micro} = timestamp) do
    {:ok, Duration.to_clock(Duration.from_erl(timestamp))}
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

