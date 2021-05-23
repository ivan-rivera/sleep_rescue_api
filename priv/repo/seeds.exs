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
alias SleepRescue.Repo
alias SleepRescue.Users.{User, Night}

gen_night_data = fn (
      slept,
      sleep_attempt_timestamp,
      final_awakening_timestamp,
      up_timestamp,
      falling_asleep_duration,
      night_awakenings_duration,
      rating
    ) ->
  %{
    "slept" => slept,
    "sleep_attempt_timestamp" => sleep_attempt_timestamp,
    "final_awakening_timestamp" => final_awakening_timestamp,
    "up_timestamp" => up_timestamp,
    "falling_asleep_duration" => falling_asleep_duration,
    "night_awakenings_duration" => night_awakenings_duration,
    "rating" => rating
  }
end

nights = %{
  "test2@mail.com" => [
    {~D[2021-05-01], gen_night_data.(true, 1619906400, 1619938800, 1619940600, 15, 60, 6)},
    {~D[2021-05-02], gen_night_data.(true, 1619998200, 1620023400, 1620024300, 30, 30, 7)},
    {~D[2021-05-03], gen_night_data.(true, 1620081900, 1620107100, 1620111600, 5, 10, 8)}
  ],
  "test3@mail.com" => [
    {~D[2021-05-01], gen_night_data.(true, 1619905500, 1619941500, 1619943300, 120, 60, 4)},
    {~D[2021-05-02], gen_night_data.(true, 1620000900, 1620026100, 1620027000, 30, 180, 3)},
    {~D[2021-05-03], gen_night_data.(true, 1620091800, 1620117900, 1620118800, 60, 60, 5)}
  ]
}

create_user_nights = fn (email) ->
  target_user = Repo.get_by(User, email: email)
  target_nights = Map.get(nights, email)
  unless is_nil(target_nights) do
    Enum.map(target_nights, fn {dt, args} -> Night.create_or_update(target_user, dt, args) end)
  end
end

users = [
  %{email: "test1@mail.com", password: "password123", password_confirmation: "password123"},
  %{email: "test2@mail.com", password: "password456", password_confirmation: "password456"},
  %{email: "test3@mail.com", password: "password789", password_confirmation: "password789"},
]

IO.puts "creating user data..."
users |> Enum.map(fn changeset -> User.create(changeset) end)
users |> Enum.map(fn %{email: email} -> create_user_nights.(email) end)
