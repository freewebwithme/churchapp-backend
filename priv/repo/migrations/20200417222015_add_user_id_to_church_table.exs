defmodule Church.Repo.Migrations.AddUserIdToChurchTable do
  use Ecto.Migration

  def change do
    alter table("churches") do
      add :user_id, references("users")
    end
  end
end
