defmodule Timex.Ecto.Date.Test do
  use ExUnit.Case
  doctest Timex.Ecto.Date

  test "cast/1 map with calendar, year, month, day" do
    map = %{"calendar" => nil, "year" => 2016, "month" => 02, "day" => 14 }
    assert Timex.Ecto.Date.cast(map) == {:ok, Timex.to_date({2016,2,14})}
  end

  test "cast/1 with a binary in the 'YYYY-MM-DD' format" do
    date = "2016-02-14"
    assert Timex.Ecto.Date.cast(date) == {:ok, Timex.to_date({2016,2,14})}
  end

  test "cast/1 map with year, month, day as integer values" do
    map = %{"year" => 2016, "month" => 02, "day" => 14 }
    assert Timex.Ecto.Date.cast(map) == {:ok, Timex.to_date({2016,2,14})}
  end

  test "cast/1 map with year, month, day as binary values" do
    map = %{"year" => "2016", "month" => "02", "day" => "14" }
    assert Timex.Ecto.Date.cast(map) == {:ok, Timex.to_date({2016,2,14})}
  end

  test "load/1 with an Ecto.Date should return a Timex date" do
    ecto_date = Ecto.Date.from_erl({2017, 2, 12})
    assert Timex.Ecto.Date.load(ecto_date) == {:ok, Timex.to_date({2017, 2, 12})}
  end
end
