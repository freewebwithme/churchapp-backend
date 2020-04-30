defmodule Church.Repo.Migrations.CreateChurch do
  use Ecto.Migration

  def change do
    create table("churches") do
      add :name, :string
      add :uuid, :string
      add :channel_id, :string

      timestamps()
    end
  end
end
