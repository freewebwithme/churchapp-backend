defmodule Church.Repo.Migrations.ChangeAddressLineFieldName do
  use Ecto.Migration

  def change do
    alter table("churches") do
      remove :address_line_1
      remove :address_line_2
      add(:address_line_one, :string)
      add(:address_line_two, :string)
    end
  end
end
