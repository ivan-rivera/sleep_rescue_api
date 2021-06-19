defmodule SleepRescue.Users.Thought do

  @moduledoc """
  Schema for negative thoughts and their counter-thoughts
  """

  use Ecto.Schema
  alias SleepRescue.Repo
  alias SleepRescue.Users.User
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @derive {Jason.Encoder, only: [:id, :negative_thought, :counter_thought]}
  schema "thoughts" do
    belongs_to :user, User
    field :negative_thought, :string, null: false
    field :counter_thought, :string, null: false
    timestamps()
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = thought, attrs \\ {}) do
    thought
    |> cast(attrs, [:negative_thought, :counter_thought])
    |> validate_required([:negative_thought, :counter_thought])
    |> validate_length(:negative_thought, min: 10, max: 150)
    |> validate_length(:counter_thought, min: 10, max: 150)
  end

  @doc """
  Create a new thought
  """
  @spec create_thought(%User{}, map()) :: {:ok, map()} | {:error, map()}
  def create_thought(%User{} = user, %{"negative_thought" => _, "counter_thought" => _} = thought) do
    user
    |> Ecto.build_assoc(:thoughts)
    |> changeset(thought)
    |> Repo.insert()
  end

  @doc """
  Delete a thought by ID
  """
  @spec delete_thought(%User{}, integer()) :: {:ok, map()} | {:error, map()}
  def delete_thought(%User{} = user, id) do
    case Repo.get_by(__MODULE__, id: id, user_id: user.id) do
      nil -> {:error, "failed to fetch thought"}
      thought -> Repo.delete(thought)
    end
  end

  @doc """
  List users thoughts
  """
  @spec list_thoughts(%User{}) :: map()
  def list_thoughts(%User{} = user) do
    with result <- from(t in __MODULE__, where: t.user_id == ^user.id) |> Repo.all() do
      {:ok, result}
    end
  end

end
