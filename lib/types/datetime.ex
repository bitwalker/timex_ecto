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
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime),              do: {:ok, datetime}
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
  def cast(input) do
    case Ecto.DateTime.cast(input) do
      {:ok, datetime} -> load({{datetime.year, datetime.month, datetime.day}, {datetime.hour, datetime.min, datetime.sec, datetime.usec}})
      :error -> :error
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
    ms = Time.from(usec, :microseconds)
         |> Time.to_milliseconds
    dt = %DateTime{
      :year => y,
      :month => m,
      :day => d,
      :hour => h,
      :minute => mm,
      :second => s,
      :millisecond => ms,
      :timezone => %TimezoneInfo{}
    }
    {:ok, dt}
  end
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = date) do
    %DateTime{year: y, month: m, day: d, hour: h, minute: min, second: s, millisecond: ms} = Timezone.convert(date, "UTC")
    {:ok, {{y, m, d}, {h, min, s, round(ms * 1_000)}}}
  end
  def dump(_), do: :error

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

