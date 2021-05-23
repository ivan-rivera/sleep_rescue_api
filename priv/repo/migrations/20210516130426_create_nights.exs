defmodule SleepRescue.Repo.Migrations.CreateNights do
  use Ecto.Migration

  @rating_constraint "rating BETWEEN 1 AND 10"
  @sleep_attempt_date_constraint "sleep_attempt_datetime::DATE - DATE::DATE BETWEEN 0 AND 2"
  @final_awakening_datetime_constraint "sleep_attempt_datetime < final_awakening_datetime"
  @up_datetime_constraint "final_awakening_datetime <= up_datetime"
  @duration_constraint "falling_asleep_duration >= 0 AND night_awakenings_duration >= 0"
  @sleep_zero_or_more_mins_constraint """
  sleep_attempt_datetime +
  ((falling_asleep_duration + night_awakenings_duration) || ' minutes')::INTERVAL <
  final_awakening_datetime
  """

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
    create constraint("nights", :rating_range, check: @rating_constraint)
    create constraint("nights", :sleep_attempt_date, check: @sleep_attempt_date_constraint)
    create constraint("nights", :final_awakening_datetime, check: @final_awakening_datetime_constraint)
    create constraint("nights", :up_datetime, check: @up_datetime_constraint)
    create constraint("nights", :duration, check: @duration_constraint)
    create constraint("nights", :slept_zero_or_more_minutes, check: @sleep_zero_or_more_mins_constraint)
  end
end
