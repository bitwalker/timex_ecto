defmodule Timex.Ecto.DateTime do
  @moduledoc """
  Support for using Timex with :datetime fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :datetime

  @doc """
  Handle casting to Timex.Ecto.DateTime
  """
  def cast(%DateTime{} = datetime), do: {:ok, datetime}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "ms" => ms,
             "timezone" => %{"full_name" => tzname,
                             "abbreviation" => abbr,
                             "offset_std" => offset_std,
                             "offset_utc" => offset_utc}}) do
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => Timex.Ecto.Helpers.millisecond_to_microsecond(ms),
      :time_zone => tzname,
      :zone_abbr => abbr,
      :utc_offset => offset_utc,
      :std_offset => offset_std
    }
    {:ok, dt}
  end
  def cast(%{"calendar" => _cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "millisecond" => ms,
             "timezone" => %{"full_name" => tzname,
                             "abbreviation" => abbr,
                             "offset_std" => offset_std,
                             "offset_utc" => offset_utc}}) do
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => Timex.Ecto.Helpers.millisecond_to_microsecond(ms),
      :time_zone => tzname,
      :zone_abbr => abbr,
      :utc_offset => offset_utc,
      :std_offset => offset_std
    }
    {:ok, dt}
  end
  def cast(%{"calendar" => _cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "microsecond" => us,
             "time_zone" => tzname, "zone_abbr" => abbr, "utc_offset" => offset_utc, "std_offset" => offset_std}) do
    us = case us do
      us when is_integer(us) -> Timex.DateTime.Helpers.construct_microseconds(us)
      {_,_} -> us
    end
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => us,
      :time_zone => tzname,
      :zone_abbr => abbr,
      :utc_offset => offset_utc,
      :std_offset => offset_std
    }
    {:ok, dt}
  end
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, d}    -> {:ok, Timex.to_datetime(d)}
      {:error, _} -> :error
    end
  end
  def cast(input) do
    case Timex.to_datetime(input) do
      {:error, _} ->
        case Ecto.DateTime.cast(input) do
          {:ok, d} -> load({{d.year, d.month, d.day}, {d.hour, d.min, d.sec, d.usec}})
          :error -> :error
        end
      %DateTime{} = d ->
        {:ok, d}
    end
  end

  @doc """
  Handle casting to Timex.Ecto.DateTime without returning a tuple
  """
  def cast!(input) do
    case cast(input) do
      {:ok, datetime} -> datetime
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({{y, m, d}, {h, mm, s, usec}}) do
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :microsecond => Timex.DateTime.Helpers.construct_microseconds(usec),
      :time_zone => "Etc/UTC",
      :zone_abbr => "UTC",
      :utc_offset => 0,
      :std_offset => 0
    }
    {:ok, dt}
  end
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = datetime) do
    case Timex.Timezone.convert(datetime, "Etc/UTC") do
      %DateTime{} = dt ->
        case Timex.to_naive_datetime(dt) do
          %NaiveDateTime{} = n ->
            {us, _} = n.microsecond
            {:ok, {{n.year, n.month, n.day}, {n.hour, n.minute, n.second, us}}}
          {:error, _} -> :error
        end
      {:error, _} -> :error
    end
  end
  def dump(datetime) do
    case Timex.to_naive_datetime(datetime) do
      {:error, _} -> :error
      %NaiveDateTime{} = n ->
        {us, _} = n.microsecond
        {:ok, {{n.year, n.month, n.day}, {n.hour, n.minute, n.second, us}}}
    end
  end

  def autogenerate(precision \\ :sec)
  def autogenerate(:sec) do
    {date, {h, m, s}} = :erlang.universaltime
    load({date,{h, m, s, 0}}) |> elem(1)
  end
  def autogenerate(:usec) do
    timestamp = {_,_, usec} = :os.timestamp
    {date, {h, m, s}} = :calendar.now_to_datetime(timestamp)
    load({date, {h, m, s, usec}}) |> elem(1)
  end
end

