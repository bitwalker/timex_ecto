defmodule Timex.Ecto.Test do
  use ExUnit.Case

  test "placeholder" do
    assert true
  end

  test "cast binary time" do
    assert Timex.Ecto.Time.cast("12:30:01") == {:ok, {0, 45001, 0.0}}
  end
end
