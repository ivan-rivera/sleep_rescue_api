defmodule SleepRescueWeb.Router do
  use SleepRescueWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SleepRescueWeb do
    pipe_through :api
  end
end
