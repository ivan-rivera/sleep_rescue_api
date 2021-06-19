defmodule SleepRescue.Users.ThoughtTest do

  use SleepRescue.DataCase
  alias SleepRescue.Repo
  alias SleepRescue.Users.{Thought, User}
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
    test "valid thought" do
      assert %{valid?: true} = Thought.changeset(%Thought{}, Defaults.get_valid_thought)
    end
    test "thought with too few characters" do
      assert %{valid?: false} = Thought.changeset(%Thought{}, Defaults.get_short_thought)
    end
    test "thought with too many characters" do
      assert %{valid?: false} = Thought.changeset(%Thought{}, Defaults.get_long_thought)
    end
  end

  describe "create_thought/2" do
    test "create a valid thoughts", %{user: user} do
      assert {:ok, %Thought{}} = Thought.create_thought(user, Defaults.get_valid_thought)
    end
  end

  describe "delete_thought/2" do
    test "delete a valid thought", %{user: user} do
      {:ok, %{id: id}} = Thought.create_thought(user, Defaults.get_valid_thought)
      assert {:ok, _} = Thought.delete_thought(user, id)
    end
  end

  describe "list_thoughts/1" do
    test "user with no thoughts", %{user: user} do
      assert [] = Thought.list_thoughts(user)
    end
    test "users with thoughts", %{user: user} do
      thought_pair = %{
        "negative_thought" => "this is a negative thought",
        "counter_thought" => "this is a counter-thought"
      }
      Thought.create_thought(user, thought_pair)
      assert {:ok, [%Thought{}]} = Thought.list_thoughts(user)
    end
  end

end
