defmodule SleepRescue.Test.Support.Setup do
  @moduledoc """
  Set up utilities for tests
  """


  @doc """
  Executed after the setup of each test. Note that timer.sleep() is
  used to avoid DB conflicts during testing, more info here:
  https://elixirforum.com/t/mix-test-fails-while-individual-test-files-succeed/41046/13
  """
  def init() do
    :timer.sleep(50)
  end

end
