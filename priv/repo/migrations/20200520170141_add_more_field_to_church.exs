defmodule Church.Repo.Migrations.AddMoreFieldToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :address_line_1, :string
      add :address_line_2, :string
      add :phone_number, :string
      add :email, :string

      add :schedules, :map
    end
  end
end
