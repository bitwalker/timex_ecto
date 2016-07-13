defmodule Timex.Ecto.TimeTest do
  use ExUnit.Case

  use Timex
  alias Timex.Ecto.Time

  test "cast binary time" do
    assert Time.cast("12:30:01") == {:ok, Duration.from_erl({0, 45001, 0})}
  end

  test "cast invalid binary time" do
    assert Time.cast("invalid") == :error
  end

  test "cast on timestamp tuple" do
    assert Time.cast({0, 45001, 0.0}) == {:ok, Duration.from_erl({0, 45001, 0})}
  end

  test "cast on invalid timestamp tuple" do
    assert Time.cast({"a","b","c"}) == :error
  end

  test "cast on calendar map" do
    calendar = %{"calendar" => :gregorian,
                 "year" => 1986,
                 "month" => 10,
                 "day" => 25,
                 "hour" => 12,
                 "minute" => 30,
                 "second" => 1,
                 "millisecond" => 0,
                 "timezone" => nil}
    assert Time.cast(calendar) == {:ok, Duration.from_erl({0, 45001, 0})}

    calendar = calendar |> Map.delete("millisecond") |> Map.put("ms", 0)
    assert Time.cast(calendar) == {:ok, Duration.from_erl({0, 45001, 0})}

    calendar = %{"calendar" => :gregorian,
                 "year" => 1986,
                 "month" => 10,
                 "day" => 25,
                 "hour" => 12,
                 "minute" => 30,
                 "second" => 1,
                 "microsecond" => {0,0},
                 "time_zone" => "Etc/UTC",
                 "zone_abbr" => "UTC",
                 "utc_offset" => 0,
                 "std_offset" => 0}
    assert Time.cast(calendar) == {:ok, Duration.from_erl({0, 45001, 0})}
  end

  test "cast on date" do
    date = %Ecto.Time{hour: 12, min: 30, sec: 1}
    assert Time.cast(date) == {:ok, Duration.from_erl({0, 45001, 0})}
  end

  test "load datetime" do
    assert Timex.Ecto.Time.load({12, 45, 35, 1}) == {:ok, Duration.from_erl({0, 45935, 1})}
  end

  test "dump datetime" do
    d = Duration.from_erl({0,50705,3})
    assert Timex.Ecto.Time.dump(d) == {:ok, {14, 5, 5, 3}}
    assert Timex.Ecto.Time.dump({0,50705,3}) == {:ok, {14, 5, 5, 3}}
  end
end
