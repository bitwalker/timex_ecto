defmodule Timex.Ecto.DateTimeWithTimezone do
  @moduledoc """
  This is a special type for storing datetime + timezone information as a composite type.

  To use this, you must first make sure you have the `datetimetz` type defined in your database:

  ```sql
  CREATE TYPE datetimetz AS (
      dt timestamptz,
      tz varchar
  );
  ```

  Then you can use that type when creating your table, i.e.:

  ```sql
  CREATE TABLE example (
    id integer,
    created_at datetimetz
  );
  ```

  That's it!
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :datetimetz

  @doc """
  Handle casting to Timex.Ecto.DateTimeWithTimezone
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
    {:ok, dt}
  end
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, datetime} -> {:ok, datetime}
      {:error, _} -> :error
    end
  end
  def cast(input) when is_map(input) do
    case Timex.Convert.convert_map(input) do
      %DateTime{} = d ->
        {:ok, d}
      %_{} = result ->
        case Timex.to_datetime(result, "Etc/UTC") do
          {:error, _} ->
            case Ecto.DateTime.cast(input) do
              {:ok, d} ->
                load({{{d.year, d.month, d.day}, {d.hour, d.min, d.sec, d.usec}}, "Etc/UTC"})
              :error ->
                :error
            end
          %DateTime{} = d ->
            {:ok, d}
        end
      {:error, _} ->
        :error
    end
  end
  def cast(input) do
    case Timex.to_datetime(input, "Etc/UTC") do
      {:error, _} ->
        case Ecto.DateTime.cast(input) do
          {:ok, d} -> 
            load({{{d.year, d.month, d.day}, {d.hour, d.min, d.sec, d.usec}}, "Etc/UTC"})
          :error -> 
            :error
        end
      %DateTime{} = d ->
        {:ok, d}
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({{{y, m, d}, {h, mm, s, usec}}, timezone}) do
    secs = :calendar.datetime_to_gregorian_seconds({{y,m,d},{h,mm,s}})
    case Timezone.resolve(timezone, secs) do
      {:error, _} -> :error
      %TimezoneInfo{} = tz ->
        dt = %DateTime{
          :year => y,
          :month => m,
          :day => d,
          :hour => h,
          :minute => mm,
          :second => s,
          :microsecond => Timex.DateTime.Helpers.construct_microseconds(usec),
          :time_zone => tz.full_name,
          :zone_abbr => tz.abbreviation,
          :utc_offset => tz.offset_utc,
          :std_offset => tz.offset_std
        }
        {:ok, dt}
      %AmbiguousTimezoneInfo{before: b, after: a} ->
        dt = %AmbiguousDateTime{
          :before => %DateTime{
            :year => y,
            :month => m,
            :day => d,
            :hour => h,
            :minute => mm,
            :second => s,
            :microsecond => Timex.DateTime.Helpers.construct_microseconds(usec),
            :time_zone => b.full_name,
            :zone_abbr => b.abbreviation,
            :utc_offset => b.offset_utc,
            :std_offset => b.offset_std
          },
          :after => %DateTime{
            :year => y,
            :month => m,
            :day => d,
            :hour => h,
            :minute => mm,
            :second => s,
            :microsecond => Timex.DateTime.Helpers.construct_microseconds(usec),
            :time_zone => a.full_name,
            :zone_abbr => a.abbreviation,
            :utc_offset => a.offset_utc,
            :std_offset => a.offset_std
          }
        }
        {:ok, dt}
    end
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%DateTime{microsecond: {us, _}, time_zone: tzname} = d) do
    {:ok, {{{d.year, d.month, d.day}, {d.hour, d.minute, d.second, us}}, tzname}}
  end

  def autogenerate(precision \\ :sec)
  def autogenerate(:sec) do
    {date, {h, m, s}} = :erlang.universaltime
    load({{date,{h, m, s, 0}}, "UTC"}) |> elem(1)
  end
  def autogenerate(:usec) do
    timestamp = {_,_, usec} = :os.timestamp
    {date, {h, m, s}} = :calendar.now_to_datetime(timestamp)
    load({{date, {h, m, s, usec}}, "UTC"}) |> elem(1)
  end

end

