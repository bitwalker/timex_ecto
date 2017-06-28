defmodule Timex.Ecto.TimestampWithTimezone.Test do
  use ExUnit.Case
  
  use Timex

  @utc_timezone %{ "full_name" => "Etc/UTC", "abbreviation" => "UTC", "offset_std" => 0, "offset_utc" => 0}
  @example_date Timex.to_datetime(~N[2017-06-27T13:31:43.763])
  
  setup do
    local_timezone = case Timezone.local() do
      {:error, _} -> @utc_timezone
      tz -> tz
    end
    {:ok, [local: local_timezone]}
  end

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, ms", %{local: local} do
    calendar = %{"calendar" => "Calendar.ISO",
                 "year"     => 2017,
                 "month"    => 6,
                 "day"      => 27,
                 "hour"     => 13,
                 "minute"   => 31,
                 "second"   => 43,
                 "ms"       => 763,
                 "timezone" => @utc_timezone
                }
    assert Timex.Ecto.TimestampWithTimezone.cast(calendar) == {:ok, Timezone.convert(@example_date, local)}
  end

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, millisecond", %{local: local} do
    calendar = %{"calendar"    => "Calendar.ISO",
                 "year"        => 2017,
                 "month"       => 6,
                 "day"         => 27,
                 "hour"        => 13,
                 "minute"      => 31,
                 "second"      => 43,
                 "millisecond" => 763,
                 "timezone"    => @utc_timezone
                }
    assert Timex.Ecto.TimestampWithTimezone.cast(calendar) == {:ok, Timezone.convert(@example_date, local)}
  end

  test "cast/1 map with calendar, year, month, day, hour, minute, seconds, microsecond", %{local: local} do
    calendar = %{"calendar"    => "Calendar.ISO",
                 "year"        => 2017,
                 "month"       => 6,
                 "day"         => 27,
                 "hour"        => 13,
                 "minute"      => 31,
                 "second"      => 43,
                 "microsecond" => {763_000, 3},
                 "time_zone"   => "Etc/UTC",
                 "zone_abbr"   => "UTC",
                 "std_offset"  => 0,
                 "utc_offset"  => 0
                }
    assert Timex.Ecto.TimestampWithTimezone.cast(calendar) == {:ok, Timezone.convert(@example_date, local)}
  end

  test "cast/1 map with castable binaries", %{local: local} do
    date = "2017-06-27T13:31:43.763+00:00"
    assert Timex.Ecto.TimestampWithTimezone.cast(date) == {:ok, Timezone.convert(@example_date, local)}
  end

  test "cast/1 map with not castable binaries" do
    assert Timex.Ecto.TimestampWithTimezone.cast("not castable") == :error
  end
  
  test "load/1 tuple with {{year, month, day}, {hour, min, sec, usec}} as DateTime", %{local: local} do
    assert Timex.Ecto.TimestampWithTimezone.load({{2017, 6, 27}, {13, 31, 43, 763000}}) == {:ok, Timezone.convert(@example_date, local)}
  end
  
  test "load/1 tuple with {{year, month, day}, {hour, min, sec}} as DateTime", %{local: local} do
    assert Timex.Ecto.TimestampWithTimezone.load({{2017, 6, 27}, {13, 31, 43}}) == {:ok, Timezone.convert(Timex.to_datetime(~N[2017-06-27T13:31:43]), local)}
  end

  test "dump/1 DateTime to tuple with {{year, month, day}, {hour, min, sec, usec}}" do
    assert Timex.Ecto.TimestampWithTimezone.dump(@example_date) == {:ok, {{2017, 6, 27}, {13, 31, 43, 763000}}}
  end
end
