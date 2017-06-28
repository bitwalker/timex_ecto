defmodule Timex.Ecto.TimestampWithTimezone do
  @moduledoc """
  Support for using Timex with :timestamptz fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :timestamptz

  @doc """
  Handle casting to Timex.Ecto.TimestampWithTimezone
  """
  def cast(%DateTime{} = dt), do: to_local(dt)
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
    to_local(dt)
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
    to_local(dt)
  end
  def cast(%{"calendar" => _cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "microsecond" => us,
             "time_zone" => tzname, "zone_abbr" => abbr, "utc_offset" => offset_utc, "std_offset" => offset_std}) do
    case us do
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
    to_local(dt)
  end
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, dt} -> to_local(dt)
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
      %DateTime{} = dt ->
        to_local(dt)
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({{_, _, _}, {_, _, _, _}} = dt), do: to_local(Timex.to_datetime(dt))
  def load({{_, _, _}, {_, _, _}} = dt), do: to_local(Timex.to_datetime(dt))
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%DateTime{microsecond: {us, _}} = dt) do
    dt = Timezone.convert(dt, "Etc/UTC")
    {:ok, {{dt.year, dt.month, dt.day}, {dt.hour, dt.minute, dt.second, us}}}
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

  defp to_local(%DateTime{} = dt) do
    case Timezone.local() do
      {:error, _} -> :error
      tz -> {:ok, Timezone.convert(dt, tz)}
    end
  end
end
