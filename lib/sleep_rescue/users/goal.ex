defmodule SleepRescue.Users.Goal do
  @moduledoc """
  User goals schema and functions
  """

  use Ecto.Schema
  alias SleepRescue.Repo
  alias SleepRescue.Users.{User, Night}
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger

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
  def list_goals(%User{} = user, yesterday \\ get_yesterday()) do
    case from(g in __MODULE__, where: g.user_id == ^user.id) |> Repo.all() do
      [] -> {:ok, []}
      user_goals ->
        max_duration = get_max_goal_duration(user_goals)
        user_nights = user
          |> Night.list_nights(max_duration, yesterday)
          |> Enum.map(&Night.summarise_night/1)
        { :ok,
          user_goals
          |> Enum.map(&Map.from_struct/1)
          |> Enum.map(fn goal -> user_nights
            |> filter_nights_by_goal(goal, yesterday)
            |> assemble_report(goal)
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

  defp get_night_stats(nights, metric) do
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

  def assemble_report(nights, goal) do
    night_count = length(nights)
    if night_count > goal.duration do
        Logger.error("night lengths exceed required duration -- nights: #{night_count}, duration: #{goal.duration}")
      end
    %{
      "id" => goal.id,
      "metric" => goal.metric,
      "duration" => goal.duration,
      "threshold" => goal.threshold,
      "completed" => night_count,
      "actual" => get_night_stats(nights, goal.metric)
    }
  end

  defp get_max_goal_duration(goals), do: goals
    |> Enum.map(fn g -> g.duration end)
    |> Enum.max()

  defp filter_nights_by_goal(nights, goal, from_date), do: nights
    |> Enum.filter(fn {d, _} -> Date.compare(d, Date.add(from_date, -goal.duration)) == :gt end)

  defp get_yesterday, do: Date.add(Date.utc_today(), -1)

end
