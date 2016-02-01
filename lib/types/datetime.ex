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
  def cast(input) do
    case Ecto.DateTime.cast(input) do
      {:ok, datetime} -> load({datetime.year, datetime.month, datetime.day}, {datetime.hour, datetime.min, datetime.sec, datetime.usec})
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({{year, month, day}, {hour, min, sec, usec}}) do
    datetime = Date.from({{year, month, day}, {hour, min, sec}})
    {:ok, %{datetime | :ms => Time.from(usec, :usecs) |> Time.to_msecs}}
  end
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = date) do
    %DateTime{year: y, month: m, day: d, hour: h, minute: min, second: s, ms: ms} = Timezone.convert(date, "UTC")
    {:ok, {{y, m, d}, {h, min, s, round(ms * 1_000)}}}
  end
  def dump(_), do: :error
end

