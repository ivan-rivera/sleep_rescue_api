defmodule SleepRescue.Users.NightTest do

  use SleepRescue.DataCase
  alias SleepRescue.Repo
  alias SleepRescue.Users.{Night, User, Goal}
  alias SleepRescue.Test.Support.Defaults

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @user %{
    email: "user@mail.com",
    password: "secret123",
    password_confirmation: "secret123"
  }

  setup do
    user = %User{} |> User.changeset(@user)
    |> Ecto.Changeset.change(%{email_confirmed_at: @now})
    |> Repo.insert!()
    %{user: user}
  end

  describe "changeset/2" do
    test "valid goal" do
      assert %{valid?: true} = Goal.changeset(%Goal{}, Defaults.get_valid_goal)
    end
    test "invalid goal: unknown metric" do
      assert %{valid?: false} = Goal.changeset(%Goal{}, Defaults.get_unknown_metric_goal)
    end
    test "invalid goal: high duration" do
      assert %{valid?: false} = Goal.changeset(%Goal{}, Defaults.get_high_duration_goal)
    end
  end

  describe "create_goal/2" do
    test "valid goal", %{user: user} do
      assert {:ok, _} = user |> Goal.create_goal(Defaults.get_valid_goal)
    end
  end

  describe "list_goals/2" do

    test "no nights recorded", %{user: user} do
      assert {:ok, []} = Goal.list_goals(user, Defaults.get_today)
    end

    test "some nights recorded", %{user: user} do
      user |> Goal.create_goal(Defaults.get_valid_goal)
      Defaults.get_nights |> Enum.map(fn n -> insert_night(user, n) end)
      assert {:ok, [%{"actual" => 3.0, "completed" => 2} | _t]} = Goal.list_goals(user, Defaults.get_today)
    end

  end

  describe "delete/2" do
    test "delete an existing goal", %{user: user} do
      user |> Goal.create_goal(Defaults.get_valid_goal)
      assert {:ok, [existing_goal]} = Goal.list_goals(user, Defaults.get_today)
      assert {:ok, _} = Goal.delete(existing_goal["id"], user)
      assert {:ok, []} = Goal.list_goals(user, Defaults.get_today)
    end
  end

  defp insert_night(user, night) do
    user |> Ecto.build_assoc(:nights) |> Night.changeset(night) |> Repo.insert()
  end
end
