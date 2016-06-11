defmodule Timex.Ecto.DateTimeWithTimezone.Test do
  use ExUnit.Case

  test "cast/1 with DateTime without a timezone" do
    date_time_with_timezone = %Timex.DateTime{timezone: %Timex.TimezoneInfo{abbreviation: "UTC", full_name: "UTC"}}
    assert Timex.Ecto.DateTimeWithTimezone.cast(%Timex.DateTime{timezone: nil}) == {:ok, date_time_with_timezone}
  end

  test "cast/1 with a valid DateTime" do
    date_time = Timex.DateTime.now
    assert Timex.Ecto.DateTimeWithTimezone.cast(date_time) == {:ok, date_time}
  end

  @example_date %Timex.DateTime{
                  calendar: :gregorian,
                  year: 2016,
                  month: 2,
                  day: 14,
                  hour: 12,
                  minute: 34,
                  second: 00,
                  millisecond: 321,
                  timezone: %Timex.TimezoneInfo{abbreviation: "UTC", full_name: "UTC"}
                }

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, ms" do
    calendar = %{"calendar" => "gregorian",
                 "year"     => 2016,
                 "month"    => 02,
                 "day"      => 14,
                 "hour"     => 12,
                 "minute"   => 34,
                 "second"   => 00,
                 "ms"       => 321,
                 "timezone" => %{ "full_name" => "UTC", "abbreviation" => "UTC", "offset_std" => 0, "offset_utc" => 0}
                }
    expected = %{@example_date | :timezone => %{@example_date.timezone | :from => nil, :until => nil}}
    assert Timex.Ecto.DateTimeWithTimezone.cast(calendar) == {:ok, expected}
  end

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, millisecond" do
    calendar = %{"calendar"    => "gregorian",
                 "year"        => 2016,
                 "month"       => 02,
                 "day"         => 14,
                 "hour"        => 12,
                 "minute"      => 34,
                 "second"      => 00,
                 "millisecond" => 321,
                 "timezone"    => %{ "full_name" => "UTC", "abbreviation" => "UTC", "offset_std" => 0, "offset_utc" => 0}
                }
    expected = %{@example_date | :timezone => %{@example_date.timezone | :from => nil, :until => nil}}
    assert Timex.Ecto.DateTimeWithTimezone.cast(calendar) == {:ok, expected}
  end

  test "cast/1 map with castable binaries" do
    date = "2016-02-14T12:34:00.321+00:00"
    assert Timex.Ecto.DateTimeWithTimezone.cast(date) == {:ok, @example_date}
  end

  test "cast/1 map with not castable binaries" do
    assert Timex.Ecto.DateTimeWithTimezone.cast("not castable") == :error
  end
end
