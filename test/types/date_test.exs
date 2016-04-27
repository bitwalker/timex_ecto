defmodule Timex.Ecto.Date.Test do
  use ExUnit.Case

  test "cast/1 with DateTime without a timezone" do
    date_time_with_timezone = %Timex.DateTime{timezone: %Timex.TimezoneInfo{abbreviation: "UTC", full_name: "UTC"}}

    assert Timex.Ecto.Date.cast(%Timex.DateTime{timezone: nil}) == {:ok, date_time_with_timezone}
  end

  test "cast/1 with a valid DateTime" do
    date_time_with_timezone = %Timex.DateTime{timezone: %Timex.TimezoneInfo{abbreviation: "UTC", full_name: "UTC"}}
    assert Timex.Ecto.Date.cast(date_time_with_timezone) == {:ok, date_time_with_timezone}
  end

  test "cast/1 with a valid Date" do
    date = %Timex.Date{}
    assert Timex.Ecto.Date.cast(date) == {:ok, date}
  end

  test "cast/1 map with calendar, year, month, day" do
    map = %{"calendar" => nil, "year" => 2016, "month" => 02, "day" => 14 }
    assert Timex.Ecto.Date.cast(map) == %Timex.Date{calendar: :gregorian, day: 14, month: 2, year: 2016}
  end

  test "cast/1 map with castable binaries" do
    date = "2016-02-14"
    assert Timex.Ecto.Date.cast(date) == {:ok, %Timex.Date{calendar: :gregorian, day: 14, month: 2, year: 2016}}
  end

end
