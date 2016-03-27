defmodule Timex.Ecto.DateTime do
  @moduledoc """
  Support for using Timex with :datetime fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :datetime

  @doc """
  We can let Ecto handle blank input
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Handle casting to Timex.Ecto.DateTime
  """
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime),              do: {:ok, datetime}
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
  def load({{year, month, day}, {hour, min, sec, usec}}) do
    datetime = Timex.datetime({{year, month, day}, {hour, min, sec}})
    {:ok, %{datetime | :millisecond => Time.from(usec, :microseconds) |> Time.to_milliseconds}}
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
end

