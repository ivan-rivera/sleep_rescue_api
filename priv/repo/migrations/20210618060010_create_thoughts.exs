defmodule SleepRescue.Repo.Migrations.CreateThoughts do
  use Ecto.Migration

  def change do
    create table(:thoughts) do
      add :negative_thought, :text, null: false
      add :counter_thought, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create constraint("thoughts", :negative_thought, check: "char_length(negative_thought) >= 10")
    create constraint("thoughts", :counter_thought, check: "char_length(counter_thought) >= 10")

  end
end
