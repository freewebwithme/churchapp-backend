defmodule Church.Accounts.Church do
  use Ecto.Schema
  import Ecto.Changeset
  alias Church.Videos.LatestVideos

  schema "churches" do
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string
    field :slide_image_one, :string
    field :slide_image_two, :string
    field :slide_image_three, :string

    belongs_to :user, Church.Accounts.User
    has_many :latest_videos, LatestVideos
    timestamps()
  end

  @doc false
  def changeset(church, attrs) do
    church
    |> cast(attrs, [
      :name,
      :intro,
      :uuid,
      :channel_id,
      :slide_image_one,
      :slide_image_two,
      :slide_image_three
    ])
    |> validate_required([:name, :intro, :uuid, :channel_id])
    |> unique_constraint(:channel_id)
  end
end
