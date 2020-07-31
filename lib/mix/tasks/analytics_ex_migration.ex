defmodule Mix.Tasks.Analytics.Gen.Migration do
  # This task was largely taken from https://github.com/kipcole9/money_sql/blob/master/lib/mix/tasks/money_postgres_migration.ex
  # Thank you kindly: https://elixirforum.com/u/kip/summary

  use Mix.Task

  import Mix.Ecto
  import Mix.Generator
  import Macro, only: [camelize: 1]

  def run(args) do
    repos = parse_repo(args)
    name = "create_metrics"
    IO.inspect(repos)

    for repo <- repos do
      ensure_repo(repo, args)
      path = Path.relative_to(Ecto.Migrator.migrations_path(repo), Mix.Project.app_path())
      file = Path.join(path, "#{timestamp()}_#{name}.exs")
      create_directory(path)
      assigns = [mod: Module.concat([repo, Migrations, camelize(name)])]

      content = migration_template(assigns)
      create_file(file, content)

      if open?(file) and Mix.shell().yes?("Do you want to run this migration?") do
        Mix.Task.run("ecto.migrate", [repo])
      end
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  embed_template(:migration, """
  defmodule <%= inspect @mod %> do
    use Ecto.Migration

    def change do
      create table(:metrics, primary_key: false) do
        add :date, :date, primary_key: true
        add :path, :string, primary_key: true
        add :counter, :integer, default: 0
      end
    end
  end
  """)
end
