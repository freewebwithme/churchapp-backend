defmodule Church.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION citext", "DROP EXTENSION citext")

    create table("users") do
      add :name, :string
      add :email, :string
      add :password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
