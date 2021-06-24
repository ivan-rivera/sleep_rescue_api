defmodule SleepRescue.Repo.Migrations.CreateIsis do
  use Ecto.Migration

  def change do
    create table(:isis) do
      add :date, :date, null: false
      add :falling_asleep, :integer, null: false
      add :staying_asleep, :integer, null: false
      add :early_wake_up, :integer, null: false
      add :sleep_pattern, :integer, null: false
      add :noticeable, :integer, null: false
      add :worried, :integer, null: false
      add :interference, :integer, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:isis, [:user_id, :date])
  end
end
