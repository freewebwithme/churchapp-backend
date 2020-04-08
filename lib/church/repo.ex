defmodule Church.Repo do
  use Ecto.Repo,
    otp_app: :church,
    adapter: Ecto.Adapters.Postgres
end
