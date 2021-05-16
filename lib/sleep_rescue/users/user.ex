defmodule SleepRescue.Users.User do
  alias SleepRescue.Repo
  use Ecto.Schema
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation]

  @derive {Jason.Encoder, only: [:id, :email, :inserted_at, :unconfirmed_email]}
  schema "users" do
    pow_user_fields()
    has_many :nights, SleepRescue.Users.Night
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
  data creation or whenever you need to create a user outside the API call
  """
  @spec create(map()) :: {:ok, map()} | {:error, map()}
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> case do
      changeset = %{valid?: true} ->
        Repo.insert(changeset)
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
