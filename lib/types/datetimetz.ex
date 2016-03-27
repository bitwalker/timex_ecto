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
  We can let Ecto handle blank input
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Handle casting to Timex.Ecto.DateTimeWithTimezone
  """
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime), do: {:ok, datetime}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "ms" => ms,
             "timezone" => %{"full_name" => tz_abbr}}) do
    datetime = Timex.datetime({{y,m,d},{h,mm,s}}, tz_abbr)
    {:ok, %{datetime | :millisecond => ms}}
  end
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d,
             "hour" => h, "minute" => mm, "second" => s, "millisecond" => ms,
             "timezone" => %{"full_name" => tz_abbr}}) do
    datetime = Timex.datetime({{y,m,d},{h,mm,s}}, tz_abbr)
    {:ok, %{datetime | :millisecond => ms}}
  end
  def cast(input) do
    case Ecto.DateTimeWithTimezone.cast(input) do
      {:ok, datetime} ->
        load({{{datetime.year, datetime.month, datetime.day},
               {datetime.hour, datetime.min, datetime.sec, datetime.usec}
              },
              datetime.timezone
            })
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({ {{year, month, day}, {hour, min, sec, usec}}, timezone}) do
    datetime = Timex.datetime({{year, month, day}, {hour, min, sec}})
    datetime = %{datetime | :millisecond => Time.from(usec, :microseconds) |> Time.to_milliseconds}
    tz       = Timezone.get(timezone, datetime)
    {:ok, %{datetime | :timezone => tz}}
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump(%DateTime{timezone: nil} = datetime) do
    {date, {hour, min, second}} = Timex.to_erlang_datetime(datetime)
    micros = datetime.millisecond * 1_000
    {:ok, {{date, {hour, min, second, micros}}, "UTC"}}
  end
  def dump(%DateTime{timezone: %TimezoneInfo{full_name: name}} = datetime) do
    {date, {hour, min, second}} = Timex.to_erlang_datetime(datetime)
    micros = datetime.millisecond * 1_000
    {:ok, {{date, {hour, min, second, micros}}, name}}
  end
  def dump(_), do: :error
end

