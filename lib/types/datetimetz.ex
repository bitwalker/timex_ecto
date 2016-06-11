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
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime), do: {:ok, datetime}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "ms" => ms,
             "timezone" => %{"full_name" => tzname,
                             "abbreviation" => abbr,
                             "offset_std" => offset_std,
                             "offset_utc" => offset_utc}}) do
    dt = %DateTime{
      :calendar => String.to_atom(cal),
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :millisecond => ms
    }
    tz = %TimezoneInfo{
      full_name: tzname, abbreviation: abbr,
      offset_std: offset_std, offset_utc: offset_utc,
      from: nil, until: nil
    }
    {:ok, %{dt | :timezone => tz}}
  end
  def cast(%{"calendar" => cal,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "millisecond" => ms,
             "timezone" => %{"full_name" => tzname,
                             "abbreviation" => abbr,
                             "offset_std" => offset_std,
                             "offset_utc" => offset_utc}}) do
    dt = %DateTime{
      :calendar => String.to_atom(cal),
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :millisecond => ms
    }
    tz = %TimezoneInfo{
      full_name: tzname, abbreviation: abbr,
      offset_std: offset_std, offset_utc: offset_utc,
      from: nil, until: nil
    }
    {:ok, %{dt | :timezone => tz}}
  end
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISO:Extended}") do
      {:ok, datetime} -> {:ok, datetime}
      {:error, _} -> :error
    end
  end
  def cast(input) do
    case Ecto.DateTime.cast(input) do
      {:ok, datetime} -> load({{datetime.year, datetime.month, datetime.day}, {datetime.hour, datetime.min, datetime.sec, datetime.usec}})
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({{{y, m, d}, {h, mm, s, usec}}, timezone}) do
    ms = Time.from(usec, :microseconds)
         |> Time.to_milliseconds
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :millisecond => ms
    }
    tz = Timezone.get(timezone, dt)
    {:ok, %{dt | :timezone => tz}}
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%DateTime{} = date) do
    %DateTime{year: y, month: m, day: d, hour: h, minute: min, second: s, millisecond: ms} = Timezone.convert(date, "UTC")
    {:ok, {{y, m, d}, {h, min, s, round(ms * 1_000)}}}
  end
  def dump(_), do: :error

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

