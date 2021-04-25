defmodule SleepRescue.Users.User do
  alias SleepRescue.Repo
  use Ecto.Schema
  use Pow.Ecto.Schema

  #TODO: reset password
  #TODO: email confirmation
  #TODO: write docs
  # todo: move create and delete into accounts
  @derive {Jason.Encoder, only: [:id, :email, :inserted_at]}
  schema "users" do
    pow_user_fields()

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> pow_changeset(attrs)
  end

  @doc """
  User creation mechanism. Note that it is not used by the registration
  controller, it uses the Pow plug instead. This method is used for dummy
  data creation or whenever you need to create a user outside the API call
  """
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

  def delete(user_id) do
    case user = Repo.get_by(__MODULE__, id: user_id) do
      nil -> {:error, "failed to fetch user"}
      _ -> Repo.delete(user)
    end
  end

end
