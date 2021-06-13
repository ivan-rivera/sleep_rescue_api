defmodule SleepRescue.Repo.Migrations.CreateGoals do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :metric, :string, null: false
      add :duration, :integer, null: false
      add :threshold, :float, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:goals, [:user_id, :metric, :duration])
  end
end
