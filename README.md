## Timex Plugin for Ecto

[![Master](https://travis-ci.org/bitwalker/timex_ecto.svg?branch=master)](https://travis-ci.org/bitwalker/timex_ecto)
[![Hex.pm Version](http://img.shields.io/hexpm/v/timex_ecto.svg?style=flat)](https://hex.pm/packages/timex_ecto)

## Getting Started

Learn how to add `timex_ecto` to your Elixir project and start using it.

**NOTE**: You must use Timex 3.0.2 or greater with timex_ecto 3.x!

### Adding timex_ecto To Your Project

To use timex_ecto with your projects, edit your `mix.exs` file and add it as a dependency:

```elixir
def application do
 [ applications: [:timex_ecto, ...], ...]
end

defp deps do
  [{:timex, "~> 3.0"},
   {:timex_ecto, "~> 3.0"}]
end
```

### Adding Timex types to your Ecto models

```elixir
defmodule User do
  use Ecto.Schema

  schema "users" do
    field :name, :string
    # Stored as an ISO date (year-month-day), reified as Date
    field :a_date,        Timex.Ecto.Date # Timex version of :date
    # Stored as an ISO time (hour:minute:second.fractional), reified as Timex.Duration
    field :a_time,        Timex.Ecto.Time # Timex version of :time
    # Stored as an ISO 8601 datetime in UTC (year-month-day hour:minute:second.fractional),
    # reified as DateTime in UTC
    field :a_datetime,    Timex.Ecto.DateTime # Timex version of :datetime
    # DateTimeWithTimezone is a special case, please see the `Using DateTimeWithTimezone` section!
    # Stored as a tuple of ISO 8601 datetime and timezone name ((year-month-day hour:minute:second.fractional, timezone)),
    # reified as DateTime in stored timezone
    field :a_datetimetz,  Timex.Ecto.DateTimeWithTimezone # A custom datatype (:datetimetz) implemented by Timex
    # Stored as an ISO 8601 datetime in UTC (year-month-day hour:minute:second.fractional),
    # reified as DateTime in local timezone
    field :a_timestamptz, Timex.Ecto.TimestampWithTimezone # Timex version of :timestamptz
  end
end
```

## Using DateTimeWithTimezone

Please see the documentation [here](https://hexdocs.pm/timex_ecto/Timex.Ecto.DateTimeWithTimezone.html#content).

### Change the default timestamps type of Ecto's `timestamps` macro

According to the documentation for [Ecto.Schema.timestamps/1](https://hexdocs.pm/ecto/Ecto.Schema.html#timestamps/1), it is simple to change the default timestamps type to others by setting `@timestamps_opts`. For example, you can use `Timex.Ecto.TimestampWithTimezone` with the following options.

```elixir
defmodule User do
  use Ecto.Schema

  @timestamps_opts [type: Timex.Ecto.TimestampWithTimezone,
                    autogenerate: {Timex.Ecto.TimestampWithTimezone, :autogenerate, []}]

  schema "users" do
    field :name, :string
    timestamps()
  end
end
```

### Using Timex with Ecto's `timestamps` macro

Super simple! Your timestamps will now be `Timex.Ecto.DateTime` structs instead of `Ecto.DateTime` structs.

```elixir
defmodule User do
  use Ecto.Schema

  @timestamps_opts [type: Timex.Ecto.DateTime]

  schema "users" do
    field :name, :string
    timestamps()
  end
end
```

### Using with Phoenix

Phoenix allows you to apply defaults globally to Ecto models via `web/web.ex` by changing the `model` function like so:

```elixir
def model do
  quote do
    use Ecto.Schema

    @timestamps_opts [type: Timex.Ecto.DateTime]
  end
end
```

By doing this, you bring the Timex timestamps into scope in all your models.


### Precision

By default Timex will generate a timestamp to the nearest second. If you would
like to generate a timestamp with more precision you can pass the option
`usec: true` to the macro. This will configure Timex to generate timestamps
down to the microsecond level of precision.

```elixir
@timestamps_opts [type: Timex.Ecto.DateTime,
                  autogenerate: {Timex.Ecto.DateTime, :autogenerate, [:usec]}]
```


## Example Usage

The following is a simple test app I built for vetting this plugin:

```elixir
defmodule EctoTest.Repo do
  use Ecto.Repo, otp_app: :timex_ecto_test
end

defmodule EctoTest.User do
  use Ecto.Schema

  @timestamps_opts [type: Timex.Ecto.DateTime,
                    autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}]

  schema "users" do
    field :name, :string
    field :date_test,        Timex.Ecto.Date
    field :time_test,        Timex.Ecto.Time
    field :datetime_test,    Timex.Ecto.DateTime
    field :datetimetz_test,  Timex.Ecto.DateTimeWithTimezone
    field :timestamptz_test, Timex.Ecto.TimestampWithTimezone

    timestamps()
  end
end

defmodule EctoTest do
  import Ecto.Query
  use Timex

  alias EctoTest.User
  alias EctoTest.Repo

  def seed do
    time        = Duration.now
    date        = Timex.today
    datetime    = Timex.now
    datetimetz  = Timezone.convert(datetime, "Europe/Copenhagen")
    timestamptz = Timex.local
    u = %User{name: "Paul", date_test: date, time_test: time, datetime_test: datetime, datetimetz_test: datetimetz, timestamptz_test: timestamptz}
    Repo.insert!(u)
  end

  def all do
    query = from u in User,
            select: u
    Repo.all(query)
  end
end

defmodule EctoTest.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    tree = [worker(EctoTest.Repo, [])]
    opts = [name: EctoTest.Sup, strategy: :one_for_one]
    Supervisor.start_link(tree, opts)
  end
end
```

And the results:

```elixir
iex(1)> EctoTest.seed

14:45:43.461 [debug] INSERT INTO "users" ("date_test", "datetime_test", "datetimetz_test", "name", "time_test") VALUES ($1, $2, $3, $4, $5) RETURNING "id" [{2015, 6, 25}, {{2015, 6, 25}, {19, 45, 43, 457000}}, {{{2015, 6, 25}, {21, 45, 43, 457000}}, "Europe/Copenhagen"}, "Paul", {19, 45, 43, 457000}] OK query=3.9ms
%EctoTest.User{__meta__: %Ecto.Schema.Metadata{source: "users",
  state: :loaded},
 date_test: ~D[2015-06-25],
 datetime_test: #<DateTime(2015-06-25T21:45:43.457Z Etc/UTC)>,
 datetimetz_test: #<DateTime(2015-06-25T21:45:43.457+02:00 Europe/Copenhagen)>,
 timestamptz_test: #<DateTime(2015-06-25T13:45:43.457-06:00 America/Chicago)>,
 name: "Paul", time_test: #<Duration(P45Y6M6DT19H45M43.456856S)>}
iex(2)> EctoTest.all

14:45:46.721 [debug] SELECT u0."id", u0."name", u0."date_test", u0."time_test", u0."datetime_test", u0."datetimetz_test" FROM "users" AS u0 [] OK query=0.7ms
[%EctoTest.User{__meta__: %Ecto.Schema.Metadata{source: "users",
   state: :loaded},
  date_test: ~D[2015-06-25],
  datetime_test: #<DateTime(2015-06-25T21:45:43.457Z Etc/UTC)>,
  datetimetz_test: #<DateTime(2015-06-25T21:45:43.457+02:00 Europe/Copenhagen)>,
  timestamptz_test: #<DateTime(2015-06-25T13:45:43.457-06:00 America/Chicago)>,
  name: "Paul", time_test: #<Duration(PT19H45M43S)>}]
iex(3)>
```

## Additional Documentation

Documentation for Timex and timex_ecto are available
[here], and on [hexdocs].

[here]: https://hexdocs.pm/timex
[hexdocs]: http://hexdocs.pm/timex_ecto/

## License

This project is MIT licensed. See the LICENSE file in this repo.
