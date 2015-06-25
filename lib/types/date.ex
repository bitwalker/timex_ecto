defmodule Timex.Ecto.Date do
  @moduledoc """
  Support for using Timex with :date fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :date

  @doc """
  We can let Ecto handle blank input
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Handle casting to Timex.Ecto.Date
  """
  def cast(input) when is_binary(input) do
    case DateFormat.parse(input, "{ISOdate}") do
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
  def load({_year, _month, _day} = date), do: {:ok, Date.from(date)}
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = datetime) do
    {{year, month, day}, _} = DateConvert.to_erlang_datetime(datetime)
    {:ok, {year, month, day}}
  end
  def dump(_), do: :error
end

