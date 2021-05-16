defmodule SleepRescue.Repo.Migrations.CreateNights do
  use Ecto.Migration

  def change do
    create table(:nights) do
      add :slept, :boolean, default: true, null: false
      add :date, :date, null: false
      add :sleep_attempt_datetime, :naive_datetime, null: true
      add :falling_asleep_duration, :integer, null: true
      add :night_awakenings_duration, :integer, null: true
      add :final_awakening_datetime, :naive_datetime, null: true
      add :up_datetime, :naive_datetime, null: true
      add :rating, :integer, null: true
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:nights, [:user_id, :date])
  end
end
