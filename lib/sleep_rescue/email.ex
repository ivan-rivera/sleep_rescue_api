defmodule SleepRescue.Email do
  use Bamboo.Template, view: SleepRescue.Mail.AccountView
  import Bamboo.Email

  def contact_email(message, user \\ nil) do
    from_user = user || "Anonymous"
    new_email(
      from: "no-reply@sleeprescue.org",
      to: "admin@sleeprescue.org",
      subject: "New email from user: #{from_user}",
      text_body: message
    )
  end

  def confirmation_email(email, token) do
    base_email("Please confirm your email")
    |> to(email)
    |> assign(:url, "#{get_url_root()}/confirming?token=#{token}")
    |> render("confirmation_email.html")
  end

  def reset_email(email, token) do
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
