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
  def cast(%Date{} = date), do: {:ok, date}
  # Support embeds_one/embeds_many
  def cast(%{"calendar" => _,
             "year" => y, "month" => m, "day" => d}) do
    date = Timex.to_date({y,m,d})
    {:ok, date}
  end
  def cast(date) when is_binary(date) do
    case Ecto.Date.cast(date) do
      {:ok, d} -> load({d.year,d.month,d.day})
      :error -> :error
    end
  end
  def cast(datetime) do
    case Timex.to_date(datetime) do
      {:error, _} ->
        case Ecto.Date.cast(datetime) do
          {:ok, date} -> load({date.year, date.month, date.day})
          :error -> :error
        end
      %Date{} = d -> {:ok, d}
    end
  end

  @doc """
  Creates a Timex.Date from from a passed in date.

  Returns `{:ok, Timex.Date}` when successful.

  Returns `:error` if the type passed in is either not an erl date nor Ecto.Date

  ## Examples
     Using an Ecto.Date:

      iex> Ecto.Date.from_erl({2017, 2, 1})
      ...> |> Timex.Ecto.Date.load
      {:ok, ~D[2017-02-01]}

    Using an erl date:

      iex> Timex.Ecto.Date.load({2017, 2, 1})
      {:ok, ~D[2017-02-01]}
  """
  def load({_year, _month, _day} = date), do: {:ok, Timex.to_date(date)}
  def load(%Ecto.Date{} = date), do: {:ok, Ecto.Date.to_erl(date) |> Timex.to_date}
  def load(_), do: :error

  @doc """
  Convert to native Ecto representation
  """
  def dump(%DateTime{} = datetime) do
    case Timex.Timezone.convert(datetime, "Etc/UTC") do
      %DateTime{year: y, month: m, day: d} -> {:ok, {y,m,d}}
      {:error, _} -> :error
    end
  end
  def dump(datetime) do
    case Timex.to_erl(datetime) do
      {:error, _}   -> :error
      {{_,_,_}=d,_} -> {:ok, d}
      {_,_,_} = d   -> {:ok, d}
    end
  end

  def autogenerate(precision \\ :sec)
  def autogenerate(_) do
    {date, {_, _, _}} = :erlang.universaltime
    load(date) |> elem(1)
  end
end
