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
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime),              do: {:ok, datetime}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d,
             "hour" => _, "minute" => _, "second" => _, "ms" => _,
             "timezone" => %{"full_name" => tz_abbr}}) do
    date = Date.from({y,m,d}, tz_abbr)
    {:ok, date}
  end
  def cast(input) do
    case Ecto.Date.cast(input) do
      {:ok, date} -> load({date.year, date.month, date.day})
      :error -> :error
    end
  end

  @doc """
  Load from the native Ecto representation
  """
  def load({_year, _month, _day} = date), do: {:ok, Date.from(date)}
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = datetime) do
    {{year, month, day}, _} = datetime |> Timezone.convert("UTC") |> DateConvert.to_erlang_datetime
    {:ok, {year, month, day}}
  end
  def dump(_), do: :error
end

