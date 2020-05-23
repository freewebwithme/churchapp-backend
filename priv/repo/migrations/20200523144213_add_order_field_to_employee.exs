defmodule Church.Repo.Migrations.AddOrderFieldToEmployee do
  use Ecto.Migration

  def change do
    alter table("employees") do
      add :order, :integer
    end
  end
end
