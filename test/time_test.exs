defmodule Timex.Ecto.Test do
  use ExUnit.Case

  test "load datetime" do
    assert Timex.Ecto.Time.load({12, 45, 35, 1}) == {:ok, {0, 45935, 1.0}}
  end

  test "dump datetime" do
    assert Timex.Ecto.Time.dump({1, 2, 3}) == {:ok, {13, 46, 42, 0}}
  end

end

