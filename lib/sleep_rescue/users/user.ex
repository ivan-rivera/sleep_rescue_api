defmodule SleepRescue.Users.User do
  alias SleepRescue.Repo
  use Ecto.Schema
  use Pow.Ecto.Schema

  @derive {Jason.Encoder, only: [:id, :email]}
  schema "users" do
    pow_user_fields()

    timestamps()
  end

  @doc """
  User creation mechanism. Note that it is not used by the registration
  controller, it uses the Pow plug instead. This method is used for dummy
  data creation or whenever you need to create a user outside the API call
  """
  def create(attrs) do
    %__MODULE__{}
    |> pow_changeset(attrs)
    |> case do
      changeset = %{valid?: true} ->
        Repo.insert(changeset)
      %{valid?: false, errors: e} ->
        {:error, e}
       end
  end

end
