defmodule SleepRescue.Test.Support.Defaults do
  @moduledoc """
  Defaults and helper functions for tests
  """

  to_timestamp = fn (datetime) ->
    datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end


  @today ~D[2021-06-07]
  @goal_valid %{"metric" => "Sleep duration", "duration" => 3, "threshold" => 6}
  @goal_unknown_metric %{"metric" => "XYZ", "duration" => 30, "threshold" => 6}
  @goal_high_duration %{"metric" => "Sleep duration", "duration" => 1000, "threshold" => 6.5}
  @nights [
    %{ # 7 hours slept
      "slept" => true,
      "date" => ~D[2021-06-01],
      "sleep_attempt_timestamp" => to_timestamp.(~N[2021-06-01 22:30:00]),
      "final_awakening_timestamp" => to_timestamp.(~N[2021-06-02 06:45:00]),
      "up_timestamp" => to_timestamp.(~N[2021-06-02 07:00:00]),
      "falling_asleep_duration" => 15,
      "night_awakenings_duration" => 60,
      "rating" => 6
    },
    %{ # 4.15 hours slept
      "slept" => true,
      "date" => ~D[2021-06-04],
      "sleep_attempt_timestamp" => to_timestamp.(~N[2021-06-04 00:45:00]),
      "final_awakening_timestamp" => to_timestamp.(~N[2021-06-04 05:45:00]),
      "up_timestamp" => to_timestamp.(~N[2021-06-04 06:00:00]),
      "falling_asleep_duration" => 30,
      "night_awakenings_duration" => 15,
      "rating" => 5
    },
    %{ # 6 hours slept
      "slept" => true,
      "date" => ~D[2021-06-05],
      "sleep_attempt_timestamp" => to_timestamp.(~N[2021-06-05 23:30:00]),
      "final_awakening_timestamp" => to_timestamp.(~N[2021-06-06 08:45:00]),
      "up_timestamp" => to_timestamp.(~N[2021-06-06 09:00:00]),
      "falling_asleep_duration" => 15,
      "night_awakenings_duration" => 180,
      "rating" => 3
    },
    %{ # 0 hours slept
      "slept" => false,
      "date" => ~D[2021-06-06]
    },
  ]

  def get_today, do: @today
  def get_valid_goal, do: @goal_valid
  def get_unknown_metric_goal, do: @goal_unknown_metric
  def get_high_duration_goal, do: @goal_high_duration
  def get_nights, do: @nights

end
