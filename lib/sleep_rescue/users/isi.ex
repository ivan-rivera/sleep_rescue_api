defmodule SleepRescue.Users.Isi do
  @moduledoc """
  Insomnia Severity Index results
  """

  use Ecto.Schema
  alias SleepRescue.Repo
  alias SleepRescue.Users.User
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @today Date.utc_today

  @derive {Jason.Encoder, except: [:user, :__meta__, :__struct__]}
  schema "isis" do
    belongs_to :user, User
    field :date, :date, null: false
    field :falling_asleep, :integer, null: false
    field :staying_asleep, :integer, null: false
    field :early_wake_up, :integer, null: false
    field :sleep_pattern, :integer, null: false
    field :noticeable, :integer, null: false
    field :worried, :integer, null: false
    field :interference, :integer, null: false
    timestamps()
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = isi, attrs \\ %{}, date \\ @today) do
    isi
    |> cast(Map.put(attrs, "date", date), [
      :date,
      :falling_asleep,
      :staying_asleep,
      :early_wake_up,
      :sleep_pattern,
      :noticeable,
      :worried,
      :interference
    ])
    |> validate_inclusion(:falling_asleep, 0..4)
    |> validate_inclusion(:staying_asleep, 0..4)
    |> validate_inclusion(:early_wake_up, 0..4)
    |> validate_inclusion(:sleep_pattern, 0..4)
    |> validate_inclusion(:noticeable, 0..4)
    |> validate_inclusion(:worried, 0..4)
    |> validate_inclusion(:interference, 0..4)
  end

  @doc """
  Create or update an ISI result
  """
  @spec create_or_update_isi(%User{}, map()) :: {:ok, map()} | {:error, map()}
  def create_or_update_isi(%User{} = user, attrs, date \\ @today) do
    case Repo.get_by(__MODULE__, [user_id: user.id, date: date]) do
      nil ->
        user
        |> Ecto.build_assoc(:isis)
        |> changeset(attrs, date)
        |> Repo.insert()
      isi ->
        isi
        |> changeset(attrs, date)
        |> Repo.update()
    end
  end

  @doc """
  Delete and ISI result
  """
  @spec delete_isi(%User{}, integer()) :: {:ok, map()} | {:error, map()}
  def delete_isi(%User{} = user, id) do
    case Repo.get_by(__MODULE__, id: id, user_id: user.id) do
      nil -> {:error, "failed to fetch isi"}
      isi -> Repo.delete(isi)
    end
  end

  @doc """
  List last N ISI results
  """
  @spec list_isis(%User{}) :: map()
  def list_isis(%User{} = user, last_n_results \\ 25) do
    with result <- from(
        i in __MODULE__,
        where: i.user_id == ^user.id,
        order_by: [desc: i.date],
        limit: ^last_n_results
      ) |> Repo.all() do
        {:ok, result}
    end
  end

end
