defmodule Church.Accounts.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :name, :string
    field :position, :string
    field :profile_image, :string

    belongs_to :church, Church.Accounts.Church
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:name, :position, :profile_image])
    |> validate_required([:name, :position])
  end
end
