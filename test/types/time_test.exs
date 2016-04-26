defmodule Timex.Ecto.TimeTest do
	use ExUnit.Case

	alias Timex.Ecto.Time

	test "cast binary time" do
		assert Time.cast("12:30:01") == {:ok, {0, 45001, 0.0}}
	end

	test "cast invalid binary time" do
		assert Time.cast("invalid") == :error
	end

	test "cast on timestamp tuple" do
		assert Time.cast({0, 45001, 0.0}) == {:ok, {0, 45001, 0.0}}
	end

	test "cast on invalid timestamp tuple" do
		assert Time.cast({"a","b","c"}) == :error
	end

	test "cast on calendar map" do
		calendar = %{"calendar" => :gregorian,
								 "year" => 1985,
								 "month" => 10,
								 "day" => 25,
								 "hour" => 12,
								 "minute" => 30,
								 "second" => 1,
								 "millisecond" => 0,
								 "timezone" => nil}
		assert Time.cast(calendar) == {:ok, {0, 45001, 0.0}}

		calendar = calendar |> Map.delete("millisecond") |> Map.put("ms", 0)
		assert Time.cast(calendar) == {:ok, {0, 45001, 0.0}}
	end
end
