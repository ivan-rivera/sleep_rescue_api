# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SleepRescue.Repo.insert!(%SleepRescue.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SleepRescueWeb
alias SleepRescue.Users.User

IO.puts "creating users..."
[
  %{email: "test1@mail.com", password: "password123", password_confirmation: "password123"},
  %{email: "test2@mail.com", password: "password456", password_confirmation: "password456"},
  %{email: "test3@mail.com", password: "password789", password_confirmation: "password789"},
] |> Enum.map(fn changeset -> User.create(changeset) end)
