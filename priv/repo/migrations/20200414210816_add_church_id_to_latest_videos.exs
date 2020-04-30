defmodule Church.Repo.Migrations.AddChurchIdToLatestVideos do
  use Ecto.Migration

  def change do
    alter table("latest_videos") do
      add :church_id, references("churches")
    end
  end
end
