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
  @valid_thought %{
    "negative_thought" => "10 letters",
    "counter_thought" => "this string has 150 characters which makes this a \"valid\" thought. 150 characters is enough to express a complex thought and look okay on a page too"
  }
  @short_thought %{
    "negative_thought" => "end",
    "counter_thought" => "and this is a thought of valid length"
  }
  @long_thought %{
    "negative_thought" => "this thought contains more than 150 characters which is the maximum allowed limit set in the database. This thought is not meant to pass the validation test!",
    "counter_thought" => "and this thought is valid but the one above is not"
  }
  @valid_isi %{
    "falling_asleep" => 0,
    "staying_asleep" => 1,
    "early_wake_up" => 2,
    "sleep_pattern" => 3,
    "noticeable" => 4,
    "worried" => 0,
    "interference" => 1
  }
  @invalid_isi %{
    "falling_asleep" => 0,
    "staying_asleep" => 1,
    "early_wake_up" => 2,
    "sleep_pattern" => 3,
    "noticeable" => 4,
    "worried" => 5,
    "interference" => 6
  }


  def get_today, do: @today
  def get_valid_goal, do: @goal_valid
  def get_unknown_metric_goal, do: @goal_unknown_metric
  def get_high_duration_goal, do: @goal_high_duration
  def get_nights, do: @nights
  def get_valid_thought, do: @valid_thought
  def get_short_thought, do: @short_thought
  def get_long_thought, do: @long_thought
  def get_valid_isi, do: @valid_isi
  def get_invalid_isi, do: @invalid_isi

end
