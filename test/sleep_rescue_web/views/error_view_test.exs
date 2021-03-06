defmodule SleepRescueWeb.ErrorViewTest do
  use SleepRescueWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(SleepRescueWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Oops, endpoint not found!"}}
  end

  test "renders 500.json" do
    assert render(SleepRescueWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal server error: you just broke something!"}}
  end
end
