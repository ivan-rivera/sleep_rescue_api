defmodule SleepRescue.Users.Night do
  use Ecto.Schema
#  alias SleepRescue.Repo
  import Ecto.Changeset

  # TODO:
  # - utility function (create, delete, update, get)
  # - Add docstrings and types
  # - Add seeds
  # - Add tests

  schema "nights" do
    belongs_to :user, SleepRescue.Users.User
    field :slept, :boolean, null: false
    field :date, :date, null: false
    field :sleep_attempt_datetime, :naive_datetime, null: true
    field :final_awakening_datetime, :naive_datetime, null: true
    field :up_datetime, :naive_datetime, null: true
    field :falling_asleep_duration, :integer, null: true
    field :night_awakenings_duration, :integer, null: true
    field :rating, :integer, null: true
    timestamps()
  end

  def changeset(%__MODULE__{} = night, attrs \\ {}) do
    night
      |> cast(convert(attrs), [
      :slept,
      :date,
      :sleep_attempt_datetime,
      :final_awakening_datetime,
      :up_datetime,
      :falling_asleep_duration,
      :night_awakenings_duration,
      :rating
    ])
    |> validate_required([:slept, :date])
    |> unique_constraint([:user_id, :date])
  end

  defp convert(attrs) do
    with_date = case attrs do
      %{"sleep_attempt_timestamp" => date_timestamp} = dated_attrs ->
        dated_attrs |> Map.put("date", to_date(date_timestamp))
      _ -> %{}
    end
    attrs
      |> Enum.filter(fn {k, _} -> String.contains?(k, "timestamp") end)
      |> Enum.map(fn {k, v} -> {String.replace(k, "timestamp", "datetime"), to_datetime(v)} end)
      |> Enum.into(%{})
      |> Map.merge(attrs)
      |> Map.merge(with_date)
  end

  defp to_datetime(timestamp) do
    timestamp
      |> DateTime.from_unix!
      |> DateTime.to_naive
  end

  defp to_date(timestamp) do
    timestamp
      |> DateTime.from_unix!
      |> DateTime.to_date
  end

end
