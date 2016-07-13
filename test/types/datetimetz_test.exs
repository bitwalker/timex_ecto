defmodule Timex.Ecto.DateTimeWithTimezone.Test do
  use ExUnit.Case

  @example_date Timex.to_datetime(~N[2016-02-14T12:34:00.321])

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, ms" do
    calendar = %{"calendar" => "Calendar.ISO",
                 "year"     => 2016,
                 "month"    => 2,
                 "day"      => 14,
                 "hour"     => 12,
                 "minute"   => 34,
                 "second"   => 0,
                 "ms"       => 321,
                 "timezone" => %{ "full_name" => "Etc/UTC", "abbreviation" => "UTC", "offset_std" => 0, "offset_utc" => 0}
                }
    assert Timex.Ecto.DateTimeWithTimezone.cast(calendar) == {:ok, @example_date}
  end

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, millisecond" do
    calendar = %{"calendar"    => "Calendar.ISO",
                 "year"        => 2016,
                 "month"       => 2,
                 "day"         => 14,
                 "hour"        => 12,
                 "minute"      => 34,
                 "second"      => 0,
                 "millisecond" => 321,
                 "timezone"    => %{ "full_name" => "Etc/UTC", "abbreviation" => "UTC", "offset_std" => 0, "offset_utc" => 0}
                }
    assert Timex.Ecto.DateTimeWithTimezone.cast(calendar) == {:ok, @example_date}
  end


  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, microsecond" do
    calendar = %{"calendar"    => "Calendar.ISO",
                 "year"        => 2016,
                 "month"       => 2,
                 "day"         => 14,
                 "hour"        => 12,
                 "minute"      => 34,
                 "second"      => 0,
                 "microsecond" => {321_000,3},
                 "time_zone"   => "Etc/UTC",
                 "zone_abbr"   => "UTC",
                 "std_offset"  => 0,
                 "utc_offset"  => 0
                }
    assert Timex.Ecto.DateTimeWithTimezone.cast(calendar) == {:ok, @example_date}
  end

  test "cast/1 map with castable binaries" do
    date = "2016-02-14T12:34:00.321+00:00"
    assert Timex.Ecto.DateTimeWithTimezone.cast(date) == {:ok, @example_date}
  end

  test "cast/1 map with not castable binaries" do
    assert Timex.Ecto.DateTimeWithTimezone.cast("not castable") == :error
  end
end
