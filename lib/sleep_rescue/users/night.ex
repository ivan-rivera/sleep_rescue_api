defmodule SleepRescue.Users.Night do
  use Ecto.Schema
  alias SleepRescue.Repo
  alias SleepRescue.Users.User
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @today Date.utc_today
  @integer_columns [
    "sleep_attempt_timestamp",
    "final_awakening_timestamp",
    "up_timestamp",
    "falling_asleep_duration",
    "night_awakenings_duration",
    "rating"
  ]

  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}
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

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
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
    |> validate_number(:falling_asleep_duration, greater_than_or_equal_to: 0)
    |> validate_number(:night_awakenings_duration, greater_than_or_equal_to: 0)
    |> validate_inclusion(:rating, 1..10)
    |> check_constraint(:sleep_attempt_datetime, name: :sleep_attempt_date, message: "sleep attempt date is invalid")
    |> check_constraint(:final_awakening_datetime, name: :final_awakening_datetime, message: "awakening date is invalid")
    |> check_constraint(:up_datetime, name: :up_datetime, message: "up date is invalid")
    |> check_constraint(:nights_table, name: :slept_zero_or_more_minutes, message: "must have slept zero or more minutes")
  end

  @doc """
  Create or update a night given a particular user and a date. If a user date pair already
  exists in the database, then the record will be updated otherwise a new one will be inserted
  """
  @spec create_or_update(User.t(), Date.t(), map()) :: Ecto.Changeset.t()
  def create_or_update(%User{} = user, date, attrs) do
    dated_attrs = Map.put(attrs, "date", date)
    case Repo.get_by(__MODULE__, [user_id: user.id, date: date]) do
      nil ->
        user
        |> Ecto.build_assoc(:nights)
        |> changeset(dated_attrs)
        |> Repo.insert()
      night ->
        night
        |> changeset(dated_attrs)
        |> Repo.update()
    end
  end

  @doc """
  Average attributes of a list of nights
  """
  def aggregate_nights(nights) do
    nights
    |> Enum.map(fn {_, n} -> Map.to_list(n) end)
    |> List.flatten()
    |> Enum.filter(fn {k, _} -> k != "slept" end)
    |> Enum.map(fn {k, v} -> %{key: k, value: v} end)
    |> Enum.group_by(fn %{key: k, value: _v} -> k end, fn %{key: _k, value: v} -> v end)
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v) / length(v)} end)
    |> Enum.into(%{})
  end

  @doc """
  Get summary statistics per night. It is an interface that allows us to get useful info
  out of the nightly records. These results are expected to be passed to the frontend
  """
  @spec summarise_night(%__MODULE__{}) :: map()
  def summarise_night(%__MODULE__{} = night) when night.slept do
    {
      night.date,
      %{"mins_to_fall_asleep" => night.falling_asleep_duration,
        "mins_awake_at_night" => night.night_awakenings_duration,
        "mins_awake" => get_minutes_awake(night),
        "mins_slept" => get_minutes_slept(night),
        "efficiency" => get_efficiency(night),
        "rating" => night.rating,
        "slept" => true}
    }
  end

  def summarise_night(%__MODULE__{} = night) when not night.slept do
    {
      night.date,
      %{"mins_to_fall_asleep" => 0,
        "mins_awake_at_night" => 0,
        "mins_awake" => 0,
        "mins_slept" => 0,
        "efficiency" => 0,
        "rating" => 0,
        "slept" => false}
    }
  end

  @doc """
  Given a user, from date (usually today) and how far back do we want to look, retrieve
  all nightly records as a list of nights
  """
  @spec list_nights(%User{}, integer(), DateTime.t()) :: list(%__MODULE__{})
  def list_nights(%User{} = user, n_days_back \\ 180, from_date \\ @today) do
    last_date = from_date
                |> Date.add(-n_days_back)
                |> Date.to_string()
    from(n in __MODULE__, where: n.user_id == ^user.id and n.date > ^last_date)
    |> Repo.all()
  end

  @spec convert(map()) :: map()
  defp convert(attrs) do
    attrs
    |> slept_as_boolean
    |> cast_integers
    |> timestamp_to_datetime
  end

  @spec slept_as_boolean(map()) :: map()
  defp slept_as_boolean(attrs) do
    if Map.has_key?(attrs, "slept") do
      %{attrs | "slept" => attrs["slept"] || attrs["slept"] == "true"}
    else
      attrs
    end
  end

  @spec timestamp_to_datetime(map()) :: map()
  defp timestamp_to_datetime(attrs) do
    attrs
    |> Enum.filter(fn {k, _} -> String.contains?(k, "timestamp") end)
    |> Enum.map(fn {k, v} -> {String.replace(k, "timestamp", "datetime"), to_datetime(v)} end)
    |> Enum.into(%{})
    |> Map.merge(attrs)
  end

  @spec cast_integers(map()) :: map()
  defp cast_integers(attrs) do
    int_attrs = attrs
    |> Enum.filter(fn {k, _} -> k in @integer_columns end)
    |> Enum.map(fn {k, v} ->
      try do
        {k, String.to_integer(v)}
      rescue
        _ -> {k, v}
      end
    end)
    |> Enum.into(%{})
    attrs
    |> Map.merge(int_attrs)
  end

  @spec to_datetime(integer()) :: NaiveDateTime.t()
  defp to_datetime(timestamp) do
    timestamp
      |> DateTime.from_unix!
      |> DateTime.to_naive
  end

  @spec get_minutes_slept(%__MODULE__{}) :: integer()
  defp get_minutes_slept(%__MODULE__{} = night) do
    seconds_awake = (night.falling_asleep_duration + night.night_awakenings_duration) * 60
    NaiveDateTime.diff(
      night.final_awakening_datetime,
      night.sleep_attempt_datetime
      |> NaiveDateTime.add(seconds_awake, :second),
      :second
    ) / 60 |> trunc()
  end

  @spec get_minutes_awake(%__MODULE__{}) :: integer()
  defp get_minutes_awake(%__MODULE__{} = night) do
    morning_awake_mins = NaiveDateTime.diff(
      night.up_datetime, night.final_awakening_datetime, :second
    ) / 60 |> trunc()
    morning_awake_mins +
      night.night_awakenings_duration +
      night.falling_asleep_duration
  end

  @spec get_efficiency(%__MODULE__{}) :: float()
  defp get_efficiency(%__MODULE__{} = night) do
    slept = get_minutes_slept(night)
    awake = get_minutes_awake(night)
    slept / (slept + awake)
  end

end
