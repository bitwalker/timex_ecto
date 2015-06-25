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
  def cast(input) when is_binary(input) do
    case DateFormat.parse(input, "{ISO}") do
      {:ok, datetime} -> {:ok, datetime}
      {:error, _}     -> :error
    end
  end
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime),              do: {:ok, datetime}
  def cast(_), do: :error

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
  def dump(%DateTime{year: y, month: m, day: d, hour: h, minute: min, second: s, ms: ms}) do
    {:ok, {{y, m, d}, {h, min, s, ms * 1_000}}}
  end
  def dump(_), do: :error
end

