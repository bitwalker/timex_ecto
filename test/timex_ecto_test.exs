if Code.ensure_loaded?(Postgrex) do

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

  defmodule EctoTest.App do
    use Application

    def start(_type, _args) do
      import Supervisor.Spec
      children = [
        worker(EctoTest.Repo, [])
      ]
      Supervisor.start_link(children, name: __MODULE__, strategy: :one_for_one)
    end
  end

  defmodule EctoTest.Migrations.CustomTypes do
    use Ecto.Migration

    def up do
      execute """
      CREATE TYPE datetimetz AS (
      dt timestamptz,
      tz varchar
      );
      """
    end

    def down do
      execute """
      DROP TYPE datetimetz;
      """
    end
  end

  defmodule EctoTest.Migrations.Setup do
    use Ecto.Migration

    def change do
      create table(:users, primary_key: true) do
        add :name, :string
        add :date_test, :date
        add :time_test, :time
        add :datetime_test, :naive_datetime
        add :datetimetz_test, :datetimetz
        add :timestamptz_test, :timestamptz

        timestamps()
      end
    end
  end

  defmodule Timex.Ecto.Test do
    use ExUnit.Case, async: true
    use Timex

    alias EctoTest.{User, Repo}

    import Ecto.Query

    setup_all do
      Application.ensure_all_started(:postgrex)
      Application.ensure_all_started(:ecto)
      EctoTest.App.start(:normal, [])
      Ecto.Migrator.run(Repo, [{0, EctoTest.Migrations.CustomTypes}, {1, EctoTest.Migrations.Setup}], :up, [all: true])
      Ecto.Adapters.SQL.Sandbox.mode(EctoTest.Repo, :manual)
    end

    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoTest.Repo)
    end

    test "integrates successfully with Ecto" do
      time        = Duration.from_clock({12, 30, 15, 120})
      date        = Timex.today
      datetime    = Timex.now
      datetimetz  = Timezone.convert(datetime, "Europe/Copenhagen")
      timestamptz = Timex.local
      u = %User{name: "Paul",
                date_test: date,
                time_test: time,
                datetime_test: datetime,
                datetimetz_test: datetimetz,
                timestamptz_test: timestamptz}
      Repo.insert!(u)

      query =
        from u in User,
        select: u

      [same_user] = Repo.all(query)
      assert same_user.name == "Paul"
      assert same_user.date_test == date
      assert same_user.time_test == time

      # To avoid microsecond mismatches on a CI server
      assert same_user.datetime_test |> DateTime.to_string == datetime |> DateTime.to_string
      assert same_user.datetimetz_test |> DateTime.to_string == datetimetz |> DateTime.to_string
      assert same_user.timestamptz_test |> DateTime.to_string == timestamptz |> DateTime.to_string

      query =
        from u in User,
        where: u.datetimetz_test == type(^Timezone.convert(datetime, "Europe/Copenhagen"), Timex.Ecto.DateTimeWithTimezone),
        select: u
      [%User{datetimetz_test: ^datetimetz}] = Repo.all(query)
    end
  end
end
