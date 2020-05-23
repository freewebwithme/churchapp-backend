defmodule ChurchWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation
  alias Church.{Accounts, Videos}

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, on_load: 2]

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :church, :church
  end

  object :church do
    field :id, :id
    field :name, :string
    field :intro, :string
    field :uuid, :string
    field :channel_id, :string

    field :address_line_one, :string
    field :address_line_two, :string
    field :phone_number, :string
    field :email, :string
    field :schedules, list_of(:schedule)

    field :user, :user

    field :latest_videos, list_of(:latest_videos) do
      resolve(fn parent, _args, %{context: %{loader: loader}} ->
        loader
        |> Dataloader.load(Accounts, :latest_videos, parent)
        |> on_load(fn loader ->
          latest_videos = Dataloader.get(loader, Accounts, :latest_videos, parent)

          case Enum.empty?(latest_videos) do
            true ->
              {:ok, Videos.get_most_recent_videos(parent)}

            _ ->
              {:ok, latest_videos}
          end
        end)
      end)
    end

    field :employees, list_of(:employee), resolve: dataloader(Accounts)
  end

  object :schedule do
    field :service_name, :string
    field :service_time, :string
    field :order, :integer
  end

  object :employee do
    field :id, :id
    field :name, :string
    field :position, :string
    field :profile_image, :string
    field :order, :integer
  end

  object :latest_videos do
    field :id, :id
    field :title, :string
    field :description, :string
    field :video_id, :string
    field :thumbnail_url, :string
    field :published_at, :string
    field :channel_title, :string
  end
end
