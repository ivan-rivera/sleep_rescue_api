defmodule SleepRescue.Users.User do
  alias SleepRescue.Repo
  alias SleepRescue.Users
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  @derive {Jason.Encoder, only: [:id, :email, :inserted_at, :unconfirmed_email]}
  schema "users" do
    pow_user_fields()
    has_many :nights, Users.Night
    has_many :goals, Users.Goal
    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  @doc """
  User creation mechanism. Note that it is not used by the registration
  controller, it uses the Pow plug instead. This method is used for dummy
  data creation or whenever you need to create a user outside the API call.
  Note that we are also creating a set of default goals for every new user
  """
  @spec create(map()) :: {:ok, map()} | {:error, map()}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> case do
      changeset = %{valid?: true} ->
        with {:ok, user} <- Repo.insert(changeset) do
          Users.Goal.create_default_goals(user)
        end
      %{valid?: false, errors: e} ->
        {:error, %{message: "failed to create user", errors: e}}
       end
  end

  @spec delete(integer()) :: {:ok, map()} | {:error, map()}
  def delete(user_id) do
    case user = Repo.get_by(__MODULE__, id: user_id) do
      nil -> {:error, "failed to fetch user"}
      _ -> Repo.delete(user)
    end
  end

end
