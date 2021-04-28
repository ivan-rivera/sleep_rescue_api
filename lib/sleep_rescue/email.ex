defmodule SleepRescue.Email do
  use Bamboo.Template, view: SleepRescue.Mail.AccountView

  def reset_email(email, token) do
    IO.puts("params received: email #{email}, token: #{token}}")
    base_email("Your password reset token is here")
    |> to(email)
    |> assign(:url, "#{get_url_root()}/reset?token=#{token}")
    |> render("reset_email.html")
  end

  defp base_email(subject) do
    new_email()
    |> from("no-reply@sleeprescue.org")
    |> subject(subject)
    |> put_html_layout({SleepRescue.Mail.LayoutView, "email.html"})
  end

  defp get_url_root do
    if Mix.env == :prod, do: "https://www.sleeprescue.org", else: "http://localhost:8000"
  end

end
