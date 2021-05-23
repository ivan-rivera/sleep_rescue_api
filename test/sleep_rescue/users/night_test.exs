defmodule SleepRescue.Users.NightTest do

  use SleepRescue.DataCase
  alias SleepRescue.Repo
  alias SleepRescue.Users.{Night, User}

  @now DateTime.utc_now |> DateTime.truncate(:second)

  setup do

    user = %User{}
    |> User.changeset(%{
      email: "user@mail.com",
      password: "secret123",
      password_confirmation: "secret123"
    })
    |> Ecto.Changeset.change(%{email_confirmed_at: @now})
    |> Repo.insert!()

    raw_inputs = [
      %{ # (1) okay
        "slept" => true,
        "date" => ~D[2021-06-01],
        "sleep_attempt_timestamp" => 1622593800,
        "final_awakening_timestamp" => 1622619000,
        "up_timestamp" => 1622619900,
        "falling_asleep_duration" => 15,
        "night_awakenings_duration" => 60,
        "rating" => 6
      },
      %{ # (2) sleep attempt date too far in the future
        "slept" => true,
        "date" => ~D[2021-06-02],
        "sleep_attempt_timestamp" => 1622932200,
        "final_awakening_timestamp" => 1622964600,
        "up_timestamp" => 1622965500,
        "falling_asleep_duration" => 15,
        "night_awakenings_duration" => 60,
        "rating" => 6
      },
      %{ # (3) durations are too long
        "slept" => true,
        "date" => ~D[2021-06-03],
        "sleep_attempt_timestamp" => 1622766600,
        "final_awakening_timestamp" => 1622788200,
        "up_timestamp" => 1622789100,
        "falling_asleep_duration" => 5000,
        "night_awakenings_duration" => 6000,
        "rating" => 6
      },
      %{ # (4) up date before final awakening
        "slept" => true,
        "date" => ~D[2021-06-04],
        "sleep_attempt_timestamp" => 1622853900,
        "final_awakening_timestamp" => 1622875500,
        "up_timestamp" => 1622868900,
        "falling_asleep_duration" => 10,
        "night_awakenings_duration" => 10,
        "rating" => 6
      },
      %{ # (5) did not sleep but should work
        "slept" => false,
        "date" => ~D[2021-06-05]
      },
    ]

    nights = [
      %Night{
        id: 1,
        slept: true,
        date: ~D[2021-05-01],
        sleep_attempt_datetime: ~N[2021-05-01 22:00:00],
        final_awakening_datetime: ~N[2021-05-02 06:00:00],
        up_datetime: ~N[2021-05-02 07:00:00],
        falling_asleep_duration: 60,
        night_awakenings_duration: 30,
        rating: 6
      },
      %Night{
        id: 2,
        slept: true,
        date: ~D[2021-05-02],
        sleep_attempt_datetime: ~N[2021-05-03 00:30:00],
        final_awakening_datetime: ~N[2021-05-03 07:45:00],
        up_datetime: ~N[2021-05-03 08:00:00],
        falling_asleep_duration: 15,
        night_awakenings_duration: 10,
        rating: 7
      },
      %Night{
        id: 3,
        slept: false,
        date: ~D[2021-05-03]
      },
    ]
    %{user: user, nights: nights, raw_inputs: raw_inputs}
  end

  test "changeset/2", %{user: user, raw_inputs: raw_inputs} do
    [c1, c2, c3, c4, c5] = raw_inputs
    assert {:ok, _} = insert_change(user, c1)
    assert {:error, %{errors: [sleep_attempt_datetime: {"sleep attempt date is invalid", _}]}} = insert_change(user, c2)
    assert {:error, %{errors: [nights_table: {"must have slept zero or more minutes", _}]}} = insert_change(user, c3)
    assert {:error, %{errors: [up_datetime: {"up date is invalid", _}]}} = insert_change(user, c4)
    assert {:ok, _} = insert_change(user, c5)
  end

  test "summarise_night/1", %{nights: nights} do
    [n1, n2, n3] = nights |> Enum.map(&Night.summarise_night/1)
    assert n1 == %{
      "efficiency" => 0.7222222222222222,
      "mins_to_fall_asleep" => 60,
      "mins_awake_at_night" => 30,
      "mins_awake" => 150,
      "mins_slept" => 390,
      "rating" => 6,
      "slept" => true
    }
    assert n2 == %{
      "efficiency" => 0.9111111111111111,
      "mins_to_fall_asleep" => 15,
      "mins_awake_at_night" => 10,
      "mins_awake" => 40,
      "mins_slept" => 410,
      "rating" => 7,
      "slept" => true
    }
    assert n3 == %{
      "efficiency" => 0,
      "mins_to_fall_asleep" => 0,
      "mins_awake_at_night" => 0,
      "mins_awake" => 0,
      "mins_slept" => 0,
      "rating" => 0,
      "slept" => false
    }
  end

  defp insert_change(user, change) do
    user |> Ecto.build_assoc(:nights) |> Night.changeset(change) |> Repo.insert()
  end

end
