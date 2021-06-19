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
alias SleepRescue.Users.{User, Night, Thought}

now = DateTime.utc_now |> DateTime.truncate(:second)

to_timestamp = fn (datetime) ->
  datetime
  |> DateTime.from_naive!("Etc/UTC")
  |> DateTime.to_unix()
end

gen_night_data = fn (
      slept,
      sleep_attempt_datetime,
      final_awakening_datetime,
      up_datetime,
      falling_asleep_duration,
      night_awakenings_duration,
      rating
    ) ->
  %{
    "slept" => slept,
    "sleep_attempt_timestamp" => to_timestamp.(sleep_attempt_datetime),
    "final_awakening_timestamp" => to_timestamp.(final_awakening_datetime),
    "up_timestamp" => to_timestamp.(up_datetime),
    "falling_asleep_duration" => falling_asleep_duration,
    "night_awakenings_duration" => night_awakenings_duration,
    "rating" => rating
  }
end

nights = %{
  "test2@mail.com" => [
    {~D[2021-06-11], gen_night_data.(true, ~N[2021-06-11 22:00:00], ~N[2021-06-12 07:00:00], ~N[2021-06-12 07:15:00], 15, 60, 6)},
    {~D[2021-06-10], gen_night_data.(true, ~N[2021-06-10 23:00:00], ~N[2021-06-11 06:00:00], ~N[2021-06-11 07:30:00], 30, 30, 7)},
    {~D[2021-06-09], gen_night_data.(true, ~N[2021-06-10 00:30:00], ~N[2021-06-10 06:00:00], ~N[2021-06-10 08:15:00], 5, 10, 8)}
  ],
  "test3@mail.com" => [
    {~D[2021-06-01], gen_night_data.(true, ~N[2021-06-01 23:30:00], ~N[2021-06-02 06:30:00], ~N[2021-06-02 07:30:00], 120, 60, 4)},
    {~D[2021-06-02], gen_night_data.(true, ~N[2021-06-03 00:15:00], ~N[2021-06-03 07:00:00], ~N[2021-06-03 07:30:00], 30, 180, 3)},
    {~D[2021-06-03], gen_night_data.(true, ~N[2021-06-03 23:30:00], ~N[2021-06-04 06:00:00], ~N[2021-06-11 06:30:00], 60, 60, 5)}
  ]
}

thoughts = %{
  "test1@mail.com" => [%{"negative_thought" => "This is just a negative thought", "counter_thought" => "and this is a counter thought"}],
  "test3@mail.com" => [%{"negative_thought" => "This is just another negative thought", "counter_thought" => "and this is a simple counter thought"}]
}

create_user_nights = fn (email) ->
  target_user = Repo.get_by(User, email: email)
  target_nights = Map.get(nights, email)
  unless is_nil(target_nights) do
    Enum.map(target_nights, fn {dt, args} -> Night.create_or_update(target_user, dt, args) end)
  end
end

create_user_thought = fn (email) ->
  target_user = Repo.get_by(User, email: email)
  target_thoughts = Map.get(thoughts, email)
  unless is_nil(target_thoughts) do
    Enum.map(target_thoughts, fn(thought) -> Thought.create_thought(target_user, thought) end)
  end
end

users = [
  %{email: "test1@mail.com", password: "password123", password_confirmation: "password123"},
  %{email: "test2@mail.com", password: "password456", password_confirmation: "password456"},
  %{email: "test3@mail.com", password: "password789", password_confirmation: "password789"},
]

IO.puts "creating user data..."
users |> Enum.map(fn changeset ->
  User.create(changeset)
  Repo.get_by(User, email: changeset.email)
  |> Ecto.Changeset.change(%{email_confirmed_at: now})
  |> Repo.update!
  create_user_nights.(changeset.email)
  create_user_thought.(changeset.email)
end)
