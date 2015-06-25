defmodule Timex.Ecto.Time do
  @moduledoc """
  Support for using Timex with :time fields
  """
  use Timex
  alias Ecto.Time

  @behaviour Ecto.Type

  def type, do: :time

  @doc """
  We can let Ecto handle blank input
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Handle casting to Timex.Ecto.DateTimeWithTimezone
  """
  def cast(input) when is_binary(input) do
    case DateFormat.parse(input, "{ISOtime}") do
      {:ok, datetime} ->
        datetime = %{datetime | :timezone => %TimezoneInfo{}}
        {:ok, Date.to_secs(datetime) |> Time.add(Time.epoch)}
      {:error, _}     -> :error
    end
  end
  def cast({_, _, _} = timestamp), do: {:ok, timestamp}
  def cast(_), do: :error

  @doc """
  Load from the native Ecto representation
  """
  def load({hour, minute, second, usecs}) do
    time = %{Date.epoch | :hour => hour, :minute => minute, :second => second, :ms => usecs / 1_000} |> Date.to_timestamp(:epoch)
    {:ok, time}
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump({_mega, _sec, _micro} = timestamp) do
    %DateTime{hour: h, minute: m, second: s, ms: ms} = timestamp |> Date.from(:timestamp, :epoch)
    {:ok, {h, m, s, ms * 1_000}}
  end
  def dump(_), do: :error
end

