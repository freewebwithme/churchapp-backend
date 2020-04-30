defmodule Church.Repo.Migrations.AddSlideImageToChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :intro, :text
      add :slide_image_one, :string
      add :slide_image_two, :string
      add :slide_image_three, :string
    end
  end
end
