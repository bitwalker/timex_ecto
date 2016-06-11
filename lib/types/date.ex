defmodule Timex.Ecto.Date do
  @moduledoc """
  Support for using Timex with :date fields
  """
  use Timex

  @behaviour Ecto.Type

  def type, do: :date

  @doc """
  Handle casting to Timex.Ecto.Date
  """
  def cast(%DateTime{timezone: nil} = datetime), do: {:ok, %{datetime | :timezone => %TimezoneInfo{}}}
  def cast(%DateTime{} = datetime),              do: {:ok, datetime}
  def cast(%Date{} = date), do: {:ok, date}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d,
             "timezone" => _}) do
    date = Timex.date({y,m,d})
    {:ok, date}
  end
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d}) do
    Timex.date({y,m,d})
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
  def load({_year, _month, _day} = date), do: {:ok, Timex.date(date)}
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = datetime) do
    {{year, month, day}, _} = datetime |> Timezone.convert("UTC") |> Timex.to_erlang_datetime
    {:ok, {year, month, day}}
  end
  def dump(%Date{} = date) do
    {date, {_, _, _}} = Timex.to_erlang_datetime(date)
    {:ok, date}
  end
  def dump(_), do: :error

  def autogenerate(precision \\ :sec)
  def autogenerate(_) do
    {date, {_, _, _}} = :erlang.universaltime
    load(date) |> elem(1)
  end


end

