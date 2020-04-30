defmodule Church.Repo.Migrations.AddUniqueIndexToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      modify(:channel_id, :citext, null: false)
    end

    create unique_index(:churches, [:channel_id])
  end
end
