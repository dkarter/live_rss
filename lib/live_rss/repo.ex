defmodule LiveRSS.Repo do
  use Ecto.Repo,
    otp_app: :live_rss,
    adapter: Ecto.Adapters.SQLite3
end
