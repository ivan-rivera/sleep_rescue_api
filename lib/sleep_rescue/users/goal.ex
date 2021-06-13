defmodule SleepRescue.Users.Goal do
  @moduledoc """
  User goals schema and functions
  """

  use Ecto.Schema
  alias SleepRescue.Repo
  alias SleepRescue.Users.{User, Night}
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @today Date.utc_today()
  @accepted_metrics [
    "Sleep duration",
    "Time to fall asleep",
    "Time awake at night",
    "Efficiency",
    "Rating"
  ]

  @default_goals [
    %{"metric" => "Sleep duration", "duration" => 30, "threshold" => 6.5},
    %{"metric" => "Efficiency", "duration" => 30, "threshold" => 0.85},
    %{"metric" => "Rating", "duration" => 30, "threshold" => 0.7},
  ]

  @derive {Jason.Encoder, only: [:id, :metric, :duration, :threshold]}
  schema "goals" do
    belongs_to :user, User
    field :metric, :string, null: false
    field :duration, :integer, null: false
    field :threshold, :float, null: false
    timestamps()
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = goal, attrs \\ {}) do
    goal
    |> cast(attrs, [:metric, :duration, :threshold])
    |> validate_required([:metric, :duration, :threshold])
    |> validate_number(:threshold, greater_than_or_equal_to: 0)
    |> validate_inclusion(:duration, 0..180)
    |> validate_inclusion(:metric, @accepted_metrics)
  end

  @doc """
  List user-owned goals together with the corresponding actual results
  """
  @spec list_goals(%User{}, %DateTime{}) :: map()
  def list_goals(%User{} = user, today \\ @today) do
    case from(g in __MODULE__, where: g.user_id == ^user.id) |> Repo.all() do
      [] -> {:ok, []}
      user_goals ->
        max_duration = Enum.map(user_goals, fn g -> g.duration end) |> Enum.max()
        user_nights =
          user
          |> Night.list_nights(max_duration + 1, today)
          |> Enum.map(&Night.summarise_night/1)
        { :ok,
          user_goals
          |> Enum.map(&Map.from_struct/1)
          |> Enum.map(fn g ->
            user_nights
            |> Enum.filter(fn {d, _} -> Date.compare(d, Date.add(today, -g.duration - 1)) == :gt end)
            |> assemble_report(g)
          end)
        }
    end
  end

  @doc """
  Create a new goal
  """
  @spec create_goal(%User{}, map()) :: {:ok, map()} | {:error, map()}
  def create_goal(%User{} = user, %{"metric" => _, "duration" => _, "threshold" => _} = attrs) do
    user
    |> Ecto.build_assoc(:goals)
    |> changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Create preset goals for a user
  """
  @spec create_default_goals(%User{}) :: {:ok, map()} | {:error, map()}
  def create_default_goals(%User{} = user) do
    Enum.map(@default_goals , fn g -> create_goal(user, g) end)
  end

  defp get_results(nights, metric) do
    if length(nights) > 0 do
      nights
      |> Night.aggregate_nights()
      |> format_night_aggregation()
      |> Map.get(metric)
    else
      nil
    end
  end

  @doc """
  Delete a goal
  """
  @spec delete(integer(), %User{}) :: {:ok, map()} | {:error, map()}
  def delete(id, user) do
    case Repo.get_by(__MODULE__, id: id, user_id: user.id) do
      nil -> {:error, "failed to fetch goal"}
      goal -> Repo.delete(goal)
    end
  end

  defp format_night_aggregation(summary) do
    %{
      "Sleep duration" => summary["mins_slept"] / 60,
      "Time to fall asleep" => summary["mins_to_fall_asleep"],
      "Time awake at night" => summary["mins_awake_at_night"],
      "Efficiency" => summary["efficiency"],
      "Rating" => summary["rating"] / 10
    }
  end

  defp assemble_report(nights, goal) do
    %{
      "id" => goal.id,
      "metric" => goal.metric,
      "duration" => goal.duration,
      "threshold" => goal.threshold,
      "completed" => length(nights),
      "actual" => get_results(nights, goal.metric)
    }
  end

end
