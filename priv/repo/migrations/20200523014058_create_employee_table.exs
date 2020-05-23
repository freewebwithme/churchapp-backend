defmodule Church.Repo.Migrations.CreateEmployeeTable do
  use Ecto.Migration

  def change do
    create table("employees") do
      add :name, :string
      add :position, :string
      add :profile_image, :string

      add :church_id, references("churches")
    end
  end
end
