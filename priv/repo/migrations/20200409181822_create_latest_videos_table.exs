defmodule Church.Repo.Migrations.CreateLatestVideosTable do
  use Ecto.Migration

  def change do
    create table("latest_videos") do
      add :title, :string
      add :description, :string
      add :video_id, :string
      add :thumbnail_url, :string
      add :published_at, :string

      timestamps()
    end
  end
end
