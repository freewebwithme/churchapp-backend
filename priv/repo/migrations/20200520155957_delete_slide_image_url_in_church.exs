defmodule Church.Repo.Migrations.DeleteSlideImageUrlInChurch do
  use Ecto.Migration

  def change do
    alter table("churches") do
      remove :slide_image_one
      remove :slide_image_two
      remove :slide_image_three
    end
  end
end
