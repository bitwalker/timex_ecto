defmodule Timex.Ecto.Time do
  @moduledoc """
  Support for using Timex with :time fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :time

  @doc """
  We can let Ecto handle blank input
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Handle casting to Timex.Ecto.Time
  """
  def cast(input) when is_binary(input) do
    case Timex.parse(input, "{ISOtime}") do
      {:ok, %Timex.DateTime{hour: hour,
                            minute: minute,
                            second: second,
                            millisecond: millisecond}} ->
        load({hour, minute, second, millisecond * 1_000})
      {:error, _}     -> :error
    end
  end
  def cast({_, _, _} = timestamp), do: {:ok, timestamp}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => _, "month" => _, "day" => _,
             "hour" => h, "minute" => mm, "second" => s, "ms" => ms,
             "timezone" => _}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(%{"calendar" => _,
             "year" => _, "month" => _, "day" => _,
             "hour" => h, "minute" => mm, "second" => s, "millisecond" => ms,
             "timezone" => _}) do
    load({h, mm, s, ms * 1_000})
  end
  def cast(input) do
    case Ecto.Time.cast(input) do
      {:ok, time} -> load({time.hour, time.minute, time.second, time.usecs})
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({hour, minute, second, usecs}) do
    millis = Time.from(usecs, :microseconds) |> Time.to_milliseconds
    time = %{DateTime.epoch | :hour => hour, :minute => minute, :second => second, :millisecond => millis} |> DateTime.to_timestamp(:epoch)
    {:ok, time}
  end
  def load(_), do: :error

  @doc """
  Convert to the native Ecto representation
  """
  def dump({_mega, _sec, _micro} = timestamp) do
    %DateTime{hour: h, minute: m, second: s, millisecond: ms} = DateTime.from_timestamp(timestamp, :epoch)
    {:ok, {h, m, s, ms * 1_000}}
  end
  def dump(_), do: :error
end

