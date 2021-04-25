defmodule SleepRescue.Mail.Email do
  import Bamboo.Email

  def welcome_email(email, body) do
    base_email("Welcome to SleepRescue!")
    |> to(email)
    |> html_body("<h2>Welcome!</h2>")
    |> text_body(body)
  end

  defp base_email(subject) do
    new_email()
    |> from("noreply@sleeprescue.org")
    |> subject(subject)
  end
end
