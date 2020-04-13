defmodule Church.Repo.Migrations.AddChannelTitleField do
  use Ecto.Migration

  def change do
    alter table("latest_videos") do
      modify :description, :text
      add :channel_title, :string
    end
  end
end
