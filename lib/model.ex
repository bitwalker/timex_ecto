defmodule Timex.Ecto.Timestamps do
  @moduledoc """
  Provides a simple way to use Timex with Ecto timestamps.

  # Example

  ```
  defmodule User do
    use Ecto.Schema
    use Timex.Ecto.Timestamps

    schema "user" do
      field :name, :string
      timestamps()
    end
  ```

  By default this will generate a timestamp with seconds precision. If you
  would like to generate a timestamp with more precision you can pass the
  option `usec: true` to the macro.

  ```
  use Timex.Ecto.Timestamps, usec: true
  ```

  For potentially easier use with Phoenix, add the following in `web/web.ex`:

  ```elixir
  def model do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps
    end
  end
  ```

  This will bring Timex timestamps into scope in all your models

  """

  @default_timestamps_opts [type: Timex.Ecto.DateTime]
  defmacro __using__(opts) do
    autogen_args = case Keyword.fetch(opts, :usec) do
      {:ok, true} -> [:usec]
      _           -> [:sec]
    end
    autogenerate_opts = [autogenerate: {Timex.Ecto.DateTime, :autogenerate, autogen_args}]
    escaped_opts = opts |> Keyword.merge(autogenerate_opts) |> Macro.escape
    quote do
      @timestamps_opts unquote(Keyword.merge(escaped_opts, @default_timestamps_opts))
    end
  end
end